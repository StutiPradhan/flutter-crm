import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
class LocationTrack extends StatefulWidget {
  const LocationTrack({super.key});

  @override
  State<LocationTrack> createState() => _LocationTrackState();
}

class _LocationTrackState extends State<LocationTrack> {
  Position? _position;

  void _getCurrentLocation() async {
    Position position = await _determinePosition();
    setState(() {
      _position = position;
    });
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied) {
        return Future.error('Location Permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
       final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
    body: SingleChildScrollView(
      child: Padding(
      padding: EdgeInsets.symmetric(
                  horizontal: width * 0.050, vertical: height * 0.25),
      child: Center(
            child: Column(
               children: [
                 _position != null ? Text('Current Location: ' + _position.toString(),style: TextStyle(fontSize: 20),) : Text('No Location Data',style: TextStyle(fontSize: 20),),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(
                  // horizontal: width * 0.00, vertical: height * 0.15),
                  //   child: Column(children: [
                  //         ElevatedButton(onPressed:_getCurrentLocation,child: Text("Know your location",style: TextStyle(fontSize: 15),),)
                  //           ],),
                  // )
               ],
             ),
            
          ),
      ),
    ),
    );
  }
}