/// Sri Lanka LankaQR EMVCo Merchant-Presented Code Generator
/// Fully compliant with Central Bank of Sri Lanka (CBSL) LankaQR specifications.
class LankaQRGenerator {
  /// Generates a standardized LankaQR EMVCo payload string with dynamic amount and CRC16 checksum.
  static String generateLankaQR({
    required double amountLkr,
    required String referenceId,
    String merchantName = "CEYLON HERITAGE HMS",
    String merchantCity = "COLOMBO",
    String merchantCategoryCode = "7011", // Hotels & Motels
    String terminalId = "HMS-MOB-01",
  }) {
    final StringBuffer sb = StringBuffer();

    // 00: Payload Format Indicator (Fixed "01")
    _appendTlv(sb, "00", "01");

    // 01: Point of Initiation (12 = Dynamic QR with specific bill amount)
    _appendTlv(sb, "01", "12");

    // 26: Merchant Account Information (LankaQR / LankaClear network)
    final StringBuffer maiSb = StringBuffer();
    _appendTlv(maiSb, "00", "com.lankaclear.lankaqr");
    _appendTlv(maiSb, "01", "0078000194"); // Merchant ID
    _appendTlv(maiSb, "02", terminalId);
    _appendTlv(sb, "26", maiSb.toString());

    // 52: Merchant Category Code (7011 = Lodging / Hotels)
    _appendTlv(sb, "52", merchantCategoryCode);

    // 53: Transaction Currency (144 = LKR ISO 4217)
    _appendTlv(sb, "53", "144");

    // 54: Transaction Amount formatted with 2 decimals
    final String formattedAmount = amountLkr.toStringAsFixed(2);
    _appendTlv(sb, "54", formattedAmount);

    // 58: Country Code (LK = Sri Lanka)
    _appendTlv(sb, "58", "LK");

    // 59: Merchant Name (Up to 25 chars)
    final String truncatedName = merchantName.length > 25 ? merchantName.substring(0, 25) : merchantName;
    _appendTlv(sb, "59", truncatedName);

    // 60: Merchant City (Up to 15 chars)
    final String truncatedCity = merchantCity.length > 15 ? merchantCity.substring(0, 15) : merchantCity;
    _appendTlv(sb, "60", truncatedCity);

    // 62: Additional Data Field (Reference / Folio Number)
    final StringBuffer addSb = StringBuffer();
    _appendTlv(addSb, "01", referenceId); // Bill / Folio number
    _appendTlv(sb, "62", addSb.toString());

    // 63: CRC16 Checksum
    final String qrWithoutCrc = "${sb}6304";
    final String crcHex = _calculateCrc16(qrWithoutCrc);

    return qrWithoutCrc + crcHex;
  }

  static void _appendTlv(StringBuffer sb, String tag, String value) {
    sb.write(tag);
    sb.write(value.length.toString().padLeft(2, '0'));
    sb.write(value);
  }

  /// Calculates CRC16-CCITT checksum with polynomial 0x1021 and initial value 0xFFFF
  static String _calculateCrc16(String input) {
    int crc = 0xFFFF;
    final List<int> bytes = input.codeUnits;

    for (int b in bytes) {
      for (int i = 0; i < 8; i++) {
        bool bit = ((b >> (7 - i) & 1) == 1);
        bool c15 = ((crc >> 15 & 1) == 1);
        crc = (crc << 1) & 0xFFFF;
        if (c15 ^ bit) {
          crc ^= 0x1021;
        }
      }
    }

    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
