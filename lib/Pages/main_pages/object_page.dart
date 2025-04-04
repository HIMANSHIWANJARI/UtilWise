//create a page for an object.dart that consists of two screens in two separate tabs; namely Expenses and Services
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:utilwise/Pages/add_from_pages/add_from_object_page.dart';
import 'package:utilwise/Pages/main_pages/navigation_page.dart';
import 'package:utilwise/Pages/profile_pages/profile_page.dart';
import 'package:utilwise/screens/objects_screens/object_expense.dart';

import '../../components/expense.dart';
import '../../provider/data_provider.dart';
import 'no_internet_page.dart';

class ObjectPage extends StatefulWidget {
  final String creatorTuple;
  final String objectName;

  const ObjectPage(
      {Key? key, required this.objectName, required this.creatorTuple})
      : super(key: key);

  @override
  State<ObjectPage> createState() => _ObjectPageState();
}

class _ObjectPageState extends State<ObjectPage> {
  List<Expense> allExpenses = [];

  void handleDataRequest(dynamic requestedData) {
    if (requestedData != null) {
      allExpenses = requestedData;
    }
  }

  Future<void> convertAndShareCSV() async {
    // Convert expenses data to CSV format
    List<List<dynamic>> csvData = [
      // Add header row if needed
      ['Creator', 'Amount', 'Date', 'Is View Only', 'Description'],
      for (Expense expense in allExpenses)
        [
          expense.creator,
          expense.amount,
          expense.date,
          expense.isViewOnly,
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
    final providerCommunity = Provider.of<DataProvider>(context, listen: false);
    return StreamBuilder<bool>(
        stream: connectivityStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!) {
              return buildScaffold(providerCommunity);
            } else {
              return const NoInternetPage();
            }
          } else {
            return buildScaffold(providerCommunity);
          }
        });
  }

  buildScaffold(providerCommunity) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF56D0A0),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 30.0),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NavigationPage()),
            );
          },
        ),
        title: Row(
          children: <Widget>[
            Image.asset(
              '${providerCommunity.extractCommunityImagePathByName(widget.creatorTuple)}',
              width: 40,
              height: 40,
            ),
            SizedBox(width: 10),
            Flexible(
                child: Text(
              (widget.creatorTuple).split(":")[0],
              overflow: TextOverflow.ellipsis,
            )),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(1),
          ),
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                // padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.green.shade50,
                  // radius: kSpacingUnit.w * 10,
                  child: Text(
                    "${providerCommunity.user?.username[0]}",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ))
        ],
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: Container(
              margin: EdgeInsets.only(left: 90),
              child: Column(children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 13.0,
                      ),
                      child: Text(
                        '↳ ',
                        style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0, top: 3),
                      child: Image.asset(
                        '${providerCommunity.extractObjectImagePathByName(widget.objectName)}',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ' ${widget.objectName}',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                    ),
                    GestureDetector(
                        onTap: () {
                          if (allExpenses.isNotEmpty) {
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
              ]),
            )),
      ),
      body: DefaultTabController(
        length: 1,
        child: Builder(
            builder: (BuildContext tabContext) => Scaffold(
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(50.0),
                    child: AppBar(
                      elevation: 0,
                      backgroundColor: Color(0xFF56D0A0),
                      bottom: const TabBar(
                        tabs: [
                          Tab(
                            icon: Icon(Icons.currency_rupee_outlined),
                          ),
                        ],
                        indicatorColor: Colors.white,
                      ),
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      ObjectExpenseScreen(
                        objectName: widget.objectName,
                        communityName: widget.creatorTuple,
                        onDataRequested: handleDataRequest,
                      ),
                    ],
                  ),
                  bottomNavigationBar: BottomAppBar(
                    color: Colors.green.shade50,
                    elevation: 0,
                    shape: CircularNotchedRectangle(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, bottom: 8, top: 4),
                          child: FloatingActionButton(
                            backgroundColor: Color(0xFF56D0A0),
                            heroTag: "BTN-13",
                            onPressed: () {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            child: Icon(Icons.home),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: FloatingActionButton(
                            heroTag: "BTN-15",
                            backgroundColor: Color(0xFF56D0A0),
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddFromObjectPage(
                                      selectedPage: 0,
                                      creatorTuple: widget.creatorTuple,
                                      objectName: widget.objectName),
                                ),
                              );
                            },
                            child: Icon(Icons.add),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 8.0, bottom: 8, top: 4),
                          child: FloatingActionButton(
                            backgroundColor: Color(0xFF56D0A0),
                            heroTag: "BTN-16",
                            onPressed: () async {
                              DataProvider dataProvider =
                                  Provider.of<DataProvider>(context,
                                      listen: false);
                              const snackbar1 = SnackBar(
                                content: Text("Refreshing..."),
                                duration: Duration(seconds: 4),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackbar1);
                              await dataProvider.getObjectDetails(
                                  widget.creatorTuple, widget.objectName);
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                            },
                            child: Icon(Icons.sync),
                          ),
                        ),
                      ],
                    ),
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.endFloat,
                )),
      ),
    );
  }

  Stream<bool> get connectivityStream =>
      Connectivity().onConnectivityChanged.map((List<ConnectivityResult> result) {
        return result != ConnectivityResult.none;
      });
}