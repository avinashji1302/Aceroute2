import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _startLocation = LatLng(28.6201, 77.3767); // Noida Sector 63
  final LatLng _endLocation = LatLng(28.6139, 77.3861); // Noida Sector 73
  final List<LatLng> polylineCoordinates = [];
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getPolyline();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  _getPolyline() async {
    PolylinePoints polylinePoints = PolylinePoints();
    // Create a request object
   /* var request = PolylineRequest(
      origin: PointLatLng(_startLocation.latitude, _startLocation.longitude),
      destination: PointLatLng(_endLocation.latitude, _endLocation.longitude),
      //apiKey: "YOUR_GOOGLE_API_KEY", // Google Maps API Key
     // travelMode: TravelMode.driving,
    //  mode: null,
    );*/

    // Pass the request object to the method
    //PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(request);

    /*if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        _polylines.add(Polyline(
          width: 6,
          polylineId: PolylineId('route'),
          color: Colors.blue,
          points: polylineCoordinates,
        ));
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route from Sector 63 to Sector 73'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _startLocation,
          zoom: 14.0,
        ),
        markers: {
          Marker(markerId: MarkerId('start'), position: _startLocation),
          Marker(markerId: MarkerId('end'), position: _endLocation),
        },
        polylines: _polylines,
      ),
    );
  }
}