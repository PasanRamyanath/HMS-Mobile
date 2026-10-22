import 'package:flutter_test/flutter_test.dart';
import 'package:hms_mobile/core/currency/currency_engine.dart';

void main() {
  group('Sri Lankan Currency Engine Tests', () {
    test('Formats LKR and USD currency strings accurately', () {
      final lkrFormatted = CurrencyEngine.formatLkr(50000);
      expect(lkrFormatted, contains('50,000'));

      final usdFormatted = CurrencyEngine.formatUsd(167.5);
      expect(usdFormatted, contains('167.50'));
    });

    test('Converts LKR to USD and vice-versa at CBSL mid-rate', () {
      // With default 298.50 rate: 29,850 LKR = 100 USD
      final usd = CurrencyEngine.lkrToUsd(29850);
      expect(usd, closeTo(100.0, 0.01));

      final lkr = CurrencyEngine.usdToLkr(100);
      expect(lkr, closeTo(29850.0, 0.01));
    });
  });
}
