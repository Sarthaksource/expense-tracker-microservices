import 'package:flutter/material.dart';

class ExpenseCard extends StatelessWidget {
  final double progress;
  final String total;
  final String spent;
  final String merchant;
  final String status;
  final String currency;

  const ExpenseCard({
    super.key,
    required this.progress,
    required this.total,
    required this.spent,
    required this.merchant,
    required this.status,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        padding: EdgeInsets.all(30),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: Duration(milliseconds: 800),
                    builder: (context, value, _) {
                      return CircularProgressIndicator(
                        strokeCap: StrokeCap.round,
                        value: value,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.purple.shade900,
                        ),
                      );
                    },
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "$currency$spent",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Spent", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1),),
                  ],
                ),
              ],
            ),
            SizedBox(width: 30),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Status: ",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      children: [
                        TextSpan(
                          text: status,
                          style: TextStyle(
                            color: getStatusColor(status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Amount limit: $currency$total', softWrap: true),
                  SizedBox(height: 8),
                  Text("Top merchant: $merchant", softWrap: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    if (status == "OverSpending") {
      return Colors.red;
    } else if (status == "Safe") {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }
}
