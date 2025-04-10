import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilwise/Pages/edit_details_pages/edit_expense_page.dart';
import 'package:utilwise/provider/data_provider.dart';

class Expense extends StatefulWidget {
  final String creator;
  final String description;
  final int amount;
  final String date;
  final bool isPaid;
  final String objectName;
  final String creatorTuple;
  final String category;
  final bool isViewOnly;
  final String type;

  const Expense(
      {Key? key,
      required this.objectName,
      required this.creator,
      required this.description,
      required this.amount,
      required this.date,
      required this.isPaid,
      required this.creatorTuple,
      required this.isViewOnly,
      required this.category,
      required this.type
      })
      : super(key: key);

  @override
  State<Expense> createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  late bool isCreator;

  @override
  void initState() {
    super.initState();
    isCreator = Provider.of<DataProvider>(context, listen: false)
        .isExpenseCreator(widget.creator);
  }

  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: widget.isPaid ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5.0,
            spreadRadius: 0.0,
            offset: Offset(0.0, 0.0), // shadow direction: bottom right
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              widget.creator,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.category,
              
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.description,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ]),
          Text(
            '₹${widget.amount}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!widget.isPaid)
            GestureDetector(
              onTap: () {
                // if the expense is view-only and the user is not the creator
                // then show a snackbar and return
                if (widget.isViewOnly && !isCreator) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'This expense is view-only and cannot be edited'),
                    ),
                  );
                  return;
                }

                Expense expense = Expense(
                  creator: widget.creator,
                  description: widget.description,
                  amount: widget.amount,
                  date: widget.date.substring(0, 10),
                  isPaid: false,
                  objectName: widget.objectName,
                  creatorTuple: widget.creatorTuple,
                  isViewOnly: widget.isViewOnly,
                  category: widget.category,
                  type: widget.type,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditExpensePage(expense: expense),
                  ),
                );
              },
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.edit,
                      color: Color(0xFF56D0A0),
                      size: 25,
                    ),
                    Text(
                      widget.date.substring(0, 10),
                      style: const TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ]),
              //const Icon(Icons.edit, color: Color(0xFF56D0A0), size: 35,),
            )
        ],
      ),
    );
  }
}
