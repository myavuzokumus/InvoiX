import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:invoix/firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late FirebaseFunctions _functions;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> initialize() async {
    await Firebase.initializeApp(
      name: "invoix",
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _auth = FirebaseAuth.instanceFor(app: Firebase.app("invoix"));
    _firestore = FirebaseFirestore.instanceFor(app: Firebase.app("invoix"));
    _functions = FirebaseFunctions.instanceFor(app: Firebase.app("invoix"));

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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

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
      print('Error signing in with Google: ${e.toString()}');
      return null;
    }
  }

  Future<void> _createNewUserProfile(final String uid) async {
    await _firestore.collection('users').doc(uid).set({
      'subscriptionId': 'new_user_offer',
      'aiInvoiceReads': 10,  // Example: 10 free reads
      'aiInvoiceAnalyses': 5,  // Example: 5 free analyses
      'subscriptionExpiryDate': DateTime.now().add(const Duration(days: 30)),  // 30-day trial
    });
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> verifyPurchase(final String productId, final String purchaseToken) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('verifyPurchase');
      final results = await callable({
        'productId': productId,
        'purchaseToken': purchaseToken,
      });

      if (results.data['isValid']) {
        await _updateUserSubscription(productId);
      }
    } catch (e) {
      print('Error verifying purchase: ${e.toString()}');
    }
  }

  Future<void> _updateUserSubscription(final String productId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'subscriptionId': productId,
        'subscriptionStatus': 'active',
        'subscriptionExpiryDate': DateTime.now().add(const Duration(days: 30)), // Example: 30-day subscription
      }, SetOptions(merge: true));
    }
  }

  Stream<DocumentSnapshot> getUserSubscriptionStream() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).snapshots();
    }
    throw Exception('User not logged in');
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}