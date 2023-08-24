import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';




class Walk extends StatefulWidget {
  const Walk({super.key});

  @override
  State<Walk> createState() => _WalkState();
}

class _WalkState extends State<Walk> {
  Location location=new Location();
 LatLng showLocation =LatLng(11.004556, 76.961632);

  MapType _currentMapType = MapType.normal;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers={};
  final Set<Polyline> polyline={};
  List<LatLng> polylinevertices=[];
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller.complete(controller);


    });

  }
  void initState(){
    super.initState();
    getLocation();
  }
  void _onMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.hybrid
          : MapType.normal;
    });
  }

  ///permission
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  ///get location
  getLocation() async {
    Position position = await _determinePosition();
    _markers.clear();
    setState(() {
      polylinevertices.add(LatLng(position.latitude,position.longitude));
      setState(() {
        _markers.add(
            Marker(
              markerId: MarkerId(position.toString()),
              position: LatLng(position.latitude,position.longitude),
              infoWindow: InfoWindow(
                title: 'Lat=${position.latitude.toStringAsFixed(3)},Long:${position.longitude.toStringAsFixed(3)}',
              ),
              icon:
              BitmapDescriptor.defaultMarker,
              onDragEnd:  ((LatLng newPosition) {

              }),

            ));
      });
      polyline.add(
          Polyline(polylineId: PolylineId("1"),
              points: polylinevertices,
              color: Colors.blue

          )
      );
    }  );
    CameraPosition cameraPosition = new CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 24,
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {});
    location.onLocationChanged.listen((LocationData ) {
      print(LocationData);
      var loca=LocationData;
      setState(() {
        polylinevertices.add(LatLng(loca!.latitude!,loca!.longitude!));

        polyline.add(
            Polyline(polylineId: PolylineId("1"),
                points: polylinevertices,
                color: Colors.blue

            )
        );
      });

          });

  }
  ///
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

        body: Stack(
            children:[
              GoogleMap(
                //polygons: polygons,
               // polylines: polyline,
                myLocationEnabled: true,

               markers: _markers,
                mapType: _currentMapType,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: showLocation,

                  zoom: 12,
                ),
                //onTap:_addPoint ,

                myLocationButtonEnabled: true,


              ),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FloatingActionButton(
                      onPressed:_onMapType,
                      child:   Icon(Icons.change_circle),
                    ),

                  )
              ),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: FloatingActionButton(
                      onPressed:getLocation,
                      child:   Column(
                        children: [
                          Icon(Icons.location_on_outlined),
                          Text("start")
                        ],
                      ),
                    ),

                  )
              ),






//

            ]
        ),
      ),
    );;
  }
}
