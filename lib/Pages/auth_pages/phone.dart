import 'package:flutter/material.dart';
import 'package:utilwise/Pages/auth_pages/auth-helpers.dart';

import 'signup.dart';
import 'verify_l.dart';

class MyPhone extends StatefulWidget {
  const MyPhone({Key? key}) : super(key: key);

  static String verify = "";
  static String phoneNo = "";
  static String email = "";

  @override
  State<MyPhone> createState() => _MyPhoneState();
}

class _MyPhoneState extends State<MyPhone> {
  String email = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/img1.png',
                width: 150,
                height: 150,
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                "Login",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Enter your email below to login to your account",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                height: 55,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 40,
                      child: Icon(
                        Icons.mail,
                      ),
                    ),
                    Text(
                      "|",
                      style: TextStyle(fontSize: 33, color: Colors.grey),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: TextField(
                      onChanged: (value) {
                        email = value;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Email",
                      ),
                    ))
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF56D0A0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () async {
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);

                            RegExp regex = RegExp(
                                r'^([a-z0-9_.-]+)@([\da-z.-]+)\.([a-z.]{2,6})$');

                            if (!regex.hasMatch(email)) {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                    content: Text('Please enter a valid email'),
                                    duration: Duration(seconds: 2)),
                              );
                              return;
                            }

                            scaffoldMessenger.showSnackBar(const SnackBar(
                                content: Text('Sending OTP...'),
                                duration: Duration(seconds: 2)));

                            try {
                              String phoneNumber =
                                  await AuthHelper.login(email);

                              MyPhone.phoneNo = phoneNumber;
                              MyPhone.email = email;

                              scaffoldMessenger.removeCurrentSnackBar();

                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'OTP sent successfully. Please check your email.'),
                                    duration: Duration(seconds: 2)),
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MyVerifyL()),
                              );
                            } catch (error) {
                              String errorMessage = 'Something went wrong 🥺';

                              if (error is Exception) {
                                errorMessage = error
                                    .toString()
                                    .replaceFirst('Exception: ', '');
                              }

                              scaffoldMessenger.removeCurrentSnackBar();

                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                    content: Text(errorMessage),
                                    duration: const Duration(seconds: 2)),
                              );
                            }
                          },
                          child: Text("Login")),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF56D0A0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MySignUp()),
                            );
                          },
                          child: Text("Sign Up")),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
