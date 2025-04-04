class ExpenseModel {
  String name;
  String? objectID;
  String? creatorID;
  String amount;
  String description;
  DateTime? date;
  bool isViewOnly;
  String category;

  ExpenseModel(
      {required this.name,
      required this.objectID,
      required this.creatorID,
      required this.amount,
      required this.description,
      required this.date,
      required this.isViewOnly,
      required this.category});

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      name: json['Name'],
      objectID: json['ObjectID'],
      creatorID: json['CreatorID'],
      amount: json['Amount'],
      description: json['Description'],
      date: json['Date'].toDate(),
      isViewOnly: json['IsViewOnly'] ?? false, // Provide a default value if not present
      category: json['Category'],
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
      };
}
