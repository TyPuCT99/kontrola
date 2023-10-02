class Transaction {
  final String type;
  final double amount;
  final String category;
  final String comment;
  final String currency;
  final DateTime date;

  Transaction({
    required this.type,
    required this.amount,
    required this.category,
    required this.comment,
    required this.currency,
    required this.date,
  });
}
