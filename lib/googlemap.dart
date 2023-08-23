import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String GoogleApiKEY = "AIzaSyB_fWAykL4Nsqz3r_4ACcMESTjr7y8TfxU";

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key, required this.title});

  final String title;

  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {

  double gettedArea = 0;
  double gettedArea1 = 0;
  List<LatLng> polygonVertices = [];
  final Set<Polygon> polygons = {};
  GoogleMapController? mapController; //contrller for Google map
  final Set<Marker> markers = {}; //markers for google map
  LatLng showLocation = const LatLng(11.004556, 76.961632);

  double calculatePolygonArea(List<LatLng> vertices) {
    double area = 0;
    for (int i = 0; i < vertices.length; i++) {
      LatLng currentPoint = vertices[i];
      LatLng nextPoint = vertices[(i + 1) % vertices.length];
      area += (nextPoint.longitude + currentPoint.longitude) *
          (nextPoint.latitude - currentPoint.latitude);
    }
    // for (int i = 0; i < vertices.length; i++) {
    //   int j = (i + 1) % vertices.length;
    //   area += (vertices[j].latitude + vertices[i].latitude) *
    //       (vertices[j].longitude - vertices[i].longitude);
    // }
    area = (area / 2) / 1000000; // Convert to sq. km
    return area.abs();
  }

  void addPolygon() {
    gettedArea = calculatePolygonArea(polygonVertices);
    print('Polygon Area: $gettedArea sq. km');

    polygons.add(
      Polygon(
        polygonId: PolygonId('my_polygon'),
        points: polygonVertices,
        fillColor: Colors.blue.withOpacity(0.3),
        strokeColor: Colors.blue,
        geodesic: true,
        visible: true,
        strokeWidth: 4,
      ),
    );

    markers.addAll(
      polygonVertices.map(
            (latLng) =>
            Marker(
              markerId: MarkerId('${latLng.latitude}_${latLng.longitude}'),
              position: latLng,
            ),
      ),
    );
  }


  void _addPoint(LatLng point) {
    setState(() {
      polygonVertices.add(point);
      gettedArea1 = gettedArea;
      print('jdfhkhherjdf');
    });

    // if (polygonVertices.length >= 2) {
    //   calculatePolygonArea(polygonVertices);
    // }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map in Flutter"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Stack(
          children: [
            GoogleMap(
              zoomGesturesEnabled: true,
              //enable Zoom in, out on map
              initialCameraPosition: CameraPosition( //innital position in map
                target: showLocation, //initial position
                zoom: 10.0, //initial zoom level
              ),
              onTap: _addPoint,
              markers: markers,
              polygons: polygons,
              mapType: MapType.terrain,
              onMapCreated: (controller) { //method called when map is created
                setState(() {
                  mapController = controller;
                  addPolygon();
                });
              },
            ),
            Column(

              children: [
                Container(
                  color: Colors.white70,
                    child: Text(gettedArea1.toDouble().toString())),
                ElevatedButton(onPressed: () {
                  addPolygon();
                }, child: Text('getArea'))
              ],
            )

          ]
      ),
    );
  }
}





