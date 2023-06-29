import 'package:application_project_1/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference _reportCollection =
        FirebaseFirestore.instance.collection("Result");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Result Report'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _reportCollection
            .where('user_id', isEqualTo: uid)
            .where('is_correct', isEqualTo: true)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error occurred",
                style: GoogleFonts.questrial(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var data = snapshot.data!.docs;
          if (data.isEmpty) {
            return Center(
              child: Text(
                "No Data",
                style: GoogleFonts.questrial(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              var document = data[index];
              var icRes = document['icRes'];
              var date = document['date'].toDate();
              var imageUrl = document['image_url'];

              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: ListTile(
                  leading: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Image.network(imageUrl),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                  ),
                  title: Text(
                    icRes,
                    style: GoogleFonts.questrial(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat("dd/MM/yyyy HH:mm").format(date),
                    style: GoogleFonts.questrial(
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
