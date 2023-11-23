import 'package:alcohol_logger/utility/bottomNav.dart';
import 'package:alcohol_logger/utility/user_info.dart';
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
final weightTextController = TextEditingController();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String dropdownValue = user_Info_Gender;

  @override
  void initState() {
    super.initState();
    getUserInfo();
    weightTextController.text = user_Info_Weight.toString();
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
                profileData("Name", user_Info_Name),
                const Padding(
                  padding: EdgeInsets.only(left: 30.0),
                  child: Text(
                    "Weight",
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          textAlign: TextAlign.center,
                          onSubmitted: (value) {
                            _firestore.collection("userData").doc(auth.currentUser?.email).update({
                              "weight": int.parse(value),
                            });
                            user_Info_Weight = int.parse(value);
                          },
                          controller: weightTextController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                ),
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
                              _firestore.collection("userData").doc(auth.currentUser?.email).update({
                                "gender": value,
                              });
                              user_Info_Gender = value;
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
