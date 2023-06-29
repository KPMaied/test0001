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
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Statistics'),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: TabBarView(
            children: [
              WasteCountPage(),
              MapPage(),
            ],
          ),
        ),
        bottomNavigationBar: const TabBar(
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
