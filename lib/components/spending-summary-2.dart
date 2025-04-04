import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/data_provider.dart';

class MySpendingSummary2 extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  MySpendingSummary2({required this.startDate, required this.endDate});

  @override
  _MySpendingSummary2State createState() => _MySpendingSummary2State();
}

class _MySpendingSummary2State extends State<MySpendingSummary2> {
  Future<Map<int, int>>? _dataMapFuture;

  @override
  void initState() {
    super.initState();
    DataProvider providerCommunity =
        Provider.of<DataProvider>(context, listen: false);
    _dataMapFuture = fetchData(providerCommunity);
  }

  @override
  void didUpdateWidget(MySpendingSummary2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      setState(() {
        DataProvider providerCommunity =
            Provider.of<DataProvider>(context, listen: false);
        _dataMapFuture = fetchData(providerCommunity);
      });
    }
  }

  Future<Map<int, int>> fetchData(DataProvider providerCommunity) async {
    // Fetch data from database and return it as a Map<String, double>
    return await providerCommunity.spendingSummaryData2(
        widget.startDate, widget.endDate);
  }

  Widget build(BuildContext context) {
    return FutureBuilder<Map<int, int>>(
      future: _dataMapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while waiting for data to load
          // return CircularProgressIndicator();
          return Text('Loading...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // Build the PieChart widget once data has been loaded
          return Row(
            children: [
              Text(
                '  Your Spending: ₹${snapshot.data![0]}\n  Total Spending: ₹${snapshot.data![1]}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        } else {
          // Handle the case where no data has been fetched
          return Text('No data available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ));
        }
      },
    );
  }
}
