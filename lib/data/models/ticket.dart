enum TicketStatus { open, inProgress, resolved, reopened }

enum TicketType { customer, merchant, rider }

enum TicketPriority { low, medium, high, critical }

class SupportTicket {
  final String id;
  final String orderId;
  final String raisedById;
  final TicketType type;
  final TicketPriority priority;
  final TicketStatus status;
  final String issueCategory;
  final String description;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final double? compensationAmount;
  final String? assignedAdminId;

  const SupportTicket({
    required this.id,
    required this.orderId,
    required this.raisedById,
    required this.type,
    required this.priority,
    required this.status,
    required this.issueCategory,
    required this.description,
    required this.createdAt,
    this.resolvedAt,
    this.compensationAmount,
    this.assignedAdminId,
  });

  SupportTicket copyWith({
    String? id,
    String? orderId,
    String? raisedById,
    TicketType? type,
    TicketPriority? priority,
    TicketStatus? status,
    String? issueCategory,
    String? description,
    DateTime? createdAt,
    DateTime? resolvedAt,
    double? compensationAmount,
    String? assignedAdminId,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      raisedById: raisedById ?? this.raisedById,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      issueCategory: issueCategory ?? this.issueCategory,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      compensationAmount: compensationAmount ?? this.compensationAmount,
      assignedAdminId: assignedAdminId ?? this.assignedAdminId,
    );
  }

  String get statusLabel {
    switch (status) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.reopened:
        return 'Reopened';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.critical:
        return 'Critical';
    }
  }
}
