import 'package:alcohol_logger/utility/bottomNav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const List<String> list = <String>[
  'Prefer not to say',
  'Male',
  'Female',
];

final auth = FirebaseAuth.instance;
final FlutterSecureStorage _storage = FlutterSecureStorage();
int count = 0;
late User loggedInUser;
final _firestore = FirebaseFirestore.instance;
Map<String, dynamic> userInformation = {};

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String dropdownValue = list.first;

  getUserInfo(Map<String, dynamic> userInformation) async {
    try {
      final user = await auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
      var docRef = _firestore.collection('userData').doc(loggedInUser.email);
      DocumentSnapshot doc = await docRef.get();
      final data = await doc.data() as Map<String, dynamic>;
      setState(() {
        userInformation = data;
        print(userInformation);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getUserInfo(userInformation);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileData("Name", userInformation["name"] == null ? "" : "hi"),
                profileData("Weight", "100"),
                const Padding(
                  padding: EdgeInsets.only(left: 30.0),
                  child: Text(
                    "Gender",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.lightBlueAccent, width: 3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          value: dropdownValue,
                          icon: const Icon(Icons.arrow_drop_down),
                          elevation: 0,
                          style: const TextStyle(fontSize: 24, color: Colors.black),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              dropdownValue = value!;
                            });
                          },
                          items: list.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                profileData("Email", auth.currentUser?.email ?? 'hello'),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                        onPressed: () async {
                          auth.signOut();
                          await _storage.deleteAll();
                          Navigator.popUntil(context, (route) {
                            return count++ == 2;
                          });
                        },
                        child: Text(
                          "Logout",
                          style: TextStyle(fontSize: 24),
                        )),
                  ),
                )
              ],
            ),
          ),
          bottomNavigationBar: BottomNav(
            selectedIndex: 0,
          ),
        ),
      ),
    );
  }

  Widget profileData(String title, String Data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Text(
              "$title",
              style: TextStyle(fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.lightBlueAccent, width: 3),
              ),
              child: Center(
                child: Text(
                  "$Data",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
