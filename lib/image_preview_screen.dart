import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ImagePreviewScreen extends StatefulWidget {
  ImagePreviewScreen({super.key, required this.picture});
  XFile picture;

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  @override
  Widget build(BuildContext context) {
    File pictureTaken = File(widget.picture.path);

    return Scaffold(
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
                  onPressed: () {},
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
}
