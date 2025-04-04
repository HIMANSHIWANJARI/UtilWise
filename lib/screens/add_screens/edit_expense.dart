// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:utilwise/components/expense.dart';

import '../../provider/data_provider.dart';

class EditExpenseScreen extends StatefulWidget {
  const EditExpenseScreen(
      {Key? key,
      required this.isFromCommunityPage,
      required this.isFromObjectPage,
      required this.expense})
      : super(key: key);
  final bool isFromCommunityPage;
  final bool isFromObjectPage;
  final Expense expense;

  @override
  State<EditExpenseScreen> createState() => ExpenseData();
}

class ExpenseData extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  String communityDropDown = '';
  String objectDropDown = '';
  late int amount;
  TextEditingController amountInvolved = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController dateController = TextEditingController();

  // for checkbox state, defaults to false
  bool isViewOnly = false;

  late bool isCreator;

  @override
  void initState() {
    super.initState();
    description.text = '${widget.expense.description}';
    amountInvolved.text = '${widget.expense.amount}';
    dateController.text = '${widget.expense.date}';
    isViewOnly = widget.expense.isViewOnly;
    isCreator = Provider.of<DataProvider>(context, listen: false)
        .isExpenseCreator(widget.expense.creator);
  }

  Widget build(BuildContext context) {
    final providerCommunity = Provider.of<DataProvider>(context, listen: true);

    return Form(
        key: _formKey,
        child: Container(
            padding: const EdgeInsets.all(16.0),
            // child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Edit Expense',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.currency_rupee_outlined),
                      hintText: 'amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    controller: amountInvolved,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Add Checkbox widget here
                  // Only show the checkbox if the user is the creator of the expense
                  // only creators can set the expense as view-only
                  if (isCreator)
                    CheckboxListTile(
                      title: Text('Set as view-only'),
                      value: isViewOnly,
                      onChanged: (bool? value) {
                        setState(() {
                          isViewOnly = value ?? false;
                        });
                      },
                    ),
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
                                    DateFormat('yyyy-MM-dd').format(today);
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
                                DateTime yesterday =
                                    DateTime.now().subtract(Duration(days: 1));
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd').format(yesterday);
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
                              DateFormat('yyyy-MM-dd').format(pickedDate);

                          setState(() {
                            dateController.text = formattedDate.toString();
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
                        heroTag: "BTN-22",
                        // added checks for empty fields
                        onPressed: () async {
                          if (RegExp(r'[,.-]').hasMatch(amountInvolved.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Amount should be valid'),
                                  duration: Duration(seconds: 3)),
                            );
                            return;
                          }

                          if (dateController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Date cannot be empty'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }

                          // CHANGED HERE
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Editing Expenses'),
                                  duration: Duration(seconds: 8)));

                          bool res = await providerCommunity.updateExpense(
                              widget.expense,
                              amountInvolved.text,
                              dateController.text,
                              description.text,
                              isViewOnly);
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();

                          if (!res) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Error in Editing Expense'),
                                    duration: Duration(seconds: 1)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Expense Edited'),
                                    duration: Duration(seconds: 1)));
                          }

                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.check),
                      )),
                ],
              ),
              // )
            )));
  }
}

// creator name: providerCommunity.user?.name as String
