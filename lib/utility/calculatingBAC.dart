import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alcohol_logger/utility/user_info.dart';

// gender constants
double maleConstant = 0.68;
double femaleConstant = 0.55;

//alcohol percentage averages
double beerAlcoholPercent = 0.05;
double redWineAlcoholPercent = 0.135;
double whiteWineAlcoholPercent = 0.12;
double cocktailAlcoholPercent = 0.22;

getBloodAlcoholLevel() async {
  final _firestore = FirebaseFirestore.instance; //for the database
  final auth = FirebaseAuth.instance;
  late User loggedInUser;
  double sum = 0;
  double genderConstant = user_Info_Gender == "Male" ? maleConstant : femaleConstant;

  try {
    final user = await auth.currentUser;
    if (user != null) {
      loggedInUser = user;
    }
    var docRef = _firestore.collection('drinks').doc(loggedInUser.email);
    DocumentSnapshot doc = await docRef.get();
    final data = await doc.data() as Map<String, dynamic>;
    String today = DateTime.now().toString().split(" ")[0];
    Map<String, dynamic> drinksForToday = data[today]; //Map<String(drink), Map<String(time), int(oz)>>
    drinksForToday.forEach((k, v) {
      Map<String, dynamic> timeAndOunces = v;
      if (k == "Beer") {
        timeAndOunces.forEach((k, v) {
          sum += ((v * 29.5735 * beerAlcoholPercent * 0.789) / (genderConstant * user_Info_Weight * 454) * 100) -
              (0.015 * DateTime.now().difference(DateTime.parse(k)).inMinutes / 60);
        });
      }
      if (k == "White Wine" || k == "Rose Wine") {
        timeAndOunces.forEach((k, v) {
          sum += ((v * 29.5735 * whiteWineAlcoholPercent * 0.789) / (genderConstant * user_Info_Weight * 454) * 100) -
              (0.015 * DateTime.now().difference(DateTime.parse(k)).inMinutes / 60);
        });
      }
      if (k == "Red Wine") {
        timeAndOunces.forEach((k, v) {
          sum += ((v * 29.5735 * redWineAlcoholPercent * 0.789) / (genderConstant * user_Info_Weight * 454) * 100) -
              (0.015 * DateTime.now().difference(DateTime.parse(k)).inMinutes / 60);
        });
      }
      if (k == "Cocktail") {
        timeAndOunces.forEach((k, v) {
          sum += ((v * 29.5735 * cocktailAlcoholPercent * 0.789) / (genderConstant * user_Info_Weight * 454) * 100) -
              (0.015 * DateTime.now().difference(DateTime.parse(k)).inMinutes / 60);
        });
      }
    });
    print(sum);
  } catch (e) {
    print(e);
  }
}

//get each drink in a list of maps of maps
//ex: [{Beer: {123213.31231: 9}}, {Wine: {123213.1231 : 8}}]   = list<map<String, map<String, dynamic>>>

// go through that list one map at a time, make sure to record the name of the drink and make something to hold the constants
//then go through each time and ounce. calculate bac by time - current time * ounce * drinkConstant and add this to the total BAC for the day
// this will work for the current day, will make it work if the time goes past midnight by checking if the current time is close to midnight
// like 4 or 5 hours off and then we will get the previous days drink as well as the current days drinks.
