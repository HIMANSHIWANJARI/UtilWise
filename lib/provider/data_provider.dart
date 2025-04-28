import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:utilwise/Models/recurring-expense.dart';
import 'package:utilwise/Notifications/notification_services.dart';
import 'package:utilwise/components/expense.dart';
import 'package:utilwise/components/member.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/community.dart';
import '../Models/expense.dart';
import '../Models/membersplit.dart';
import '../Models/objects.dart';
import '../Models/user.dart';
import '../database/db_communities.dart';
import '../database/db_expenses.dart';
import '../database/db_objects.dart';
import '../database/db_user.dart';
import '../Models/requests.dart';

class DataProvider extends ChangeNotifier {
  int communitiesIndex = 0;
  int objectIndex = 0;
  int expenseIndex = 0;

  UserModel? user;
  List<String> allUserPhones = [];
  Map<String, List<Member>> communityMembersMap = {};

  List<CommunityModel>? communitiesdb = [];
  Map<CommunityModel, List<ObjectsModel>>? communityObjectMapdb = {};
  Map<CommunityModel, Map<ObjectsModel, List<ExpenseModel>>>?
  objectUnresolvedExpenseMapdb = {};

  List<String> communities = [];
  Map<String, List<String>> communityObjectMap = {};
  Map<String, Map<String, List<Expense>>> objectUnresolvedExpenseMap = {};

  void checkuser(String phoneNo) async {
    user = await UserDataBaseService.getUser(phoneNo);
  }

  //***********************************************
  // Images for common names
  
  
  Map<String, String> communityNameToImagePath = {
    "Home": "assets/images/communityImages/Home.jpg",
    "Office": "assets/images/communityImages/Office.png",
    "Shop": "assets/images/communityImages/Shop.jpg",
    "Hospital": "assets/images/communityImages/Hospital.jpeg",
    "Work": "assets/images/communityImages/Work.png",
    "Lab": "assets/images/communityImages/Lab.jpeg",
    "Friends": "assets/images/communityImages/Friends.jpeg",
    "Family": "assets/images/communityImages/Family.jpeg",
    "Trip": "assets/images/communityImages/Travel.jpeg",
    "Travel": "assets/images/communityImages/Travel.jpeg",
    "Apartment": "assets/images/communityImages/Apartment.jpeg",
    "Flat": "assets/images/communityImages/Apartment.jpeg",
    "Villa": "assets/images/communityImages/Apartment.jpeg",
    "Myself": "assets/images/communityImages/Myself.jpeg",
    "Me": "assets/images/communityImages/Myself.jpeg",
    "Own": "assets/images/communityImages/Myself.jpeg",
    "Self": "assets/images/communityImages/Myself.jpeg",
    "Couple": "assets/images/communityImages/Love.jpeg",
    "Love": "assets/images/communityImages/Love.jpeg",
    "Test": "assets/images/communityImages/Test.jpeg",
    "Default": "assets/images/communityImages/Default.jpg",
  };

  Map<String, String> objectNameToImagePath = {
    "Car": "assets/images/objectImages/Car.png",
    "furniture": "assets/images/objectImages/Furniture.jpeg",
    "fridge": "assets/images/objectImages/Fridge.jpeg",
    "fees" : "assets/images/objectImages/fees.jpg",
    "Mobile": "assets/images/objectImages/Mobile.jpeg",
    "Server": "assets/images/objectImages/Server.jpeg",
    "Shopping": "assets/images/objectImages/Shopping.jpeg",
    "Snacks": "assets/images/objectImages/Snacks.jpeg",
    "Table": "assets/images/objectImages/Table.jpeg",
    "Washing": "assets/images/objectImages/Washing Machine.jpeg",
    "Bills" : "assets/images/objectImages/bills.jpg",
    "Education" : "assets/images/objectImages/education.jpg",
    "Water" : "assets/images/objectImages/Water.jpeg",
    "Rent" : "assets/images/objectImages/fees.jpg",
    "Misc" : "assets/images/objectImages/Misc.jpeg",
    "Clothing" : "assets/images/objectImages/clothing.jpg",
    "Food" : "assets/images/objectImages/food.jpg",
    "Book" : "assets/images/objectImages/book.jpg",
    "Grocery": "assets/images/objectImages/grocery.jpg",
    "Groceries" : "assets/images/objectImages/grocery.jpg",
    "Electronics" : "assets/images/objectImages/electronics.jpg",
    "Security" : "assets/images/objectImages/security.jpg",
    "Repair" : "assets/images/objectImages/repairing.jpg",
    "Stationary" : "assets/images/objectImages/stationary.jpg",
    "Subscription" : "assets/images/objectImages/subscription.jpg",
    "Taxi" : "assets/images/objectImages/taxi.jpg",
    "Travel" : "assets/images/objectImages/travel.jpg",
    "Event" : "assets/images/objectImages/events.jpg",
    "Party" : "assets/images/objectImages/event.jpg",
    "Gift" : "assets/images/objectImages/gift.jpg",
    "Default": "assets/images/objectImages/Default.jpeg"

  };

  //***********************************************
  bool isSubstring(String s, String t) {
    if (s.isEmpty) return true;
    if (t.isEmpty) return false;
    if (t.length < s.length) return false;

    for (int i = 0; i <= t.length - s.length; i++) {
      if (t.substring(i, i + s.length) == s) {
        return true;
      }
    }
    return false;
  }

  String extractCommunityImagePathByName(String creatorTuple) {
    String communityName = creatorTuple.split(":")[0];

    for (String key in communityNameToImagePath.keys) {
      String value = communityNameToImagePath[key]!;
      if (isSubstring(key.toLowerCase(), communityName.toLowerCase())) {
        return value;
      }
    }
    return communityNameToImagePath["Default"]!;
  }

  String extractObjectImagePathByName(String objectName) {
    for (String key in objectNameToImagePath.keys) {
      String value = objectNameToImagePath[key]!;
      if (isSubstring(key.toLowerCase(), objectName.toLowerCase())) {
        return value;
      }
    }
    return objectNameToImagePath["Default"]!;
  }

  int communityTotalExpense(String creatorTuple) {
    int sum = 0;
    for (int i = 0; i < communityObjectMap[creatorTuple]!.length; i++) {
      for (
      int j = 0;
      j <
          objectUnresolvedExpenseMap[creatorTuple]![communityObjectMap[creatorTuple]![i]]!
              .length;
      j++
      ) {
        sum +=
            objectUnresolvedExpenseMap[creatorTuple]![communityObjectMap[creatorTuple]![i]]![j]
                .amount;
      }
    }
    return sum;
  }

  int communityTotalExpenseDateRange(String creatorTuple,
      DateTime startDate,
      DateTime endDate,) {
    int sum = 0;
    for (int i = 0; i < communityObjectMap[creatorTuple]!.length; i++) {
      String objectID = communityObjectMap[creatorTuple]![i];
      List<Expense> expenses =
          objectUnresolvedExpenseMap[creatorTuple]![objectID] ?? [];
      for (int j = 0; j < expenses.length; j++) {
        Expense expense = expenses[j];
        // Parse the date string to DateTime
        DateTime expenseDate = DateTime.parse(expense.date!);
        // Check if the expense date falls within the provided date range
        if (expenseDate.isAfter(startDate) && expenseDate.isBefore(endDate)) {
          // Parse the amount string to an integer before adding to the sum
          sum += expense.amount;
        }
      }
    }
    return sum;
  }

  Future<int> totalExpense() async {
    int sum = 0;
    List<CommunityModel>? communityList =
    await UserDataBaseService.getCommunities(user!.phoneNo);
    communityList!.forEach((element) {
      String creatorTuple = "${element.name}:${element.phoneNo}";
      sum += communityTotalExpense(creatorTuple);
    });
    return sum;
  }

  Future<int> totalExpense2(DateTime startDate, DateTime endDate) async {
    int sum = 0;
    List<CommunityModel>? communityList =
    await UserDataBaseService.getCommunities(user!.phoneNo);
    communityList!.forEach((element) {
      String creatorTuple = "${element.name}:${element.phoneNo}";
      sum += communityTotalExpenseDateRange(creatorTuple, startDate, endDate);
    });
    return sum;
  }

  Future<int> myTotalExpense() async {
    int sum = 0;
    List<CommunityModel>? communityList =
    await UserDataBaseService.getCommunities(user!.phoneNo);
    communityList!.forEach((element) {
      String creatorTuple = "${element.name}:${element.phoneNo}";
      sum += myExpenseInCommunity(creatorTuple);
    });
    return sum;
  }

  Future<int> myTotalExpense2(DateTime startDate, DateTime endDate) async {
    int sum = 0;
    List<CommunityModel>? communityList =
    await UserDataBaseService.getCommunities(user!.phoneNo);
    communityList!.forEach((element) {
      String creatorTuple = "${element.name}:${element.phoneNo}";
      sum += myExpenseInCommunity2(creatorTuple, startDate, endDate);
    });
    return sum;
  }

  Future<Map<int, int>> spendingSummaryData() async {
    Map<int, int> spendingSummary = {};
    spendingSummary[0] = await myTotalExpense();
    spendingSummary[1] = await totalExpense();
    return spendingSummary;
  }

  Future<Map<int, int>> spendingSummaryData2(DateTime startDate,
      DateTime endDate,) async {
    Map<int, int> spendingSummary = {};
    spendingSummary[0] = await myTotalExpense2(startDate, endDate);
    spendingSummary[1] = await totalExpense2(startDate, endDate);
    return spendingSummary;
  }

  int myExpenseInCommunity(String creatorTuple) {
    int sum = 0;
    for (int i = 0; i < communityObjectMap[creatorTuple]!.length; i++) {
      for (
      int j = 0;
      j <
          objectUnresolvedExpenseMap[creatorTuple]![communityObjectMap[creatorTuple]![i]]!
              .length;
      j++
      ) {
        if (user!.name ==
            objectUnresolvedExpenseMap[creatorTuple]![communityObjectMap[creatorTuple]![i]]![j]
                .creator) {
          sum +=
              objectUnresolvedExpenseMap[creatorTuple]![communityObjectMap[creatorTuple]![i]]![j]
                  .amount;
        }
      }
    }
    return sum;
  }

  int myExpenseInCommunity2(String creatorTuple,
      DateTime startDate,
      DateTime endDate,) {
    int sum = 0;
    for (int i = 0; i < communityObjectMap[creatorTuple]!.length; i++) {
      String objectID = communityObjectMap[creatorTuple]![i];
      List<Expense> expenses =
          objectUnresolvedExpenseMap[creatorTuple]![objectID] ?? [];
      for (int j = 0; j < expenses.length; j++) {
        Expense expense = expenses[j];
        // Parse the date string to DateTime
        DateTime expenseDate = DateTime.parse(expense.date);
        // Check if the expense date falls within the provided date range and if the expense is created by the user
        if (expenseDate.isAfter(startDate) &&
            expenseDate.isBefore(endDate) &&
            user!.name == expense.creator) {
          // Parse the amount string to an integer before adding to the sum
          sum += expense.amount;
        }
      }
    }
    return sum;
  }

  int objectTotalExpense(String communityName, String objectName) {
    int sum = 0;
    for (
    int j = 0;
    j < objectUnresolvedExpenseMap[communityName]![objectName]!.length;
    j++
    ) {
      sum += objectUnresolvedExpenseMap[communityName]![objectName]![j].amount;
    }
    return sum;
  }

  int myExpenseInObject(String communityName, String objectName) {
    int sum = 0;
    for (
    int j = 0;
    j < objectUnresolvedExpenseMap[communityName]![objectName]!.length;
    j++
    ) {
      if (user!.name ==
          objectUnresolvedExpenseMap[communityName]![objectName]![j].creator) {
        sum +=
            objectUnresolvedExpenseMap[communityName]![objectName]![j].amount;
      }
    }
    return sum;
  }

  Future<bool> addUser(String name, String email, String phoneNo) async {
    UserModel userM = UserModel(
      name: name,
      username: name,
      phoneNo: phoneNo,
      email: email,
    );
    await UserDataBaseService.createUserDb(userM);
    return true;
  }

  Future<Map<String, double>> pieChartDataOfCommunities() async {
    Map<String, double> communityTotalExpenseMap = {};
    List<CommunityModel>? communityList =
    await UserDataBaseService.getCommunities(user!.phoneNo);
    for (int i = 0; i < communityList!.length; i++) {
      String creatorTuple =
          "${communityList[i].name}:${communityList[i].phoneNo}";
      String commCreatorName =
          creatorTuple.split(":")[0] +
              " - " +
              communityMembersMap[creatorTuple]!
                  .firstWhere(
                    (member) => member.phone == (creatorTuple).split(":")[1],
                orElse:
                    () =>
                    communityMembersMap[creatorTuple]!.firstWhere(
                          (member) => member.isCreator == true,
                    ),
              )
                  .name;
      communityTotalExpenseMap[commCreatorName] =
          communityTotalExpense(creatorTuple).toDouble();
    }
    return communityTotalExpenseMap;
  }

  Future<Map<String, double>> pieChartDataOfCommunities2(DateTime startDate,
      DateTime endDate,) async {
    Map<String, double> communityTotalExpenseMap = {};
    List<CommunityModel>? communityList =
    await UserDataBaseService.getCommunities(user!.phoneNo);
    for (int i = 0; i < communityList!.length; i++) {
      String creatorTuple =
          "${communityList[i].name}:${communityList[i].phoneNo}";
      String commCreatorName =
          creatorTuple.split(":")[0] +
              " - " +
              communityMembersMap[creatorTuple]!
                  .firstWhere(
                    (member) => member.phone == (creatorTuple).split(":")[1],
                orElse:
                    () =>
                    communityMembersMap[creatorTuple]!.firstWhere(
                          (member) => member.isCreator == true,
                    ),
              )
                  .name;
      communityTotalExpenseMap[commCreatorName] =
          communityTotalExpenseDateRange(
            creatorTuple,
            startDate,
            endDate,
          ).toDouble();
    }
    return communityTotalExpenseMap;
  }

  void getAllUserPhones() async {
    allUserPhones = await UserDataBaseService.getAllUserPhones();
    notifyListeners();
  }

  Future<void> getAllDetails(String phoneNo) async {
    deleteState();
    checkuser(phoneNo);

    List<CommunityModel>? communityTemp =
    await UserDataBaseService.getCommunities(phoneNo);
    communitiesdb = communityTemp;

    for (int i = 0; i < communityTemp!.length; i++) {
      String creatorTuple =
          '${communityTemp[i].name}:${communityTemp[i].phoneNo}';
      communities.add(creatorTuple);
    }

    notifyListeners();
    getAllUserPhones();

    for (int i = 0; i < communityTemp.length; i++) {
      getCommunityDetails(
        '${communityTemp[i].name}:${communityTemp[i].phoneNo}',
      );
    }

    notifyListeners();
  }

  Future<void> getCommunityDetails(String creatorTuple) async {
    List<String> extractedTupleInfo = creatorTuple.split(':');
    String communityName = extractedTupleInfo[0];
    String creatorPhoneNo = extractedTupleInfo[1];

    CommunityModel? currCommunity = null;
    for (int i = 0; i < communitiesdb!.length; i++) {
      if (communitiesdb![i].name == communityName &&
          communitiesdb![i].phoneNo == creatorPhoneNo) {
        currCommunity = communitiesdb![i];
        break;
      }
    }

    if (currCommunity == null) {
      return;
    }

    communityObjectMap[creatorTuple] = [];
    communityObjectMapdb![currCommunity] = [];
    objectUnresolvedExpenseMap[creatorTuple] = {};
    objectUnresolvedExpenseMapdb![currCommunity] = {};

    String? communityID = await CommunityDataBaseService.getCommunityID(
      currCommunity,
    );
    List<ObjectsModel>? objectTemp = await ObjectDataBaseService.getObjects(
      communityID!,
    );

    for (int j = 0; j < objectTemp!.length; j++) {
      communityObjectMap[creatorTuple]!.add(objectTemp[j].name);
      communityObjectMapdb![currCommunity]!.add(objectTemp[j]);

      getObjectDetails(creatorTuple, objectTemp[j].name);
    }

    getIndividualCommunityMembers(currCommunity);

    notifyListeners();
  }

  Future<void> getObjectDetails(String creatorTuple, String ObjectName) async {
    List<String> extractedTupleInfo = creatorTuple.split(':');
    String communityName = extractedTupleInfo[0];
    String creatorPhoneNo = extractedTupleInfo[1];

    CommunityModel? currCommunity = null;
    for (int i = 0; i < communitiesdb!.length; i++) {
      if (communitiesdb![i].name == communityName &&
          communitiesdb![i].phoneNo == creatorPhoneNo) {
        currCommunity = communitiesdb![i];
        break;
      }
    }

    if (currCommunity == null) {
      return;
    }

    ObjectsModel? currObject = null;
    for (int i = 0; i < communityObjectMapdb![currCommunity]!.length; i++) {
      if (communityObjectMapdb![currCommunity]![i].name == ObjectName) {
        currObject = communityObjectMapdb![currCommunity]![i];
        break;
      }
    }

    if (currObject == null) {
      return;
    }

    objectUnresolvedExpenseMap[creatorTuple]![currObject.name] = [];
    objectUnresolvedExpenseMapdb![currCommunity]![currObject] = [];
    List<ExpenseModel>? expenseTemp = await ObjectDataBaseService.getExpenses(
      currObject,
    );

    for (int k = 0; k < expenseTemp.length; k++) {
      objectUnresolvedExpenseMap[creatorTuple]![currObject.name]!.add(
        Expense(
          creatorTuple: creatorTuple,
          objectName: currObject.name,
          creator: await UserDataBaseService.getName(expenseTemp[k].creatorID!),
          description: expenseTemp[k].name,
          isPaid: false,
          amount: int.parse(expenseTemp[k].amount),
          date: expenseTemp[k].date.toString(),
          isViewOnly: expenseTemp[k].isViewOnly,
          category : expenseTemp[k].category,
          type : expenseTemp[k].type,
        ),
      );
      objectUnresolvedExpenseMapdb![currCommunity]![currObject]!.add(
        expenseTemp[k],
      );
    }

    notifyListeners();
  }

  void getIndividualCommunityMembers(CommunityModel community) async {
    List<Member> memberList = [];
    List<dynamic>? group = await UserDataBaseService.getCommunityMembers(
      community.name,
      community.phoneNo,
    );
    for (int j = 0; j < group.length; j++) {
      memberList.add(
        Member(
          name: group[j]["Name"],
          phone: group[j]["Phone Number"],
          isCreator: group[j]["Is Admin"],
        ),
      );
    }
    String creatorTuple = '${community.name}:${community.phoneNo}';
    communityMembersMap[creatorTuple] = memberList;
  }

  void deleteState() {
    user = null;
    allUserPhones = [];
    // communityMembersMap = {};

    communitiesdb = [];
    objectUnresolvedExpenseMapdb = {};
    communityObjectMapdb = {};

    communities = [];
    communityObjectMap = {};
    objectUnresolvedExpenseMap = {};

    // notifyListeners();
  }

  void communityListen(String creatorTuple) {
    communitiesIndex = communities.indexOf(creatorTuple);
    notifyListeners();
  }

  void objectListen(String communityName, String objectName) {
    objectIndex = communityObjectMap[communityName]!.indexOf(objectName);
    notifyListeners();
  }

  void expenseListen(Expense expense) {
    expenseIndex = objectUnresolvedExpenseMap[expense.creatorTuple]![expense
        .objectName]!
        .indexOf(expense);
    notifyListeners();
  }

  Future<bool> addCommunity(String communityName) async {
    CommunityModel community = CommunityModel(
      name: communityName,
      phoneNo: user!.phoneNo,
      //lastSettledDate: DateTime.now(),
    );
    CommunityModel community2 = CommunityModel(
      name: communityName,
      phoneNo: user!.phoneNo,
      lastSettledDate: DateTime.now(),
    );
    // creating misc object model here
    String? communityID = await CommunityDataBaseService.getCommunityID(
      community,
    );
    ObjectsModel object = ObjectsModel(
      name: "Misc",
      communityID: communityID,
      creatorPhoneNo: community.phoneNo,
      type: "",
      description: "",
    );
    if (await CommunityDataBaseService.createCommunity(community2) == false) {
      return false;
    }

    String creatorTuple = '${communityName}:${user!.phoneNo}';
    communities.add(creatorTuple);
    communityObjectMap[creatorTuple] = ["Misc"];
    objectUnresolvedExpenseMap[creatorTuple] = {};
    communityMembersMap[creatorTuple] = [];
    communityMembersMap[creatorTuple]!.add(
      Member(name: user!.name, phone: user!.phoneNo, isCreator: true),
    );
    communitiesdb!.add(community);

    // added init code here
    communityObjectMapdb![community] = [object];
    objectUnresolvedExpenseMapdb![community] = {};
    objectUnresolvedExpenseMapdb![community]![object] = [];

    // await addObject(communityName, "Misc");
    // communityObjectMap[communityName]?.add("Misc");
    objectUnresolvedExpenseMap[creatorTuple]!["Misc"] = [];

    notifyListeners();
    // removed await
    CommunityDataBaseService.communityAddRemoveNotification(
      community,
      user!.phoneNo,
      true,
    );
    CommunityDataBaseService.addCommunityLogNotification(
      community,
      "Community Created",
    );
    return true;
  }

  Future<bool> addObject(String creatorTuple, String objectName) async {
    notifyListeners();
    List<String> extractedTupleInfo = creatorTuple.split(':');
    String communityName = extractedTupleInfo[0];
    String creatorPhoneNo = extractedTupleInfo[1];
    CommunityModel ctmp = communitiesdb!.firstWhere(
          (element) =>
      element.name == communityName && element.phoneNo == creatorPhoneNo,
    );
    String? communityID = await CommunityDataBaseService.getCommunityID(ctmp);

    //checking if object already present?

    ObjectsModel? otmp = communityObjectMapdb![ctmp]!.firstWhereOrNull(
          (element) => element.name == objectName,
    );

    if (otmp != null) {
      return false;
    }

    ObjectsModel object = ObjectsModel(
      name: objectName,
      communityID: communityID,
      creatorPhoneNo: user!.phoneNo,
      type: "",
      description: "",
    );

    if (ObjectDataBaseService.createObjects(object) == false) {
      return false;
    }

    communityObjectMapdb![ctmp]!.add(object);
    communityObjectMap[creatorTuple]!.add(objectName);
    objectUnresolvedExpenseMap[creatorTuple]![objectName] = [];

    objectUnresolvedExpenseMapdb![ctmp]![object] = [];
    notifyListeners();

    ObjectDataBaseService.ObjectAddNotification(object);
    // removed await
    CommunityDataBaseService.addCommunityLogNotification(
      ctmp,
      "Object Added : " + objectName + " by ${user?.name}",
    );
    return true;
  }

  Future<bool> addExpense(String objectName,
      String creator,
      int amount,
      String expenseDate,
      String description,
      String creatorTuple,
      bool isViewOnly,
      String categoryName,
      String type,
      List<Map<String, dynamic>> memberSplits,
      String paidBy,
      ) async {
    
    if( type == 'Personal' ){
        List<String> extractedTupleInfo = creatorTuple.split(':');
        String communityName = extractedTupleInfo[0];
        String creatorPhoneNo = extractedTupleInfo[1];
        CommunityModel ctmp = communitiesdb!.firstWhere(
              (element) =>
          element.name == communityName && element.phoneNo == creatorPhoneNo,
        );
        DateTime time = DateTime.now().toLocal();
        DateTime dateTime = DateTime.parse(expenseDate);
        expenseDate +=
            " " +
                time.hour.toString() +
                ":" +
                time.minute.toString() +
                ":" +
                time.second.toString() +
                "." +
                time.millisecond.toString();
        dateTime = new DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          time.hour,
          time.minute,
          time.second,
          time.millisecond,
        );

        ObjectsModel otmp = communityObjectMapdb![ctmp]!.firstWhere(
              (element) => element.name == objectName,
        );

        String? objectID = await ObjectDataBaseService.getObjectID(otmp);
        ExpenseModel expense = ExpenseModel(
          creatorID: await UserDataBaseService.getUserID(user!.phoneNo),
          amount: amount.toString(),
          name: description,
          objectID: objectID,
          description: "",
          date: dateTime,
          isViewOnly: isViewOnly,
          category: categoryName,
          type: type,
          memberSplits: [],
          paidBy: paidBy,
        );

        if (ExpenseDataBaseService.createExpense(expense) == false) {
          return false;
        }

        objectUnresolvedExpenseMap[creatorTuple]![objectName]?.add(
          Expense(
            objectName: objectName,
            creator: creator,
            amount: amount,
            date: expenseDate,
            description: description,
            isPaid: false,
            creatorTuple: creatorTuple,
            isViewOnly: isViewOnly,
            category: categoryName,
            type : type,
            
          ),
        );
        objectUnresolvedExpenseMapdb![ctmp]![otmp]!.add(expense);
        notifyListeners();

        // moved these lines from above add function
        // removed await
        ExpenseDataBaseService.ExpenseAddNotification(expense);
        CommunityDataBaseService.addCommunityLogNotification(
          ctmp,
          "Expense Added In ${objectName}: ₹" +
              amount.toString() +
              " by ${user?.name}",
        );

        return true;
    }

    else{
        List<MemberSplit> formattedSplits = memberSplits.map((entry) {
        return MemberSplit(
          memberEmail: entry['email'],
          percent: (entry['percent'] as num).toDouble(),
          isSettled: entry['isSettled'] ?? false,
          );
        }).toList();

        List<String> extractedTupleInfo = creatorTuple.split(':');
        String communityName = extractedTupleInfo[0];
        String creatorPhoneNo = extractedTupleInfo[1];
        CommunityModel ctmp = communitiesdb!.firstWhere(
              (element) =>
          element.name == communityName && element.phoneNo == creatorPhoneNo,
        );
        DateTime time = DateTime.now().toLocal();
        DateTime dateTime = DateTime.parse(expenseDate);
        expenseDate +=
            " " +
                time.hour.toString() +
                ":" +
                time.minute.toString() +
                ":" +
                time.second.toString() +
                "." +
                time.millisecond.toString();
        dateTime = new DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          time.hour,
          time.minute,
          time.second,
          time.millisecond,
        );

        ObjectsModel otmp = communityObjectMapdb![ctmp]!.firstWhere(
              (element) => element.name == objectName,
        );

        String? objectID = await ObjectDataBaseService.getObjectID(otmp);
        ExpenseModel expense = ExpenseModel(
          creatorID: await UserDataBaseService.getUserID(user!.phoneNo),
          amount: amount.toString(),
          name: description,
          objectID: objectID,
          description: "",
          date: dateTime,
          isViewOnly: isViewOnly,
          category: categoryName,
          type: type,
          memberSplits: formattedSplits,
          paidBy: paidBy,
        );

        if (ExpenseDataBaseService.createExpense(expense) == false) {
          return false;
        }

        objectUnresolvedExpenseMap[creatorTuple]![objectName]?.add(
          Expense(
            objectName: objectName,
            creator: creator,
            amount: amount,
            date: expenseDate,
            description: description,
            isPaid: false,
            creatorTuple: creatorTuple,
            isViewOnly: isViewOnly,
            category: categoryName,
            type : type,
          ),
        );
        objectUnresolvedExpenseMapdb![ctmp]![otmp]!.add(expense);
        notifyListeners();

        // moved these lines from above add function
        // removed await
        ExpenseDataBaseService.ExpenseAddNotification(expense);
        CommunityDataBaseService.addCommunityLogNotification(
          ctmp,
          "Expense Added In ${objectName}: ₹" +
              amount.toString() +
              " by ${user?.name}",
        );

        return true;
    }
  }

  Future<bool> updateExpense(Expense expense,
      String newAmount,
      String newDate,
      String newDescription,
      bool isViewOnly,) async {
    List<String> extractedTupleInfo = expense.creatorTuple.split(':');
    String communityName = extractedTupleInfo[0];
    String creatorPhoneNo = extractedTupleInfo[1];

    CommunityModel ctmp = communitiesdb!.firstWhere(
          (element) =>
      element.name == communityName && element.phoneNo == creatorPhoneNo,
    );
    ObjectsModel? otmp = communityObjectMapdb![ctmp]!.firstWhere(
          (element) => element.name == expense.objectName,
    );
    ExpenseModel? rtmp = objectUnresolvedExpenseMapdb![ctmp]![otmp]!.firstWhere(
          (element) => element.name == expense.description,
    );

    if (ExpenseDataBaseService.deleteExpense(rtmp) == false) {
      return false;
    }

    objectUnresolvedExpenseMapdb![ctmp]![otmp]!.remove(rtmp);

    Expense? item = objectUnresolvedExpenseMap[expense.creatorTuple]![expense
        .objectName]
        ?.firstWhere(
          (element) =>
      element.objectName == expense.objectName &&
          element.creator == expense.creator &&
          element.amount == expense.amount &&
          element.description == expense.description,
    );

    objectUnresolvedExpenseMap[expense.creatorTuple]![expense.objectName]
        ?.remove(item);

    DateTime? dateTime = DateTime.tryParse(newDate);
    ExpenseModel expenseM = ExpenseModel(
      creatorID: await UserDataBaseService.getUserID(user!.phoneNo),
      amount: newAmount,
      name: newDescription,
      objectID: await ObjectDataBaseService.getObjectID(otmp),
      description: "",
      date: dateTime,
      isViewOnly: isViewOnly,
      category: "",
      type: "",
      memberSplits: [],
      paidBy: "",
    );

    if (ExpenseDataBaseService.createExpense(expenseM) == false) {
      return false;
    }

    ExpenseDataBaseService.ExpenseEditNotification(
      rtmp,
      expenseM,
      user!.phoneNo,
    );

    objectUnresolvedExpenseMap[expense.creatorTuple]![expense.objectName]?.add(
      Expense(
        objectName: expense.objectName,
        creator: expense.creator,
        amount: int.parse(newAmount),
        date: newDate,
        description: newDescription,
        isPaid: false,
        creatorTuple: expense.creatorTuple,
        isViewOnly: isViewOnly,
        category : expense.category,
        type : expense.type,
      ),
    );

    objectUnresolvedExpenseMapdb![ctmp]![otmp]!.add(expenseM);
    notifyListeners();
    return true;
  }

  addMembersToCommunity(String creatorTuple,
      List<dynamic> names,
      List<dynamic> phones,
      String phoneNo,) async {
    List<String> extractedTupleInfo = creatorTuple.split(":");
    String communityName = extractedTupleInfo[0];
    String creatorPhoneNo = extractedTupleInfo[1];

    for (int i = 0; i < names.length; i++) {
      Member member = Member(
        name: names[i],
        phone: phones[i],
        isCreator: false,
      );
      if (!communityMembersMap[creatorTuple]!.contains(member)) {
        CommunityModel ctmp = communitiesdb!.firstWhere(
              (element) =>
          element.name == communityName &&
              element.phoneNo == creatorPhoneNo,
        );
        if (await CommunityDataBaseService.addUserInCommunity(
          ctmp,
          member.phone,
          false,
        )) {
          communityMembersMap[creatorTuple]!.add(member);
          CommunityDataBaseService.communityAddRemoveNotification(
            ctmp,
            member.phone,
            true,
          );
          await CommunityDataBaseService.addCommunityLogNotification(
            ctmp,
            "Member Added : ${member.name}",
          );
        }
      }
    }
    notifyListeners();
  }

  Future<(bool, String)> addMemberByPhoneNumber(String creatorTuple,
      String phoneNumber,) async {
    String memberName = await UserDataBaseService.getNameFromPhone(phoneNumber);

    if (memberName.isEmpty) {
      return (true, 'User not found');
    }

    List<String> extractedTupleInfo = creatorTuple.split(":");
    String communityName = extractedTupleInfo[0];
    String creatorPhoneNo = extractedTupleInfo[1];

    Member member = Member(
      name: memberName,
      phone: phoneNumber,
      isCreator: false,
    );

    bool memberExistsInCommunity = communityMembersMap[creatorTuple]!.any(
          (existingMember) => existingMember.phone == member.phone,
    );

    if (!memberExistsInCommunity) {
      CommunityModel ctmp = communitiesdb!.firstWhere(
            (element) =>
        element.name == communityName && element.phoneNo == creatorPhoneNo,
      );
      if (await CommunityDataBaseService.addUserInCommunity(
        ctmp,
        member.phone,
        false,
      )) {
        communityMembersMap[creatorTuple]!.add(member);
        CommunityDataBaseService.communityAddRemoveNotification(
          ctmp,
          member.phone,
          true,
        );
        await CommunityDataBaseService.addCommunityLogNotification(
          ctmp,
          "Member Added : ${member.name}",
        );
      }
    } else {
      return (false, 'User already exists in the community');
    }

    notifyListeners();

    return (false, 'User added successfully');
  }

  void removeMemberFromCommunity(String creatorTuple, String phoneNo) async {
    List<String> extractedTupleInfo = creatorTuple.split(":");
    String communityName = extractedTupleInfo[0];
    String creatorPhone = extractedTupleInfo[1];

    CommunityModel ctmp = communitiesdb!.firstWhere(
          (element) =>
      element.name == communityName && element.phoneNo == creatorPhone,
    );
    if (await CommunityDataBaseService.removeUserFromCommunity(ctmp, phoneNo)) {
      Member member = communityMembersMap[creatorTuple]!.firstWhere(
            (element) => element.phone == phoneNo,
      );
      communityMembersMap[creatorTuple]!.remove(member);
      communities.remove(creatorTuple);
      CommunityDataBaseService.communityAddRemoveNotification(
        ctmp,
        phoneNo,
        false,
      );
      await CommunityDataBaseService.addCommunityLogNotification(
        ctmp,
        "No longer in $communityName : ${member.name}",
      );
    }
    notifyListeners();
  }

  void toggleCreatorPower(String creatorTuple, String phoneNo) async {
    List<String> extractedTupleInfo = creatorTuple.split(":");
    String communityName = extractedTupleInfo[0];
    String creatorPhone = extractedTupleInfo[1];

    CommunityModel ctmp = communitiesdb!.firstWhere(
          (element) =>
      element.name == communityName && element.phoneNo == creatorPhone,
    );
    if (await CommunityDataBaseService.toggleCreatorPower(ctmp, phoneNo)) {
      Member member = communityMembersMap[creatorTuple]!.firstWhere(
            (element) => element.phone == phoneNo,
      );
      member.isCreator = !member.isCreator;
      await CommunityDataBaseService.addCommunityLogNotification(
        ctmp,
        "Creator Power Toggled : ${member.name}",
      );
    }
    notifyListeners();
  }

  void addToken() async {
    NotificationServices notificationServices = NotificationServices();
    String token = await notificationServices.getToken();
    if (user != null) {
      UserDataBaseService.addToken(user!.phoneNo, token);
    }
  }

  Future<List<String>> getNotification(String creatorTuple) async {
    List<String> extractedTupleInfo = creatorTuple.split(":");
    String communityName = extractedTupleInfo[0];
    String creatorPhone = extractedTupleInfo[1];

    CommunityModel ctmp = communitiesdb!.firstWhere(
          (element) =>
      element.name == communityName && element.phoneNo == creatorPhone,
    );
    List<String> notification =
    await CommunityDataBaseService.getCommunityNotification(ctmp);
    return notification;
  }

  Future<bool> deleteCommunity(String creatorTuple) async {
    List<String> extractedTupleInfo = creatorTuple.split(":");
    String communityName = extractedTupleInfo[0];
    String creatorPhone = extractedTupleInfo[1];

    CommunityModel ctmp = communitiesdb!.firstWhere(
          (element) =>
      element.name == communityName && element.phoneNo == creatorPhone,
    );

    communitiesdb!.remove(ctmp);
    communityMembersMap.remove(creatorTuple);
    communityObjectMap.remove(creatorTuple);
    communityObjectMapdb!.remove(ctmp);
    objectUnresolvedExpenseMap.remove(creatorTuple);
    objectUnresolvedExpenseMapdb!.remove(ctmp);

    communities.remove(creatorTuple);

    notifyListeners();
    CommunityDataBaseService.deleteCommunity(ctmp);
    return true;
  }

  Future<bool> deleteObject(String creatorTuple, String objectName) async {
    List<String> extractedTupleInfo = creatorTuple.split(":");
    String communityName = extractedTupleInfo[0];
    String creatorPhone = extractedTupleInfo[1];

    CommunityModel ctmp = communitiesdb!.firstWhere(
          (element) =>
      element.name == communityName && element.phoneNo == creatorPhone,
    );
    ObjectsModel otmp = communityObjectMapdb![ctmp]!.firstWhere(
          (element) => element.name == objectName,
    );
    communityObjectMapdb![ctmp]!.remove(otmp);
    objectUnresolvedExpenseMapdb![ctmp]!.remove(otmp);
    communityObjectMap[creatorTuple]!.remove(objectName);
    objectUnresolvedExpenseMap[creatorTuple]!.remove(objectName);
    notifyListeners();
    ObjectDataBaseService.deleteObject(otmp);
    return true;
  }

  Future<bool> isAdmin(String creatorTuple) async {
    List<String> extractedTupleInfo = creatorTuple.split(":");
    String communityName = extractedTupleInfo[0];
    String creatorPhone = extractedTupleInfo[1];

    CommunityModel ctmp = communitiesdb!.firstWhere(
          (element) =>
      element.name == communityName && element.phoneNo == creatorPhone,
    );
    bool res = await UserDataBaseService.isAdmin(ctmp, user!.phoneNo);
    return res;
  }

  // Returns true if the current logged in user is the creator of the expense
  bool isExpenseCreator(String expenseCreator) {
    return user!.name == expenseCreator;
  }

  Future<bool> addRecurringExpense(String creatorTuple,
      int amount,
      String description,
      String expenseDate,
      String frequency,) async {
    try {
      DateTime currentTime = DateTime.now().toLocal();
      DateTime time = DateTime.now().toLocal();
      DateTime dateTime = DateTime.parse(expenseDate);

      expenseDate +=
          " " +
              time.hour.toString() +
              ":" +
              time.minute.toString() +
              ":" +
              time.second.toString() +
              "." +
              time.millisecond.toString();

      dateTime = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        time.hour,
        time.minute,
        time.second,
        time.millisecond,
      );

      RecurringExpenseModel expense = RecurringExpenseModel(
        creatorID: await UserDataBaseService.getUserID(user!.phoneNo),
        creatorTuple: creatorTuple,
        creatorName: user!.name,
        amount: amount.toString(),
        description: description,
        date: dateTime,
        frequency: frequency,
        createdAt: currentTime,
      );

      if (await ExpenseDataBaseService.createRecurringExpense(expense) ==
          false) {
        print("\x1B[31mError parsing date:\x1B[0m"); // Red text
        return false;
      }

      notifyListeners();

      // moved these lines from above add function
      // removed await
      ExpenseDataBaseService.RecurringExpenseAddNotification(expense);

      return true;
    } catch (e) {
      print("Error parsing date: $expenseDate");
      print(e);
      return false;
    }
  }

  Future<List<RecurringExpenseModel>> getRecurringExpenses(
      String creatorTuple,) async {
    return ExpenseDataBaseService.getRecurringExpensesByUserId(creatorTuple);
  }

  Future<void> updateCommunity(String communityName,
      String creatorPhoneNumber,
      String newCommunityName,) async {
    bool res = await CommunityDataBaseService.updateCommunity(
      communityName,
      creatorPhoneNumber,
      newCommunityName,
    );

    await getAllDetails(user!.phoneNo);
  }

  Future<List<(String, String)>> fetchAllRequests(String userPhoneNumber) async
  {
    List<(String, String)> requests = await CommunityDataBaseService
        .fetchAllRequests(
        userPhoneNumber);

    return requests;
  }

  Future<(bool, String)> createRequest(String creatorTuple,
      String phoneNumber,) async {
      String memberName = await UserDataBaseService.getNameFromPhone(phoneNumber);

    if (memberName.isEmpty) {
      return (true, 'User not found');
    }

    List<String> extractedTupleInfo = creatorTuple.split(":");
    String communityName = extractedTupleInfo[0];
    String creatorPhoneNo = extractedTupleInfo[1];

    Member member = Member(
      name: memberName,
      phone: phoneNumber,
      isCreator: false,
    );

    bool memberExistsInCommunity = communityMembersMap[creatorTuple]!.any(
          (existingMember) => existingMember.phone == member.phone,
    );

    if (!memberExistsInCommunity) {
      CommunityModel ctmp = communitiesdb!.firstWhere(
            (element) =>
        element.name == communityName && element.phoneNo == creatorPhoneNo,
      );
      if (await CommunityDataBaseService.addRequest(
        ctmp,
        member.phone
      )) {

        await CommunityDataBaseService.addCommunityLogNotification(
          ctmp,
          "Member Invited : ${member.name}",
        );
      }
    } else {
      return (false, 'User already exists in the community');
    }

    notifyListeners();

    return (false, 'Request Sent Successfully!');
  }

  Future<bool> acceptRequest(String communityID, String phoneNo) async {
    try {
      // Create an instance and call the instance method
      bool result = await CommunityDataBaseService().addMember(
          communityID, phoneNo);
      return result;
    } catch (e) {
      print("Error accepting request: $e");
      return false;
    }
  }

  Future<bool> deleteRequest(String communityID, String phoneNo) async {
    try {
      // Create an instance and call the instance method
      await CommunityDataBaseService().rejectRequest(communityID, phoneNo);
      return true;
    } catch (e) {
      print("Error deleting request: $e");
      return false;
    }
  }
}





