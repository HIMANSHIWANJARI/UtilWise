import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utilwise/Models/expense.dart';
import 'package:utilwise/screens/settleup.dart';
import 'package:utilwise/screens/settlementsummarypage.dart';
import 'package:provider/provider.dart';

import '../../provider/data_provider.dart';

class SettlePage extends StatefulWidget {

  const SettlePage({super.key,required this.creatorTuple});
  final String creatorTuple;

  @override
  State<SettlePage> createState() => _SettlePageState();
}

class _SettlePageState extends State<SettlePage> {

@override
Widget build(BuildContext context) {
  final providerCommunity = Provider.of<DataProvider>(context, listen: false);
    return DefaultTabController(
      length: 2, // Two tabs
      child: Scaffold(
        appBar: AppBar(
      backgroundColor: const Color(0xFF56D0A0),
      title: Row(
            children: <Widget>[
              Image.asset(
                '${providerCommunity.extractCommunityImagePathByName(widget.creatorTuple)}',
                width: 40,
                height: 40,
              ),
              SizedBox(width: 10),
              Flexible(
                  child: Text(
                (widget.creatorTuple).split(":")[0],
                style: TextStyle(fontSize: 18,),
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
              icon: Icon(Icons.payment, size: 20),
              child: Text(
              "Settle Bills",
              style: TextStyle(fontSize: 12),
            ),
            ),

              Tab(
              icon: Icon(Icons.list_alt, size: 20),
              child: Text(
              "Settlements",
              style: TextStyle(fontSize: 12),
              ),
),

            ],
          ),
    ),
        body: TabBarView(
          children: [
            Settleup(creatorTuple: widget.creatorTuple),
            Settlementsummarypage(creatorTuple: widget.creatorTuple),
          ],
        ),
      ),
    );
  }

}