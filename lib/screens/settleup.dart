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


  DateTime? lastSettledDate;

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
  final communityDoc = communitySnapshot.docs.first;
  final communityId = communitySnapshot.docs.first.id;
  lastSettledDate = (communityDoc.data()['LastSettledDate'] as Timestamp?)?.toDate();

  final objectsSnapshot = await firestore
      .collection('objects')
      .where('CommunityID', isEqualTo: communityId)
      .get();
  final objectIDs = objectsSnapshot.docs.map((doc) => doc.id).toList();

  List<String> results = [];

  if (objectIDs.isEmpty) {
    setState(() {
      isLoading = false;
    });
    return;
  }

  // Firestore limits whereIn to 10 values
  for (int i = 0; i < objectIDs.length; i += 10) {
    final batch = objectIDs.skip(i).take(10).toList();

    final expensesSnapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .where('ObjectID', whereIn: batch)
        .where('Date', isGreaterThanOrEqualTo: lastSettledDate)
        .where('Date' , isLessThanOrEqualTo: DateTime.now())
        .get();

    for (var doc in expensesSnapshot.docs) {
      final expense = ExpenseModel.fromJson(doc.data());
      final paidBy = expense.paidBy;
      final totalAmount = double.tryParse(expense.amount) ?? 0;

      for (var split in expense.memberSplits ?? []) {
        if (!split.isSettled && split.memberEmail != paidBy) {
          final owedAmount = totalAmount * (split.percent / 100);
          results.add("${split.memberEmail} owes $paidBy ₹${owedAmount.toStringAsFixed(2)}");
        }
      }
    }
  }

  setState(() {
    owedSummaries = results;
    isLoading = false;
  });
}
  
Future<void> settleAllExpenses() async {
  final firestore = FirebaseFirestore.instance;
  final communitySnapshot = await firestore
      .collection('communities')
      .where('Name', isEqualTo: widget.creatorTuple.split(":")[0])
      .limit(1)
      .get();
  final communityDoc = communitySnapshot.docs.first;
  final communityId = communityDoc.id;

  final objectsSnapshot = await firestore
      .collection('objects')
      .where('CommunityID', isEqualTo: communityId)
      .get();
  final objectIDs = objectsSnapshot.docs.map((doc) => doc.id).toList();

  Map<String, double> netBalance = {};
  List<DocumentSnapshot> expensesToUpdate = [];

  // Step 1: Collect expenses & build net balances
  for (int i = 0; i < objectIDs.length; i += 10) {
    final batch = objectIDs.skip(i).take(10).toList();

    final expensesSnapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .where('ObjectID', whereIn: batch)
        .where('Date', isGreaterThanOrEqualTo: lastSettledDate ?? DateTime(2024, 1, 1))
        .where('Date', isLessThanOrEqualTo: DateTime.now())
        .get();

    for (var doc in expensesSnapshot.docs) {
      final expense = ExpenseModel.fromJson(doc.data());
      final paidBy = expense.paidBy;
      final totalAmount = double.tryParse(expense.amount) ?? 0;
      bool hasUnsettled = false;

      for (var split in expense.memberSplits ?? []) {
        if (!split.isSettled && split.memberEmail != paidBy) {
          final owedAmount = totalAmount * (split.percent / 100);

          netBalance[paidBy] = (netBalance[paidBy] ?? 0) + owedAmount;
          netBalance[split.memberEmail] = (netBalance[split.memberEmail] ?? 0) - owedAmount;
          hasUnsettled = true;
        }
      }

      if (hasUnsettled) {
        expensesToUpdate.add(doc);
      }
    }
  }

  // Step 2: Simplify balances (who pays whom)
  List<Map<String, dynamic>> finalSettlements = [];
  var creditors = <String, double>{};
  var debtors = <String, double>{};

  for (var entry in netBalance.entries) {
    if (entry.value > 0) {
      creditors[entry.key] = entry.value;
    } else if (entry.value < 0) {
      debtors[entry.key] = -entry.value;
    }
  }

  final creditorList = creditors.entries.toList();
  final debtorList = debtors.entries.toList();
  int i = 0, j = 0;

  while (i < debtorList.length && j < creditorList.length) {
    final debtor = debtorList[i];
    final creditor = creditorList[j];

    final amount = debtor.value < creditor.value ? debtor.value : creditor.value;

    finalSettlements.add({
      'from': debtor.key,
      'to': creditor.key,
      'amount': amount,
    });

    debtorList[i] = MapEntry(debtor.key, debtor.value - amount);
    creditorList[j] = MapEntry(creditor.key, creditor.value - amount);

    if (debtorList[i].value == 0) i++;
    if (creditorList[j].value == 0) j++;
  }

  // Step 3: Update Firestore: mark splits as settled
  for (var doc in expensesToUpdate) {
    final expense = ExpenseModel.fromJson(doc.data() as Map<String, dynamic>);

    for (int i = 0; i < expense.memberSplits!.length; i++) {
      final split = expense.memberSplits![i];
      if (!split.isSettled && split.memberEmail != expense.paidBy) {
        expense.memberSplits![i].isSettled = true;
      }
    }

    await FirebaseFirestore.instance
        .collection('expenses')
        .doc(doc.id)
        .update({
      'MemberSplits': expense.memberSplits!.map((e) => e.toJson()).toList(),
    });
  }

  // Step 4: Update LastSettledDate in community
  await FirebaseFirestore.instance
      .collection('communities')
      .doc(communityId)
      .update({
    'LastSettledDate': Timestamp.fromDate(DateTime.now())
  });

  // Step 5: Show summary in dialog
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Final Settlements"),
        content: finalSettlements.isEmpty
            ? const Text("All expenses already settled 🎉")
            : SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: finalSettlements.map((settle) {
                    return ListTile(
                      title: Text("${settle['from']} pays ${settle['to']} ₹${settle['amount'].toStringAsFixed(2)}"),
                    );
                  }).toList(),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              loadSplits(); // Refresh UI
            },
            child: const Text("Close"),
          )
        ],
      );
    },
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
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ElevatedButton(
      onPressed: settleAllExpenses,
      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF56D0A0)),
      child: const Text("Settle All", style: TextStyle(color: Colors.white)),
      ),
      if (lastSettledDate != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            "Last settled on: $lastSettledDate ${DateTime.now()}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
      Expanded(
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
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF56D0A0),
                  child: Icon(Icons.currency_rupee, color: Colors.white, size: 15),
                ),
                title: Text("$from owes $to",
                    style: const TextStyle(fontSize: 11)),
                subtitle: Text("Amount: ₹$amount",
                    style: const TextStyle(fontSize: 11)),
              ),
            );
          },
        ),
      ),
    ],
  ),
)

  );
}
}