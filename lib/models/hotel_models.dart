import '../core/tax/tax_engine.dart';

enum RoomCleanStatus {
  clean,
  dirty,
  inspected,
  maintenance,
}

enum MealPlan {
  ro, // Room Only
  bb, // Bed & Breakfast
  hb, // Half Board
  fb, // Full Board
  ai, // All Inclusive
}

class Room {
  final String id;
  final String roomNumber;
  final String categoryName;
  final int floor;
  RoomCleanStatus status;
  bool isOccupied;
  String? currentGuestName;
  final double rateLkr;
  final double rateUsd;
  final int occupancyLimit;

  Room({
    required this.id,
    required this.roomNumber,
    required this.categoryName,
    required this.floor,
    required this.status,
    required this.isOccupied,
    this.currentGuestName,
    required this.rateLkr,
    required this.rateUsd,
    this.occupancyLimit = 2,
  });
}

class Reservation {
  final String id;
  final String guestName;
  final String guestContact;
  final String nicOrPassport;
  final String roomNumber;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final MealPlan mealPlan;
  String status; // CONFIRMED, CHECKED_IN, CHECKED_OUT, CANCELLED
  final double totalAmountLkr;
  double paidAmountLkr;
  final int guestCount;

  Reservation({
    required this.id,
    required this.guestName,
    required this.guestContact,
    required this.nicOrPassport,
    required this.roomNumber,
    required this.checkInDate,
    required this.checkOutDate,
    required this.mealPlan,
    required this.status,
    required this.totalAmountLkr,
    required this.paidAmountLkr,
    this.guestCount = 2,
  });

  bool get isFullyPaid => paidAmountLkr >= totalAmountLkr;
  double get balanceLkr => totalAmountLkr - paidAmountLkr;
}

enum SpiceLevel {
  mild,
  medium,
  hot,
  extraHot,
}

enum CourseType {
  appetizer,
  main,
  dessert,
  beverage,
}

class OrderItem {
  final String id;
  final String name;
  final String nameSi;
  final String category;
  final double priceLkr;
  int quantity;
  final SpiceLevel spiceLevel;
  final CourseType course;
  final String? specialInstructions;

  OrderItem({
    required this.id,
    required this.name,
    this.nameSi = '',
    required this.category,
    required this.priceLkr,
    this.quantity = 1,
    this.spiceLevel = SpiceLevel.medium,
    this.course = CourseType.main,
    this.specialInstructions,
  });

  double get subtotalLkr => priceLkr * quantity;
}

enum KdsTicketStatus {
  pending,
  preparing,
  ready,
  served,
  cancelled,
}

class KdsTicket {
  final String id;
  final String ticketNumber;
  final String tableOrRoom;
  final String orderType; // "Dine-in", "Room Service", "Pool Bar"
  KdsTicketStatus status;
  final List<OrderItem> items;
  final DateTime createdTime;
  final bool hasAllergyWarning;
  final String? allergyNotes;

  KdsTicket({
    required this.id,
    required this.ticketNumber,
    required this.tableOrRoom,
    required this.orderType,
    required this.status,
    required this.items,
    required this.createdTime,
    this.hasAllergyWarning = false,
    this.allergyNotes,
  });

  int get elapsedMinutes => DateTime.now().difference(createdTime).inMinutes;
  double get totalLkr => items.fold(0.0, (sum, item) => sum + item.subtotalLkr);
}

class FolioPayment {
  final String id;
  final DateTime timestamp;
  final String method; // "LankaQR", "Cash", "Credit Card", "Room Charge"
  final double amountLkr;
  final String referenceId;

  FolioPayment({
    required this.id,
    required this.timestamp,
    required this.method,
    required this.amountLkr,
    required this.referenceId,
  });
}

class Folio {
  final String id;
  final String folioNumber;
  final String guestName;
  final String roomNumber;
  final double baseAmountLkr;
  final SriLankaTaxBreakdown taxBreakdown;
  final List<FolioPayment> payments;
  bool isSettled;

  Folio({
    required this.id,
    required this.folioNumber,
    required this.guestName,
    required this.roomNumber,
    required this.baseAmountLkr,
    required this.taxBreakdown,
    required this.payments,
    this.isSettled = false,
  });

  double get totalPaidLkr => payments.fold(0.0, (sum, p) => sum + p.amountLkr);
  double get outstandingBalanceLkr => taxBreakdown.grandTotal - totalPaidLkr;
}

class InventoryItem {
  final String id;
  final String sku;
  final String name;
  final String category;
  double currentStock;
  final String unit; // kg, L, bottles, packs
  final double unitCostLkr;
  final double minReorderLevel;
  final DateTime lastRestocked;

  InventoryItem({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.unit,
    required this.unitCostLkr,
    required this.minReorderLevel,
    required this.lastRestocked,
  });

  bool get isLowStock => currentStock <= minReorderLevel;
}

class BanquetEvent {
  final String id;
  final String clientName;
  final String eventType; // "Poruwa Ceremony & Reception", "Corporate Gala"
  final String hallName;
  final DateTime eventDate;
  final String auspiciousTime; // Nekath time e.g. "09:42 AM (North Facing)"
  final int guestCount;
  final double packageRateLkr;
  double depositPaidLkr;
  String status;

  BanquetEvent({
    required this.id,
    required this.clientName,
    required this.eventType,
    required this.hallName,
    required this.eventDate,
    required this.auspiciousTime,
    required this.guestCount,
    required this.packageRateLkr,
    required this.depositPaidLkr,
    required this.status,
  });

  double get totalAmountLkr => packageRateLkr * guestCount;
  double get balanceDueLkr => totalAmountLkr - depositPaidLkr;
}

class SpaBooking {
  final String id;
  final String guestName;
  final String roomNumber;
  final String treatmentName;
  final String doshaType; // "Vata (Air/Space)", "Pitta (Fire/Water)", "Kapha (Earth/Water)"
  final String therapistName;
  final DateTime scheduledTime;
  final int durationMinutes;
  final double priceLkr;
  String status;

  SpaBooking({
    required this.id,
    required this.guestName,
    required this.roomNumber,
    required this.treatmentName,
    required this.doshaType,
    required this.therapistName,
    required this.scheduledTime,
    required this.durationMinutes,
    required this.priceLkr,
    required this.status,
  });
}

class StaffPayroll {
  final String id;
  final String staffName;
  final String designation;
  final double basicSalaryLkr;
  final double allowancesLkr;
  final double serviceChargeShareLkr;
  final PayrollDeductions deductions;

  StaffPayroll({
    required this.id,
    required this.staffName,
    required this.designation,
    required this.basicSalaryLkr,
    required this.allowancesLkr,
    required this.serviceChargeShareLkr,
    required this.deductions,
  });
}
