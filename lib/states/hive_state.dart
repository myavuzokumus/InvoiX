import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/services/hive_service.dart';

final hiveServiceProvider = Provider<HiveService>((final ref) {
  return HiveService();
});
