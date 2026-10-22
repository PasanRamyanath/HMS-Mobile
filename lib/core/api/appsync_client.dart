import 'package:flutter/foundation.dart';
import '../../models/hotel_models.dart';
import '../tax/tax_engine.dart';
import '../tenant/tenant_engine.dart';

class DashboardMetrics {
  final int totalRooms;
  final int occupiedRooms;
  final int arrivingToday;
  final int departingToday;
  final double occupancyRate;
  final double adrLkr;
  final double revparLkr;
  final int breakfastCount;
  final int lunchCount;
  final int dinnerCount;

  const DashboardMetrics({
    required this.totalRooms,
    required this.occupiedRooms,
    required this.arrivingToday,
    required this.departingToday,
    required this.occupancyRate,
    required this.adrLkr,
    required this.revparLkr,
    required this.breakfastCount,
    required this.lunchCount,
    required this.dinnerCount,
  });
}

class AppSyncClient extends ChangeNotifier {
  static final AppSyncClient _instance = AppSyncClient._internal();
  factory AppSyncClient() => _instance;
  AppSyncClient._internal() {
    _initializeData();
  }

  String _graphqlEndpoint = 'https://d2pf537unmm77a.cloudfront.net/graphql';
  bool _isOnline = true;

  String get graphqlEndpoint => _graphqlEndpoint;
  bool get isOnline => _isOnline;

  void setEndpoint(String endpoint) {
    _graphqlEndpoint = endpoint;
    notifyListeners();
  }

  void toggleOnlineStatus() {
    _isOnline = !_isOnline;
    notifyListeners();
  }

  /// Headers attached to every outgoing AppSync request enforcing multi-vendor tenant isolation
  Map<String, String> getRequestHeaders() {
    return {
      'Content-Type': 'application/json',
      'x-tenant-id': TenantEngine().activeTenantId,
    };
  }

  // In-memory persistent collections
  final List<Room> _rooms = [];
  final List<Reservation> _reservations = [];
  final List<KdsTicket> _kdsTickets = [];
  final List<Folio> _folios = [];
  final List<InventoryItem> _inventory = [];
  final List<BanquetEvent> _banquets = [];
  final List<SpaBooking> _spaBookings = [];
  final List<StaffPayroll> _payroll = [];

  List<Room> get rooms => List.unmodifiable(_rooms);
  List<Reservation> get reservations => List.unmodifiable(_reservations);
  List<KdsTicket> get kdsTickets => List.unmodifiable(_kdsTickets);
  List<Folio> get folios => List.unmodifiable(_folios);
  List<InventoryItem> get inventory => List.unmodifiable(_inventory);
  List<BanquetEvent> get banquets => List.unmodifiable(_banquets);
  List<SpaBooking> get spaBookings => List.unmodifiable(_spaBookings);
  List<StaffPayroll> get payroll => List.unmodifiable(_payroll);

  void _initializeData() {
    // 1. Rooms
    _rooms.addAll([
      Room(id: 'R101', roomNumber: '101', categoryName: 'Deluxe Ocean View', floor: 1, status: RoomCleanStatus.clean, isOccupied: true, currentGuestName: 'Dr. Michael Perera', rateLkr: 48500, rateUsd: 162.5),
      Room(id: 'R102', roomNumber: '102', categoryName: 'Deluxe Ocean View', floor: 1, status: RoomCleanStatus.dirty, isOccupied: false, rateLkr: 48500, rateUsd: 162.5),
      Room(id: 'R103', roomNumber: '103', categoryName: 'Superior Garden Pool', floor: 1, status: RoomCleanStatus.inspected, isOccupied: true, currentGuestName: 'Sophie Van Der Berg', rateLkr: 36000, rateUsd: 120.6),
      Room(id: 'R104', roomNumber: '104', categoryName: 'Superior Garden Pool', floor: 1, status: RoomCleanStatus.clean, isOccupied: false, rateLkr: 36000, rateUsd: 120.6),
      Room(id: 'R201', roomNumber: '201', categoryName: 'Colonial Suite Galle', floor: 2, status: RoomCleanStatus.clean, isOccupied: true, currentGuestName: 'Lord Alistair Campbell', rateLkr: 89000, rateUsd: 298.2),
      Room(id: 'R202', roomNumber: '202', categoryName: 'Colonial Suite Galle', floor: 2, status: RoomCleanStatus.maintenance, isOccupied: false, rateLkr: 89000, rateUsd: 298.2),
      Room(id: 'R203', roomNumber: '203', categoryName: 'Heritage Villa Pavillion', floor: 2, status: RoomCleanStatus.clean, isOccupied: true, currentGuestName: 'Hiroshi Tanaka', rateLkr: 115000, rateUsd: 385.3),
      Room(id: 'R204', roomNumber: '204', categoryName: 'Heritage Villa Pavillion', floor: 2, status: RoomCleanStatus.clean, isOccupied: false, rateLkr: 115000, rateUsd: 385.3),
    ]);

    // 2. Reservations
    final now = DateTime.now();
    _reservations.addAll([
      Reservation(
        id: 'RES-2026-001',
        guestName: 'Dr. Michael Perera',
        guestContact: '+94 77 123 4567',
        nicOrPassport: '198421503342',
        roomNumber: '101',
        checkInDate: now.subtract(const Duration(days: 2)),
        checkOutDate: now.add(const Duration(days: 3)),
        mealPlan: MealPlan.hb,
        status: 'CHECKED_IN',
        totalAmountLkr: 242500,
        paidAmountLkr: 100000,
        guestCount: 2,
      ),
      Reservation(
        id: 'RES-2026-002',
        guestName: 'Sophie Van Der Berg',
        guestContact: '+31 6 555 8899',
        nicOrPassport: 'NL8472910',
        roomNumber: '103',
        checkInDate: now.subtract(const Duration(days: 1)),
        checkOutDate: now.add(const Duration(days: 4)),
        mealPlan: MealPlan.fb,
        status: 'CHECKED_IN',
        totalAmountLkr: 180000,
        paidAmountLkr: 180000,
        guestCount: 2,
      ),
      Reservation(
        id: 'RES-2026-003',
        guestName: 'Lord Alistair Campbell',
        guestContact: '+44 7911 123456',
        nicOrPassport: 'GB9821045',
        roomNumber: '201',
        checkInDate: now.subtract(const Duration(days: 3)),
        checkOutDate: now.add(const Duration(days: 1)),
        mealPlan: MealPlan.ai,
        status: 'CHECKED_IN',
        totalAmountLkr: 356000,
        paidAmountLkr: 200000,
        guestCount: 2,
      ),
      Reservation(
        id: 'RES-2026-004',
        guestName: 'Elena Rostova',
        guestContact: '+7 903 111 2233',
        nicOrPassport: 'RU76452109',
        roomNumber: '104',
        checkInDate: now,
        checkOutDate: now.add(const Duration(days: 5)),
        mealPlan: MealPlan.bb,
        status: 'CONFIRMED',
        totalAmountLkr: 180000,
        paidAmountLkr: 50000,
        guestCount: 2,
      ),
    ]);

    // 3. KDS Orders
    _kdsTickets.addAll([
      KdsTicket(
        id: 'KOT-101',
        ticketNumber: 'KOT #101',
        tableOrRoom: 'Table 4 (Ocean Terrace)',
        orderType: 'Dine-in',
        status: KdsTicketStatus.preparing,
        createdTime: now.subtract(const Duration(minutes: 8)),
        hasAllergyWarning: true,
        allergyNotes: 'Crustacean Allergy - Strict No Prawn Paste',
        items: [
          OrderItem(
            id: 'ITM-01',
            name: 'Negombo Lagoon Crab Curry',
            nameSi: 'මීගමු කලපු කකුළු ව්‍යංජනය',
            category: 'Sri Lankan Curries',
            priceLkr: 4800,
            quantity: 1,
            spiceLevel: SpiceLevel.extraHot,
            course: CourseType.main,
          ),
          OrderItem(
            id: 'ITM-02',
            name: 'Crispy Egg Hoppers with Seeni Sambol',
            nameSi: 'බිත්තර ආප්ප සීනි සම්බෝල සමග',
            category: 'Sri Lankan Specialties',
            priceLkr: 1400,
            quantity: 3,
            spiceLevel: SpiceLevel.hot,
            course: CourseType.appetizer,
          ),
        ],
      ),
      KdsTicket(
        id: 'KOT-102',
        ticketNumber: 'KOT #102',
        tableOrRoom: 'Room 201 (Colonial Suite)',
        orderType: 'Room Service',
        status: KdsTicketStatus.pending,
        createdTime: now.subtract(const Duration(minutes: 3)),
        items: [
          OrderItem(
            id: 'ITM-03',
            name: 'Weligama Yellowfin Tuna Steak',
            nameSi: 'වැලිගම කෙලවල්ලා ස්ටේක්',
            category: 'Seafood Grills',
            priceLkr: 5200,
            quantity: 2,
            spiceLevel: SpiceLevel.medium,
            course: CourseType.main,
          ),
          OrderItem(
            id: 'ITM-04',
            name: 'Curd & Kithul Treacle',
            nameSi: 'මී කිරි සහ කිතුල් පැණි',
            category: 'Desserts',
            priceLkr: 1200,
            quantity: 2,
            spiceLevel: SpiceLevel.mild,
            course: CourseType.dessert,
          ),
        ],
      ),
      KdsTicket(
        id: 'BOT-201',
        ticketNumber: 'BOT #201',
        tableOrRoom: 'Pool Cabana 2',
        orderType: 'Pool Bar',
        status: KdsTicketStatus.ready,
        createdTime: now.subtract(const Duration(minutes: 14)),
        items: [
          OrderItem(
            id: 'ITM-05',
            name: 'Arrack Sour Galle Fort Cocktail',
            nameSi: 'ගාලු කොටුව අරක් සවර් කොක්ටේල්',
            category: 'Signature Mixology',
            priceLkr: 2400,
            quantity: 2,
            course: CourseType.beverage,
          ),
          OrderItem(
            id: 'ITM-06',
            name: 'King Coconut Thambili Cooler',
            nameSi: 'තැඹිලි පානය',
            category: 'Fresh Juices',
            priceLkr: 850,
            quantity: 2,
            course: CourseType.beverage,
          ),
        ],
      ),
    ]);

    // 4. Folios
    final tax1 = TaxEngine.calculate(baseAmount: 185000);
    _folios.add(
      Folio(
        id: 'FOL-2026-001',
        folioNumber: 'FOL #101-DR-PERERA',
        guestName: 'Dr. Michael Perera',
        roomNumber: '101',
        baseAmountLkr: 185000,
        taxBreakdown: tax1,
        payments: [
          FolioPayment(
            id: 'PAY-01',
            timestamp: now.subtract(const Duration(days: 2)),
            method: 'Credit Card (Visa)',
            amountLkr: 100000,
            referenceId: 'TXN-VISA-9941',
          ),
        ],
      ),
    );

    // 5. Inventory
    _inventory.addAll([
      InventoryItem(id: 'INV-01', sku: 'SEA-CRAB-01', name: 'Fresh Jumbo Lagoon Mud Crabs', category: 'Seafood', currentStock: 14.5, unit: 'kg', unitCostLkr: 3200, minReorderLevel: 20.0, lastRestocked: now.subtract(const Duration(days: 1))),
      InventoryItem(id: 'INV-02', sku: 'LIQ-ARRK-01', name: 'Rockland Old Arrack 750ml', category: 'Liquor', currentStock: 38, unit: 'bottles', unitCostLkr: 4100, minReorderLevel: 15, lastRestocked: now.subtract(const Duration(days: 4))),
      InventoryItem(id: 'INV-03', sku: 'PRO-KITH-01', name: 'Sinharaja Pure Kithul Treacle', category: 'Produce', currentStock: 8.0, unit: 'L', unitCostLkr: 2800, minReorderLevel: 12.0, lastRestocked: now.subtract(const Duration(days: 6))),
      InventoryItem(id: 'INV-04', sku: 'LIN-TOWL-01', name: 'Egyptian Cotton Bath Towels 600GSM', category: 'Linen', currentStock: 120, unit: 'pcs', unitCostLkr: 2200, minReorderLevel: 50, lastRestocked: now.subtract(const Duration(days: 15))),
    ]);

    // 6. Banquets & Poruwa Weddings
    _banquets.addAll([
      BanquetEvent(
        id: 'BNQ-001',
        clientName: 'Dr. Shenal & Dr. Bhagya',
        eventType: 'Traditional Poruwa Ceremony & Reception',
        hallName: 'Grand Dutch Ball Room',
        eventDate: now.add(const Duration(days: 3)),
        auspiciousTime: '09:42 AM (North-East Facing Nekath)',
        guestCount: 350,
        packageRateLkr: 12500,
        depositPaidLkr: 2000000,
        status: 'CONFIRMED',
      ),
      BanquetEvent(
        id: 'BNQ-002',
        clientName: 'Dilmah Tea Global Partner Summit',
        eventType: 'Corporate Gala Dinner',
        hallName: 'Rampart Ocean Pavilion',
        eventDate: now.add(const Duration(days: 7)),
        auspiciousTime: '07:00 PM',
        guestCount: 180,
        packageRateLkr: 14500,
        depositPaidLkr: 1500000,
        status: 'CONFIRMED',
      ),
    ]);

    // 7. Spa
    _spaBookings.addAll([
      SpaBooking(
        id: 'SPA-01',
        guestName: 'Sophie Van Der Berg',
        roomNumber: '103',
        treatmentName: 'Traditional Shirodhara & Herbal Steam',
        doshaType: 'Vata Calming',
        therapistName: 'Kanthi Wijesinghe',
        scheduledTime: now.add(const Duration(hours: 2)),
        durationMinutes: 90,
        priceLkr: 16500,
        status: 'CONFIRMED',
      ),
      SpaBooking(
        id: 'SPA-02',
        guestName: 'Lord Alistair Campbell',
        roomNumber: '201',
        treatmentName: 'Abhyanga Deep Tissue Oil Therapy',
        doshaType: 'Pitta Balancing',
        therapistName: 'Sunil Rathnayake',
        scheduledTime: now.add(const Duration(hours: 4)),
        durationMinutes: 60,
        priceLkr: 12500,
        status: 'CONFIRMED',
      ),
    ]);

    // 8. Staff Payroll
    _payroll.addAll([
      StaffPayroll(
        id: 'PAY-STAFF-01',
        staffName: 'Kasun Bandara',
        designation: 'Head Chef',
        basicSalaryLkr: 125000,
        allowancesLkr: 35000,
        serviceChargeShareLkr: 42350,
        deductions: TaxEngine.calculatePayroll(grossSalary: 160000, serviceChargeShare: 42350),
      ),
      StaffPayroll(
        id: 'PAY-STAFF-02',
        staffName: 'Nirosha Fernando',
        designation: 'Front Office Supervisor',
        basicSalaryLkr: 95000,
        allowancesLkr: 20000,
        serviceChargeShareLkr: 42350,
        deductions: TaxEngine.calculatePayroll(grossSalary: 115000, serviceChargeShare: 42350),
      ),
      StaffPayroll(
        id: 'PAY-STAFF-03',
        staffName: 'Sampath Wickramasinghe',
        designation: 'Senior Waiter',
        basicSalaryLkr: 65000,
        allowancesLkr: 15000,
        serviceChargeShareLkr: 42350,
        deductions: TaxEngine.calculatePayroll(grossSalary: 80000, serviceChargeShare: 42350),
      ),
    ]);
  }

  // Dashboard Metrics Getter
  DashboardMetrics getDashboardMetrics() {
    final total = _rooms.length;
    final occupied = _rooms.where((r) => r.isOccupied).length;
    final occupancy = total > 0 ? (occupied / total) * 100 : 0.0;
    final totalRevenueLkr = _rooms.where((r) => r.isOccupied).fold(0.0, (sum, r) => sum + r.rateLkr);
    final adr = occupied > 0 ? (totalRevenueLkr / occupied) : 0.0;
    final revpar = total > 0 ? (totalRevenueLkr / total) : 0.0;

    return DashboardMetrics(
      totalRooms: total,
      occupiedRooms: occupied,
      arrivingToday: 3,
      departingToday: 1,
      occupancyRate: (occupancy * 10).roundToDouble() / 10,
      adrLkr: (adr).roundToDouble(),
      revparLkr: (revpar).roundToDouble(),
      breakfastCount: 14,
      lunchCount: 18,
      dinnerCount: 22,
    );
  }

  // Mutators
  void updateRoomCleanStatus(String roomId, RoomCleanStatus newStatus) {
    final room = _rooms.firstWhere((r) => r.id == roomId);
    room.status = newStatus;
    notifyListeners();
  }

  void checkInGuest(String reservationId, String roomNumber) {
    final res = _reservations.firstWhere((r) => r.id == reservationId);
    res.status = 'CHECKED_IN';
    final room = _rooms.firstWhere((r) => r.roomNumber == roomNumber);
    room.isOccupied = true;
    room.currentGuestName = res.guestName;
    notifyListeners();
  }

  void updateTicketStatus(String ticketId, KdsTicketStatus newStatus) {
    final ticket = _kdsTickets.firstWhere((t) => t.id == ticketId);
    ticket.status = newStatus;
    notifyListeners();
  }

  void fireOrder(KdsTicket ticket) {
    _kdsTickets.insert(0, ticket);
    notifyListeners();
  }

  void recordPayment(String folioId, FolioPayment payment) {
    final folio = _folios.firstWhere((f) => f.id == folioId);
    folio.payments.add(payment);
    if (folio.outstandingBalanceLkr <= 0) {
      folio.isSettled = true;
    }
    notifyListeners();
  }
}
