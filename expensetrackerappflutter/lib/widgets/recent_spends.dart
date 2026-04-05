import 'package:expensetrackerappflutter/entities/expense.dart';
import 'package:flutter/material.dart';

class recentSpendsCard extends StatelessWidget {
  final Expense expense;
  final String currency;

  const recentSpendsCard({super.key, required this.expense, required this.currency});

  @override
  Widget build(BuildContext context) {
    final _merchant = expense.merchant;
    final _amount = expense.amount;
    final _dateTime = expense.createdAt.toLocal();
    final _formattedDate =
        "${_dateTime.day}/${_dateTime.month}, ${_dateTime.hour}:${_dateTime.minute.toString().padLeft(2, '0')}";
    // final _currencySymbol = getCurrencySymbol(expense.currency);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(width: 0.3, color: Colors.grey.shade500),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$_merchant",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text("$_formattedDate", style: TextStyle(fontSize: 15)),
                ],
              ),
              Text("- $currency$_amount", style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  String getCurrencySymbol(String currency) {
    final c = currency.toLowerCase();

    if (c.contains('inr') || c.contains('rs') || c.contains('₹')) {
      return '₹';
    } else if (c.contains('usd') || c.contains('\$')) {
      return '\$';
    } else if (c.contains('eur') || c.contains('€')) {
      return '€';
    } else if (c.contains('gbp') || c.contains('£')) {
      return '£';
    }
    return '';
  }
}
