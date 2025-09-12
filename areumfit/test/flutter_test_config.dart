import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Mock dotenv for testing environment
  dotenv.testLoad(fileInput: '''
# Mock environment variables for testing
MOCK_VAR=test_value
''');
  
  await testMain();
}