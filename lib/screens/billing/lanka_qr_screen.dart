import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/lanka_qr/lanka_qr_generator.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

/// Web-Parity Dynamic LankaQR EMVCo Checkout Screen (`FrontDeskLankaQrModal.tsx` & `GuestLankaQrPay.tsx`).
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
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        child: Column(
          children: [
            LiquidGlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const MetricBadge(
                    label: 'LankaQR CBSL Certified • EMVCo Dynamic',
                    color: Color(0xFFEA580C),
                    icon: CupertinoIcons.qrcode,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    CurrencyEngine.formatLkr(amountLkr),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: theme.primaryColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Approx. USD ${CurrencyEngine.lkrToUsd(amountLkr).toStringAsFixed(2)} at CBSL Mid-Rate (1:${CurrencyEngine.usdToLkrRate.toStringAsFixed(1)})',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Crisp White QR Code Canvas
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.lightBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(18),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: qrPayload,
                      version: QrVersions.auto,
                      size: 196.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ref: $folioReference • Guest: $guestName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: const [
                      MetricBadge(label: 'COMBANK Q+', color: Color(0xFF0284C7)),
                      MetricBadge(label: 'BOC SmartPay', color: Color(0xFFD97706)),
                      MetricBadge(label: 'Sampath WePay', color: Color(0xFFEA580C)),
                      MetricBadge(label: 'HNB SOLO', color: Color(0xFF2563EB)),
                      MetricBadge(label: 'FriMi', color: Color(0xFF7C3AED)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Simulate Successful Scan Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(CupertinoIcons.checkmark_seal_fill, size: 18),
                label: const Text(
                  'Simulate Bank Settlement (CEFT Instant)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                ),
                onPressed: () {
                  onPaymentConfirmed();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('LankaQR Payment Approved via LankaClear CEFT!'),
                      backgroundColor: Color(0xFF16A34A),
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
