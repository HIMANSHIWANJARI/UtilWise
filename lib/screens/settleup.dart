import 'package:flutter/material.dart';

class Settleup extends StatefulWidget {

  const Settleup({super.key,required this.creatorTuple});
  final String creatorTuple;

  @override
  State<Settleup> createState() => _SettleupState();
}

class _SettleupState extends State<Settleup> {
  
    @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF56D0A0),
      title: const Text('Settle Dues'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
  );
}
}