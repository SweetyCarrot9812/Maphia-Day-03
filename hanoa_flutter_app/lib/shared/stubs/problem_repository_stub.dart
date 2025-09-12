// 웹용 ProblemRepository 스텁
class ProblemRepository {
  Future<List<dynamic>> getAll() async => [];
  Future<dynamic> getById(int id) async => null;
  Future<dynamic> create(dynamic problem) async => problem;
  Future<dynamic> update(dynamic problem) async => problem;
  Future<bool> delete(int id) async => true;
  Future<List<dynamic>> search(String query) async => [];
  Future<int> count() async => 0;
}

class Problem {
  int? id;
  String stem = '';
  List<String> choices = [];
  int answerIndex = 0;
  List<String> tags = [];
  DateTime updatedAt = DateTime.now();
}