import 'package:flutter_test/flutter_test.dart';
import 'package:keepr/services/account_role_service.dart';

void main() {
  group('hasAccountRole', () {
    test('matches the exact role claim', () {
      expect(
        hasAccountRole(<String, dynamic>{'role': 'seller'}, sellerRole),
        isTrue,
      );
      expect(
        hasAccountRole(<String, dynamic>{'role': 'admin'}, sellerRole),
        isFalse,
      );
    });

    test('treats missing or malformed claims as not authorized', () {
      expect(hasAccountRole(null, sellerRole), isFalse);
      expect(hasAccountRole(<String, dynamic>{}, sellerRole), isFalse);
      expect(
        hasAccountRole(
          <String, dynamic>{'role': <String>['seller']},
          sellerRole,
        ),
        isFalse,
      );
    });
  });
}
