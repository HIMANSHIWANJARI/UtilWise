import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utilwise/Models/expense.dart';

class Settleup extends StatefulWidget {

  const Settleup({super.key,required this.creatorTuple});
  final String creatorTuple;

  @override
  State<Settleup> createState() => _SettleupState();
}

class _SettleupState extends State<Settleup> {
  
  List<String> owedSummaries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    //loadAndSettleAll();
  }

  
  Future<void> loadAndSettleAll() async {
  setState(() => isLoading = true);

  final firestore = FirebaseFirestore.instance;

  // Get community info
  final communitySnapshot = await firestore
      .collection('communities')
      .where('Name', isEqualTo: widget.creatorTuple.split(":")[0])
      .limit(1)
      .get();

  final communityDoc = communitySnapshot.docs.first;
  final communityId = communityDoc.id;
  final lastSettledDate = (communityDoc.data()['lastSettledDate'] as Timestamp?)?.toDate() ?? DateTime(2000);
  final now = DateTime.now();

  // Get object IDs
  final objectsSnapshot = await firestore
      .collection('objects')
      .where('CommunityID', isEqualTo: communityId)
      .get();

  final objectIDs = objectsSnapshot.docs.map((doc) => doc.id).toList();

  if (objectIDs.isEmpty) {
    setState(() => isLoading = false);
    return;
  }

  // Step 1: Collect unpaid splits between members
  final Map<String, Map<String, double>> netOwed = {};

  for (int i = 0; i < objectIDs.length; i += 10) {
    final batch = objectIDs.skip(i).take(10).toList();

    final expensesSnapshot = await firestore
        .collection('expenses')
        .where('ObjectID', whereIn: batch)
        .where('Date', isGreaterThan: lastSettledDate)
        .get();

    for (var expenseDoc in expensesSnapshot.docs) {
      final data = expenseDoc.data();
      final expense = ExpenseModel.fromJson(data);
      final paidBy = expense.paidBy;
      final totalAmount = double.tryParse(expense.amount) ?? 0;

      bool needsUpdate = false;

      for (int i = 0; i < (expense.memberSplits?.length ?? 0); i++) {
        final split = expense.memberSplits![i];
        if (!split.isSettled && split.memberEmail != paidBy) {
          final amount = totalAmount * (split.percent / 100);

          // Accumulate
          netOwed.putIfAbsent(split.memberEmail, () => {});
          netOwed[split.memberEmail]!.update(
            paidBy,
            (prev) => prev + amount,
            ifAbsent: () => amount,
          );

          // Mark as settled
          expense.memberSplits![i].isSettled = true;
          needsUpdate = true;
        }
      }

      // Update Firestore if needed
      if (needsUpdate) {
        await firestore.collection('expenses').doc(expenseDoc.id).update({
          'MemberSplits': expense.memberSplits!.map((e) => e.toJson()).toList(),
        });
      }
    }
  }

  // Step 2: Generate summary strings
  List<String> finalSummary = [];
  netOwed.forEach((from, toMap) {
    toMap.forEach((to, amount) {
      if (amount > 0.01) {
        finalSummary.add("$from owes $to ₹${amount.toStringAsFixed(2)}");
      }
    });
  });

  // Step 3: Store in Firestore
  if (finalSummary.isNotEmpty) {
    await firestore.collection('settlements').add({
      'communityID': communityId,
      'summary': finalSummary,
      'settledAt': Timestamp.fromDate(now),
    });
  }

  // Step 4: Update lastSettledDate
  await firestore.collection('communities').doc(communityId).update({
    'lastSettledDate': Timestamp.fromDate(now),
  });

  // Step 5: Show result
  setState(() {
    owedSummaries = finalSummary;
    isLoading = false;
  });
}


  
    @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF56D0A0),
      title: const Text('Settle Dues'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),

    body : Container(
      child : Column(children: [
        ElevatedButton(
          onPressed: loadAndSettleAll,
          child: const Text("Settle All and Show Summary"),
      ),
      const SizedBox(height: 20),
        isLoading
          ? const Center(child: CircularProgressIndicator())
          : owedSummaries.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.celebration, size: 48, color: Colors.green),
                      SizedBox(height: 10),
                      Text("All settled! 🎉", style: TextStyle(fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: owedSummaries.length,
                  itemBuilder: (context, index) {
                    final summary = owedSummaries[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF56D0A0),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          summary,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    );
                  },
                ),
                
      ],),
      
    )
);
}
}