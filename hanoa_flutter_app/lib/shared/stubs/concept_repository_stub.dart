// 웹용 ConceptRepository 스텁
class ConceptRepository {
  Future<List<dynamic>> getAll() async => [];
  Future<dynamic> getById(int id) async => null;
  Future<dynamic> create(dynamic concept) async => concept;
  Future<dynamic> update(dynamic concept) async => concept;
  Future<bool> delete(int id) async => true;
  Future<List<dynamic>> search(String query) async => [];
  Future<int> count() async => 0;
}

class Concept {
  int? id;
  String title = '';
  String body = '';
  List<String> tags = [];
  DateTime updatedAt = DateTime.now();
}