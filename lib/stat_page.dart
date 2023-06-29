import 'package:application_project_1/home.dart';
import 'package:application_project_1/waste_count_page.dart';
import 'package:flutter/material.dart';

import 'map.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Home();
                  },
                ),
              );
            },
          ),
          title: Text('Statistics'),
        ),
        body: TabBarView(
          children: [
            WasteCountPage(),
            MapPage(),
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(
              text: "Waste Count",
            ),
            Tab(
              text: "Map",
            )
          ],
        ),
      ),
    );
  }
}
