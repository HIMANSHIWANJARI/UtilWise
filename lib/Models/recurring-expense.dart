class RecurringExpenseModel {
  String? creatorID;
  String creatorTuple;
  String creatorName;
  String amount;
  String description;
  DateTime date;
  String frequency;
  DateTime createdAt; // New field

  RecurringExpenseModel({
    required this.creatorID,
    required this.creatorTuple,
    required this.creatorName,
    required this.amount,
    required this.description,
    required this.date,
    required this.frequency,
    required this.createdAt, // New field
  });

  factory RecurringExpenseModel.fromJson(Map<String, dynamic> json) {
    return RecurringExpenseModel(
      creatorID: json['CreatorID'],
      creatorTuple: json['CreatorTuple'],
      creatorName: json['CreatorName'],
      amount: json['Amount'],
      description: json['Description'],
      date: json['Date'].toDate(),
      frequency: json['Frequency'],
      createdAt: json['CreatedAt'].toDate(), // Adjust field name if necessary
    );
  }

  Map<String, dynamic> toJson() => {
        'CreatorID': creatorID,
        'CreatorTuple': creatorTuple,
        'CreatorName': creatorName,
        'Amount': amount,
        'Description': description,
        'Date': date,
        'Frequency': frequency,
        'CreatedAt': createdAt, // New field
      };
}
