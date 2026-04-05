class Expense {
  final String merchant;
  final double amount;
  final DateTime createdAt;

  Expense({
    required this.merchant,
    required this.amount,
    required this.createdAt,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      merchant: map['merchant'],
      amount: map['amount'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}