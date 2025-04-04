import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilwise/Pages/main_pages/community_page.dart';
import 'package:utilwise/components/member.dart';

import '../../provider/data_provider.dart';

class NavigationPage extends StatefulWidget {
  //const NavigationPage({Key? key}) : super(key: key);
  const NavigationPage({super.key});

  @override
  NavigationPageState createState() => NavigationPageState();
}

class NavigationPageState extends State<NavigationPage> {
  int clickedCommunity = 0;
  String communityName = "";
  Random random = Random();

  @override
  Widget build(BuildContext context) {
    final providerCommunity = Provider.of<DataProvider>(context, listen: false);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: Color(0xFF56D0A0),
          title: Text('Communities'),
        ),
      ),
      body: Consumer<DataProvider>(
        builder: (context, communityDataProvider, child) {
          return Column(
            children: [
              // Container(
              //   height: 50,
              //   margin: const EdgeInsets.only(
              //       left: 10.0, right: 10.0, top: 20.0, bottom: 10.0),
              //   padding: const EdgeInsets.only(
              //       left: 10.0, right: 10.0, top: 0.0, bottom: 0.0),
              //   decoration: BoxDecoration(
              //     // borderRadius: BorderRadius.circular(10),
              //     border: Border.all(
              //       color: Color(0xFF56D0A0),
              //       width: 1,
              //     ),
              //     borderRadius: BorderRadius.circular(10),
              //     color: Colors.green.shade50,
              //     boxShadow: const [
              //       BoxShadow(
              //         color: Colors.black26,
              //         blurRadius: 2,
              //         spreadRadius: 0,
              //         offset: Offset(0, 1),
              //       ),
              //     ],
              //   ),
              //   child: GestureDetector(
              //     onTap: () {
              //       // Handle item click
              //     },
              //     child: ListTile(
              //         tileColor: Color(0xFF56D0A0),
              //         title: Row(children: [
              //           Icon(
              //             Icons.explore,
              //             size: 18,
              //             color: Color(0xFF56D0A0),
              //           ),
              //           SizedBox(
              //             width: 20,
              //           ),
              //           Text(
              //             'Communities',
              //             style: TextStyle(fontSize: 18.0),
              //           ),
              //         ])),
              //   ),
              // ),
              Container(
                height: 50,
                margin:
                    const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Color(0xFF56D0A0),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green.shade50,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      spreadRadius: 0,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    // Handle item click
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: ListTile(
                      tileColor: Color(0xFF56D0A0),
                      title: Row(children: [
                        Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: Color(0xFF56D0A0),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Go home',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ])),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                    vertical: 10.0), // Margin top and bottom
                child: Divider(
                  color: Colors.green,
                ),
              ),
              communityDataProvider.communities.isEmpty
                  ? Expanded(
                      child: Center(
                          child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: const Text(
                            'Any community you\'re added to will appear here.',
                            style: TextStyle(
                              fontSize: 18,
                            )),
                      )),
                    )
                  : Expanded(child: SingleChildScrollView(
                      child: Column(children:
                          List.of(communityDataProvider.communities.map((e) {
                        int k =
                            communityDataProvider.communities.indexOf(e) + 1;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              communityName = e;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 10.0, right: 10.0, bottom: 10.0),
                            padding: const EdgeInsets.only(
                                left: 10.0, right: 10.0, top: 0.0, bottom: 0.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF56D0A0),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.green.shade50,
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: FloatingActionButton(
                                        heroTag: "${random.nextInt(1000000)}",
                                        elevation: 0,
                                        onPressed: () {
                                          try {
                                            String imagePath = providerCommunity
                                                    .extractCommunityImagePathByName(
                                                        e) ??
                                                'default_image_path';

                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                              _createRoute(e),
                                              ModalRoute.withName('/home'),
                                            );
                                          } catch (error) {
                                            // Log the error or perform other actions (e.g., show a default image)
                                            print(
                                                'Error retrieving image path: $error');
                                          }
                                        },
                                        child: ListTile(
                                          leading: Image.asset(
                                            '${providerCommunity.extractCommunityImagePathByName(e)}',
                                            width: 45,
                                          ),
                                          tileColor: Colors.green.shade50,
                                          title: Text(e.split(":")[0] +
                                              " - " +
                                              (providerCommunity
                                                      .communityMembersMap[e]
                                                      ?.firstWhere(
                                                    (member) =>
                                                        member.phone ==
                                                        (e).split(":")[1],
                                                    orElse: () {
                                                      Member? creatorMember = providerCommunity
                                                          .communityMembersMap[
                                                              e]
                                                          ?.firstWhere(
                                                              (member) =>
                                                                  member.isCreator ==
                                                                  true,
                                                              orElse: () => Member(
                                                                  name:
                                                                      'Unknown',
                                                                  isCreator:
                                                                      false,
                                                                  phone:
                                                                      'phone'));
                                                      return creatorMember ??
                                                          Member(
                                                              name: 'Unknown',
                                                              isCreator: false,
                                                              phone: 'phone');
                                                    },
                                                  ).name ??
                                                  'Loading...')),
                                        ),
                                      ),
                                    ),
                                  ]),
                            ), // margin: const EdgeInsets.only(top: 20.0),
                          ),
                        );
                      }))),
                    ))
            ],
          );
        },
      ),
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
