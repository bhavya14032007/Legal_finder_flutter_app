import 'package:flutter_test/flutter_test.dart';
import 'package:legal_helper/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('requiredField returns error for empty string or null', () {
      expect(Validators.requiredField(null, 'Name'), 'Name is required');
      expect(Validators.requiredField('', 'Name'), 'Name is required');
      expect(Validators.requiredField('   ', 'Name'), 'Name is required');
      expect(Validators.requiredField('Advocate', 'Name'), isNull);
    });

    test('email validation passes for valid emails and fails for invalid ones', () {
      expect(Validators.email(null), 'Email is required');
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email('invalid-email'), 'Please enter a valid email address');
      expect(Validators.email('user@'), 'Please enter a valid email address');
      expect(Validators.email('advocate@domain.com'), isNull);
    });

    test('password validation enforces length constraint', () {
      expect(Validators.password(null), 'Password is required');
      expect(Validators.password('12345'), 'Password must be at least 8 characters long');
      expect(Validators.password('securePassword123'), isNull);
    });

    test('confirmPassword matches original password', () {
      expect(Validators.confirmPassword(null, 'pass1234'), 'Please confirm your password');
      expect(Validators.confirmPassword('different', 'pass1234'), 'Passwords do not match');
      expect(Validators.confirmPassword('pass1234', 'pass1234'), isNull);
    });
  });
}
