import 'package:flutter/foundation.dart';

enum UserRole {
  superAdmin,
  hotelAdmin,
  frontDesk,
  posCashier,
  kitchenKds,
  housekeeping,
  guest,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'SaaS Super Admin';
      case UserRole.hotelAdmin:
        return 'General Manager';
      case UserRole.frontDesk:
        return 'Front Desk Supervisor';
      case UserRole.posCashier:
        return 'F&B Waiter / Cashier';
      case UserRole.kitchenKds:
        return 'Executive Chef (KDS)';
      case UserRole.housekeeping:
        return 'Housekeeping Runner';
      case UserRole.guest:
        return 'In-House Guest';
    }
  }

  String get code {
    switch (this) {
      case UserRole.superAdmin:
        return 'SUPER_ADMIN';
      case UserRole.hotelAdmin:
        return 'HOTEL_ADMIN';
      case UserRole.frontDesk:
        return 'FRONT_DESK';
      case UserRole.posCashier:
        return 'POS_CASHIER';
      case UserRole.kitchenKds:
        return 'KITCHEN_KDS';
      case UserRole.housekeeping:
        return 'HOUSEKEEPING';
      case UserRole.guest:
        return 'GUEST';
    }
  }
}

class UserSession {
  final String userId;
  final String name;
  final String email;
  final UserRole role;
  final String propertyId;
  final String propertyName;

  const UserSession({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.propertyId,
    required this.propertyName,
  });
}

class AuthState extends ChangeNotifier {
  static final AuthState _instance = AuthState._internal();
  factory AuthState() => _instance;
  AuthState._internal();

  // Start as unauthenticated (null) so user always lands on the Login Screen
  UserSession? _currentUser;

  bool get isAuthenticated => _currentUser != null;
  UserSession? get currentUser => _currentUser;
  UserRole get currentRole => _currentUser?.role ?? UserRole.guest;

  /// Authenticate with Staff Email / +94 Mobile Phone and Password
  bool loginWithCredentials({
    required String identifier,
    required String password,
    UserRole role = UserRole.hotelAdmin,
  }) {
    if (identifier.trim().isNotEmpty && password.trim().isNotEmpty) {
      _currentUser = UserSession(
        userId: 'USR-${identifier.hashCode.abs() % 10000}',
        name: identifier.contains('@') ? identifier.split('@').first.toUpperCase() : 'Staff Member',
        email: identifier.contains('@') ? identifier : 'kasun@ceylonheritage.lk',
        role: role,
        propertyId: 'PROP-LK-001',
        propertyName: role == UserRole.superAdmin
            ? 'Ceylon Heritage SaaS Cloud HQ (Mumbai ap-south-1)'
            : 'Ceylon Heritage Resort & Spa - Galle Fort',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Authenticate with 4-digit PIN (default demo PINs: 1234, 5678, 4321, 8765, 4821, 0000)
  bool loginWithPin(String pin, {UserRole role = UserRole.hotelAdmin}) {
    final validPins = {'1234', '5678', '4321', '8765', '4821', '0000'};
    if (validPins.contains(pin)) {
      String name = 'Staff Member (${role.displayName})';
      if (pin == '1234') role = UserRole.hotelAdmin;
      if (pin == '5678') role = UserRole.frontDesk;
      if (pin == '4321') role = UserRole.posCashier;
      if (pin == '8765') role = UserRole.housekeeping;
      if (pin == '0000') role = UserRole.superAdmin;

      _currentUser = UserSession(
        userId: 'USR-PIN-${pin.hashCode.abs() % 1000}',
        name: name,
        email: 'staff@ceylonheritage.lk',
        role: role,
        propertyId: 'PROP-LK-001',
        propertyName: role == UserRole.superAdmin
            ? 'Ceylon Heritage SaaS Cloud HQ (Mumbai ap-south-1)'
            : 'Ceylon Heritage Resort & Spa - Galle Fort',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Switch active role instantly for demo/departmental testing
  void switchRole(UserRole newRole) {
    _currentUser = UserSession(
      userId: _currentUser?.userId ?? 'USR-DEMO-01',
      name: '${newRole.displayName} Demo',
      email: '${newRole.name}@ceylonheritage.lk',
      role: newRole,
      propertyId: 'PROP-LK-001',
      propertyName: newRole == UserRole.superAdmin
          ? 'Ceylon Heritage SaaS Cloud HQ'
          : 'Ceylon Heritage Resort & Spa - Galle Fort',
    );
    notifyListeners();
  }

  /// Log out from session and return to Login Screen
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
