import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Pages/main_pages/community_page.dart';
import '../../provider/data_provider.dart';

class CommunityScreen2 extends StatefulWidget {
  const CommunityScreen2({Key? key}) : super(key: key);

  @override
  State<CommunityScreen2> createState() => CommunityData();
}

class CommunityData extends State<CommunityScreen2> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController communityName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final providerCommunity = Provider.of<DataProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF56D0A0),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20.0),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.car_repair_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                const Text(
                  'Add Car',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(
                  height: 10,
                ),

                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    icon: Icon(Icons.home_work),
                    hintText: 'Enter the Car Name',
                  ),
                  controller: communityName,
                ),

                SizedBox(
                  height: 10,
                ),

                // TextFormField(
                //   decoration: const InputDecoration(
                //     icon: Icon(Icons.edit),
                //     hintText: 'Remark',
                //   ),
                // ),
                Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: FloatingActionButton(
                      backgroundColor: Color(0xFF56D0A0),
                      heroTag: "BTN-19",
                      // added empty comm check
                      onPressed: () async {
                        if (communityName.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please enter the car name'),
                                  duration: Duration(seconds: 3)));
                          return;
                        }

                        // CHANGED HERE

                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Adding Car'),
                                duration: Duration(seconds: 8)));

                        bool res = await providerCommunity
                            .addCommunity(communityName.text);

                        String community_Name = communityName.text;
                        String? currentUserPhoneNumber =
                            providerCommunity.user?.phoneNo;

                        String creatorTuple =
                            '${community_Name}:${currentUserPhoneNumber}';
                        // await Future.delayed(Duration(seconds: 2));

                        bool res1 = await providerCommunity.addObject(
                            creatorTuple, "Repair");

                        bool res2 = await providerCommunity.addObject(
                            creatorTuple, "Fuel");

                        bool res3 = await providerCommunity.addObject(
                            creatorTuple, "Tyres");

                        bool res4 = await providerCommunity.addObject(
                            creatorTuple, "Car Wash");

                        bool res5 = await providerCommunity.addObject(
                            creatorTuple, "Insurance");

                        ScaffoldMessenger.of(context).removeCurrentSnackBar();

                        if (!res) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Error in Adding Car'),
                                  duration: Duration(seconds: 1)));
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Car Added'),
                                  duration: Duration(seconds: 1)));
                          Navigator.pop(context);

                          await Future.delayed(Duration(seconds: 1));

                          await providerCommunity
                              .getCommunityDetails(creatorTuple);
                          // await Future.delayed(Duration(seconds: 5));
                          // Navigator.of(context)
                          //     .push(_createRoute(community_Name));
                        }
                      },
                      child: const Icon(Icons.check),
                    )),
              ],
            ),
          )),
    );
  }
}

Route _createRoute(String communityName) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        CommunityPage(creatorTuple: communityName),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
