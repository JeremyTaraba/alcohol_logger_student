import 'package:alcohol_logger/helper/image_classification_helper.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_auth/firebase_auth.dart';

final _firestore = FirebaseFirestore.instance; //for the database
final auth = FirebaseAuth.instance;
late User loggedInUser;

Future<void> getCurrentUser() async {
  try {
    final user = await auth.currentUser;
    if (user != null) {
      loggedInUser = user;
    }
  } catch (e) {
    print(e);
  }
}

class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({super.key, required this.picture});
  final XFile picture;

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late final Interpreter interpreter;

  late Tensor inputTensor;

  late Tensor outputTensor;

  img.Image? image;

  late final List<String> labels;

  bool _isProcessing = false;

  late Map<String, double> classification;

  late ImageClassificationHelper imageClassificationHelper;
  List<bool> lights = [];
  List<String> finalClassification = [];

  int ouncesEntered = 0;
  String drinkSelected = "";
  int count = 0;

  @override
  void initState() {
    super.initState();
    tensorFlowSetup();
    _loadLabels();
    getCurrentUser();
    imageClassificationHelper = ImageClassificationHelper();
    imageClassificationHelper.initHelper();
  }

  List<String> sortClassifications() {
    List<String> sortedResults = [];
    double highestPercentage = 0.0;
    int index = 0;
    int index2 = 0;
    classification.forEach((key, value) {
      if (value > highestPercentage) {
        highestPercentage = value;
        sortedResults.add(key);
        index = index2 + 1;
      } else {
        sortedResults.add(key);
      }
      index2++;
    });

    String temp = sortedResults[0];
    sortedResults[0] = sortedResults[index - 1];
    sortedResults[index - 1] = temp;

    return sortedResults;
  }

  @override
  Widget build(BuildContext context) {
    File pictureTaken = File(widget.picture.path);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text("Image Preview"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.lightBlueAccent,
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 1.3,
                child: Image.file(pictureTaken),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              width: double.infinity,
              color: Colors.lightBlueAccent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FloatingActionButton(
                  onPressed: () async {
                    await processImage(pictureTaken);
                    print(sortClassifications());
                    finalClassification = sortClassifications();
                    for (int i = 0; i < finalClassification.length; i++) {
                      lights.add(false);
                    }
                    lights[0] = true;
                    drinkSelected = finalClassification[0];
                    _dialogBuilder(context);
                  },
                  child: const Text(
                    "Analyze",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> tensorFlowSetup() async {
    interpreter = await Interpreter.fromAsset("assets/model.tflite");
    inputTensor = interpreter.getInputTensors().first;
    outputTensor = interpreter.getOutputTensors().first;
    image = img.decodeImage(await File(widget.picture.path).readAsBytes());
  }

  Future<void> _loadLabels() async {
    final labelText = await rootBundle.loadString("assets/labels.txt");
    labels = labelText.split("\n");
  }

  Future<void> processImage(File imagePath) async {
    final imageData = imagePath.readAsBytesSync();
    image = img.decodeImage(imageData);
    setState(() {});
    classification = await imageClassificationHelper.inferenceImage(image!);
    setState(() {});
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Confirm Drink'),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: ListView.separated(
                      itemCount: finalClassification.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(finalClassification[index]),
                                Switch(
                                  value: lights[index],
                                  activeColor: Colors.green,
                                  onChanged: (bool value) {
                                    setState(() {
                                      for (int i = 0; i < lights.length; i++) {
                                        lights[i] = false;
                                      }
                                      lights[index] = value;
                                      drinkSelected = finalClassification[index];
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) => const Divider(),
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: "Enter ounces"),
                    onChanged: (value) {
                      ouncesEntered = int.parse(value);
                    },
                    keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Confirm'),
                onPressed: () async {
                  var docRef = _firestore.collection("drinks").doc(loggedInUser.email);
                  DocumentSnapshot doc = await docRef.get();
                  final data = doc.data() as Map<String, dynamic>;
                  String date = DateTime.now().toString().split(" ")[0];
                  Map<String, int> ouncesAndTime = {DateTime.now().toString(): ouncesEntered};
                  if (data.containsKey(date)) {
                    // if we have logged something today
                    var data2 = data[date]; // map of drinks logged today
                    if (data2.containsKey(drinkSelected)) {
                      // if we have logged the drink today
                      Map<String, dynamic> drinkData = data2[drinkSelected]; //copying the data
                      drinkData[DateTime.now().toString()] = ouncesEntered; //add new drink
                      Map<String, Map<String, dynamic>> submittedInfo = {drinkSelected: drinkData}; // create drink and time
                      await docRef.set({date: submittedInfo}, SetOptions(merge: true)); // updates the database
                    } else {
                      // we have logged something but not this specific drink
                      Map<String, Map<String, int>> submittedInfo = {drinkSelected: ouncesAndTime};

                      await docRef.set({date: submittedInfo}, SetOptions(merge: true));
                    }
                  } else {
                    // if we have never logged anything today
                    Map<String, Map<String, int>> submittedInfo = {drinkSelected: ouncesAndTime};

                    await docRef.set({date: submittedInfo}, SetOptions(merge: true));
                  }

                  Navigator.popUntil(context, (route) {
                    return count++ == 2;
                  });
                },
              ),
            ],
          );
        });
      },
    );
  }
}
