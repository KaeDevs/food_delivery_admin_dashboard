import '../models/audit_log.dart';
import '../mock/mock_audit_logs.dart';

class AuditRepository {
  static List<AuditLog> getAll() => MockAuditLogs.logs;
  static List<AuditLog> getByAction(String action) => MockAuditLogs.logs.where((l) => l.actionName == action).toList();
  static List<AuditLog> getByEntity(String entityType) => MockAuditLogs.logs.where((l) => l.entityType == entityType).toList();
  static List<AuditLog> getByActor(String adminId) => MockAuditLogs.logs.where((l) => l.actorAdminId == adminId).toList();
  static void add(AuditLog log) => MockAuditLogs.logs.insert(0, log);
}
