enum PaymentChannel { upi, card, wallet, netBanking, cod }

enum PaymentStatus { success, failed, pending, refunded }

class PaymentTransaction {
  final String id;
  final String orderId;
  final double amount;
  final PaymentChannel channel;
  final PaymentStatus status;
  final DateTime timestamp;
  final String? failureReason;
  final bool isRefunded;
  final double? refundAmount;

  const PaymentTransaction({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.channel,
    required this.status,
    required this.timestamp,
    this.failureReason,
    this.isRefunded = false,
    this.refundAmount,
  });

  PaymentTransaction copyWith({
    String? id,
    String? orderId,
    double? amount,
    PaymentChannel? channel,
    PaymentStatus? status,
    DateTime? timestamp,
    String? failureReason,
    bool? isRefunded,
    double? refundAmount,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      channel: channel ?? this.channel,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      failureReason: failureReason ?? this.failureReason,
      isRefunded: isRefunded ?? this.isRefunded,
      refundAmount: refundAmount ?? this.refundAmount,
    );
  }

  String get channelLabel {
    switch (channel) {
      case PaymentChannel.upi:
        return 'UPI';
      case PaymentChannel.card:
        return 'Card';
      case PaymentChannel.wallet:
        return 'Wallet';
      case PaymentChannel.netBanking:
        return 'Net Banking';
      case PaymentChannel.cod:
        return 'COD';
    }
  }

  String get statusLabel {
    switch (status) {
      case PaymentStatus.success:
        return 'Success';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}
