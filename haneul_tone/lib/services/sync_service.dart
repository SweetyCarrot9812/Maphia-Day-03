import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'mongodb_service.dart';

/// Simple offline outbox for sessions; retries send when online.
class SyncService {
  static final SyncService instance = SyncService._();
  SyncService._();

  static const String _boxName = 'outbox_sessions';
  Box<String>? _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.initFlutter();
      _box = await Hive.openBox<String>(_boxName);
    } else {
      _box = Hive.box<String>(_boxName);
    }
  }

  Future<void> enqueueSession({required String token, required Map<String, dynamic> session}) async {
    _box ??= Hive.isBoxOpen(_boxName) ? Hive.box<String>(_boxName) : await Hive.openBox<String>(_boxName);
    final payload = jsonEncode({'token': token, 'session': session});
    await _box!.add(payload);
  }

  Future<int> flushQueued() async {
    _box ??= Hive.isBoxOpen(_boxName) ? Hive.box<String>(_boxName) : await Hive.openBox<String>(_boxName);
    int sent = 0;
    // Iterate over a snapshot of keys to allow deletion during loop
    final keys = List<dynamic>.from(_box!.keys);
    for (final k in keys) {
      final raw = _box!.get(k);
      if (raw == null) continue;
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final token = map['token'] as String;
        final session = Map<String, dynamic>.from(map['session'] as Map);
        final res = await MongoDBService.saveSession(token: token, sessionData: session);
        if (res['success'] == true) {
          await _box!.delete(k);
          sent++;
        }
      } catch (_) {
        // keep item for later
      }
    }
    return sent;
  }
}

