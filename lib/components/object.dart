import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilwise/Pages/main_pages/object_page.dart';

import '../Pages/add_from_pages/add_from_object_page.dart';
import '../provider/data_provider.dart';
import 'community.dart';

class Object extends StatefulWidget {
  final String name;
  final String creatorTuple;

  const Object({Key? key, required this.name, required this.creatorTuple})
      : super(key: key);

  @override
  State<Object> createState() => _ObjectState();
}

class _ObjectState extends State<Object> {
  Future<bool> showDeleteDialog(BuildContext context) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content:
              Text('Are you sure you want to delete ${widget.name} object?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
    return confirmDelete ?? false;
  }

  Choice selectedOption = choices[0];

  handleSelect(Choice choice) async {
    if (choice.name == "Delete Object") {
      Future<bool> returnValue = showDeleteDialog(context);
      bool alertResponse = await returnValue;
      if (alertResponse == true) {
        if (await Provider.of<DataProvider>(context, listen: false)
                .isAdmin(widget.creatorTuple) ==
            true) {
          Provider.of<DataProvider>(context, listen: false)
              .deleteObject(widget.creatorTuple, widget.name);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are not an admin of this community'),
            ),
          );
          return;
        }
      } else {
        return;
      }
    }
  }

  Random random = Random();

  @override
  Widget build(BuildContext context) {
    final providerCommunity = Provider.of<DataProvider>(context, listen: false);
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(widget.name),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ObjectPage(
                                  objectName: widget.name,
                                  creatorTuple: widget.creatorTuple,
                                )));
                  },
                  child: const Text('See All Payments'),
                ),
              ],
            );
          },
        );
      },
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ObjectPage(
                      objectName: widget.name,
                      creatorTuple: widget.creatorTuple,
                    )));
      },
      child: Container(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 8.0), // Adjust top padding as needed
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipOval( // Ensures image is circular
                        child: Image.asset(
                          providerCommunity.extractObjectImagePathByName(widget.name),
                          fit: BoxFit.cover, // Ensures image covers the circle properly
                        ),
                      ),
                    ),
                  ),



                  Expanded(
                      child: Container(
                    child: Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 12,
                      ),

                      overflow: TextOverflow.visible,
                    ),
                  )),
                  if (widget.name != "Misc")
                    SizedBox(
                      width: 30, // Reduce the width
                      height: 30, // Reduce the height
                      child: PopupMenuButton<Choice>(
                        padding: EdgeInsets.zero, // Remove extra padding
                        itemBuilder: (BuildContext context) {
                          return choices.skip(0).map((Choice choice) {
                            return PopupMenuItem<Choice>(
                              value: choice,
                              child: Text(choice.name),
                            );
                          }).toList();
                        },
                        onSelected: handleSelect,
                        icon: Icon(Icons.more_vert, size: 18), // Make the icon smaller
                      ),
                    ),

                ]),

            Row(
              children: [
                Icon(Icons.person),
                Text(" = "),
                Text(
                  "₹ ${providerCommunity.myExpenseInObject(widget.creatorTuple, widget.name)}",
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.group),
                Text(" = "),
                Text(
                    "₹ ${providerCommunity.objectTotalExpense(widget.creatorTuple, widget.name)}",
                    style: TextStyle(color: Colors.blue)),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: const EdgeInsets.only(bottom: 5.0, right: 5.0),
                height: 30.0,
                width: 30.0,
                child: new FloatingActionButton(
                  heroTag: "${random.nextInt(1000000)}",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddFromObjectPage(
                              selectedPage: 0,
                              creatorTuple: widget.creatorTuple,
                              objectName: widget.name)),
                    );
                  },
                  backgroundColor: Color(0xFF56D0A0),
                  child: const Icon(Icons.add),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

const List<Choice> choices = <Choice>[Choice(name: 'Delete Object')];