import 'package:flutter_test/flutter_test.dart';
import 'package:areumfit/services/notification_service.dart';

void main() {
  group('NotificationService Tests', () {
    
    test('NotificationService should be singleton', () {
      final service1 = NotificationService();
      final service2 = NotificationService();
      
      expect(identical(service1, service2), isTrue);
    });
    
    test('Service initialization should not throw', () {
      expect(() => NotificationService(), returnsNormally);
    });
  });
}