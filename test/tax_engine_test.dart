import 'package:flutter_test/flutter_test.dart';
import 'package:hms_mobile/core/tax/tax_engine.dart';

void main() {
  group('Sri Lankan Statutory Tax Engine Tests', () {
    test('Calculates 4-stage compounding tax correctly on LKR 100,000 base', () {
      final breakdown = TaxEngine.calculate(baseAmount: 100000.0);

      expect(breakdown.baseAmount, equals(100000.0));
      expect(breakdown.serviceCharge, equals(10000.0)); // 10% on 100k
      expect(breakdown.tdl, equals(1100.0)); // 1% on (100k + 10k)
      expect(breakdown.sscl, equals(2750.0)); // 2.5% on (100k + 10k)
      expect(breakdown.vat, equals(20295.0)); // 18% on (100k + 10k + 2750)
      expect(breakdown.grandTotal, equals(134145.0));
      expect(breakdown.totalTaxesAndLevies, equals(34145.0));
      expect(breakdown.effectiveTaxPercentage, closeTo(34.145, 0.01));
    });

    test('Calculates statutory EPF and ETF payroll deductions accurately', () {
      final payroll = TaxEngine.calculatePayroll(
        grossSalary: 100000.0,
        serviceChargeShare: 40000.0,
      );

      expect(payroll.grossSalary, equals(100000.0));
      expect(payroll.epfEmployee, equals(8000.0)); // 8% Employee
      expect(payroll.epfEmployer, equals(12000.0)); // 12% Employer
      expect(payroll.etfEmployer, equals(3000.0)); // 3% Employer
      // Net take home = (100,000 - 8,000) + 40,000 = 132,000
      expect(payroll.netTakeHome, equals(132000.0));
    });
  });
}
