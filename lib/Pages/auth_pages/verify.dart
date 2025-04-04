import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilwise/Pages/auth_pages/auth-helpers.dart';
import 'package:utilwise/Pages/auth_pages/signup.dart';

import '../../provider/data_provider.dart';

class MyVerify extends StatefulWidget {
  const MyVerify({Key? key}) : super(key: key);

  @override
  State<MyVerify> createState() => _MyVerifyState();
}

class _MyVerifyState extends State<MyVerify> {
  @override
  Widget build(BuildContext context) {
    var code = "";

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
          ),
          elevation: 0,
        ),
        body: Consumer<DataProvider>(
            builder: (context, objectDataProvider, child) {
          return Container(
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
                    "2-Step Verification",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "An email with a 6-digit verification code was just sent to ${MySignUp.emailId}",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Pinput(
                    onChanged: (value) {
                      code = value;
                    },
                    length: 6,
                    showCursor: true,
                    onCompleted: (pin) => print(pin),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
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

                          scaffoldMessenger.showSnackBar(const SnackBar(
                              content: Text('Verifying OTP...'),
                              duration: Duration(seconds: 2)));

                          try {
                            await AuthHelper.verify(MySignUp.emailId, code);

                            DataProvider dataProvider =
                                Provider.of<DataProvider>(context,
                                    listen: false);

                            await dataProvider.addUser(MySignUp.name,
                                MySignUp.emailId, MySignUp.phoneNo);

                            var sharedPref =
                                await SharedPreferences.getInstance();
                            sharedPref.setString("userPhone", MySignUp.phoneNo);

                            await dataProvider.getAllDetails(MySignUp.phoneNo);

                            scaffoldMessenger.removeCurrentSnackBar();

                            Navigator.pushNamedAndRemoveUntil(
                                context, '/home', (route) => false);
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
                                  duration: Duration(seconds: 2)),
                            );
                          }
                        },
                        child: Text("Next")),
                  ),
                  // Row(
                  //   children: [
                  //     TextButton(
                  //         onPressed: () {
                  //           Navigator.pushNamedAndRemoveUntil(
                  //             context,
                  //             'phone',
                  //                 (route) => false,
                  //           );
                  //         },
                  //         child: Text(
                  //           "Edit Phone Number ?",
                  //           style: TextStyle(color: Colors.black),
                  //         )
                  //     )
                  //   ],
                  // )
                ],
              ),
            ),
          );
        }));
  }
}
