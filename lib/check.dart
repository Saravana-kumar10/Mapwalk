
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class Check extends StatefulWidget{
  @override
  _CheckState createState() => _CheckState();
}

class _CheckState extends State<Check> {

  GoogleMapController? mapController; //contrller for Google map
  Set<Marker> markers = Set(); //markers for google map
  Set<Polyline> polylines={};

  LatLng loc1 = LatLng(27.6602292, 85.308027);

  int numDeltas = 50; //number of delta to devide total distance
  int delay = 50; //milliseconds of delay to pass each delta
  var i = 0;
  double? deltaLat;
  double? deltaLng;
  var position; //position variable while moving marker

  late LatLng pos1; //positions for polylines
  late LatLng pos2;

  @override
  void initState() {
    position = [loc1.latitude, loc1.longitude]; //initial position of moving marker
    pos1 = loc1;
    pos2 = loc1;
    addMarkers();
    super.initState();
  }

  addMarkers() async {
    markers.add(
        Marker(
            markerId: MarkerId(loc1.toString()),
            position: loc1,
            icon: BitmapDescriptor.defaultMarker
        )
    );

    setState(() {
      //refresh UI
    });
  }

  transition(result){
    i = 0;
    deltaLat = (result[0] - position[0])/numDeltas;
    deltaLng = (result[1] - position[1])/numDeltas;
    moveMarker();
  }

  moveMarker(){
    position[0] += deltaLat;
    position[1] += deltaLng;
    var latlng = LatLng(position[0], position[1]);

    markers = {
      Marker(
        markerId: MarkerId("movingmarker"),
        position: latlng,
        icon: BitmapDescriptor.defaultMarker,
      )
    };

    pos1 = pos2;
    pos2 = LatLng(position[0], position[1]);

    polylines.add(Polyline(
      polylineId: PolylineId(pos2.toString()),
      visible: true,
      width: 5, //width of polyline
      points: [
        pos1,
        pos2,
      ],
      color: Colors.deepPurpleAccent, //color of polyline
    ));

    setState(() {
      //refresh UI
    });


    if(i!=numDeltas){
      i++;
      Future.delayed(Duration(milliseconds: delay), (){
        moveMarker();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text("Move Marker Position on Google Map"),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        floatingActionButton: FloatingActionButton(
          child: Text("Move"),
          onPressed: (){
            var result = [27.661838, 85.308543];
            //latitude and longitude of new position

            transition(result);
            //start moving marker
          },
        ),
        body: GoogleMap( //Map widget from google_maps_flutter package
          zoomGesturesEnabled: true, //enable Zoom in, out on map
          initialCameraPosition: CameraPosition( //innital position in map
            target: loc1, //initial position
            zoom: 14.0, //initial zoom level
          ),
          markers: markers, //markers to show on map
          polylines: polylines, //polylines list
          mapType: MapType.normal, //map type
          onMapCreated: (controller) { //method called when map is created
            setState(() {
              mapController = controller;
            });
          },
        )
    );
  }
}






















//
