import 'dart:io';
import 'package:application_project_1/ResultReport.dart';
import 'package:application_project_1/edit_profile_page.dart';
import 'package:application_project_1/login.dart';
import 'package:application_project_1/history_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
// import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  File? _image;
  late List _output;
  final imagepicker = ImagePicker();
  final auth = FirebaseAuth.instance;
  CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection("users");
  void _logout() async {
    await FirebaseAuth.instance.signOut().then((value) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return LoginPage();
      }));
    });
  }

  bool isModelLoaded = false;
  bool isBusy = false;

  @override
  void initState() {
    super.initState();
    loadmodel();
    // Provider.of<ReportProvider>(context, listen: false).initData();
  }

  loadmodel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/model_01.tflite',
        labels: 'assets/labels.txt',
      );
      isModelLoaded = true;
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  detect_image(File image) async {
    if (!isModelLoaded) {
      print('Model is not loaded');
      return;
    }

    if (isBusy) {
      print('Model is busy. Please wait...');
      return;
    }

    try {
      var startPrediction = DateTime.now();

      isBusy = true;
      var prediction = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 8,
        threshold: 0.2,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      var endPrediction = DateTime.now();
      var duration = endPrediction.difference(startPrediction);
      var durationInMilliseconds = duration.inMilliseconds.toDouble();

      setState(() {
        _output = prediction!;
        _loading = false;
      });

      var uid = auth.currentUser!.uid;

      var res_name =
          _output != null ? _output[0]['label'].toString().substring(2) : '';

      ResultReport result = ResultReport(
        icRes: res_name,
        date: DateTime.now(),
      );

      CollectionReference resultHistoryRef =
          _usersCollection.doc(uid).collection('result_history');

      DocumentReference newResultRef = resultHistoryRef.doc();

      await newResultRef.set({
        'icRes': result.icRes,
        'date': result.date,
      }); //เพิ่ม Data

      // var provider = Provider.of<ReportProvider>(context, listen: false);
      // provider.addResultReport(result);

      print('Inference completed');
    } catch (e) {
      print('Failed to run model: $e');
    } finally {
      isBusy = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  pickimage_camera() async {
    var image = await imagepicker.getImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detect_image(_image!);
  }

  pickimage_gallery() async {
    var image = await imagepicker.getImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detect_image(_image!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Waste Sorting App',
          style: GoogleFonts.questrial(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'history') {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return HistoryPage();
                }));
              } else if (value == 'profile') {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return EditProfilePage();
                }));
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.account_circle_outlined),
                  title: Text('Profile'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'history',
                child: ListTile(
                  leading: Icon(Icons.article_outlined),
                  title: Text('History'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Log Out'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                height: 200,
                width: 200,
                padding: EdgeInsets.all(10),
                child: Image.asset('assets/Bin_White.png'),
              ),
              Container(
                child: Text(
                  'Waste Sorting',
                  style: GoogleFonts.questrial(
                      fontSize: (30), fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  width: 1000,
                  height: 70,
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      pickimage_camera();
                    },
                    child: Text(
                      'Camera',
                      style: GoogleFonts.questrial(
                          fontSize: (25), fontWeight: FontWeight.bold),
                    ),
                  )),
              Container(
                width: 1000,
                height: 70,
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    pickimage_gallery();
                  },
                  child: Text(
                    'Gallery',
                    style: GoogleFonts.questrial(
                        fontSize: (25), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              _loading != true
                  ? Container(
                      child: Column(
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          child: Image.file(_image!),
                        ),
                        _output != null
                            ? Text(
                                (_output[0]['label']).toString().substring(2),
                                style: GoogleFonts.questrial(fontSize: 18))
                            : Text(''),
                        _output != null
                            ? Text(
                                'Confidence: ' +
                                    (_output[0]['confidence']).toString(),
                                style: GoogleFonts.questrial(fontSize: 18))
                            : Text('')
                      ],
                    ))
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
