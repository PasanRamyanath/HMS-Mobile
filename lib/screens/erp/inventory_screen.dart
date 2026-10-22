import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/translations.dart';
import '../../core/currency/currency_engine.dart';
import '../../core/api/appsync_client.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/metric_badge.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final client = AppSyncClient();
    final items = client.inventory;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.tr('inventory_bom')),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return LiquidGlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.isLowStock
                        ? Colors.red.withAlpha(isDark ? 40 : 25)
                        : theme.primaryColor.withAlpha(isDark ? 40 : 25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: item.isLowStock ? Colors.red : theme.primaryColor.withAlpha(80),
                    ),
                  ),
                  child: Icon(
                    item.isLowStock ? CupertinoIcons.exclamationmark_triangle_fill : CupertinoIcons.cube_box_fill,
                    color: item.isLowStock ? Colors.red : theme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                          MetricBadge(
                            label: item.isLowStock ? 'LOW STOCK' : 'IN STOCK',
                            color: item.isLowStock ? Colors.red : const Color(0xFF10B981),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('SKU: ${item.sku} | Category: ${item.category}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Stock: ${item.currentStock} ${item.unit} (Min: ${item.minReorderLevel} ${item.unit})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: item.isLowStock ? Colors.redAccent : (isDark ? Colors.white70 : const Color(0xFF475569)),
                            ),
                          ),
                          Text(
                            '${CurrencyEngine.formatLkr(item.unitCostLkr)} / ${item.unit}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
