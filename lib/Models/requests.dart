import '../Models/community.dart';
class Request {
  final String phoneNumber;
  final String communityId;

  Request({required this.phoneNumber, required this.communityId});

  // Convert a Member to a map
  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'communityId': communityId, // Store only the ID, like ObjectId in MongoDB
    };
  }

  // Create a Member from a map
  factory Request.fromJson(String id, Map<String, dynamic> json) {
    return Request(
      phoneNumber: json['phoneNumber'],
      communityId: json['communityId'], // Retrieve only the stored community ID
    );
  }

}
