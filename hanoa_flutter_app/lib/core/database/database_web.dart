// Web용 데이터베이스 스텁 (Isar 대신 사용)
class Database {
  static dynamic isar = null;
  
  static Future<void> initialize() async {
    // Web에서는 Isar를 사용할 수 없으므로 스킵
    print('Web platform detected - skipping Isar database initialization');
  }
  
  static void close() {
    // Web에서는 아무것도 하지 않음
    print('Web platform - database close skipped');
  }
}