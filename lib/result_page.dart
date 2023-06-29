import 'package:application_project_1/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class ResultPage extends StatefulWidget {
  final File image;
  final List output;

  final double predictionDuration;

  ResultPage(
      {Key? key,
      required this.image,
      required this.output,
      required this.predictionDuration})
      : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final Map<String, String> categoryMapping = {
    'General': 'General',
    'Organic': 'Organic',
    'Recycle - Plastic': 'Recycle',
    'Recycle - Aluminium': 'Recycle',
    'Recycle - Cardboard': 'Recycle',
    'Recycle - Paper': 'Recycle',
    'Hazardous - Battery': 'Hazardous',
    'Hazardous - Blub': 'Hazardous',
  };
  Future<void> saveResult(bool isCorrect, String province) async {
    // Included the province parameter in the method signature
    var uid = FirebaseAuth.instance.currentUser!.uid;

    var res_name = widget.output != null
        ? widget.output[0]['label'].toString().substring(2)
        : '';

    var category = categoryMapping[res_name] ?? 'Unknown'; // Get the category

    // Save image to Firebase Storage
    String imagePath =
        isCorrect ? "/PredictedImage/Correct" : "/PredictedImage/Incorrect";
    final Reference storageReference =
        FirebaseStorage.instance.ref().child(imagePath).child(uid);
    final UploadTask uploadTask = storageReference.putFile(widget.image);

    await uploadTask.whenComplete(
        () => print('Image uploaded to Firebase Storage at $imagePath.'));

    // Get the URL of the uploaded image
    final String imageUrl = await storageReference.getDownloadURL();

    // Construct the result
    var result = {
      'user_id': uid,
      'icRes': res_name,
      'image_url': imageUrl,
      'date': DateTime.now(),
      'duration': widget.predictionDuration,
      'isCorrect': isCorrect,
      'category': category,
      'province': province, // New field for province
    };

    // Save the result in the "Result" collection
    CollectionReference resultsCollection =
        FirebaseFirestore.instance.collection("Result");
    DocumentReference newResultRef = resultsCollection.doc();

    await newResultRef.set(result); // Save data

    print('Result saved in Firestore at /Result/${newResultRef.id}');

    // Increase the corresponding statistics
    var userStatsRef =
        FirebaseFirestore.instance.collection('Statistics').doc(uid);
    var generalStatsRef =
        FirebaseFirestore.instance.collection('Statistics').doc('General');

    // Update the user statistics
    await userStatsRef.set({
      category: FieldValue.increment(1),
      'provinces.$province': FieldValue.increment(1), // New field for province
    }, SetOptions(merge: true));

    // Update the general statistics
    await generalStatsRef.set({
      category: FieldValue.increment(1),
      'provinces.$province': FieldValue.increment(1), // New field for province
    }, SetOptions(merge: true));

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return Home();
    }));
  }

  @override
  Widget build(BuildContext context) {
    Future<String?> _getProvince() async {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      return placemarks[0]
          .administrativeArea; // This usually returns the province
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Result"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                height: 200,
                width: 200,
                child: Image.file(widget.image),
              ),
              widget.output != null
                  ? Text((widget.output[0]['label']).toString().substring(2),
                      style: GoogleFonts.questrial(fontSize: 18))
                  : Text(''),
              widget.output != null
                  ? Text(
                      'Confidence: ' +
                          (widget.output[0]['confidence']).toString(),
                      style: GoogleFonts.questrial(fontSize: 18))
                  : Text(''),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      String? province = await _getProvince();
                      saveResult(true, province!);
                    },
                    child: Text('Correct'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String? province = await _getProvince();
                      saveResult(false, province!);
                    },
                    child: Text('Incorrect'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
