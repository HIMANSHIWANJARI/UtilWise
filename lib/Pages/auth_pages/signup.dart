import 'package:flutter/material.dart';
import 'package:utilwise/Pages/auth_pages/auth-helpers.dart';
import 'package:utilwise/Pages/auth_pages/verify.dart';

class MySignUp extends StatefulWidget {
  const MySignUp({Key? key}) : super(key: key);

  static String verify = "";
  static String phoneNo = "";
  static String name = "";
  static String emailId = "";

  @override
  State<MySignUp> createState() => _MySignUpState();
}

class _MySignUpState extends State<MySignUp> {
  TextEditingController countryController = TextEditingController();
  String phone = "";
  String email = "";
  String nam = "";

  @override
  void initState() {
    countryController.text = " +91";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                "Sign Up",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Enter your information to create an account",
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
                        Icons.person,
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
                        nam = value;
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Username",
                      ),
                    ))
                  ],
                ),
              ),
              SizedBox(
                height: 10,
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
                height: 10,
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
                      child: TextField(
                        controller: countryController,
                        enabled: false,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
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
                        phone = value;
                      },
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Phone Number",
                      ),
                    ))
                  ],
                ),
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
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      if (nam.length < 2) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Username must be at least 2 characters.'),
                              duration: Duration(seconds: 2)),
                        );
                        return;
                      } else if (nam.length > 30) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Username must not be longer than 30 characters.'),
                              duration: Duration(seconds: 2)),
                        );
                        return;
                      }

                      // Match only @iitrpr.ac.in domain
                      // RegExp regex = RegExp(
                      //     r'^[a-zA-Z0-9_.+-]+@(?:(?:[a-zA-Z0-9-]+\.)?[a-zA-Z]+\.)?iitrpr\.ac\.in$');

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

                      regex = RegExp(r'^[0-9]{10}$');
                      if (!regex.hasMatch(phone)) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please enter a valid phone number'),
                              duration: Duration(seconds: 2)),
                        );
                        return;
                      }

                      scaffoldMessenger.showSnackBar(const SnackBar(
                          content: Text('Sending OTP...'),
                          duration: Duration(seconds: 2)));

                      try {
                        await AuthHelper.register(nam, email, phone);

                        MySignUp.phoneNo = phone;
                        MySignUp.emailId = email;
                        MySignUp.name = nam;

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
                              builder: (context) => const MyVerify()),
                        );
                      } catch (error) {
                        String errorMessage = 'Something went wrong 🥺';

                        if (error is Exception) {
                          errorMessage =
                              error.toString().replaceFirst('Exception: ', '');
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
