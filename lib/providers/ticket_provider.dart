import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/ticket.dart';
import '../data/mock/mock_tickets.dart';

final ticketProvider = StateNotifierProvider<TicketListNotifier, List<SupportTicket>>((ref) => TicketListNotifier());

class TicketListNotifier extends StateNotifier<List<SupportTicket>> {
  TicketListNotifier() : super(MockTickets.tickets);
  void updateTicket(String id, SupportTicket updated) { state = state.map((t) => t.id == id ? updated : t).toList(); }
}

final openTicketsProvider = Provider<List<SupportTicket>>((ref) => ref.watch(ticketProvider).where((t) => t.status != TicketStatus.resolved).toList());
