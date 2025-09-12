// 웹용 PendingChangeRepository 스텁
class PendingChangeRepository {
  Future<List<dynamic>> getAll() async => [];
  Future<dynamic> getById(int id) async => null;
  Future<dynamic> create(dynamic pendingChange) async => pendingChange;
  Future<dynamic> update(dynamic pendingChange) async => pendingChange;
  Future<bool> delete(int id) async => true;
  Future<List<dynamic>> search(String query) async => [];
  Future<int> count() async => 0;
  Future<List<dynamic>> getPending() async => [];
  Future<int> getPendingCount() async => 0;
  Future<List<dynamic>> getPendingForEntity(String entityType, int entityId) async => [];
  Future<bool> approve(int id) async => true;
  Future<bool> reject(int id) async => true;
  Future<int> cleanupExpired() async => 0;
  Future<List<dynamic>> getByStatus(String status) async => [];
}

class PendingChange {
  int? id;
  String entityType = '';
  int entityId = 0;
  String summary = '';
  String diffJson = '';
  String status = 'pending';
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  
  bool get isExpired => DateTime.now().difference(createdAt).inDays >= 7;
  bool get isPending => status == 'pending' && !isExpired;
}