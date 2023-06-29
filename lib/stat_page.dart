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
