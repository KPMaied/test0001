import 'package:application_project_1/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WasteCountPage extends StatelessWidget {
  WasteCountPage({Key? key}) : super(key: key);

  Future<int> getStatsFor(String category, {String? userId}) async {
    Query query;
    if (userId != null) {
      query = FirebaseFirestore.instance
          .collection('Result')
          .where('icRes', isEqualTo: category)
          .where('isCorrect', isEqualTo: true)
          .where('user_id', isEqualTo: userId);
    } else {
      query = FirebaseFirestore.instance
          .collection('Result')
          .where('icRes', isEqualTo: category)
          .where('isCorrect', isEqualTo: true);
    }

    final querySnapshot = await query.get();

    return querySnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final categories = ['General', 'Organic', 'Recycle', 'Hazardous'];

    return Scaffold(
      body: ListView(
        children: <Widget>[
          const Text(
            'User Statistics',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 16),
          for (var category in categories)
            FutureBuilder<int>(
              future: getStatsFor(category, userId: userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  return ListTile(
                    title: Text(category),
                    trailing: Text(snapshot.data.toString()),
                    tileColor: getCategoryColor(category),
                  );
                }
              },
            ),
          const SizedBox(height: 16),
          const Text(
            'All Users Statistics',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 16),
          for (var category in categories)
            FutureBuilder<int>(
              future: getStatsFor(category),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  return ListTile(
                    title: Text(category),
                    trailing: Text(snapshot.data.toString()),
                    tileColor: getCategoryColor(category),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'General':
        return Colors.blue;
      case 'Organic':
        return Colors.green;
      case 'Recycle':
        return Colors.yellow;
      case 'Hazardous':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
