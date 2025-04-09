import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';

class SpendingSummaryScreen extends StatefulWidget {
  const SpendingSummaryScreen({super.key,required this.creatorTuple});
  final String creatorTuple;

  @override
  State<SpendingSummaryScreen> createState() => _SpendingSummaryScreenState();
}

class _SpendingSummaryScreenState extends State<SpendingSummaryScreen> {


DateTimeRange? _selectedRange;

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
    }
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }


  Map<String, double> dataMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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
          String objectName = objectIdToName[objectId] ?? 'Unknown';

          tempMap[objectName] = (tempMap[objectName] ?? 0) + amount;
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
  final start = _selectedRange?.start;
  final end = _selectedRange?.end;
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF56D0A0),
      title: const Text('Spending Summary'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
    body: Builder(
      builder: (context) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (dataMap.isEmpty) {
          return Center(child: Text((widget.creatorTuple).split(":")[0]));
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
                PieChart(
                  dataMap: dataMap,
                  chartRadius: MediaQuery.of(context).size.width / 1.2,
                  chartType: ChartType.disc,
                  legendOptions: const LegendOptions(
                    showLegends: true,
                    legendPosition: LegendPosition.right,
                  ),
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValuesInPercentage: true,
                    showChartValues: true,
                    decimalPlaces: 1,
                  ),
                ),

                Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickDateRange,
                  child: Text('View Pie-Chart Of Specific date'),
                  style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFF56D0A0),
                  elevation: 4,
                  shadowColor: Colors.deepPurpleAccent,
                  ),
                ),
                ],
                ),

                if (_selectedRange != null) ...[
              SizedBox(height: 20),
              Text(
                'Selected Range:\n${formatDate(start!)} to ${formatDate(end!)}',
                textAlign: TextAlign.center,
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
  );
}

}
