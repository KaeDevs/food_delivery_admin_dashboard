import 'package:flutter/material.dart';
import '../../../data/models/order.dart';
import '../../../core/theme/app_colors.dart';

class SlaBadge extends StatelessWidget {
  final Order order;
  const SlaBadge({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled || order.status == OrderStatus.failed) {
      if (order.isSlaBreached) {
        return _badge('Breached', kDanger);
      }
      return _badge('On Time', kSuccess);
    }

    if (order.isSlaBreached) {
      return _badge('Breached', kDanger);
    }

    if (order.promisedDeliveryAt != null) {
      final remaining = order.promisedDeliveryAt!.difference(DateTime.now());
      if (remaining.inMinutes <= 5) {
        return _badge('At Risk', kWarning);
      }
    }

    return _badge('On Track', kSuccess);
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
