import 'package:utilwise/Models/membersplit.dart';

class ExpenseModel {
  String name;
  String? objectID;
  String? creatorID;
  String amount;
  String description;
  DateTime? date;
  bool isViewOnly;
  String category;
  String type;
  List<MemberSplit>? memberSplits;
  String paidBy;

  ExpenseModel(
      {required this.name,
      required this.objectID,
      required this.creatorID,
      required this.amount,
      required this.description,
      required this.date,
      required this.isViewOnly,
      required this.category,
      required this.type,
      this.memberSplits,
      required this.paidBy
      });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      name: json['Name'],
      objectID: json['ObjectID'],
      creatorID: json['CreatorID'],
      amount: json['Amount'],
      description: json['Description'],
      date: json['Date'].toDate(),
      isViewOnly: json['IsViewOnly'] ?? false,
      category: json['Category'],
      type: json['Type'], // Provide a default value if not present
      memberSplits: json['MemberSplits'] != null
          ? (json['MemberSplits'] as List)
              .map((e) => MemberSplit.fromJson(e))
              .toList()
          : [],
      paidBy: json['PaidBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'Name': name,
        'ObjectID': objectID,
        'CreatorID': creatorID,
        'Amount': amount,
        'Description': description,
        'Date': date,
        'IsViewOnly': isViewOnly,
        'Category': category,
        'Type': type,
        'MemberSplits': memberSplits?.map((e) => e.toJson()).toList(),
        'PaidBy': paidBy,
      };
}
