import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/services/firebase_service.dart';
import 'package:invoix/services/hive_service.dart';
import 'package:invoix/services/in_app_purchase_service.dart';

final firebaseServiceProvider = Provider<FirebaseService>((final ref) {
  return FirebaseService();
});

final hiveServiceProvider = Provider<HiveService>((final ref) {
  return HiveService();
});

final inAppPurchaseServiceProvider = Provider<InAppPurchaseService>((final ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return InAppPurchaseService(firebaseService);
});

final authStateProvider = StreamProvider<User?>((final ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.authStateChanges();
});