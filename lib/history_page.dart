// import 'package:application_project_1/ResultReport.dart';
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
    CollectionReference _reportCollection = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('result_history');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Result Report',
          style: GoogleFonts.questrial(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _reportCollection.orderBy('date', descending: true).snapshots(),
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

              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: ListTile(
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

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Result Report',
            style: GoogleFonts.questrial(),
          ),
        ),
        body: Consumer(
          builder: (context, ReportProvider provider, child) {
            var count = provider.res_report.length;
            if (count <= 0) {
              return Center(
                child: Text(
                  "No Data",
                  style: GoogleFonts.questrial(
                      fontSize: (30), fontWeight: FontWeight.bold,color: Colors.grey),
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: provider.res_report.length,
                  itemBuilder: (context, int index) {
                    ResultReport data = provider.res_report[index];
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 5),
                      child: ListTile(
                        title: Text(data.icRes,style: GoogleFonts.questrial(
                        fontSize: (20), fontWeight: FontWeight.bold),),
                        subtitle:
                            Text(DateFormat("dd/MM/yyyy HH:mm").format(data.date),style: GoogleFonts.questrial(
                        fontSize: (18))),
                      ),
                    );
                  });
            }
          },
        ));
  }
}
*/
