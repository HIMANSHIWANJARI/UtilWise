class CommunityModel {
  String name;
  String phoneNo; // phone number of owner
  DateTime? lastSettledDate;

  CommunityModel({required this.name, required this.phoneNo
  , this.lastSettledDate
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      name: json['Name'],
      phoneNo: json['Phone Number'],
      lastSettledDate: json['LastSettledDate'].toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Phone Number': phoneNo,
        'LastSettledDate': lastSettledDate,
      };
}
