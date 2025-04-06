// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../provider/data_provider.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen(
      {Key? key,
      required this.isFromCommunityPage,
      required this.isFromObjectPage,
      required this.creatorTuple,
      required this.objectName})
      : super(key: key);
  final bool isFromCommunityPage;
  final bool isFromObjectPage;
  final String creatorTuple;
  final String objectName;

  @override
  State<ExpenseScreen> createState() => ExpenseData();
}

class ExpenseData extends State<ExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();

  String? selectedSubCategory;  // Stores selected sub-category
  final TextEditingController categoryName = TextEditingController();
  final Map<String, List<String>> categoryData = {
    'Education': ['Fee', 'Uniform', 'Stationary','Others'],
    'Shopping': ['Cosmetics', 'Wearables', 'Gadgets','Others'],
    'Entertainment': ['Movies', 'Games', 'Concerts','Others'],
    'House': ['Rent', 'Bills', 'Maintainance','Others'],
    'Vehicle' : ['Fuel', 'Repair', 'Insurance','Others'],
    'Health': ['Medicines', 'Checkup', 'Insurance','Others'],
    'Food': ['Groceries', 'Dining', 'Snacks','Others'],
    'Gifts': ['Birthday', 'Anniversary', 'Festival','Others'],
    'Travel': ['Tickets', 'Stay', 'Food','Others'],
    'Other': ['Miscellaneous'],
  };

  // DateTime expenseDate=

  String communityDropDown = '';
  String objectDropDown = '';
  late int amount;
  TextEditingController amountInvolved = TextEditingController();
  TextEditingController description = TextEditingController();

  // for checkbox state, defaults to false
  bool isViewOnly = false;

  @override
  void initState() {
    super.initState();
    dateController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    final providerCommunity = Provider.of<DataProvider>(context, listen: true);

    if (providerCommunity.communities.isEmpty) {
      return Container(
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 150),
          child: Text(
            "Hey there! Double-swipe left to add your first community! Then come back here to add an expense!",
            style: TextStyle(fontSize: 30),
          ));
    }

    if (widget.isFromCommunityPage || widget.isFromObjectPage) {
      communityDropDown = widget.creatorTuple;
    } else {
      communityDropDown =
          providerCommunity.communities[providerCommunity.communitiesIndex];
    }

    if (providerCommunity.objectIndex >=
        providerCommunity.communityObjectMap[communityDropDown]!.length) {
      providerCommunity.objectIndex = 0;
    }

    if (widget.isFromObjectPage) {
      objectDropDown = widget.objectName;
    } else if (providerCommunity
        .communityObjectMap[communityDropDown]!.isNotEmpty) {
      objectDropDown = providerCommunity.communityObjectMap[communityDropDown]![
          providerCommunity.objectIndex];
    } else {
      return Container(
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 150),
          child: Text(
            "Hey there! Swipe left to add your first object! Then come back here to add an expense!",
            style: TextStyle(fontSize: 30),
          ));
    }

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
                    'Add Expense',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (!widget.isFromCommunityPage && !widget.isFromObjectPage)
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      itemHeight: null,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.home_work),
                        hintText: 'Community',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      value: communityDropDown,
                      items: providerCommunity.communities
                          .map<DropdownMenuItem<String>>((String chosenValue) {
                        return DropdownMenuItem<String>(
                          value: chosenValue,
                          child: Text((chosenValue).split(":")[0] +
                              " - " +
                              providerCommunity
                                  .communityMembersMap[chosenValue]!
                                  .firstWhere(
                                      (member) =>
                                          member.phone ==
                                          (chosenValue).split(":")[1],
                                      orElse: () => providerCommunity
                                          .communityMembersMap[chosenValue]!
                                          .firstWhere((member) =>
                                              member.isCreator == true))
                                  .name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          communityDropDown = newValue!;
                          // objectDropDown=providerCommunity.communityObjectMap[communityDropDown]![0];
                          providerCommunity.objectIndex = 0;
                          providerCommunity.communityListen(communityDropDown);
                        });
                      },
                    ),
                  SizedBox(
                    height: 10,
                  ),
                  if (!widget.isFromObjectPage)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.grid_view),
                        hintText: 'Object',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      value: objectDropDown,
                      items: providerCommunity
                          .communityObjectMap[communityDropDown]
                          ?.map<DropdownMenuItem<String>>((String chosenValue) {
                        return DropdownMenuItem<String>(
                          value: chosenValue,
                          child: Text(chosenValue),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          objectDropDown = newValue!;
                        });
                        providerCommunity.objectListen(
                            communityDropDown, objectDropDown);
                      },
                    ),
                  SizedBox(
                    height: 10,
                  ),
              
              DropdownButtonFormField<String>(
  decoration: const InputDecoration(
    icon: Icon(Icons.category),
    border: OutlineInputBorder(),
    hintText: 'Select Category',
  ),
  value: selectedSubCategory,
  items: (objectDropDown != null && categoryData[objectDropDown]?.isNotEmpty == true)
      ? categoryData[objectDropDown]!
          .map((String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ))
          .toList()
      : [
          const DropdownMenuItem<String>(
            value: 'None',
            child: Text('None'),
          )
        ],
  onChanged: (String? newValue) {
    setState(() {
      selectedSubCategory = newValue;
      categoryName.text = newValue!; // Update the controller
    });
  },
),

            SizedBox(height : 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.currency_rupee_outlined),
                      hintText: 'Amount',
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
                  // Add Checkbox widget
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
                        heroTag: "BTN-20",
                        // added checks for valid amount and date
                        onPressed: () async {
                          if (RegExp(r'[,.-]|\s')
                                  .hasMatch(amountInvolved.text) ||
                              amountInvolved.text.isEmpty) {
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
                          int amount = int.parse(amountInvolved.text);
                          if (amount > 100000000) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Amount is too high! Please check and try again!'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }

                          if (description.text.length > 15) {
                            ScaffoldMessenger.of(context).showSnackBar(
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

                          bool res = await providerCommunity.addExpense(
                              objectDropDown,
                              providerCommunity.user!.name,
                              int.parse(amountInvolved.text),
                              dateController.text,
                              description.text,
                              communityDropDown,
                              isViewOnly,
                              categoryName.text);

                          ScaffoldMessenger.of(context).removeCurrentSnackBar();

                          if (!res) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Error in Adding Expense'),
                                    duration: Duration(seconds: 1)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Expense Added'),
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
