

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapasPage extends StatefulWidget{
  final double latitude;
  final double longetude;

  MapasPage({Key? ke, required this.latitude, required this.longetude}) : super(key: ke);

  @override
  _MapasPageState createState() => _MapasPageState();

}

class _MapasPageState extends State<MapasPage>{
  final _controller = Completer<GoogleMapController>();
  StreamSubscription<Position>? _subscription;

  @override
  void initState(){
    super.initState();
    _monitorarLocalizacao();
  }

  @override
  void dispose(){
    super.dispose();
    _subscription?.cancel();
    _subscription = null;
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Mapa Interno'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: {
          Marker(
            markerId: MarkerId('1'),
            position: LatLng(widget.latitude, widget.longetude),
            infoWindow: InfoWindow(
            title: 'Marcador da localozação inicial do dispositivo',
             ),
          ),
        },
        initialCameraPosition: CameraPosition(target: LatLng(widget.latitude, widget.longetude),
        zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller){
          _controller.complete(controller);
        },
        myLocationEnabled: true,
      ),
    );
  }

  void _monitorarLocalizacao(){
    final LocationSettings locationSettings = LocationSettings(accuracy: LocationAccuracy.high,
        distanceFilter: 100);
    _subscription = Geolocator.getPositionStream(
        locationSettings: locationSettings).listen((Position position) async {
          final controller = await _controller.future;
          final zoom = await controller.getZoomLevel();
          controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
              target: LatLng(widget.latitude, widget.longetude),
            zoom: zoom,
          )));
    });
  }
}