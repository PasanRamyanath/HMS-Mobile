import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/lanka_qr/lanka_qr_generator.dart';
import '../../widgets/liquid_glass_card.dart';

class LankaQrScreen extends StatelessWidget {
  final double amountLkr;
  final String folioReference;
  final String guestName;
  final VoidCallback onPaymentConfirmed;

  const LankaQrScreen({
    super.key,
    required this.amountLkr,
    required this.folioReference,
    required this.guestName,
    required this.onPaymentConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final qrPayload = LankaQRGenerator.generateLankaQR(
      amountLkr: amountLkr,
      referenceId: folioReference,
      merchantName: 'CEYLON HERITAGE HMS',
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('LankaQR Dynamic Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // CBSL LankaQR Header Card
            LiquidGlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA580C).withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFEA580C)),
                        ),
                        child: const Row(
                          children: [
                            Icon(CupertinoIcons.qrcode, color: Color(0xFFEA580C), size: 16),
                            SizedBox(width: 6),
                            Text(
                              'LankaQR CBSL Certified',
                              style: TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.w800, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    CurrencyEngine.formatLkr(amountLkr),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: theme.primaryColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'USD ~${CurrencyEngine.lkrToUsd(amountLkr).toStringAsFixed(2)} at CBSL Mid-Rate',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // QR Code Canvas
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: qrPayload,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ref: $folioReference | Guest: $guestName',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Scan using Commercial Bank COMBANK Q+, BOC SmartPay, Sampath WePay, HNB SOLO, or any LankaQR compliant app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Simulate Successful Scan Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(CupertinoIcons.checkmark_seal_fill),
                label: const Text('Simulate Bank Settlement (CEFT Instant)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                onPressed: () {
                  onPaymentConfirmed();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('LankaQR Payment Approved via LankaClear CEFT!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
