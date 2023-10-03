import 'dart:async';
import 'dart:math';
 import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'package:flutter/material.dart';
import 'dart:math' as Math;

import 'mathutil.dart';











class mtrack extends StatefulWidget {
  const mtrack({super.key});

  static const LatLng _center =  LatLng(45.521563, -122.677433);

  @override
  State<mtrack> createState() => _mtrackState();
}

class _mtrackState extends State<mtrack> {
  bool clk=true;
  int count=0;
  List<LatLng> polygonVertices = [];

  final Set<Polygon> polygons = {};
  final Set<Polyline> polyline={};
  List<LatLng> polylinevertices=[];

  Set<Marker> _markers={};


  LatLng showLocation =  LatLng(11.004556, 76.961632);




  var dist,km,rearea,acre;
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






  void _addPoint(LatLng point) {
    if(clk)
      {
        setState(() {
          polygonVertices.add(point);
          setState(() {
            _markers.add(
                Marker(
                  markerId: MarkerId(point.toString()),
                  position: point,
                  infoWindow: InfoWindow(
                    title: 'Lat=${point.latitude.toStringAsFixed(3)},Long:${point.longitude.toStringAsFixed(3)}',
                  ),
                  icon:
                  BitmapDescriptor.defaultMarker,
                  onDragEnd:  ((LatLng newPosition) {

                  }),

                ));
          });
          polygons.add(
              Polygon(
                polygonId: PolygonId('my_polygon'),
                points: polygonVertices,
                fillColor: Colors.blue.withOpacity(0.3),
                strokeColor: Colors.amberAccent,
                geodesic: true,
                consumeTapEvents: true,
                visible: true,
                strokeWidth: 4,
              )
          );

        }  );
      }
    else

      {

        setState(() {
          polylinevertices.add(point);
          setState(() {
            _markers.add(
                Marker(
                  markerId: MarkerId(point.toString()),
                  position: point,
                  infoWindow: InfoWindow(
                    title: 'Lat=${point.latitude.toStringAsFixed(3)},Long:${point.longitude.toStringAsFixed(3)}',
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


      }





  }


  calculatearea (){
    final p1=polygonVertices[0];
    final p2=polygonVertices[1];
    final p3=polygonVertices[2];
    final p4=polygonVertices[3];
    return computeArea([p1,p2,p3,p4,p1]);



  }

  void addPolygon() {


 polyline.add(
   Polyline(polylineId: PolylineId("1"),
   points: polygonVertices,
     color: Colors.blue
 )
 );

  }

  double calculateDistance(){

    double lat1=polylinevertices[0].latitude;
    double lat2=polylinevertices[1].latitude;
    double lon1=polylinevertices[0].longitude;
    double lon2=polylinevertices[1].longitude;





    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));

  }

  MapType _currentMapType = MapType.normal;
  Completer<GoogleMapController> _controller = Completer();
  void _onMapCreated(GoogleMapController controller) {
   setState(() {
     _controller.complete(controller);

   });

  }
  void _onMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.hybrid
          : MapType.normal;
    });
  }
  getLocation() async {
    Position position = await _determinePosition();


    _markers.clear();
    _markers.add(Marker(
        markerId:  MarkerId(position.toString()),
        position: LatLng(position.latitude, position.longitude)));
    CameraPosition cameraPosition = new CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 24,
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

        body: Stack(
          children:[
            GoogleMap(
              polygons: polygons,
              polylines: polyline,

              markers: _markers,
              mapType: _currentMapType,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: showLocation,
              zoom: 12,
            ),
              onTap:_addPoint ,

              myLocationButtonEnabled: true,


          ),
            Row(children: [
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
                    alignment: Alignment.topCenter,
                    child: FloatingActionButton(
                      onPressed:(){
                        if(clk){
                          setState(() {
                            clk=false;
                          });
                        }
                        else
                        {
                         setState(() {
                           clk=true;
                         });
                        }




                      },
                      child:  clk? Icon(Icons.check_box_outline_blank):Icon(Icons.line_axis),
                    ),

                  )
              ),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: FloatingActionButton(
                      onPressed:(){

                        rearea=calculatearea();
                        acre=calculatearea()*0.000247105;




                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:  Column(
                            children: [

                              Text('AREA=${rearea.toString()}'),
                              Text('Acres=${acre.toString()}'),
                            ],
                          ),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              setState(() {
                                _markers.clear();
                                polygonVertices.clear();
                                polygons.clear();
                                polylinevertices.clear();

                              });
                            },
                          ),
                        )
                        );
                      },
                      child: Column(
                        children: [
                          const Icon(Icons.track_changes),
                          Text("AREA")
                        ],
                      ),
                    ),

                  )
              ),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: FloatingActionButton(
                      onPressed:(){
                        dist=calculateDistance()*1000;
                        km=calculateDistance();





                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:  Column(
                            children: [
                              Text('${dist.toString()}.meters'),
                              Text('${km.toString()}.km'),

                            ],
                          ),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              setState(() {
                                _markers.clear();
                                polygonVertices.clear();
                                polygons.clear();
                                polylinevertices.clear();

                              });
                            },
                          ),
                        )
                        );
                      },
                      child: Column(
                        children: [
                          const Icon(Icons.social_distance),
                          Text("distance")
                        ],
                      ),
                    ),

                  )
              ),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: FloatingActionButton(
                      onPressed:() async {
                        Position position = await _determinePosition();


                        _markers.clear();
                        _markers.add(Marker(
                            markerId:  MarkerId(position.toString()),
                            position: LatLng(position.latitude, position.longitude)));
                        CameraPosition cameraPosition = new CameraPosition(
                          target: LatLng(position.latitude, position.longitude),
                          zoom: 24,
                        );
                        final GoogleMapController controller = await _controller.future;
                        controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

                        setState(() {});
                      }
                      ,
                      child: Column(
                        children: [
                          const Icon(Icons.location_on),
                          Text("current location")
                        ],
                      ),
                    ),

                  )
              ),

            ],)





//
          
          ]
        ),
      ),
    );

  }
 static const num earthRadius=6371009.0;
  static num computeArea(List<LatLng> path) => computeSignedArea(path).abs();


  static num computeSignedArea(List<LatLng> path) =>
      _computeSignedArea(path, earthRadius);


  static num _computeSignedArea(List<LatLng> path, num radius) {
    if (path.length < 3) {
      return 0;
    }

    final prev = path.last;
    var prevTanLat = tan((pi / 2 - MathUtil.toRadians(prev.latitude)) / 2);
    var prevLng = MathUtil.toRadians(prev.longitude);

    // For each edge, accumulate the signed area of the triangle formed by the
    // North Pole and that edge ("polar triangle").
    final total = path.fold<num>(0.0, (value, point) {
      final tanLat = tan((pi / 2 - MathUtil.toRadians(point.latitude)) / 2);
      final lng = MathUtil.toRadians(point.longitude);

      value += _polarTriangleArea(tanLat, lng, prevTanLat, prevLng);

      prevTanLat = tanLat;
      prevLng = lng;

      return value;
    });

    return total * (radius * radius);
  }


  static num _polarTriangleArea(num tan1, num lng1, num tan2, num lng2) {
    final deltaLng = lng1 - lng2;
    final t = tan1 * tan2;
    return 2 * atan2(t * sin(deltaLng), 1 + t * cos(deltaLng));
  }
}
