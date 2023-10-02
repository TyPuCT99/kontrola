import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Transaction> transactions = [];
  final TextEditingController amountController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  String selectedType = 'income';
  String selectedCategory = 'Oplaty komunikacyjne';
  String selectedCurrency = 'Dollar';

  static const double zlotyConversion = 1;
  static const double dollarConversion = 4.1;
  static const double euroConversion = 4.5;
  static const double hryvniaConversion = 0.15;

  double convertToZloty(double amount, String currency) {
    switch (currency) {
      case 'Dollar':
        return amount * dollarConversion;
      case 'Euro':
        return amount * euroConversion;
      case 'Hryvnia':
        return amount * hryvniaConversion;
      default:
        return amount;
    }
  }

  double convertToSelectedCurrency(double amount) {
    switch (selectedCurrency) {
      case 'Dollar':
        return amount / dollarConversion;
      case 'Euro':
        return amount / euroConversion;
      case 'Hryvnia':
        return amount / hryvniaConversion;
      default:
        return amount;
    }
  }

  List<PieChartSectionData> getPieSections() {
    double income = transactions
        .where((transaction) => transaction.type == 'income')
        .fold(
            0,
            (sum, transaction) =>
                sum + convertToZloty(transaction.amount, transaction.currency));

    double expense = transactions
        .where((transaction) => transaction.type == 'expense')
        .fold(
            0,
            (sum, transaction) =>
                sum + convertToZloty(transaction.amount, transaction.currency));

    return [
      PieChartSectionData(
        color: Colors.green,
        value: convertToSelectedCurrency(income),
        title: 'Dochód',
        radius: 80,
        titleStyle: TextStyle(color: Colors.white, fontSize: 14),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: convertToSelectedCurrency(expense),
        title: 'Wydatki',
        radius: 80,
        titleStyle: TextStyle(color: Colors.white, fontSize: 14),
      ),
    ];
  }

  double getBalance() {
    double income = transactions
        .where((transaction) => transaction.type == 'income')
        .fold(
            0,
            (sum, transaction) =>
                sum + convertToZloty(transaction.amount, transaction.currency));

    double expense = transactions
        .where((transaction) => transaction.type == 'expense')
        .fold(
            0,
            (sum, transaction) =>
                sum + convertToZloty(transaction.amount, transaction.currency));

    double balance =
        convertToSelectedCurrency(income) - convertToSelectedCurrency(expense);

    return balance;
  }

  void addTransaction() {
    double amount = double.parse(amountController.text);
    String comment = commentController.text;

    setState(() {
      transactions.add(Transaction(
        type: selectedType,
        amount: amount,
        category: selectedCategory,
        comment: comment,
        currency: selectedCurrency,
        date: DateTime.now(),
      ));

      amountController.clear();
      commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zarządzanie finansami'),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.5,
            child: Card(
              elevation: 6,
              margin: const EdgeInsets.all(8),
              color: const Color(0xff020227),
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: getPieSections(),
                ),
              ),
            ),
          ),
          Text(
            'Bieżący stan: ${getBalance().toStringAsFixed(2)} ${selectedCurrency}',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<String>(
                value: selectedType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue!;
                  });
                },
                items: ['income', 'expense']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'income' ? 'Dochód' : 'Wydatki'),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                value: selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                items: [
                  'Oplaty komunikacyjne',
                  'Jedzenie',
                  'Samochód',
                  'Rozrywka',
                  'Inne'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                value: selectedCurrency,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCurrency = newValue!;
                  });
                },
                items: ['Dollar', 'Zloty', 'Euro', 'Hryvnia']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Kwota'),
          ),
          TextField(
            controller: commentController,
            decoration: InputDecoration(labelText: 'Komentarz'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: addTransaction,
            child: Text('Dodaj transakcję'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      '${convertToSelectedCurrency(transactions[index].amount).toStringAsFixed(2)} ${selectedCurrency}'),
                  subtitle: Text(
                      '${transactions[index].category} - ${transactions[index].comment}'),
                  trailing: Text('${transactions[index].date.toString()}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
