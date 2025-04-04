import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:utilwise/Models/recurring-expense.dart';

import '../Models/expense.dart';
import './db_communities.dart';
import './db_objects.dart';
import './db_user.dart';

class ExpenseDataBaseService {
  static final _db = FirebaseFirestore.instance;

  static Future<bool> createExpense(ExpenseModel expense) async {
    try {
      final sp = await _db
          .collection('expenses')
          .where("Name", isEqualTo: expense.name)
          .where("ObjectID", isEqualTo: expense.objectID)
          .where("Date", isEqualTo: expense.date)
          .get();

      if (sp.docs.isNotEmpty) {
        return false;
      }
      await _db.collection('expenses').add(expense.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> createRecurringExpense(
      RecurringExpenseModel expense) async {
    try {
      await _db.collection('RecurringExpenses').add(expense.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<RecurringExpenseModel>> getRecurringExpensesByUserId(
      String creatorTuple) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('RecurringExpenses')
          .where('CreatorTuple', isEqualTo: creatorTuple)
          .get();

      List<RecurringExpenseModel> expenses = querySnapshot.docs
          .map((doc) => RecurringExpenseModel.fromJson(
              doc.data() as Map<String, dynamic>))
          .toList();
      expenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return expenses;
    } catch (e) {
      // Handle error if needed
      print("Error fetching recurring expenses: $e");
      return [];
    }
  }

  static Future<String?> getExpenseID(ExpenseModel expense) async {
    try {
      final sp = await _db
          .collection('expenses')
          .where("Name", isEqualTo: expense.name)
          .where("ObjectID", isEqualTo: expense.objectID)
          .get();

      if (sp.docs.isNotEmpty) {
        return sp.docs.first.id;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> deleteExpense(ExpenseModel expense) async {
    try {
      final sp = await _db
          .collection('expenses')
          .where("ObjectID", isEqualTo: expense.objectID)
          .where("CreatorID", isEqualTo: expense.creatorID)
          .where("Amount", isEqualTo: expense.amount)
          .where("Name", isEqualTo: expense.name)
          .get();

      if (sp.docs.isEmpty) {
        return false; // Expense not found
      }

      final expenseDoc = sp.docs.first;
      await expenseDoc.reference.delete();
      return true; // Expense deleted successfully
    } catch (e) {
      return false; // Failed to delete expense
    }
  }

  static Future<List<String>> getTokens(String? CommunityID) async {
    List<String> userID = [];
    await _db
        .collection("communityMembers")
        .where("CommunityID", isEqualTo: CommunityID)
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                userID.add(element.data()['UserID']);
              })
            });

    List<String> tokens = [];
    for (var id in userID) {
      await _db
          .collection("tokens")
          .where("UserID", isEqualTo: id)
          .get()
          .then((value) => {
                value.docs.forEach((element) {
                  tokens.add(element.data()['Token']);
                })
              });
    }

    return tokens;
  }

  static Future<bool> ExpenseAddNotification(ExpenseModel expense) async {
    String communitiesID =
        await ObjectDataBaseService.getCommunityID(expense.objectID);
    String communityName =
        await CommunityDataBaseService.getCommunityName(communitiesID);
    String objectName =
        await ObjectDataBaseService.getObjectName(expense.objectID);

    List<String> tokens = await getTokens(communitiesID);

    for (var token in tokens) {
      var data = {
        'to': token.toString(),
        'priority': 'high',
        'notification': {
          'title': 'Expense Added in ${objectName}',
          'body':
              '${expense.name} has been added in ${objectName} of ${communityName} of Amount ${expense.amount}',
        }
      };

      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          body: jsonEncode(data),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization':
                'key=AAAAsXT8mZo:APA91bEjQMOMbx42wNSYYqsQsFQcQX3QEWrjeSVE0kKtvkxtoJrhhvJvqb2yCjPRHFlQQ05YZRkjgYkHJvNtO0O4n5b8w35-XMNQHda0Y_D7XPoF5oZWRN7U6HhmsymK7hEzK2qrms74'
          });
    }

    return true;
  }

  static Future<bool> RecurringExpenseAddNotification(
      RecurringExpenseModel expense) async {
    String token = '';
    await _db
        .collection("tokens")
        .where("UserID", isEqualTo: expense.creatorID)
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                token = element.data()['Token'];
              })
            });

    var data = {
      'to': token.toString(),
      'priority': 'high',
      'notification': {
        'title': 'New ${expense.frequency} Recurring Expense Added',
        'body':
            '${expense.frequency} Expense of ₹ ${expense.amount} added: ${expense.description}',
      }
    };

    await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAsXT8mZo:APA91bEjQMOMbx42wNSYYqsQsFQcQX3QEWrjeSVE0kKtvkxtoJrhhvJvqb2yCjPRHFlQQ05YZRkjgYkHJvNtO0O4n5b8w35-XMNQHda0Y_D7XPoF5oZWRN7U6HhmsymK7hEzK2qrms74'
        });

    return true;
  }

  static Future<bool> ExpenseEditNotification(
      ExpenseModel OldExpense, ExpenseModel NewExpense, String phoneNo) async {
    String communitiesID =
        await ObjectDataBaseService.getCommunityID(OldExpense.objectID);
    String communityName =
        await CommunityDataBaseService.getCommunityName(communitiesID);
    String objectName =
        await ObjectDataBaseService.getObjectName(OldExpense.objectID);

    List<String> tokens = await getTokens(communitiesID);

    String creatorName = await UserDataBaseService.getNameFromPhone(phoneNo);

    for (var token in tokens) {
      var data = {
        'to': token.toString(),
        'priority': 'high',
        'notification': {
          'title': 'Expense Edited in ${objectName}',
          'body':
              '${OldExpense.name} has been Edited in ${objectName} \nof ${communityName} to ${NewExpense.name} \nof Amount ${NewExpense.amount} by ${creatorName}',
        }
      };

      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          body: jsonEncode(data),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization':
                'key=AAAAsXT8mZo:APA91bEjQMOMbx42wNSYYqsQsFQcQX3QEWrjeSVE0kKtvkxtoJrhhvJvqb2yCjPRHFlQQ05YZRkjgYkHJvNtO0O4n5b8w35-XMNQHda0Y_D7XPoF5oZWRN7U6HhmsymK7hEzK2qrms74'
          });
    }

    return true;
  }
}
