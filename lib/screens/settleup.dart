import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utilwise/Models/expense.dart';
import 'package:intl/intl.dart';

class Settleup extends StatefulWidget {

  const Settleup({super.key,required this.creatorTuple});
  final String creatorTuple;

  @override
  State<Settleup> createState() => _SettleupState();
}

class _SettleupState extends State<Settleup> {

  List<Map<String, dynamic>> unsettledExpenses = [];
  DateTime? lastSettledDate;
  bool isSettling = false;

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

  List<Map<String, dynamic>> results = [];

  if (objectIDs.isEmpty) {
    setState(() {
      isLoading = false;
    });
    return;
  }

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
      bool hasUnsettled = false;

      for (var split in expense.memberSplits ?? []) {
        if (!split.isSettled) {
          hasUnsettled = true;
          break;
        }
      }

      if (hasUnsettled) {
        results.add({
          'paidBy': expense.paidBy,
          'date': expense.date,
          'amount': expense.amount,
          'memberSplits': expense.memberSplits,
        });
      }
    }
  }

  setState(() {
    unsettledExpenses = results;
    isLoading = false;
  });
}

  
Future<void> settleAllExpenses() async {
  if (isSettling) return;
  setState(() {
    isSettling = true;
  });
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.receipt_long, color: Color(0xFF56D0A0)),
          SizedBox(width: 8),
          Text(
            "Final Settlements",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: finalSettlements.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "All expenses already settled 🎉",
                style: TextStyle(fontSize: 14),
              ),
            )
          : SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: finalSettlements.length,
                separatorBuilder: (_, __) => const Divider(height: 10),
                itemBuilder: (context, index) {
                  final entry = finalSettlements[index];
                  return Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${entry['from']} pays ${entry['to']} ₹${(entry['amount'] as num).toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            loadSplits();
          },
          icon: const Icon(Icons.close),
          label: const Text("Close"),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF56D0A0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  },
);


  await FirebaseFirestore.instance.collection('settlements').add({
  'communityID': communityId,
  'startDate': lastSettledDate ?? DateTime(2024, 1, 1),
  'endDate': DateTime.now(),
  'summary': finalSettlements.map((entry) => {
    'from': entry['from'],
    'to': entry['to'],
    'amount': entry['amount'],
  }).toList(),
});
}


  
    @override
Widget build(BuildContext context) {
  return Scaffold(
  body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : unsettledExpenses.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.celebration, size: 48, color: Color(0xFF56D0A0)),
                SizedBox(height: 10),
                Text("No pending splits",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        : Padding(
  padding: const EdgeInsets.all(12.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    SizedBox(height: 20),
    Center(
  child: ElevatedButton(
    //onPressed: settleAllExpenses,
    onPressed: isSettling ? null : settleAllExpenses,

    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF56D0A0)),
    child: const Text(
      "Settle All Unsettled Expenses",
      style: TextStyle(color: Colors.white),
    ),
  ),
),
SizedBox(height: 30),

      if (lastSettledDate != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0,),
          child: Center(
          child: Text(
          "All Unsettled Expenses from ${DateFormat('d MMM yyyy').format(lastSettledDate!)}",
          style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF56D0A0),
          fontSize: 14,
        ),
  ),
)

        ),
      Expanded(
  child: ListView.builder(
    itemCount: unsettledExpenses.length,
    itemBuilder: (context, index) {
      final expense = unsettledExpenses[index];
      final paidBy = expense['paidBy'];
      final amount = expense['amount'];
      final date = expense['date'] as DateTime? ?? DateTime.now();
      final splits = expense['memberSplits'] as List<dynamic>;

      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
          color: Colors.green, // light gray border color
          width: 1, // thickness of the border
    ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Paid by: $paidBy",
                style: const TextStyle( fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                "Date: ${DateFormat('d MMM yyyy').format(date)}",
              style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                "Total Amount: ₹$amount",
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              const Text(
                "Splits:",
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 6),
              ...splits.map((split) {
                final memberEmail = split.memberEmail;
                final percent = split.percent;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "$memberEmail has ${percent.toStringAsFixed(1)}% ${'Share'} ",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
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