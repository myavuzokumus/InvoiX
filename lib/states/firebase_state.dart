import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/services/firebase_service.dart';

final firebaseServiceProvider = Provider<FirebaseService>((final ref) {
  return FirebaseService();
});

final authStateProvider = StreamProvider<User?>((final ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.authStateChanges();
});