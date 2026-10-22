import 'package:intl/intl.dart';

/// Sri Lankan Dual-Currency Engine (LKR & Foreign Visitor USD).
/// Provides CBSL daily mid FX conversions, currency formatting with tabular
/// numerals, and integer cent conversions for financial folios and IRD invoices.
class CurrencyEngine {
  /// Default Central Bank of Sri Lanka (CBSL) indicative mid-rate for USD/LKR.
  static const double defaultCbslUsdToLkr = 298.50;

  static double currentCbslRate = defaultCbslUsdToLkr;

  static double get usdToLkrRate => currentCbslRate;

  /// Formats an integer LKR amount or cents.
  static String formatLkr(num amount, {bool isCents = false}) {
    final value = isCents ? amount / 100.0 : amount.toDouble();
    final formatter = NumberFormat.currency(
      locale: 'en_LK',
      symbol: 'Rs. ',
      decimalDigits: value.truncateToDouble() == value ? 0 : 2,
    );
    return formatter.format(value);
  }

  /// Formats a USD amount with 2 decimal places.
  static String formatUsd(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$ ',
      decimalDigits: 2,
    );
    return formatter.format(amount.toDouble());
  }

  /// Converts LKR amount to USD using current CBSL mid-rate.
  static double lkrToUsd(num lkrAmount) {
    if (currentCbslRate <= 0) return 0.0;
    return lkrAmount / currentCbslRate;
  }

  /// Converts USD amount to LKR using current CBSL mid-rate.
  static double usdToLkr(num usdAmount) {
    return usdAmount * currentCbslRate;
  }
}
