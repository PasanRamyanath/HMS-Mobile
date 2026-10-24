import 'package:flutter/foundation.dart';

/// Hospitality Staff & Guest Roles matching `hms-frontend/src/lib/auth.ts` and `RoleSimulatorBar.tsx`.
enum UserRole {
  superAdmin,
  hotelAdmin,
  frontDesk,
  posCashier,
  kitchenKds,
  housekeeping,
  guest,
}

enum ShiftType {
  morning,
  evening,
  night,
  split,
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

  String get shortBadge {
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
        return 'GUEST_QR';
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

  String get department {
    switch (this) {
      case UserRole.superAdmin:
        return 'Cloud Platform HQ';
      case UserRole.hotelAdmin:
        return 'Executive Management';
      case UserRole.frontDesk:
        return 'Front Office & Reception';
      case UserRole.posCashier:
        return 'Food & Beverage Outlets';
      case UserRole.kitchenKds:
        return 'Culinary & Bar Production';
      case UserRole.housekeeping:
        return 'Housekeeping & Engineering';
      case UserRole.guest:
        return 'Room 101 Verified Stay';
    }
  }

  /// Default bottom-nav tab index when logging in as this role
  int get defaultShellTabIndex {
    switch (this) {
      case UserRole.superAdmin:
        return 0; // Touchpoints / Super Admin Launcher
      case UserRole.hotelAdmin:
        return 1; // Executive Dashboard
      case UserRole.frontDesk:
        return 2; // 14-Day Tape Chart & Front Desk
      case UserRole.posCashier:
        return 3; // Waiter POS
      case UserRole.kitchenKds:
        return 0; // Touchpoints / KDS Launcher
      case UserRole.housekeeping:
        return 0; // Touchpoints / Housekeeping Launcher
      case UserRole.guest:
        return 0; // Touchpoints / Guest QR Launcher
    }
  }
}

class StaffShiftSession {
  final String shiftId;
  final String staffId;
  final String staffName;
  final UserRole role;
  final String tenantId;
  final String department;
  final ShiftType shiftType;
  final DateTime startedAt;
  final double floatAmountLkr;
  DateTime? endedAt;

  StaffShiftSession({
    required this.shiftId,
    required this.staffId,
    required this.staffName,
    required this.role,
    required this.tenantId,
    required this.department,
    this.shiftType = ShiftType.morning,
    required this.startedAt,
    this.floatAmountLkr = 25000.0,
    this.endedAt,
  });
}

class UserSession {
  final String userId;
  final String name;
  final String email;
  final UserRole role;
  final String propertyId;
  final String propertyName;
  final StaffShiftSession? shiftSession;

  const UserSession({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.propertyId,
    required this.propertyName,
    this.shiftSession,
  });
}

/// Web-Parity Role-Based Access Control (RBAC) & Authentication Engine (`src/lib/auth.ts` & `AdminShell.tsx`).
class AuthState extends ChangeNotifier {
  static final AuthState _instance = AuthState._internal();
  factory AuthState() => _instance;
  AuthState._internal();

  UserSession? _currentUser;

  bool get isAuthenticated => _currentUser != null;
  UserSession? get currentUser => _currentUser;
  UserRole get currentRole => _currentUser?.role ?? UserRole.guest;
  StaffShiftSession? get currentShift => _currentUser?.shiftSession;

  /// Granular Permission Matrix matching `ROLE_PERMISSIONS` in `hms-frontend/src/lib/auth.ts`
  static const Map<UserRole, List<String>> rolePermissions = {
    UserRole.superAdmin: ['*'],
    UserRole.hotelAdmin: [
      'manage:hotel',
      'manage:staff',
      'view:reports',
      'manage:rates',
      'manage:rooms',
      'manage:orders',
      'manage:folios',
      'manage:inventory',
      'manage:payroll',
      'view:guests',
      'manage:settings',
      'view:kds',
      'view:housekeeping',
    ],
    UserRole.frontDesk: [
      'view:rooms',
      'manage:checkin',
      'manage:checkout',
      'view:folios',
      'manage:folios',
      'view:orders',
      'view:guests',
      'view:housekeeping',
    ],
    UserRole.posCashier: [
      'create:order',
      'view:menu',
      'settle:payment',
      'view:folios',
      'view:orders',
      'view:kds',
    ],
    UserRole.kitchenKds: [
      'view:kds',
      'update:order_status',
      'view:menu',
    ],
    UserRole.housekeeping: [
      'view:housekeeping',
      'update:room_status',
      'view:rooms',
    ],
    UserRole.guest: [
      'view:guest_qr',
      'create:guest_order',
      'view:guest_folio',
    ],
  };

  /// Route-Level RBAC Matrix matching `ADMIN_NAV_ITEMS` in `hms-frontend/src/admin/layout/AdminShell.tsx`
  static const Map<String, List<UserRole>> routeAllowedRoles = {
    '/touchpoints': UserRole.values,
    '/dashboard': [UserRole.superAdmin, UserRole.hotelAdmin, UserRole.frontDesk],
    '/tape_chart': [UserRole.superAdmin, UserRole.hotelAdmin, UserRole.frontDesk, UserRole.housekeeping],
    '/express_checkin': [UserRole.superAdmin, UserRole.hotelAdmin, UserRole.frontDesk],
    '/waiter_pos': [UserRole.superAdmin, UserRole.hotelAdmin, UserRole.frontDesk, UserRole.posCashier, UserRole.kitchenKds],
    '/dark_kds': [UserRole.superAdmin, UserRole.hotelAdmin, UserRole.frontDesk, UserRole.kitchenKds, UserRole.posCashier],
    '/bar_bot': [UserRole.superAdmin, UserRole.hotelAdmin, UserRole.frontDesk, UserRole.kitchenKds, UserRole.posCashier],
    '/housekeeping': [UserRole.superAdmin, UserRole.hotelAdmin, UserRole.frontDesk, UserRole.housekeeping],
    '/split_folios': [UserRole.superAdmin, UserRole.hotelAdmin, UserRole.frontDesk, UserRole.posCashier],
    '/guest_dining': UserRole.values,
    '/direct_booking': UserRole.values,
    '/banquets': [UserRole.superAdmin, UserRole.hotelAdmin, UserRole.frontDesk, UserRole.posCashier],
    '/ayurveda': [UserRole.superAdmin, UserRole.hotelAdmin, UserRole.frontDesk, UserRole.guest],
    '/inventory': [UserRole.superAdmin, UserRole.hotelAdmin, UserRole.kitchenKds],
    '/sltda_taxes': [UserRole.superAdmin, UserRole.hotelAdmin],
    '/payroll': [UserRole.superAdmin, UserRole.hotelAdmin],
    '/channels': [UserRole.superAdmin, UserRole.hotelAdmin, UserRole.frontDesk],
    '/excursions': [UserRole.superAdmin, UserRole.hotelAdmin, UserRole.frontDesk, UserRole.guest],
    '/my_payslip': [
      UserRole.superAdmin,
      UserRole.hotelAdmin,
      UserRole.frontDesk,
      UserRole.posCashier,
      UserRole.kitchenKds,
      UserRole.housekeeping,
    ],
    '/super_admin': [UserRole.superAdmin],
    '/settings': [UserRole.superAdmin, UserRole.hotelAdmin],
  };

  /// Checks whether a role has a specific permission token
  static bool hasRolePermission(UserRole role, String requiredPermission) {
    final perms = rolePermissions[role] ?? const [];
    if (perms.contains('*')) return true;
    return perms.contains(requiredPermission);
  }

  bool hasPermission(String requiredPermission) {
    return hasRolePermission(currentRole, requiredPermission);
  }

  /// Checks whether the current user role can access the given route
  bool canAccessRoute(String route) {
    return isRouteAllowedForRole(route, currentRole);
  }

  static bool isRouteAllowedForRole(String route, UserRole role) {
    if (role == UserRole.superAdmin) return true;
    final allowed = routeAllowedRoles[route];
    if (allowed == null) return true;
    return allowed.contains(role);
  }

  /// Returns a human-readable list of roles allowed for a route
  static String allowedRolesDescription(String route) {
    final allowed = routeAllowedRoles[route] ?? UserRole.values;
    return allowed.map((r) => r.displayName).join(', ');
  }

  /// Infer role from email/staff ID if not explicitly overridden
  UserRole _resolveRoleFromIdentifier(String identifier, UserRole fallback) {
    final lower = identifier.toLowerCase();
    if (lower.contains('admin@hms') || lower.contains('super')) return UserRole.superAdmin;
    if (lower.contains('reception') || lower.contains('front') || lower.contains('stf-014')) {
      return UserRole.frontDesk;
    }
    if (lower.contains('waiter') || lower.contains('pos') || lower.contains('cashier')) {
      return UserRole.posCashier;
    }
    if (lower.contains('chef') || lower.contains('kds') || lower.contains('kitchen')) {
      return UserRole.kitchenKds;
    }
    if (lower.contains('hk') || lower.contains('housekeeping') || lower.contains('runner')) {
      return UserRole.housekeeping;
    }
    if (lower.contains('guest') || lower.contains('room')) return UserRole.guest;
    return fallback;
  }

  /// Authenticate with Staff Email / +94 Mobile Phone and Password
  bool loginWithCredentials({
    required String identifier,
    required String password,
    UserRole role = UserRole.hotelAdmin,
  }) {
    if (identifier.trim().isNotEmpty && password.trim().isNotEmpty) {
      final resolvedRole = _resolveRoleFromIdentifier(identifier, role);
      final userId = 'USR-${identifier.hashCode.abs() % 10000}';
      final userName = identifier.contains('@')
          ? identifier.split('@').first.replaceAll('.', ' ').toUpperCase()
          : 'Staff ($identifier)';
      final shift = StaffShiftSession(
        shiftId: 'SHF-${DateTime.now().millisecondsSinceEpoch % 10000}',
        staffId: userId,
        staffName: userName,
        role: resolvedRole,
        tenantId: 'TEN-GALLE-01',
        department: resolvedRole.department,
        startedAt: DateTime.now(),
      );

      _currentUser = UserSession(
        userId: userId,
        name: userName,
        email: identifier.contains('@') ? identifier : 'staff@ceylonheritage.lk',
        role: resolvedRole,
        propertyId: 'PROP-LK-001',
        propertyName: resolvedRole == UserRole.superAdmin
            ? 'Ceylon Heritage SaaS Cloud HQ (Mumbai ap-south-1)'
            : 'Ceylon Heritage Resort & Spa - Galle Fort',
        shiftSession: shift,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Authenticate with 4 to 6-digit PIN (default demo PINs: 1234, 5678, 4321, 8765, 4821, 4829, 0000, 1111)
  bool loginWithPin(String pin, {UserRole role = UserRole.hotelAdmin}) {
    final validPins = {'1234', '5678', '4321', '8765', '4821', '4829', '0000', '1111'};
    if (validPins.contains(pin)) {
      if (pin == '1234') role = UserRole.hotelAdmin;
      if (pin == '5678' || pin == '4829') role = UserRole.frontDesk;
      if (pin == '4321') role = UserRole.posCashier;
      if (pin == '4821') role = UserRole.kitchenKds;
      if (pin == '8765') role = UserRole.housekeeping;
      if (pin == '0000') role = UserRole.superAdmin;
      if (pin == '1111') role = UserRole.guest;

      final String name = _staffNameForRole(role);
      final String userId = 'USR-PIN-${pin.hashCode.abs() % 1000}';
      final shift = StaffShiftSession(
        shiftId: 'SHF-${DateTime.now().millisecondsSinceEpoch % 10000}',
        staffId: userId,
        staffName: name,
        role: role,
        tenantId: 'TEN-GALLE-01',
        department: role.department,
        startedAt: DateTime.now(),
      );

      _currentUser = UserSession(
        userId: userId,
        name: name,
        email: '${role.name}@ceylonheritage.lk',
        role: role,
        propertyId: 'PROP-LK-001',
        propertyName: role == UserRole.superAdmin
            ? 'Ceylon Heritage SaaS Cloud HQ (Mumbai ap-south-1)'
            : 'Ceylon Heritage Resort & Spa - Galle Fort',
        shiftSession: shift,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  String _staffNameForRole(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Vishwa Jayawardena (Platform Owner)';
      case UserRole.hotelAdmin:
        return 'Pasan Ramyanath (General Manager)';
      case UserRole.frontDesk:
        return 'Nirosha Fernando (Front Office)';
      case UserRole.posCashier:
        return 'Dinesh Fernando (Captain Waiter)';
      case UserRole.kitchenKds:
        return 'Nuwan Kumara (Executive Chef)';
      case UserRole.housekeeping:
        return 'Sanduni Silva (Floor Attendant)';
      case UserRole.guest:
        return 'Dr. Michael Perera (Room 101)';
    }
  }

  /// Switch active role instantly for demo/departmental RBAC simulation (`RoleSimulatorBar.tsx`)
  void switchRole(UserRole newRole) {
    final name = _staffNameForRole(newRole);
    final userId = _currentUser?.userId ?? 'USR-DEMO-01';
    final shift = StaffShiftSession(
      shiftId: 'SHF-${DateTime.now().millisecondsSinceEpoch % 10000}',
      staffId: userId,
      staffName: name,
      role: newRole,
      tenantId: 'TEN-GALLE-01',
      department: newRole.department,
      startedAt: DateTime.now(),
    );

    _currentUser = UserSession(
      userId: userId,
      name: name,
      email: '${newRole.name}@ceylonheritage.lk',
      role: newRole,
      propertyId: 'PROP-LK-001',
      propertyName: newRole == UserRole.superAdmin
          ? 'Ceylon Heritage SaaS Cloud HQ'
          : 'Ceylon Heritage Resort & Spa - Galle Fort',
      shiftSession: shift,
    );
    notifyListeners();
  }

  /// Log out from session and return to Login Screen
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
