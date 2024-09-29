import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:invoix/firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final FirebaseFunctions _functions;
  late final GenerativeModel model;
  late final GoogleSignIn _googleSignIn;

  Future<void> initialize() async {
    await Firebase.initializeApp(
      name: "invoix",
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _auth = FirebaseAuth.instanceFor(app: Firebase.app("invoix"));
    _firestore = FirebaseFirestore.instanceFor(app: Firebase.app("invoix"));
    _functions = FirebaseFunctions.instanceFor(app: Firebase.app("invoix"));
    _googleSignIn = GoogleSignIn(scopes: ["profile", "email"]);
    model = FirebaseVertexAI.instanceFor(
      appCheck: FirebaseAppCheck.instanceFor(app: Firebase.app("invoix")),
    ).generativeModel(
      model: 'gemini-1.5-flash',
      generationConfig: GenerationConfig(responseMimeType: 'application/json', temperature: 1.15),
    );

    if (!kDebugMode) {
      await FirebaseAppCheck.instanceFor(app: Firebase.app("invoix")).activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      );
    } else {
      await FirebaseAppCheck.instanceFor(app: Firebase.app("invoix")).activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      );
    }
  }

  User? getUser() {
    return _auth.currentUser;
  }

  Future<User?> signInWithGoogle() async {
    try {
      print("Starting Google Sign-In process");

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print("Google Sign-In account retrieved: ${googleUser != null}");

      if (googleUser == null) {
        Exception("Google Sign-In was cancelled by the user");
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if it's a new user
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          await _createNewUserProfile(user.uid);
        }
      }

      return user;
    } catch (e) {
      print('Detailed error in signInWithGoogle: ${e.toString()}');
      return null;
    }
  }

  Future<void> _createNewUserProfile(final String uid) async {
    await _firestore.collection('users').doc(uid).set({
      'subscriptionId': 'new_user_offer',
      'aiInvoiceReads': 30,
      'aiInvoiceAnalyses': 10,
      'subscriptionExpiryDate': DateTime.now().add(const Duration(days: 30)),
    });
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<bool> verifyPurchase(final String productId, final String purchaseToken) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('verifyPurchase');
      final results = await callable({
        'productId': productId,
        'purchaseToken': purchaseToken,
      });

      return results.data['isValid'] as bool;
    } catch (e) {
      print('Error verifying purchase: ${e.toString()}');
      return false;
    }
  }

  Future<void> updateUserSubscription(final String productId) async {
    final user = _auth.currentUser;
    if (user != null) {
      final subscriptionDetails = _getSubscriptionDetails(productId);
      await _firestore.collection('users').doc(user.uid).set({
        'subscriptionId': productId,
        'subscriptionStatus': 'active',
        'subscriptionExpiryDate': DateTime.now().add(const Duration(days: 30)),
        'aiInvoiceReads': subscriptionDetails['aiInvoiceReads'],
        'aiInvoiceAnalyses': subscriptionDetails['aiInvoiceAnalyses'],
      }, SetOptions(merge: true));
    }
  }

  Map<String, dynamic> _getSubscriptionDetails(final String productId) {
    switch (productId) {
      case 'individual_subscription':
        return {'aiInvoiceReads': 1000, 'aiInvoiceAnalyses': 1000};
      case 'advanced_subscription':
        return {'aiInvoiceReads': 10000, 'aiInvoiceAnalyses': 10000};
      case 'corporate_subscription':
        return {'aiInvoiceReads': -1, 'aiInvoiceAnalyses': -1}; // Unlimited
      default:
        return {'aiInvoiceReads': 0, 'aiInvoiceAnalyses': 0};
    }
  }

  Stream<DocumentSnapshot> getUserSubscriptionStream() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).snapshots();
    }
    throw Exception('User not logged in');
  }

  Future<Map<String, dynamic>> checkUsageRights(final String processType, {final bool decrease = false}) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('checkAndUpdateUsage');
      final result = await callable.call<Map<String, dynamic>>({
        'processType': processType,
        'decrease': decrease,
      });
      return result.data;
    } catch (e) {
      print('Error checking usage rights: ${e.toString()}');
      return {'success': false, 'error': e.toString(), 'remainingUsage': null};
    }
  }

  // Future<bool> checkUsageRights(final String processType) async {
  //   try {
  //     final HttpsCallable callable = _functions.httpsCallable('checkAndDecrementUsage');
  //     final result = await callable.call<Map<String, dynamic>>({'processType': processType});
  //     return result.data['success'] as bool;
  //   } catch (e) {
  //     throw Exception('Error checking usage rights: ${e.toString()}');
  //   }
  // }
  //
  // Future<void> decrementUsage(final String processType) async {
  //   final user = _auth.currentUser;
  //   if (user != null) {
  //     final userDoc = await _firestore.collection('users').doc(user.uid).get();
  //
  //     int amount = userDoc.get(processType) as int;
  //     if (amount > 0) {
  //       amount--;
  //       await _firestore.collection('users').doc(user.uid).update({
  //         processType: amount,
  //       });
  //     }
  //     else {
  //       throw Exception('No more usage rights');
  //     }
  //   }
  // }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
