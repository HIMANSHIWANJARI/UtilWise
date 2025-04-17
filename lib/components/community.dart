import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/data_provider.dart';
import '../Pages/add_from_pages/add_from_community_page.dart';

class Community extends StatefulWidget {
  final String creatorTuple;

  const Community({Key? key, required this.creatorTuple}) : super(key: key);

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  Future<bool> showDeleteDialog(BuildContext context) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete ${(widget.creatorTuple).split(":")[0]} community?'),
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

  void updateCommunityDialog(BuildContext context) async {
    final providerCommunity = Provider.of<DataProvider>(context, listen: false);
    TextEditingController controller =
        TextEditingController(text: (widget.creatorTuple).split(":")[0]);

    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Community'),
          content: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Community Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                      content: Text('Updating community...'),
                      duration: Duration(seconds: 2)),
                );

                await providerCommunity.updateCommunity(
                    (widget.creatorTuple).split(":")[0],
                    (widget.creatorTuple).split(":")[1],
                    controller.text);
                Navigator.pop(context, true);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Choice selectedOption = choices[0];

  handleSelect(Choice choice) async {
    if (choice.name == "Delete Community") {
      Future<bool> returnValue = showDeleteDialog(context);
      bool alertResponse = await returnValue;
      if (alertResponse == true) {
        if (await Provider.of<DataProvider>(context, listen: false)
                .isAdmin(widget.creatorTuple) ==
            true) {
          Provider.of<DataProvider>(context, listen: false)
              .deleteCommunity(widget.creatorTuple);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Only creators have delete power! Become a creator to delete this community!'),
            ),
          );
          return;
        }
      } else {
        return;
      }
    } else if (choice.name == "Edit Community") {
      updateCommunityDialog(context);
    }
  }

  bool clicked = false;

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
                title: Text((widget.creatorTuple).split(":")[0]),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddFromCommunityPage(
                                  selectedPage: 0,
                                  creatorTuple: widget.creatorTuple,
                                )),
                      );
                    },
                    child: Text('Payments'),
                  ),
                ],
              );
            },
          );
        },
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Flexible(
                        child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 1.0,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          '${providerCommunity.extractCommunityImagePathByName(widget.creatorTuple)}',
                          fit: BoxFit.cover,
                        ),),
                    )),
                    
                    Expanded(
                        flex : 4,
                        child: Container(
                          width : 400,
                          child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (widget.creatorTuple).split(":")[0],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Icon(Icons.person_pin_circle_outlined, size: 14,),
                        //     Flexible(
                        //       child:
                        //         Text(
                        //           providerCommunity.communityMembersMap[widget.creatorTuple]!.isEmpty || providerCommunity.communityMembersMap[widget.creatorTuple] == null? "Creator" :
                        //           providerCommunity.communityMembersMap[widget.creatorTuple]!.firstWhere((member) => member.phone == (widget.creatorTuple).split(":")[1], orElse: () => providerCommunity.communityMembersMap[widget.creatorTuple]!.firstWhere((member) => member.isCreator == true)).name,
                        //           style: const TextStyle(
                        //             color: Colors.black,
                        //             fontSize: 10,
                        //           ),
                        //           overflow: TextOverflow.ellipsis,
                        //         ),
                        //     )
                        //   ],
                        // )
                      Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // First Row
                        Row(
                          children: <Widget>[
                            // Widgets for the first row
                            Icon(
                              Icons.person,
                            ),
                            Text(
                              ' = ',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "₹ ${providerCommunity.myExpenseInCommunity(widget.creatorTuple)}",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(
                          width: 10,
                        ),
                        // Second Row
                        Row(
                          children: <Widget>[
                            // Widgets for the second row
                            Icon(
                              Icons.group,
                            ),
                            Text(
                              ' = ',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "₹ ${providerCommunity.communityTotalExpense(widget.creatorTuple)}",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ],
                    ))),
                    
                    Row(children: [
                      // PopupMenuButton<Choice>(
                      //   itemBuilder: (BuildContext context) {
                      //     return choices.skip(0).map((Choice choice) {
                      //       return PopupMenuItem <Choice>(
                      //         value: choice,
                      //         child: Text(choice.name),
                      //
                      //       );
                      //     }).toList();
                      //
                      //   },
                      //   onSelected: handleSelect,
                      // ),

                      Container(
                        margin: const EdgeInsets.only(bottom: 1.0),
                        height: 20.0,
                        width: 20.0,
                        child: new FloatingActionButton(
                          heroTag: "${random.nextInt(1000000)}",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddFromCommunityPage(
                                        selectedPage: 0,
                                        creatorTuple: widget.creatorTuple,
                                      )),
                            );
                          },
                          backgroundColor: Color(0xFF56D0A0),
                          child: FittedBox(
                            child: const Icon(
                              Icons.add,
                            ),
                          ),
                        ),
                      ),
                      // ),
                      PopupMenuButton<Choice>(
                          itemBuilder: (BuildContext context) {
                            return choices.skip(0).map((Choice choice) {
                              return PopupMenuItem<Choice>(
                                value: choice,
                                child: Text(choice.name),
                              );
                            }).toList();
                          },
                          onSelected: handleSelect
                          // color: Colors.black,
                          ),
                    ])
                  ]),
            ],
          ),
        ));
  }
}

class Choice {
  final String name;

  const Choice({required this.name});
}

const List<Choice> choices = <Choice>[
  Choice(name: 'Delete Community'),
  Choice(name: 'Edit Community'),
];
