/// Sri Lankan Statutory Tax Engine
/// Implements the legal compounding formula:
/// Stage 1: Base Amount
/// Stage 2: 10% Service Charge (Mandatory in SL hospitality, levied on Base)
/// Stage 3: 1% Tourism Development Levy (TDL, levied on Base + SC)
/// Stage 4: 2.5% Social Security Contribution Levy (SSCL, effective 2.5641% or statutory 2.5% on Base + SC)
/// Stage 5: 18% Value Added Tax (VAT, levied on Base + SC + SSCL)
/// Total effective tax rate ≈ 34.343%
class TaxEngine {
  static const double serviceChargeRate = 0.10; // 10%
  static const double tdlRate = 0.01; // 1% Tourism Development Levy
  static const double ssclRate = 0.025; // 2.5% SSCL
  static const double vatRate = 0.18; // 18% VAT

  /// Calculates the exact 4-stage Sri Lankan hospitality compounding tax.
  /// All calculations operate with double precision and round to 2 decimal places.
  static SriLankaTaxBreakdown calculate({
    required double baseAmount,
    bool includeServiceCharge = true,
  }) {
    final double sc = includeServiceCharge ? (baseAmount * serviceChargeRate) : 0.0;
    final double subtotalWithSc = baseAmount + sc;
    final double tdl = subtotalWithSc * tdlRate;
    final double sscl = subtotalWithSc * ssclRate;
    final double vat = (subtotalWithSc + sscl) * vatRate;
    final double grandTotal = subtotalWithSc + tdl + sscl + vat;

    return SriLankaTaxBreakdown(
      baseAmount: _round2(baseAmount),
      serviceCharge: _round2(sc),
      tdl: _round2(tdl),
      sscl: _round2(sscl),
      vat: _round2(vat),
      grandTotal: _round2(grandTotal),
    );
  }

  /// Calculates EPF and ETF deductions based on basic salary + allowances
  static PayrollDeductions calculatePayroll({
    required double grossSalary,
    required double serviceChargeShare,
  }) {
    final double epfEmployee = grossSalary * 0.08; // 8% Employee EPF
    final double epfEmployer = grossSalary * 0.12; // 12% Employer EPF
    final double etfEmployer = grossSalary * 0.03; // 3% Employer ETF
    final double netTakeHome = (grossSalary - epfEmployee) + serviceChargeShare;

    return PayrollDeductions(
      grossSalary: _round2(grossSalary),
      serviceChargeShare: _round2(serviceChargeShare),
      epfEmployee: _round2(epfEmployee),
      epfEmployer: _round2(epfEmployer),
      etfEmployer: _round2(etfEmployer),
      netTakeHome: _round2(netTakeHome),
    );
  }

  static double _round2(double val) => (val * 100).roundToDouble() / 100;
}

class SriLankaTaxBreakdown {
  final double baseAmount;
  final double serviceCharge;
  final double tdl;
  final double sscl;
  final double vat;
  final double grandTotal;

  const SriLankaTaxBreakdown({
    required this.baseAmount,
    required this.serviceCharge,
    required this.tdl,
    required this.sscl,
    required this.vat,
    required this.grandTotal,
  });

  double get totalTaxesAndLevies => grandTotal - baseAmount;
  double get effectiveTaxPercentage => baseAmount > 0 ? (totalTaxesAndLevies / baseAmount) * 100 : 0.0;
}

class PayrollDeductions {
  final double grossSalary;
  final double serviceChargeShare;
  final double epfEmployee;
  final double epfEmployer;
  final double etfEmployer;
  final double netTakeHome;

  const PayrollDeductions({
    required this.grossSalary,
    required this.serviceChargeShare,
    required this.epfEmployee,
    required this.epfEmployer,
    required this.etfEmployer,
    required this.netTakeHome,
  });
}
