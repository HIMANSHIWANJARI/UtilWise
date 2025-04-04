import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:utilwise/Models/community.dart';
import 'package:utilwise/components/chart.dart';
import 'package:utilwise/components/chart2.dart';
import 'package:utilwise/components/expense.dart';
import 'package:utilwise/components/spending-summary-2.dart';
import 'package:utilwise/components/spendingSummary.dart';
import 'package:utilwise/database/db_user.dart';
import 'package:utilwise/provider/data_provider.dart';

class ProfileAnalytics extends StatefulWidget {
  final String? currentUserPhoneNumber;
  final String? currentUserName;

  ProfileAnalytics(
      {required this.currentUserPhoneNumber, required this.currentUserName});

  @override
  _ProfileAnalyticsState createState() => _ProfileAnalyticsState();
}

class _ProfileAnalyticsState extends State<ProfileAnalytics> {
  DateTimeRange? selectedDates;

  void exportData({bool myData = true}) async {
    List<CommunityModel>? myCommunities =
        await UserDataBaseService.getCommunities(
            widget.currentUserPhoneNumber!);

    if (myCommunities == null || myCommunities.isEmpty) {
      return;
    }

    List<List<dynamic>> csvData = [
      [
        'Community Name',
        'Object Name',
        'Creator',
        'Amount',
        'Date',
        'isViewOnly',
        'Description'
      ],
    ];

    myCommunities.forEach((community) {
      String creatorTuple = "${community.name}:${community.phoneNo}";

      Map<String, List<Expense>>? objectsInCommunity =
          Provider.of<DataProvider>(context, listen: false)
              .objectUnresolvedExpenseMap[creatorTuple];

      if (objectsInCommunity == null || objectsInCommunity.isEmpty) {
        return;
      }

      objectsInCommunity.forEach((objectName, expenses) {
        expenses.forEach((expense) {
          if (myData && widget.currentUserName != expense.creator) {
            return;
          }

          csvData.add([
            community.name,
            objectName,
            expense.creator,
            expense.amount,
            expense.date,
            expense.isViewOnly,
            expense.description
          ]);
        });
      });
    });

    String csv = const ListToCsvConverter().convert(csvData);

    Directory directory = await getTemporaryDirectory();
    File file = File('${directory.path}/data.csv');

    await file.writeAsString(csv);

    Share.shareXFiles([XFile('${directory.path}/data.csv')], text: 'CSV file');

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: Color(0xFF56D0A0),
          title: Text('Profile Analytics'),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10.0, bottom: 10),
        padding:
            EdgeInsets.only(top: 22.0, bottom: 15.0, left: 10.0, right: 10),
        child: Scrollbar(
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ButtonTheme(
                    minWidth: 150,
                    child: FloatingActionButton.extended(
                      backgroundColor: Color(0xFF56D0A0),
                      heroTag: "BTN-1",
                      onPressed: () {
                        if (widget.currentUserPhoneNumber == null ||
                            widget.currentUserPhoneNumber!.isEmpty) {
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);

                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                                content: Text('Login to export data'),
                                duration: Duration(seconds: 2)),
                          );

                          return;
                        }

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Export Data'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    // Export all data
                                    exportData(myData: false);
                                  },
                                  child: Text('All Expenses'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Export my data
                                    exportData();
                                  },
                                  child: Text('My Expenses'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      label: Row(
                        children: [
                          Icon(Icons.download_rounded),
                          SizedBox(width: 8),
                          Text('Export Data'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    child: Center(
                      child: selectedDates != null
                          ? MySpendingSummary2(
                              startDate: selectedDates!.start,
                              endDate: selectedDates!.end,
                            )
                          : MySpendingSummary(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ButtonTheme(
                    minWidth: 150,
                    child: FloatingActionButton.extended(
                      backgroundColor: Color(0xFF56D0A0),
                      heroTag: "BTN-2",
                      onPressed: () async {
                        final DateTimeRange? dateTimeRange =
                            await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(3000),
                          initialDateRange: selectedDates ??
                              DateTimeRange(
                                start: DateTime.now(),
                                end: DateTime.now(),
                              ),
                        );

                        if (dateTimeRange != null) {
                          setState(() {
                            selectedDates = dateTimeRange;
                          });
                        }
                      },
                      label: Row(
                        children: [
                          Icon(Icons.access_time_rounded),
                          SizedBox(width: 8),
                          Text(selectedDates != null
                              ? '${selectedDates!.start.toString().substring(0, 10)} - ${selectedDates!.end.toString().substring(0, 10)}'
                              : 'Choose Dates'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Container(
                child: Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 20, left: 10),
                            child: selectedDates != null
                                ? MyPieChart2(
                                    startDate: selectedDates!.start,
                                    endDate: selectedDates!.end,
                                  )
                                : MyPieChart(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
