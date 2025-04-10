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
  TextEditingController type = TextEditingController();
  String expenseType = 'Personal';

  TextEditingController amountInvolved = TextEditingController();
  TextEditingController description = TextEditingController();
  List<Map<String, dynamic>> memberSplits = [];

  String newMemberPhone = '';
  String newMemberPercent = '';

  // for checkbox state, defaults to false
  bool isViewOnly = false;

  List<String> availableMembers = [
  '9923456781',
  '9876543210',
  '9812547376',
];

  void _openMemberSplitDialog() async {
  final updatedSplits = await showDialog<List<Map<String, dynamic>>>(
    context: context,
    builder: (context) {
      List<Map<String, dynamic>> tempSplits = List.from(memberSplits);
      String? selectedMember;
      String newPercent = '';

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add Member Splits'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedMember,
                          hint: Text("Select Member"),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: availableMembers.map((member) {
                            return DropdownMenuItem<String>(
                              value: member,
                              child: Text(member),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedMember = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          decoration: InputDecoration(hintText: '%'),
                          keyboardType: TextInputType.number,
                          onChanged: (val) => newPercent = val,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          if (selectedMember != null &&
                              double.tryParse(newPercent) != null) {
                            setState(() {
                              tempSplits.add({
                                'name': selectedMember!,
                                'percent': double.parse(newPercent),
                              });
                              selectedMember = null;
                              newPercent = '';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Divider(),
                  ...tempSplits.map((entry) => ListTile(
                        title: Text(entry['name']),
                        trailing: Text('${entry['percent']}%'),
                      )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  double total = tempSplits.fold(
                      0.0, (sum, item) => sum + item['percent']);
                  if (total > 100.0) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Total percentage exceeds 100%!'),
                      backgroundColor: Colors.red,
                    ));
                    return;
                  }

                  Navigator.pop(context, tempSplits); // return data to screen
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );

  if (updatedSplits != null) {
    setState(() {
      memberSplits = updatedSplits;
    });
  }
}


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
                          selectedSubCategory = null; // Reset selected sub-category
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
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    ),
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
    DropdownButtonFormField<String>(
    decoration: InputDecoration(
      icon: Icon(Icons.people_outline),
      hintText: 'Expense Type',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
    ),
    value: expenseType,
    items: ['Sharable', 'Personal'].map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          expenseType = newValue!;
          type.text = newValue!;
      });
    },
    ),
                  SizedBox(
                    height: 12,
                  ),
                  if( expenseType == 'Sharable' )
                      ElevatedButton(
                      onPressed: _openMemberSplitDialog,
                      style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFF56D0A0),
                      elevation: 4,
                      ),
                      child: Text("Add Member Split"),),

                  

if (expenseType=="Sharable" && memberSplits.isNotEmpty) ...[
  const SizedBox(height: 20),
  const Text(
    'Expense Split:',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  Column(
    children: memberSplits.map((entry) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(entry['name'], style: TextStyle(fontSize: 16)),
          Text('${entry['percent']}%', style: TextStyle(fontSize: 16)),
        ],
      );
    }).toList(),
  ),
],
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
                              categoryName.text,
                              expenseType,
                              );

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
