import '../models/ticket.dart';
import '../mock/mock_tickets.dart';

class TicketRepository {
  static List<SupportTicket> getAll() => MockTickets.tickets;
  static SupportTicket? getById(String id) {
    try { return MockTickets.tickets.firstWhere((t) => t.id == id); } catch (_) { return null; }
  }
  static List<SupportTicket> getOpen() => MockTickets.tickets.where((t) => t.status != TicketStatus.resolved).toList();
  static List<SupportTicket> getByType(TicketType type) => MockTickets.tickets.where((t) => t.type == type).toList();
  static List<SupportTicket> getByPriority(TicketPriority priority) => MockTickets.tickets.where((t) => t.priority == priority).toList();
}
