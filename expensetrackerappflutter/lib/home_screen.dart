import 'dart:convert';

import 'package:expensetrackerappflutter/config/app_config.dart';
import 'package:expensetrackerappflutter/config/constants.dart';
import 'package:expensetrackerappflutter/entities/expense.dart';
import 'package:expensetrackerappflutter/form_dialog.dart';
import 'package:expensetrackerappflutter/login_screen.dart';
import 'package:expensetrackerappflutter/profile_screen.dart';
import 'package:expensetrackerappflutter/services/permission_service.dart';
import 'package:expensetrackerappflutter/services/sms_service.dart';
import 'package:expensetrackerappflutter/widgets/expense_card.dart';
import 'package:expensetrackerappflutter/widgets/expense_filter.dart';
import 'package:expensetrackerappflutter/widgets/recent_spends.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BASE_URL = AppConfig.baseUrl;
  final List<Expense> _expenses = [];
  ExpenseFilter _activeFilter = const ExpenseFilter(type: ExpenseFilterType.all);
  List<Expense> _filteredExpenses = [];
  final storage = FlutterSecureStorage();
  String _topMerchant = "None";
  String _amountLimit = "0.0";
  String _amountSpent = "0.0";
  String _currency = "₹";
  final ScrollController _scrollController = ScrollController();
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showFab) {
          setState(() => _showFab = false);
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showFab) {
          setState(() => _showFab = true);
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  void init() async {
    await getExpenses();
    await getExpenseInfo();
    getSMS();
  }

  void _applyFilter() {
    final filtered = _expenses
        .where((e) => _activeFilter.includes(e.createdAt))
        .toList();

    setState(() {
      _filteredExpenses = filtered;
      _topMerchant = getTopMerchant(filtered);
      _amountSpent = getAmountSpent(filtered);
    });
  }

  void _onFilterChanged(ExpenseFilter newFilter) {
    setState(() {
      _activeFilter = newFilter;
    });
    _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Expense Tracker",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple.shade900,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen()),
                ).then((_) async {
                  setState(() {
                    getExpenseInfo();
                  });
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage("https://picsum.photos/200"),
                  radius: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            ExpenseCard(
              progress: getProgress(),
              total: _amountLimit,
              spent: _amountSpent,
              merchant: _topMerchant,
              status: getStatus(),
              currency: _currency,
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Recent Spends",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                if (_expenses.isNotEmpty)
                  ExpenseFilterDropdown(
                    currentFilter: _activeFilter,
                    onFilterChanged: _onFilterChanged,
                  ),
              ],
            ),
            SizedBox(height: 15),
            Expanded(child: getRecentExpensesCard()),
          ],
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: Duration(milliseconds: 300),
        offset: _showFab ? Offset(0, 0) : Offset(0, 2),
        child: FloatingActionButton(
          shape: CircleBorder(),
          elevation: 5,
          backgroundColor: Colors.purple.shade900,
          foregroundColor: Colors.white,
          onPressed: () async {
            final result = await showDialog<Map<String, String?>>(
              context: context,
              builder: (_) => const ExpenseFormDialog(),
            );
            if (result != null) {
              await addExpenses(result);
              await getExpenses();
            }
          },
          child: Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget getRecentExpensesCard() {
    if (_filteredExpenses.isEmpty) {
      return Center(child: Text("No record found"));
    }

    return ListView(
      controller: _scrollController,
      children: _filteredExpenses.map((e) {
        return recentSpendsCard(expense: e, currency: _currency);
      }).toList(),
    );
  }

  Future<void> getExpenses() async {
    String? accessToken = await storage.read(key: "accessToken");
    String? userId = await storage.read(key: "userId");

    final response = await http.get(
      Uri.parse("$BASE_URL/expense/v1/getExpense?user_id=$userId"),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      final List<Expense> loadedExpenses = [];
      for (var e in data) {
        loadedExpenses.add(Expense.fromMap(e as Map<String, dynamic>));
      }
      loadedExpenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _expenses.clear();
        _expenses.addAll(loadedExpenses);
      });
      _applyFilter();
    }
  }

  String getAmountSpent(List<Expense> loadedExpenses) {
    double amount = 0;
    for (var e in loadedExpenses) {
      amount += e.amount;
    }
    return amount.toString();
  }

  String getTopMerchant(List<Expense> loadedExpenses) {
    final Map<String, int> merchantCount = {};
    final Map<String, double> merchantAmount = {};
    for (var e in loadedExpenses) {
      merchantCount[e.merchant] = (merchantCount[e.merchant] ?? 0) + 1;
      merchantAmount[e.merchant] = (merchantAmount[e.merchant] ?? 0) + e.amount;
    }
    String topMerchant = "None";
    if (merchantCount.isNotEmpty) {
      final topCountEntry = merchantCount.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      if (topCountEntry.value > 1) {
        final topCountMerchant = topCountEntry.key;
        final topCountAmount = merchantAmount[topCountMerchant] ?? 0;
        bool isValid = merchantAmount.entries.every(
          (entry) =>
              entry.key == topCountMerchant || topCountAmount >= entry.value,
        );
        if (isValid) {
          return topCountMerchant;
        }
      }
      final topAmountEntry = merchantAmount.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      topMerchant = topAmountEntry.key;
    }
    return topMerchant;
  }

  Future<void> addExpenses(Map<String, String?> data) async {
    String? accessToken = await storage.read(key: "accessToken");

    final response = await http.post(
      Uri.parse("$BASE_URL/expense/v1/addExpense"),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        "amount": data['amount'],
        "merchant": data['merchant'],
        "created_at": data['date'],
      }),
    );
    if (response.statusCode == 200) {
      print("addExpenses response: ${response.body}");
    } else if (response.statusCode == 401) {
      bool refreshed = await getRefreshToken();
      if (refreshed) {
        return await addExpenses(data);
      } else {
        logoutUser();
      }
    }
  }

  void logoutUser() async {
    await storage.deleteAll();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  Future<bool> getRefreshToken() async {
    String? refreshToken = await storage.read(key: "refreshToken");
    if (refreshToken == null) {
      print("getRefreshToken: No refresh token found");
      return false;
    }
    final response = await http.post(
      Uri.parse("$BASE_URL/auth/v1/refreshToken"),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
      body: jsonEncode({"token": refreshToken}),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      await storage.write(key: "refreshToken", value: data['token']);
      await storage.write(key: "accessToken", value: data['accessToken']);
      await storage.write(key: "userId", value: data['userId']);

      return true;
    }
    return false;
  }

  double getProgress() {
    double spent = double.tryParse(_amountSpent) ?? 0.0;
    double limit = double.tryParse(_amountLimit) ?? 0.0;

    double progress = limit == 0 ? 0 : spent / limit;

    return progress;
  }

  String getStatus() {
    if (_amountLimit == '0.0') return "";
    final progress = getProgress();

    if (progress >= 1.0) {
      return "OverSpending";
    } else if (progress < 0.7) {
      return "Safe";
    }
    return "At Risk";
  }

  Future<void> getExpenseInfo() async {
    String? accessToken = await storage.read(key: "accessToken");

    final response = await http.get(
      Uri.parse("$BASE_URL/expense/v1/getExpenseInfo"),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final symbol = getCurrencySymbol(data['currency']);
      setState(() {
        _amountLimit = (data['amount_limit']).toString();
        _currency = symbol;
      });
    }
  }

  Future<void> getSMS() async {
    final permitted = await requestSmsPermission();
    if (!permitted) {
      print("getSMS: Permission denied!!");
      return;
    }
    try {
      List<SmsMessage> messages = await readSMS();
      await Future.wait(messages.map((msg) => setMessage(msg)));
      await getExpenses();
    } catch (e) {
      print("getSMS error: $e");
    }
  }

  Future<void> setMessage(var message) async {
    String? accessToken = await storage.read(key: "accessToken");

    final response = await http.post(
      Uri.parse("$BASE_URL/ds/v1/message"),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        "message": message.body,
        "datetime": message.date!.toUtc().toIso8601String(),
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("setMessage: $data");
    } else {
      print(response.statusCode);
    }
  }
}