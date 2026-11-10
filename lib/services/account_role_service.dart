import 'package:firebase_auth/firebase_auth.dart';

const String sellerRole = 'seller';
const String adminRole = 'admin';

bool hasAccountRole(Map<String, dynamic>? claims, String role) {
  return claims?['role'] == role;
}

class AccountRoleService {
  const AccountRoleService();

  Future<String?> roleFor(User user, {bool forceRefresh = false}) async {
    final IdTokenResult token = await user.getIdTokenResult(forceRefresh);
    final Object? role = token.claims?['role'];
    return role is String ? role : null;
  }

  Future<void> requireSeller(User user) async {
    final String? role = await roleFor(user);
    if (role != sellerRole) {
      throw StateError('Seller approval is required to manage products.');
    }
  }
}
