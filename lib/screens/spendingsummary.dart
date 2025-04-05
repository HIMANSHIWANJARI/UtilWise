import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../provider/data_provider.dart';
import 'package:utilwise/Pages/profile_pages/profile_page.dart';
import 'package:utilwise/Pages/main_pages/no_internet_page.dart';
import 'package:utilwise/Pages/main_pages/navigation_page.dart';
import 'package:utilwise/Pages/group_member_pages/community_info_page.dart';
import 'package:utilwise/Pages/logs_notification_pages/logs_notification.dart';

class SpendingSummaryScreen extends StatefulWidget {
  const SpendingSummaryScreen({super.key,required this.creatorTuple});
  final String creatorTuple;

  @override
  State<SpendingSummaryScreen> createState() => _SpendingSummaryScreenState();
}

class _SpendingSummaryScreenState extends State<SpendingSummaryScreen> {
  

  @override
  Widget build(BuildContext context) {
    final providerCommunity = Provider.of<DataProvider>(context, listen: false);
    return StreamBuilder<bool>(
        stream: connectivityStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!) {
              return buildScaffold(providerCommunity);
            } else {
              return const NoInternetPage();
            }
          } else {
            return buildScaffold(providerCommunity);
          }
        });
  }

  buildScaffold(providerCommunity) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF56D0A0),
        leading: Container(
          width: 30,
          child: IconButton(
            icon: const Icon(
              Icons.menu,
              size: 25,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NavigationPage()),
              );
            },
          ),
        ),
        title: Row(
          children: <Widget>[
            Image.asset(
              '${providerCommunity.extractCommunityImagePathByName(widget.creatorTuple)}',
              width: 20,
              height: 20,
            ),
            SizedBox(width: 5),
            Flexible(
                child: Text(
              (widget.creatorTuple).split(":")[0],
              style: TextStyle(fontSize: 18),
            )),
          ],
        ),
        actions: [
          Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(1),
              child: GestureDetector(
                onTap: () async {
                  List<String> notification = await providerCommunity
                      .getNotification(widget.creatorTuple);

                  // ignore: use_build_context_synchronously
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LogsNotification(
                        creatorTuple: widget.creatorTuple,
                        notification: notification,
                      ),
                    ),
                  );
                },
                child: const Icon(
                  Icons.notifications,
                  size: 20,
                ),
              )),
          Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(1),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommunityInfo(
                        creatorTuple: widget.creatorTuple,
                      ),
                    ),
                  );
                },
                child: const Icon(
                  Icons.group,
                  size: 25,
                ),
              )),
          Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(1),
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    // padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.green.shade50,
                      radius: 15,
                      // radius: kSpacingUnit.w * 10,
                      child: Text(
                        "${providerCommunity.user?.username[0]}",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  )))
        ],
      ),);
  }

    Stream<bool> get connectivityStream =>
      Connectivity().onConnectivityChanged.map((List<ConnectivityResult> result) {
        return result != ConnectivityResult.none;
      });
}


