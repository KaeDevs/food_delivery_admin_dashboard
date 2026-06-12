class AuditLog {
  final String id;
  final String actorAdminId;
  final String actorRole;
  final String actionName;
  final String entityType;
  final String entityId;
  final String beforeState;
  final String afterState;
  final String reasonCode;
  final DateTime timestamp;

  const AuditLog({
    required this.id,
    required this.actorAdminId,
    required this.actorRole,
    required this.actionName,
    required this.entityType,
    required this.entityId,
    required this.beforeState,
    required this.afterState,
    required this.reasonCode,
    required this.timestamp,
  });

  AuditLog copyWith({
    String? id,
    String? actorAdminId,
    String? actorRole,
    String? actionName,
    String? entityType,
    String? entityId,
    String? beforeState,
    String? afterState,
    String? reasonCode,
    DateTime? timestamp,
  }) {
    return AuditLog(
      id: id ?? this.id,
      actorAdminId: actorAdminId ?? this.actorAdminId,
      actorRole: actorRole ?? this.actorRole,
      actionName: actionName ?? this.actionName,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      beforeState: beforeState ?? this.beforeState,
      afterState: afterState ?? this.afterState,
      reasonCode: reasonCode ?? this.reasonCode,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
