import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Settlementsummarypage extends StatefulWidget {
  const Settlementsummarypage({super.key, required this.creatorTuple});
  final String creatorTuple;

  @override
  State<Settlementsummarypage> createState() => _SettlementsummarypageState();
}

class _SettlementsummarypageState extends State<Settlementsummarypage> {

  Future<String> getCommunityId() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('communities')
        .where('Name', isEqualTo: widget.creatorTuple.split(":")[0])
        .limit(1)
        .get();
    return snapshot.docs.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getCommunityId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final communityId = snapshot.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('settlements')
              .where('communityID', isEqualTo: communityId)
              .orderBy('endDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text("No settlement history found."));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final summary = List<Map<String, dynamic>>.from(data['summary']);
                final startDate = (data['startDate'] as Timestamp).toDate();
                final endDate = (data['endDate'] as Timestamp).toDate();
                final dateFormat = DateFormat('d MMM yyyy');
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                  color: Colors.green, // light gray border color
                  width: 1, // thickness of the border
                ),
        ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("From: ${dateFormat.format(startDate)}, To: ${dateFormat.format(endDate)} ",style: const TextStyle(fontSize: 11),),
                        //Text("To ${dateFormat.format(endDate)}",style: const TextStyle(fontSize: 11),),
                        const SizedBox(height: 10),
                        ...summary.map((entry) => Text(
                        "• ${entry['from']} owes ${entry['to']} ₹${(entry['amount'] as num).toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 11),
                        ))
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}