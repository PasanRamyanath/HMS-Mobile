import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/currency/currency_engine.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

class HotelTenant {
  final String tenantId;
  final String name;
  final String province;
  final String plan;
  final String status;
  final int roomCount;
  final int monthlyQrOrders;
  final double monthlyRevenueLkr;
  final String sltdaNumber;
  final double awsStorageMb;
  final int appsyncOps30d;

  const HotelTenant({
    required this.tenantId,
    required this.name,
    required this.province,
    required this.plan,
    required this.status,
    required this.roomCount,
    required this.monthlyQrOrders,
    required this.monthlyRevenueLkr,
    required this.sltdaNumber,
    required this.awsStorageMb,
    required this.appsyncOps30d,
  });
}

class SaasSuperAdminScreen extends StatelessWidget {
  const SaasSuperAdminScreen({super.key});

  static const List<HotelTenant> tenants = [
    HotelTenant(
      tenantId: 'TEN-GALLE-01',
      name: 'Galle Fort Heritage Boutique',
      province: 'Southern Province',
      plan: 'PROFESSIONAL',
      status: 'ACTIVE',
      roomCount: 18,
      monthlyQrOrders: 412,
      monthlyRevenueLkr: 3850000,
      sltdaNumber: 'SLTDA/SQA/HOTEL/2026/089',
      awsStorageMb: 420.5,
      appsyncOps30d: 48500,
    ),
    HotelTenant(
      tenantId: 'TEN-ELLA-02',
      name: 'Ella Cloud Misty Resort',
      province: 'Uva Province',
      plan: 'ENTERPRISE',
      status: 'ACTIVE',
      roomCount: 28,
      monthlyQrOrders: 680,
      monthlyRevenueLkr: 6200000,
      sltdaNumber: 'SLTDA/SQA/RESORT/2026/044',
      awsStorageMb: 780.0,
      appsyncOps30d: 67400,
    ),
    HotelTenant(
      tenantId: 'TEN-KANDY-03',
      name: 'Kandy Lake Royal Hotel',
      province: 'Central Province',
      plan: 'STARTER',
      status: 'ACTIVE',
      roomCount: 14,
      monthlyQrOrders: 245,
      monthlyRevenueLkr: 2100000,
      sltdaNumber: 'SLTDA/SQA/HOTEL/2026/112',
      awsStorageMb: 210.0,
      appsyncOps30d: 31200,
    ),
    HotelTenant(
      tenantId: 'TEN-PELM-04',
      name: 'Pelmadulla Gem Villa',
      province: 'Sabaragamuwa Province',
      plan: 'STARTER',
      status: 'TRIAL',
      roomCount: 6,
      monthlyQrOrders: 98,
      monthlyRevenueLkr: 850000,
      sltdaNumber: 'SLTDA/SQA/VILLA/2026/201',
      awsStorageMb: 85.0,
      appsyncOps30d: 9200,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalMonthlyRev = tenants.fold(0.0, (sum, t) => sum + t.monthlyRevenueLkr);
    final totalRooms = tenants.fold(0, (sum, t) => sum + t.roomCount);
    final totalAppSyncOps = tenants.fold(0, (sum, t) => sum + t.appsyncOps30d);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('SaaS Multi-Tenant Super Admin'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.plus_circle_fill),
            tooltip: 'Onboard New Hotel Tenant',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Multi-tenant provisioning wizard opened for SLTDA certified hotel.')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Platform Header KPI
          LiquidGlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Platform Portfolio Revenue', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('4 Active Tenants', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  CurrencyEngine.formatLkr(totalMonthlyRev),
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: theme.primaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalRooms Total Managed Rooms across 4 Provinces • 0% Overbooking',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // AWS Permanent Free Tier Consumption Card
          LiquidGlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(CupertinoIcons.cloud_fill, color: Color(0xFFEA580C), size: 18),
                    SizedBox(width: 8),
                    Text('AWS Free Tier Consumption (ap-south-1)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMeter('AppSync GraphQL Operations', '$totalAppSyncOps / 250,000 Ops', totalAppSyncOps / 250000, const Color(0xFF0284C7)),
                const SizedBox(height: 8),
                _buildMeter('DynamoDB Single-Table Storage', '1.49 GB / 25 GB Free', 1.49 / 25.0, const Color(0xFF10B981)),
                const SizedBox(height: 8),
                _buildMeter('CloudFront Egress (Image CDN)', '184 GB / 1,000 GB Free', 184 / 1000.0, const Color(0xFFF59E0B)),
                const SizedBox(height: 8),
                _buildMeter('AWS Lambda Compute Invocations', '82,400 / 1,000,000 Invocations', 82400 / 1000000.0, const Color(0xFF9333EA)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Registered Hotel Tenants Directory
          const Text('Registered Sri Lankan Hotel Tenants', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 8),

          ...tenants.map((t) {
            return LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      ),
                      MetricBadge(
                        label: t.plan,
                        color: t.plan == 'ENTERPRISE'
                            ? const Color(0xFF9333EA)
                            : (t.plan == 'PROFESSIONAL' ? const Color(0xFF0284C7) : const Color(0xFF15803D)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${t.province} • ${t.sltdaNumber}', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : const Color(0xFF64748B))),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rooms: ${t.roomCount}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      Text('Monthly QR Orders: ${t.monthlyQrOrders}', style: const TextStyle(fontSize: 12)),
                      Text(CurrencyEngine.formatLkr(t.monthlyRevenueLkr), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('AppSync Ops: ${t.appsyncOps30d.toString()} | Storage: ${t.awsStorageMb} MB', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMeter(String title, String ratioText, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(ratioText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey.withAlpha(40),
          color: color,
          minHeight: 5,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
