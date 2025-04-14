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
    loadSplits();
  }

  Future<void> loadSplits() async {
    
    final firestore = FirebaseFirestore.instance;
    final communitySnapshot = await firestore
        .collection('communities')
        .where('Name', isEqualTo: (widget.creatorTuple).split(":")[0])
        .limit(1)
        .get();

    final communityId = communitySnapshot.docs.first.id;

    List<String> objectIDs = [];

    final objectsSnapshot = await FirebaseFirestore.instance
        .collection('objects')
        .where('CommunityID', isEqualTo: communityId)
        .get();
    objectIDs = objectsSnapshot.docs.map((doc) => doc.id).toList();
    List<String> expenseIDs = [];
    if (objectIDs.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    List<String> results = [];

    for (String objID in objectIDs) {
      final expensesSnapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('ObjectID', isEqualTo: objID)
          .get();

      for (var doc in expensesSnapshot.docs) {
        final expense = ExpenseModel.fromJson(doc.data());
        final paidBy = expense.paidBy;
        final double totalAmount = double.tryParse(expense.amount) ?? 0;

        for (var split in expense.memberSplits ?? []) {
          if (!split.isSettled && split.memberEmail != paidBy) {
            final owedAmount = totalAmount * (split.percent / 100);
            results.add(
              "${split.memberEmail} owes $paidBy ₹${owedAmount.toStringAsFixed(2)}",
            );
          }
        }
      }
    }

    setState(() {
      owedSummaries = results;
      isLoading = false;
    });
  }

  Future<void> settlePayment(String from, String to, double amount) async {
    
  final firestore = FirebaseFirestore.instance;
    final communitySnapshot = await firestore
        .collection('communities')
        .where('Name', isEqualTo: (widget.creatorTuple).split(":")[0])
        .limit(1)
        .get();

    final communityId = communitySnapshot.docs.first.id;
  
  final objectsSnapshot = await FirebaseFirestore.instance
      .collection('objects')
      .where('CommunityID', isEqualTo: communityId)
      .get();

  final objectIDs = objectsSnapshot.docs.map((doc) => doc.id).toList();
  for (String objectID in objectIDs) {
      final expensesSnapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('ObjectID', isEqualTo: objectID)
          .get();

      for (var expenseDoc in expensesSnapshot.docs) {
        final data = expenseDoc.data();
        final expense = ExpenseModel.fromJson(data);

        if (expense.paidBy != to) continue; // must be owed to `to`

        final double totalAmount = double.tryParse(expense.amount) ?? 0;

        for (int i = 0; i < (expense.memberSplits?.length ?? 0); i++) {
          final split = expense.memberSplits![i];

          final owedAmt = totalAmount * (split.percent / 100);
          final isMatch = split.memberEmail == from &&
                          !split.isSettled &&
                          (owedAmt - amount).abs() < 0.01;

          if (isMatch) {
            // Mark as settled
            expense.memberSplits![i].isSettled = true;

            // Push update to Firestore
            await FirebaseFirestore.instance
                .collection('expenses')
                .doc(expenseDoc.id)
                .update({
              'MemberSplits':
                  expense.memberSplits!.map((e) => e.toJson()).toList(),
            });
            
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        backgroundColor: const Color(0xFF56D0A0),
          content: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Payment settled successfully",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      );

            loadSplits(); // Refresh UI
            return;
          }
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No matching unpaid split found.")),
    );
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
  body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : owedSummaries.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.celebration, size: 48, color: Colors.green),
                SizedBox(height: 10),
                Text("No pending splits 🎉",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
  itemCount: owedSummaries.length,
  itemBuilder: (context, index) {
    final data = owedSummaries[index].split(" owes ");
    final from = data[0];
    final rest = data[1].split(" ₹");
    final to = rest[0];
    final amount = rest[1];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFF56D0A0),
          child: Icon(Icons.attach_money, color: Colors.white, size: 15),
        ),
        title: Text("$from owes $to",
            style: const TextStyle(
                fontSize: 11,)),
        subtitle: Text("Amount: ₹$amount", style: const TextStyle(
                fontSize: 11,)),
        trailing: ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF56D0A0),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 3,
  ),
  onPressed: () => settlePayment(from, to, double.parse(amount)),
  icon: const Icon(Icons.check_circle_outline, size: 15, color: Colors.white),
  label: const Text(
    "Settle",
    style: TextStyle(
      fontSize: 9,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),
),

      ),
    );
  },
)

          ),
  );
}
}