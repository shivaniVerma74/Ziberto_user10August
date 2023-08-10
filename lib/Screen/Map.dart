import 'dart:async';
import 'dart:math';

import 'package:eshop_multivendor/Screen/Add_Address.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Helper/Color.dart';
import '../Helper/Session.dart';
import 'package:map_picker/map_picker.dart';

class Map extends StatefulWidget {
  final double? latitude, longitude;
  final String? from;

  const Map({Key? key, this.latitude, this.longitude, this.from})
      : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  LatLng? latlong = null;
  late CameraPosition _cameraPosition;
  GoogleMapController? _controller;
  TextEditingController locationController = TextEditingController();
  Set<Marker> _markers = Set();
  MapPickerController mapPickerController = MapPickerController();

  Future getCurrentLocation() async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(widget.latitude!, widget.longitude!);

    if (mounted)
      setState(() {
        latlong = new LatLng(widget.latitude!, widget.longitude!);

        _cameraPosition =
            CameraPosition(target: latlong!, zoom: 15.0, bearing: 0);
        if (_controller != null)
          _controller!
              .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));

        var address;
        address = placemark[0].name;
        address = address + "," + placemark[0].subLocality;
        address = address + "," + placemark[0].locality;
        address = address + "," + placemark[0].administrativeArea;
        address = address + "," + placemark[0].country;
        address = address + "," + placemark[0].postalCode;

        locationController.text = address;
        _markers.add(Marker(
          markerId: MarkerId("Marker"),
          position: LatLng(widget.latitude!, widget.longitude!),
        ));
      });
  }

  @override
  void initState() {
    super.initState();

    _cameraPosition = CameraPosition(target: LatLng(0, 0), zoom: 10.0);
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          getSimpleAppBar(getTranslated(context, 'CHOOSE_LOCATION')!, context),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(children: [
                (latlong != null)
                    ? MapPicker(
                        mapPickerController: mapPickerController,
                        iconWidget: Icon(Icons.location_on_rounded , size: 30,),
                        child: GoogleMap(
                          initialCameraPosition: _cameraPosition,
                          onMapCreated: (GoogleMapController controller) {
                            _controller = (controller);
                            _controller!.animateCamera(
                                CameraUpdate.newCameraPosition(
                                    _cameraPosition));
                          },
                          // markers: this.myMarker(),
                          onCameraMoveStarted: () {
                            // notify map is moving
                            mapPickerController.mapMoving!();
                            locationController.text = "checking ...";
                          },
                          onCameraMove: (cameraPosition) {
                            this._cameraPosition = cameraPosition;
                          },
                          onCameraIdle: () async {
                            // notify map stopped moving
                            mapPickerController.mapFinishedMoving!();
                            //get address name from camera position
                            List<Placemark> placemarks = await placemarkFromCoordinates(
                              _cameraPosition.target.latitude,
                              _cameraPosition.target.longitude,
                            );

                            // update the ui with the address
                            locationController.text =
                            '${placemarks.first.street}, ${placemarks.first.subLocality}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}';
                          },
                          // onTap: (latLng) {
                          //   if (mounted)
                          //     setState(
                          //       () {
                          //         latlong = latLng;
                          //       },
                          //     );
                          // },
                        ),
                      )
                    : Container(),
              ]),
            ),
            TextField(
              cursorColor: Theme.of(context).colorScheme.black,
              controller: locationController,
              readOnly: true,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                icon: Container(
                  margin: EdgeInsetsDirectional.only(start: 20, top: 0),
                  width: 10,
                  height: 10,
                  child: Icon(
                    Icons.location_on,
                    color: Colors.green,
                  ),
                ),
                hintText: "pick up",
                border: InputBorder.none,
                contentPadding:
                    EdgeInsetsDirectional.only(start: 15.0, top: 12.0),
              ),
            ),
            ElevatedButton(
              child: Text("Update Location"),
              onPressed: () {
                if (widget.from == getTranslated(context, 'ADDADDRESS')) {
                  // latitude = latlong!.latitude.toString();
                  // longitude = latlong!.longitude.toString();
                  latitude = _cameraPosition.target.latitude.toString();
                  longitude =_cameraPosition.target.longitude.toString();
                  print(
                      "Location ${_cameraPosition.target.latitude} ${_cameraPosition.target.longitude}");
                  print("Address: ${locationController.text}");
                }

                Navigator.pop(context , true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Set<Marker> myMarker() {
    if (_markers != null) {
      _markers.clear();
    }

    _markers.add(Marker(
      markerId: MarkerId(Random().nextInt(10000).toString()),
      position: LatLng(latlong!.latitude, latlong!.longitude),
    ));

    getLocation();

    return _markers;
  }

  Future<void> getLocation() async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(latlong!.latitude, latlong!.longitude);

    var address;
    address = placemark[0].name;
    address = address + "," + placemark[0].subLocality;
    address = address + "," + placemark[0].locality;
    address = address + "," + placemark[0].administrativeArea;
    address = address + "," + placemark[0].country;
    address = address + "," + placemark[0].postalCode;
    // locationController.text = address;
    if (mounted) setState(() {});
  }
}
