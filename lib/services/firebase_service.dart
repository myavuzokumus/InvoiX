import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:invoix/firebase_options.dart';
import 'package:invoix/l10n/localization_extension.dart';
import 'package:invoix/states/global_provider.dart';
import 'package:invoix/states/language_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ProcessType {
  scan,
  describe,
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final FirebaseFunctions _functions;
  late final GenerativeModel _model;
  late final GoogleSignIn _googleSignIn;
  late final FirebaseRemoteConfig remoteConfig;

  late final HttpsCallableOptions _options;

  Future<void> initialize() async {
    await Firebase.initializeApp(
      name: "invoix",
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _auth = FirebaseAuth.instanceFor(app: Firebase.app("invoix"));
    _firestore = FirebaseFirestore.instanceFor(app: Firebase.app("invoix"));
    _functions = FirebaseFunctions.instanceFor(app: Firebase.app("invoix"));
    _googleSignIn = GoogleSignIn(scopes: ["profile", "email"]);
    remoteConfig =
        FirebaseRemoteConfig.instanceFor(app: Firebase.app("invoix"));

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await remoteConfig.fetchAndActivate();
    _options = HttpsCallableOptions(limitedUseAppCheckToken: true);

    _model = FirebaseVertexAI.instanceFor(
      appCheck: FirebaseAppCheck.instanceFor(app: Firebase.app("invoix")),
    ).generativeModel(
      model: remoteConfig.getString('model_name'),
      generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: remoteConfig.getDouble('temperature')),
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

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
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
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if it's a new user
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          await createNewUserProfile(user.uid);
        }
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLogin', false);

      return user;
    } catch (e) {
      print('Detailed error in signInWithGoogle: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> createNewUserProfile(final String uid) async {
    try {
      final HttpsCallable callable =
          _functions.httpsCallable('createNewUserProfile', options: _options);
      await callable.call<void>({'uid': uid});
    } catch (e) {
      print('Error creating new user profile: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<bool> verifyPurchase(
      final String productId, final String purchaseToken) async {
    try {
      final HttpsCallable callable =
          _functions.httpsCallable('verifyPurchase', options: _options);
      final results = await callable.call({
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
    try {
      final HttpsCallable callable =
          _functions.httpsCallable('updateUserSubscription', options: _options);
      await callable.call<void>({'productId': productId});
    } catch (e) {
      print('Error updating user subscription: ${e.toString()}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSubscriptionDetails(
      final String productId) async {
    try {
      final HttpsCallable callable =
          _functions.httpsCallable('getSubscriptionDetails', options: _options);
      final result =
          await callable.call<Map<String, dynamic>>({'productId': productId});
      return result.data;
    } catch (e) {
      print('Error getting subscription details: ${e.toString()}');
      rethrow;
    }
  }

  Stream<DocumentSnapshot> getUserSubscriptionStream() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).snapshots();
    }
    throw Exception('User not logged in');
  }

  Future<Map<String, dynamic>> checkUsageRights(final String processType,
      {final int decrease = 0}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to use this function.');
    }

    try {
      print(
          'Calling checkAndUpdateUsage with processType: $processType, decrease: $decrease');
      final HttpsCallable callable =
          _functions.httpsCallable('checkAndUpdateUsage', options: _options);

      final result = await callable.call<Map<String, dynamic>>({
        'processType': processType,
        'decrease': decrease,
      });

      print('checkUsageRights result: ${result.data}');
      return result.data;
    } catch (e) {
      print('Error checking usage rights: ${e.toString()}');
      if (e is FirebaseFunctionsException) {
        print('Firebase Functions Error Code: ${e.code}');
        print('Firebase Functions Error Details: ${e.details}');
        return {
          'success': false,
          'error': e.code,
          'details': e.details,
          'remainingUsage': null
        };
      }
      return {'success': false, 'error': e.toString(), 'remainingUsage': null};
    }
  }

  Future<String> describeImageWithAI(
      {required final File imgFile, required final ProcessType type}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to use this function.');
    }

    final String processType =
        type == ProcessType.scan ? 'aiInvoiceReads' : 'aiInvoiceAnalyses';

    final String prompt = remoteConfig.getString(processType);
    final Map<String, dynamic> checkUsage =
        await checkUsageRights(processType, decrease: 1);

    if (!checkUsage["success"]) {
      throw Exception(checkUsage.toString());
    }

    final imageBytes = await imgFile.readAsBytes();

    try {
      final currentLocale = GlobalProviderContainer.get().read(localeProvider);

      final response = await (_model.generateContent([
        Content.multi([
          TextPart(prompt),
          TextPart("Target response language: ${LocalizationManager.instance.getLanguageName(currentLocale)}"),
          DataPart('image/jpeg', imageBytes)])
      ]));

      final HttpsCallable callable =
          _functions.httpsCallable('logUsage', options: _options);
      await callable.call<void>({
        'processType': processType,
        'decrease': 1,
        'image': base64Encode(imageBytes),
        'output': response.text,
      });

      return response.text!;
    } on Exception catch (e) {
      print('Error describing image: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final HttpsCallable callable = _functions.httpsCallable('deleteAccount', options: _options);
      final result = await callable.call<Map<String, dynamic>>({});

      if (result.data['success'] == true) {
        await signOut();
      } else {
        throw Exception(result.data['message'] ?? 'Unknown error occurred while deleting account');
      }
    } catch (e) {
      print('Error deleting account: ${e.toString()}');
      rethrow;
    }
  }
}
