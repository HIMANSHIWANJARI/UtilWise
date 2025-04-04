import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:utilwise/Models/recurring-expense.dart';

import '../../provider/data_provider.dart';

class RecurringExpensesScreen extends StatefulWidget {
  final String creatorTuple;

  RecurringExpensesScreen({
    Key? key,
    required this.creatorTuple,
  }) : super(key: key);

  @override
  _RecurringExpensesScreenState createState() =>
      _RecurringExpensesScreenState();
}

class _RecurringExpensesScreenState extends State<RecurringExpensesScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedFrequency = 'Daily';
  TextEditingController amountInvolved = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController description = TextEditingController();

  late Future<List<RecurringExpenseModel>> _expenses;
  List<RecurringExpenseModel> recurrExp = [];

  @override
  void initState() {
    super.initState();
    _expenses = Provider.of<DataProvider>(context, listen: false)
        .getRecurringExpenses(widget.creatorTuple);
  }

  Future<void> convertAndShareCSV() async {
    // Convert expenses data to CSV format
    List<List<dynamic>> csvData = [
      // Add header row if needed
      ['Creator', 'Amount', 'Date', 'Daily', 'Description'],
      for (RecurringExpenseModel expense in recurrExp)
        [
          expense.creatorName,
          expense.amount,
          expense.date,
          expense.frequency,
          expense.description
        ],
    ];

    String csv = const ListToCsvConverter().convert(csvData);

    // Get the directory for storing the CSV file
    Directory directory = await getTemporaryDirectory();
    File file = File('${directory.path}/data.csv');

    // Write the CSV data to the file
    await file.writeAsString(csv);

    // Share the CSV file
    Share.shareXFiles([XFile('${directory.path}/data.csv')], text: 'CSV file');

  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(100.0),
              child: AppBar(
                backgroundColor: Color(0xFF56D0A0),
                title: Text('Recurring Expenses'),
                bottom: const TabBar(
                  tabs: [
                    // Tab(icon: Icon(Icons.person_add),),
                    Tab(
                      icon: Icon(Icons.grid_view, color: Colors.white),
                    ),
                    Tab(
                      icon: Icon(Icons.currency_rupee_outlined,
                          color: Colors.white),
                    ),
                    // Tab(icon: Icon(Icons.home_repair_service),),
                  ],
                  indicatorColor: Colors.white,
                ),
              ),
            ),
            body: TabBarView(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "All Recurring Expenses",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                            onTap: () {
                              if (recurrExp.isNotEmpty) {
                                convertAndShareCSV();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('No expenses found'),
                                      duration: Duration(seconds: 3)),
                                );
                              }
                            },
                            child: Icon(Icons.file_download)),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: FutureBuilder<List<RecurringExpenseModel>>(
                        future: _expenses,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            List<RecurringExpenseModel>? expenses =
                                snapshot.data;
                            if (expenses != null && expenses.isNotEmpty) {
                              recurrExp = expenses;
                              return ListView.builder(
                                itemCount: expenses.length,
                                itemBuilder: (context, index) {
                                  RecurringExpenseModel expense =
                                      expenses[index];
                                  return Container(
                                    height: 60,
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 5.0,
                                          spreadRadius: 0.0,
                                          offset: Offset(0.0,
                                              0.0), // shadow direction: bottom right
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                expense.creatorName,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                expense.description.isNotEmpty
                                                    ? '${expense.frequency} - ${expense.description}'
                                                    : expense.frequency,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ]),
                                        Text(
                                          '₹${expense.amount}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Center(child: Text('No expenses found.'));
                            }
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 8.0, bottom: 8, top: 4),
                      child: FloatingActionButton(
                        backgroundColor: Color(0xFF56D0A0),
                        heroTag: "BTN-12",
                        onPressed: () {
                          Future.delayed(Duration.zero, () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RecurringExpensesScreen(
                                      creatorTuple: widget.creatorTuple)),
                            );
                          });
                        },
                        child: Icon(Icons.sync),
                      ),
                    ),
                  ],
                ),
                Form(
                    key: _formKey,
                    child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Add New',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              itemHeight: null,
                              value: _selectedFrequency,
                              onChanged: (value) {
                                setState(() {
                                  _selectedFrequency = value!;
                                });
                              },
                              items: [
                                'Daily',
                                'Weekly',
                                'Monthly',
                                'Yearly'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                icon: Icon(Icons.event_repeat),
                                labelText: 'Frequency',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              decoration: const InputDecoration(
                                icon: Icon(Icons.currency_rupee_outlined),
                                hintText: 'Amount',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              controller: amountInvolved,
                            ),
                            SizedBox(height: 10),
                            TextField(
                                controller: dateController,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.calendar_month_rounded),
                                  labelText: "Date",
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          DateTime today = DateTime.now();
                                          String formattedDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(today);
                                          dateController.text = formattedDate;
                                        },
                                        child: Text(
                                          'Today',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF3880f4)),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          DateTime yesterday = DateTime.now()
                                              .subtract(Duration(days: 1));
                                          String formattedDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(yesterday);
                                          dateController.text = formattedDate;
                                        },
                                        child: Text(
                                          'Yesterday',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF3880f4)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );

                                  if (pickedDate != null) {
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);

                                    setState(() {
                                      dateController.text =
                                          formattedDate.toString();
                                    });
                                  }
                                }),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                icon: Icon(Icons.edit),
                                hintText: 'Remark',
                              ),
                              controller: description,
                            ),
                            Container(
                                margin: const EdgeInsets.only(top: 20.0),
                                child: FloatingActionButton(
                                  backgroundColor: Color(0xFF56D0A0),
                                  heroTag: "BTN-20",
                                  // added checks for valid amount and date
                                  onPressed: () async {
                                    if (RegExp(r'[,.-]|\s')
                                            .hasMatch(amountInvolved.text) ||
                                        amountInvolved.text.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Amount should be valid'),
                                            duration: Duration(seconds: 3)),
                                      );
                                      return;
                                    }

                                    if (dateController.text.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Date cannot be empty'),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                      return;
                                    }
                                    int amount = int.parse(amountInvolved.text);
                                    if (amount > 100000000) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Amount is too high! Please check and try again!'),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                      return;
                                    }

                                    if (description.text.length > 15) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Description is too long! Try describing your expense in lesser characters!'),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                      return;
                                    }

                                    // CHANGED HERE

                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Adding Expenses'),
                                            duration: Duration(seconds: 8)));

                                    bool res = await Provider.of<DataProvider>(
                                            context,
                                            listen: false)
                                        .addRecurringExpense(
                                            widget.creatorTuple,
                                            int.parse(amountInvolved.text),
                                            description.text,
                                            dateController.text,
                                            _selectedFrequency);

                                    ScaffoldMessenger.of(context)
                                        .removeCurrentSnackBar();

                                    if (!res) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Error in Adding Expense'),
                                              duration: Duration(seconds: 1)));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text('Expense Added'),
                                              duration: Duration(seconds: 1)));
                                    }
                                  },
                                  child: const Icon(Icons.check),
                                )),
                          ],
                        )))),
              ],
            )));
  }
}
