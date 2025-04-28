import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:utilwise/Pages/auth_pages/phone.dart';

import '../../provider/data_provider.dart';

class AddMembers extends StatefulWidget {
  const AddMembers({Key? key, required this.creatorTuple}) : super(key: key);
  final String creatorTuple;

  @override
  State<AddMembers> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMembers> {
  List<Contact>? _contacts;
  bool _permissionDenied = false;
  var selectedContacts = [];

  TextEditingController countryController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String phone = "";
  bool isLoading = false;
  
  @override
  void initState() {
    countryController.text = "  +91";
    super.initState();
    _fetchContacts();
  }

  Future _fetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      setState(() => _permissionDenied = false);
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      setState(() => _contacts = contacts);
    } else {
      setState(() {
        _permissionDenied = true;
        _contacts = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_contacts == null)
      return Center(
        child: CircularProgressIndicator(),
      );
    final providerCommunity = Provider.of<DataProvider>(context, listen: true);
    List<Contact> contactsOnPlatform = [];
    for (var i = 0; i < _contacts!.length; i++) {
      for (var j = 0; j < providerCommunity.allUserPhones.length; j++) {
        if (_contacts![i].phones.isNotEmpty) {
          String phone =
              _contacts![i].phones.first.number.toString().replaceAll(' ', '');
          // only Indian country code
          if (phone.startsWith('+91')) {
            phone = phone.substring(3);
          }
          _contacts![i].phones.first.number = phone;
          bool inComm = false;
          for (var k = 0;
              k <
                  providerCommunity
                      .communityMembersMap[widget.creatorTuple]!.length;
              k++) {
            String memberPhone = providerCommunity
                .communityMembersMap[widget.creatorTuple]![k].phone
                .toString()
                .replaceAll(' ', '');
            if (memberPhone.startsWith('+91')) {
              memberPhone = memberPhone.substring(3);
            }
            if (phone == memberPhone) {
              inComm = true;
              break;
            }
          }
          if (!inComm &&
              phone == providerCommunity.allUserPhones[j].toString()) {
            contactsOnPlatform.add(_contacts![i]);
          }
        }
      }
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF56D0A0),
          title: const Text('Add Members'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            // Add your additional widget here
            Container(
                // Adjust padding as needed
                padding: EdgeInsets.all(25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Phone Number",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
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
                                controller: phoneController,
                            onChanged: (value) {
                              phone = value;
                            },
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter a phone number",
                            ),
                          ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Add members by entering their phone numbers. Unregistered users will receive an invitation to join utilwise.",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Center(
                          child: SizedBox(
                            width: 100, // Set the desired width here
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF56D0A0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        isLoading = true;
                                      });

                                      try {
                                        RegExp regex = RegExp(r'^[0-9]{10}$');
                                        final scaffoldMessenger =
                                            ScaffoldMessenger.of(context);

                                        if (!regex.hasMatch(phone)) {
                                          scaffoldMessenger.showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Please enter a valid phone number'),
                                                duration: Duration(seconds: 2)),
                                          );
                                          return;
                                        }

                                        var (state, message) =
                                            await providerCommunity
                                                .createRequest(
                                                widget.creatorTuple, phone);
                                        phoneController.clear();
                                        scaffoldMessenger.showSnackBar(
                                          SnackBar(
                                              content: Text(message),
                                              duration:
                                                  const Duration(seconds: 2)),
                                        );

                                        if (state) {
                                          final Uri uri = Uri(
                                            scheme: 'sms',
                                            path: phone,
                                            queryParameters: {
                                              'body':
                                                  '''Here’s a link to download utilwise, the utility manager I was telling you about!

https://play.google.com/store/apps/details?id=pranav.com.hello_world&pcampaignid=web_share'''
                                            },
                                          );

                                          await launchUrl(uri);
                                        }
                                      } catch (error) {
                                        print(error);
                                      } finally {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    },
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                )
                // child: YourWidget(), // Replace YourWidget with your desired widget
                ),
            Expanded(
              child: _body(contactsOnPlatform, providerCommunity),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.green.shade50,
          elevation: 0,
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8, top: 4),
                child: FloatingActionButton.extended(
                  backgroundColor: Color(0xFF56D0A0),
                  heroTag: "BTN-12",
                  onPressed: () {
                    giftutilwise();
                  },
                  label: const Text('Share utilwise'),
                  icon: const Icon(Icons.card_giftcard),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _body(contactsOnPlatform, providerCommunity) {
    if (_permissionDenied) return Center(child: Text('Permission denied'));
    if (contactsOnPlatform == null)
      return Center(child: CircularProgressIndicator());
    if (contactsOnPlatform.isEmpty)
      return Center(child: Text('No new contacts found on utilwise!'));

    Future<bool> showAddMemberDialog(BuildContext context) async {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Add Member'),
            content: Text('Are you sure you want to add?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Yes'),
              ),
            ],
          );
        },
      );
      return confirm ?? false;
    }

    return Container(
      child: Column(children: [
        Container(
          height: selectedContacts.isEmpty ? 0 : 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.of(
              selectedContacts.map(
                (contact) => Container(
                  margin: const EdgeInsets.all(0.0),
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 30,
                    child: Text(
                      contact.name.first,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
              child: ListView.builder(
                  itemCount: contactsOnPlatform!.length,
                  itemBuilder: (context, i) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF56D0A0),
                          width: 2.0,
                        ),
                      ),
                      margin: const EdgeInsets.only(top: 5, right: 5, left: 5),
                      padding: const EdgeInsets.all(0),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(contactsOnPlatform![i].displayName[0]),
                        ),
                        title: Text(contactsOnPlatform![i].displayName),
                        subtitle: Text(contactsOnPlatform![i].phones.length > 0
                            ? contactsOnPlatform![i].phones.first.number
                            : '(none)'),
                        trailing: Checkbox(
                          value:
                              selectedContacts.contains(contactsOnPlatform![i]),
                          onChanged: (value) {
                            if (value == true) {
                              setState(() {
                                selectedContacts.add(contactsOnPlatform![i]);
                              });
                            } else {
                              setState(() {
                                selectedContacts.remove(contactsOnPlatform![i]);
                              });
                            }
                          },
                        ),
                      )))),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 50.0, top: 10),
          child: selectedContacts.isEmpty
              ? null
              : FloatingActionButton.extended(
                  heroTag: "BTN-3",
                  onPressed: () async {
                    Future<bool> returnValue = showAddMemberDialog(context);
                    bool alertResponse = await returnValue;
                    if (alertResponse == true) {
                      var selectedNames = selectedContacts
                          .map((contact) => contact.name.first)
                          .toList();
                      var selectedPhones = selectedContacts
                          .map((contact) => contact.phones.first.number)
                          .toList();
                      providerCommunity.addMembersToCommunity(
                          widget.creatorTuple,
                          selectedNames,
                          selectedPhones,
                          MyPhone.phoneNo);
                      Navigator.pop(context);
                    }
                  },
                  label: Row(
                    children: const [
                      Text(
                        "Add Members",
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  )),
        ),
      ]),
    );
  }

  Future<void> giftutilwise() async {
    Share.share(
        '''Here’s a link to download utilwise, the utility manager I was telling you about!

https://play.google.com/store/apps/details?id=pranav.com.hello_world&pcampaignid=web_share''',
        subject: 'Share utilwise');
  }
}
