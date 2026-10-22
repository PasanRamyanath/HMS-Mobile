import 'package:flutter_test/flutter_test.dart';
import 'package:hms_mobile/core/lanka_qr/lanka_qr_generator.dart';

void main() {
  group('LankaQR EMVCo Generator Tests', () {
    test('Generates valid EMVCo payload with Tag 00, 53 (144 LKR), 58 (LK) and 63 (CRC16)', () {
      final payload = LankaQRGenerator.generateLankaQR(
        amountLkr: 15450.00,
        referenceId: 'FOL-101-TEST',
        merchantName: 'CEYLON HERITAGE HMS',
      );

      // Verify EMVCo tags
      expect(payload.startsWith('000201'), isTrue); // Tag 00 length 02 value 01
      expect(payload, contains('5303144')); // ISO 4217 Currency: 144 LKR
      expect(payload, contains('540815450.00')); // Transaction Amount
      expect(payload, contains('5802LK')); // Country LK
      expect(payload, contains('6304')); // CRC tag prefix

      // Length should be correct with 4-char CRC16 at the end
      final crcIndex = payload.lastIndexOf('6304');
      final crcHex = payload.substring(crcIndex + 4);
      expect(crcHex.length, equals(4));
    });
  });
}
