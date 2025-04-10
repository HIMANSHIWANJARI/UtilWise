class MemberSplit {
  String memberEmail;
  double percent;
  bool isSettled;

  MemberSplit({
    required this.memberEmail,
    required this.percent,
    this.isSettled = false,
  });

  factory MemberSplit.fromJson(Map<String, dynamic> json) {
    return MemberSplit(
      memberEmail: json['MemberEmail'],
      percent: (json['Percent'] as num).toDouble(),
      isSettled: json['IsSettled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'MemberEmail': memberEmail,
        'Percent': percent,
        'IsSettled': isSettled,
      };
}
