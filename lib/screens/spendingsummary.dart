import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../provider/data_provider.dart';

class SpendingSummaryScreen extends StatefulWidget {
  const SpendingSummaryScreen({super.key,required this.creatorTuple});
  final String creatorTuple;

  @override
  State<SpendingSummaryScreen> createState() => _SpendingSummaryScreenState();
}

class _SpendingSummaryScreenState extends State<SpendingSummaryScreen> {


DateTimeRange? _selectedRange;
Map<String, double> dataMap = {};
bool isLoading = true;

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _selectedRange,
    );

    if (picked != null) {
      setState(() {
        _selectedRange = picked;
      });
      fetchExpensesData();
      print(dataMap);
    }
  }

String formatDateReadable(DateTime date) {
  return DateFormat('MMMM d, y').format(date); // e.g., April 14, 2025
}

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0); // handles month-end

  _selectedRange = DateTimeRange(start: startOfMonth, end: endOfMonth);
  fetchExpensesData();
  }

  Future<void> fetchExpensesData() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final communitySnapshot = await firestore
          .collection('communities')
          .where('Name', isEqualTo: (widget.creatorTuple).split(":")[0].toString())
          .limit(1)
          .get();

      if (communitySnapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final communityId = communitySnapshot.docs.first.id;
      final objectsSnapshot = await firestore
          .collection('objects')
          .where('CommunityID', isEqualTo: communityId)
          .get();

      Map<String, String> objectIdToName = {};
      List<String> objectIds = [];

      for (var doc in objectsSnapshot.docs) {
        objectIds.add(doc.id);
        objectIdToName[doc.id] = doc['Name'] ?? 'Unnamed';
      }

      if (objectIds.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      Map<String, double> tempMap = {};
      const batchSize = 10;

      for (int i = 0; i < objectIds.length; i += batchSize) {
        final batchIds = objectIds.sublist(i, i + batchSize > objectIds.length ? objectIds.length : i + batchSize);

        final expensesSnapshot = await firestore
            .collection('expenses')
            .where('ObjectID', whereIn: batchIds)
            .get();

        for (var doc in expensesSnapshot.docs) {
          String objectId = doc['ObjectID'];
          double amount =  double.parse(doc['Amount']);
          //String objectName = objectIdToName[objectId] ?? 'Unknown';
          //tempMap[objectName] = (tempMap[objectName] ?? 0) + amount;
          if( _selectedRange != null) {
            DateTime expenseDate = (doc['Date'] as Timestamp).toDate();
            if (expenseDate.isBefore(_selectedRange!.start) || expenseDate.isAfter(_selectedRange!.end)) {
              continue;
          }
            else
          {
              String objectName = objectIdToName[objectId] ?? 'Unknown';
              tempMap[objectName] = (tempMap[objectName] ?? 0) + amount;
            }
          }
          else
          {
            String objectName = objectIdToName[objectId] ?? 'Unknown';
            tempMap[objectName] = (tempMap[objectName] ?? 0) + amount;
          }

        }
      }

      setState(() {
        dataMap = tempMap;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  final providerCommunity = Provider.of<DataProvider>(context, listen: false);
  final start = _selectedRange?.start;
  final end = _selectedRange?.end;
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF56D0A0),
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
                style: TextStyle(fontSize: 18,),
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
    body: Column(
      children : [

      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        SizedBox(height: 20),
  ElevatedButton(
  onPressed: _pickDateRange,
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    backgroundColor: const Color(0xFF56D0A0),
    elevation: 4,
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: const [
      Icon(Icons.date_range, size: 20),
      SizedBox(width: 8),
      Text('Select Date'),
    ],
  ),
),


        const SizedBox(height: 20),],
      ),
      Builder(
      builder: (context) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (dataMap.isEmpty) {
          return Center(child: Text('Choose the dates to see the expense summary'));
        }

        // Main content shown only when not loading and dataMap is not empty
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: dataMap.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Text('₹${entry.value.toStringAsFixed(2)}'),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
              if (_selectedRange != null) ...[
              SizedBox(height: 20),
              Text(
            'Spending Summary:\n${formatDateReadable(start!)} to ${formatDateReadable(end!)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
            ),

              SizedBox(height: 30),
              PieChart(
                dataMap: dataMap,
                chartRadius: MediaQuery.of(context).size.width / 2.2,
                legendOptions: LegendOptions(
                  showLegends: true,
                  legendPosition: LegendPosition.right,
                ),
                chartValuesOptions: ChartValuesOptions(
                  showChartValuesInPercentage: true,
                ),
              ),
            ],
              ]
            ),
          ),
        );
      },
    ),
      ]
    )
  );
}

}
