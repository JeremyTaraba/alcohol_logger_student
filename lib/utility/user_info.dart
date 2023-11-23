import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String user_Info_Name = "";
late int user_Info_Weight;
late String user_Info_Gender;

getUserInfo() async {
  final _firestore = FirebaseFirestore.instance; //for the database
  final auth = FirebaseAuth.instance;
  late User loggedInUser;

  try {
    final user = await auth.currentUser;
    if (user != null) {
      loggedInUser = user;
    }
    var docRef = _firestore.collection('userData').doc(loggedInUser.email);
    DocumentSnapshot doc = await docRef.get();
    final data = await doc.data() as Map<String, dynamic>;

    user_Info_Name = data["name"];
    user_Info_Weight = data["weight"];
    user_Info_Gender = data["gender"];
  } catch (e) {
    print(e);
  }
}
