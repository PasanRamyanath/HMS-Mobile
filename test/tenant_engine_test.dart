import 'package:flutter_test/flutter_test.dart';
import 'package:hms_mobile/core/tenant/tenant_engine.dart';
import 'package:hms_mobile/core/api/appsync_client.dart';

void main() {
  group('Multi-Tenant SaaS Property Engine Tests', () {
    test('Switches between multiple registered Sri Lankan hotel tenants', () {
      final engine = TenantEngine();

      // Default property should be Galle Fort
      expect(engine.activeTenantId, equals('TEN-GALLE-01'));
      expect(engine.currentProperty.province, equals('Southern Province'));

      // Switch to Ella Cloud Resort
      engine.switchProperty('TEN-ELLA-02');
      expect(engine.activeTenantId, equals('TEN-ELLA-02'));
      expect(engine.currentProperty.name, contains('Ella'));
      expect(engine.currentProperty.province, equals('Uva Province'));

      // Switch to Kandy Lake Hotel
      engine.switchProperty('TEN-KANDY-03');
      expect(engine.activeTenantId, equals('TEN-KANDY-03'));
      expect(engine.currentProperty.name, contains('Kandy'));

      // Switch back to Galle Fort
      engine.switchProperty('TEN-GALLE-01');
      expect(engine.activeTenantId, equals('TEN-GALLE-01'));
    });

    test('Attaches active tenantId to AppSync GraphQL request headers', () {
      final engine = TenantEngine();
      final client = AppSyncClient();

      engine.switchProperty('TEN-ELLA-02');
      final headers = client.getRequestHeaders();

      expect(headers['x-tenant-id'], equals('TEN-ELLA-02'));
      expect(headers['Content-Type'], equals('application/json'));
    });
  });
}
