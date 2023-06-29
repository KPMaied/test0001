import 'package:application_project_1/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:math' as math;

class MapPage extends StatefulWidget {
  MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  late List<Color> colors;
  late List<String> labels;
  late TabController _controller;

  @override
  void initState() {
    super.initState();

    colors = [
      Colors.grey,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.red,
    ];

    labels = ['All Waste', 'General', 'Organic', 'Recycle', 'Hazardous'];

    _controller = TabController(length: colors.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.black,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back),
      //     color: Colors.white,
      //     onPressed: () {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) {
      //             return const Home();
      //           },
      //         ),
      //       );
      //     },
      //   ),
      //   title: const Text('Map'),
      //   bottom: TabBar(
      //     controller: _controller,
      //     tabs: labels.map((String label) => Tab(text: label)).toList(),
      //   ),
      // ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Result').snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');

          Map<String, int> provinceData = Map();

          snapshot.data!.docs.forEach((doc) {
            String province = doc.get('province');
            // String category = doc.get('category');

            // if (_controller.indexIsChanging &&
            //     labels[_controller.previousIndex] == category) {
            provinceData.update(
              province.substring(10),
              (value) => value + 1,
              ifAbsent: () => 1,
            );
            // }
          });

          // // Find the province with maximum waste
          int maxWaste = provinceData.values.reduce(math.max);

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: SfMaps(
              layers: [
                MapShapeLayer(
                  source: MapShapeSource.asset(
                    'assets/map2.json',
                    shapeDataField: 'name',
                    dataCount: provinceData.length,
                    primaryValueMapper: (int index) =>
                        provinceData.keys.elementAt(index),
                    // shapeColorMappers: provinceData.entries.map((e) {
                    //   double intensity = e.value / maxWaste;
                    //   return MapColorMapper(
                    //     value: e.key,
                    //     color: color.withOpacity(intensity),
                    //   );
                    // }).toList(),
                    dataLabelMapper: (index) => '',
                    shapeColorValueMapper: (index) {
                      final key = provinceData.keys.elementAt(index);
                      final scale = provinceData[key]! / maxWaste;

                      return colors[1].withOpacity(scale);
                    },
                  ),
                  strokeColor: Colors.white,
                  strokeWidth: 0.5,
                  showDataLabels: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
