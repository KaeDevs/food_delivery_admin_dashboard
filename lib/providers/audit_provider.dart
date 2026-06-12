import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/audit_log.dart';
import '../data/mock/mock_audit_logs.dart';

final auditProvider = StateNotifierProvider<AuditNotifier, List<AuditLog>>((ref) => AuditNotifier());

class AuditNotifier extends StateNotifier<List<AuditLog>> {
  AuditNotifier() : super(MockAuditLogs.logs);

  void log(AuditLog entry) {
    MockAuditLogs.logs.insert(0, entry);
    state = [...MockAuditLogs.logs];
  }
}
