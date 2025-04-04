import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class AuthHelper {
  static final _db = FirebaseFirestore.instance;

  static Future<void> _sendTwoFactorTokenEmail(
      String email, String token) async {
    String username = dotenv.env['EMAIL']!;
    String password = dotenv.env['PASSWORD']!;

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'UtilMan Team')
      ..recipients.add(email)
      ..subject = '2FA Code'
      ..html = "<p>Your 2FA code: $token (Expires in 10 minutes)</p>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  static Future<void> register(
      String username, String email, String phoneNumber) async {
    // check if username already exists
    final userSnapshot =
        await _db.collection('users').where('Name', isEqualTo: username).get();

    if (userSnapshot.docs.isNotEmpty) {
      throw Exception('That username is taken. Try another.');
    }

    // check if email already exists
    final userSnapshot2 =
        await _db.collection('users').where('Email ID', isEqualTo: email).get();

    if (userSnapshot2.docs.isNotEmpty) {
      throw Exception('Email already exists');
    }

    // check if phone number already exists
    final userSnapshot3 = await await _db
        .collection('users')
        .where('Phone Number', isEqualTo: phoneNumber)
        .get();

    if (userSnapshot3.docs.isNotEmpty) {
      throw Exception('Phone number already exists');
    }

    // check if token already exists
    final tokenSnapshot = await _db
        .collection('twoFactorToken')
        .where('email', isEqualTo: email)
        .get();

    Random random = Random();
    String token = (100000 + random.nextInt(900000)).toString();

    if (tokenSnapshot.docs.isNotEmpty) {
      await _db
          .collection('twoFactorToken')
          .doc(tokenSnapshot.docs.first.id)
          .update({
        'token': token,
        'expiry': DateTime.now().add(const Duration(minutes: 10)),
      });
    } else {
      await _db.collection('twoFactorToken').add({
        'email': email,
        'token': token,
        'expiry': DateTime.now().add(const Duration(minutes: 10)),
      });
    }

    await _sendTwoFactorTokenEmail(email, token);
  }

  static Future<void> verify(String email, String token) async {
    final tokenSnapshot = await _db
        .collection('twoFactorToken')
        .where('email', isEqualTo: email)
        .get();

    if (tokenSnapshot.docs.isEmpty) {
      throw Exception('OTP not found');
    }

    final twoFactorToken = tokenSnapshot.docs.first.data();
    if (twoFactorToken['token'] != token) {
      throw Exception('Invalid OTP');
    }

    final expiry = twoFactorToken['expiry'].toDate();
    if (DateTime.now().isAfter(expiry)) {
      throw Exception('OTP expired');
    }

    await _db
        .collection('twoFactorToken')
        .doc(tokenSnapshot.docs.first.id)
        .delete();
  }

  static Future<String> login(String email) async {
    // check if user exists
    final userSnapshot =
        await _db.collection('users').where('Email ID', isEqualTo: email).get();

    if (userSnapshot.docs.isEmpty) {
      throw Exception('User not found');
    }

    final user = userSnapshot.docs.first.data();

    // check if token already exists
    final tokenSnapshot = await _db
        .collection('twoFactorToken')
        .where('email', isEqualTo: email)
        .get();

    Random random = Random();
    String token = (100000 + random.nextInt(900000)).toString();

    if (tokenSnapshot.docs.isNotEmpty) {
      await _db
          .collection('twoFactorToken')
          .doc(tokenSnapshot.docs.first.id)
          .update({
        'token': token,
        'expiry': DateTime.now().add(const Duration(minutes: 10)),
      });
    } else {
      await _db.collection('twoFactorToken').add({
        'email': email,
        'token': token,
        'expiry': DateTime.now().add(const Duration(minutes: 10)),
      });
    }

    await _sendTwoFactorTokenEmail(email, token);

    return user['Phone Number'];
  }
}
