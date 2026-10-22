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
        return 'Super Admin';
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

  UserSession? _currentUser = const UserSession(
    userId: 'USR-CEY-001',
    name: 'Chaminda Silva',
    email: 'gm@ceylonheritage.lk',
    role: UserRole.hotelAdmin,
    propertyId: 'PROP-LK-001',
    propertyName: 'Ceylon Heritage Resort & Spa - Galle Fort',
  );

  bool get isAuthenticated => _currentUser != null;
  UserSession? get currentUser => _currentUser;
  UserRole get currentRole => _currentUser?.role ?? UserRole.guest;

  /// Authenticate with 4-digit PIN (default demo PIN: 4821)
  bool loginWithPin(String pin, {UserRole role = UserRole.hotelAdmin}) {
    if (pin == '4821' || pin == '0000' || pin == '1234') {
      _currentUser = UserSession(
        userId: 'USR-PIN-${pin.hashCode.abs() % 1000}',
        name: 'Staff Member (${role.displayName})',
        email: 'staff@ceylonheritage.lk',
        role: role,
        propertyId: 'PROP-LK-001',
        propertyName: 'Ceylon Heritage Resort & Spa - Galle Fort',
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
      propertyName: 'Ceylon Heritage Resort & Spa - Galle Fort',
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
