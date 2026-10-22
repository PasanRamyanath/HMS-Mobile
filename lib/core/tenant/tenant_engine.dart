import 'package:flutter/foundation.dart';

class HotelProperty {
  final String tenantId;
  final String tenantSlug;
  final String name;
  final String legalEntityName;
  final String city;
  final String province;
  final String sltdaRegistrationNumber;
  final int totalRooms;
  final String subscriptionPlan; // "STARTER", "PROFESSIONAL", "ENTERPRISE"
  final String contactPhone;
  final String contactEmail;

  const HotelProperty({
    required this.tenantId,
    required this.tenantSlug,
    required this.name,
    required this.legalEntityName,
    required this.city,
    required this.province,
    required this.sltdaRegistrationNumber,
    required this.totalRooms,
    required this.subscriptionPlan,
    required this.contactPhone,
    required this.contactEmail,
  });
}

class TenantEngine extends ChangeNotifier {
  static final TenantEngine _instance = TenantEngine._internal();
  factory TenantEngine() => _instance;
  TenantEngine._internal();

  static const List<HotelProperty> registeredProperties = [
    HotelProperty(
      tenantId: 'TEN-GALLE-01',
      tenantSlug: 'galle-fort-heritage',
      name: 'Ceylon Heritage Resort & Spa - Galle Fort',
      legalEntityName: 'Ceylon Heritage Hospitality (Pvt) Ltd',
      city: 'Galle Fort',
      province: 'Southern Province',
      sltdaRegistrationNumber: 'SLTDA/SQA/HOTEL/2026/089',
      totalRooms: 18,
      subscriptionPlan: 'PROFESSIONAL',
      contactPhone: '+94 91 223 4567',
      contactEmail: 'galle@ceylonheritage.lk',
    ),
    HotelProperty(
      tenantId: 'TEN-ELLA-02',
      tenantSlug: 'ella-cloud-resort',
      name: 'Ella Cloud Misty Mountain Resort',
      legalEntityName: 'Ella Highland Leisure (Pvt) Ltd',
      city: 'Ella',
      province: 'Uva Province',
      sltdaRegistrationNumber: 'SLTDA/SQA/RESORT/2026/044',
      totalRooms: 28,
      subscriptionPlan: 'ENTERPRISE',
      contactPhone: '+94 57 222 8900',
      contactEmail: 'ella@cloudresorts.lk',
    ),
    HotelProperty(
      tenantId: 'TEN-KANDY-03',
      tenantSlug: 'kandy-royal-hotel',
      name: 'Kandy Lake Royal Palace Hotel',
      legalEntityName: 'Kandy Heritage Inns (Pvt) Ltd',
      city: 'Kandy',
      province: 'Central Province',
      sltdaRegistrationNumber: 'SLTDA/SQA/HOTEL/2026/112',
      totalRooms: 14,
      subscriptionPlan: 'STARTER',
      contactPhone: '+94 81 220 1234',
      contactEmail: 'reception@kandylake.lk',
    ),
    HotelProperty(
      tenantId: 'TEN-PELM-04',
      tenantSlug: 'pelmadulla-gem-villa',
      name: 'Pelmadulla Gem Villa & Rest House',
      legalEntityName: 'Rathnapura Gemfield Rest Houses',
      city: 'Pelmadulla',
      province: 'Sabaragamuwa Province',
      sltdaRegistrationNumber: 'SLTDA/SQA/VILLA/2026/201',
      totalRooms: 6,
      subscriptionPlan: 'STARTER',
      contactPhone: '+94 45 227 5544',
      contactEmail: 'villa@pelmadulla.lk',
    ),
  ];

  HotelProperty _currentProperty = registeredProperties[0];

  HotelProperty get currentProperty => _currentProperty;
  String get activeTenantId => _currentProperty.tenantId;

  /// Switch the active hotel tenant across all mobile PMS screens and GraphQL headers
  void switchProperty(String tenantId) {
    final found = registeredProperties.firstWhere(
      (p) => p.tenantId == tenantId,
      orElse: () => registeredProperties[0],
    );
    _currentProperty = found;
    notifyListeners();
  }
}
