import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jhatfat/Maps/UI/location_page.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/Themes/constantfile.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/parcel/pharmacybean/parceladdress.dart';
import 'package:jhatfat/parcel/receiveraddress.dart';

class AddressFrom extends StatefulWidget {
  final dynamic vendor_name;
  final dynamic vendor_id;
  final dynamic distance;

  AddressFrom(this.vendor_name, this.vendor_id, this.distance);

  @override
  State<StatefulWidget> createState() {
    return AddressFromState();
  }
}

class AddressFromState extends State<AddressFrom> {
  TextEditingController houseno = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController landmark = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController sendername = TextEditingController();
  TextEditingController sendercontact = TextEditingController();

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: apiKey);

  bool isFetchStore = false;

  double lat = 0.0;
  double lng = 0.0;

  String currentAddress = '';

  @override
  void initState() {
    _getLocation();
    super.initState();
  }

  void _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      bool isLocationServiceEnableds =
      await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnableds) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        double lat = position.latitude;
        double lng = position.longitude;
        GeoData data = await Geocoder2.getDataFromCoordinates(
            latitude: lat,
            longitude: lng,
            googleMapApiKey:apiKey);
        setState(() {
          city.text = data.city;
          pincode.text = data.postalCode;
          state.text = data.state;
        });

        // for (int i = 0; i < data.length; i++) {
        //   print('${data.state}');
        //   if (value[i].locality != null && value[i].locality.length > 1) {
        //     setState(() {
        //       city.text = value[i].locality;
        //       pincode.text = value[i].postalCode;
        //       state.text = value[i].adminArea;
        //     });
        // }
        //  }
      } else {
        await Geolocator.openLocationSettings().then((value) {
          if (value) {
            _getLocation();
          } else {
            Fluttertoast.showToast(
                msg: 'Location permission is required!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black26,
                textColor: Colors.white,
                fontSize: 14.0
            );
          }
        }).catchError((e) {
          Fluttertoast.showToast(
              msg: 'Location permission is required!',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black26,
              textColor: Colors.white,
              fontSize: 14.0
          );
        });
      }
    } else if (permission == LocationPermission.denied) {
      LocationPermission permissiond = await Geolocator.requestPermission();
      if (permissiond == LocationPermission.whileInUse ||
          permissiond == LocationPermission.always) {
        _getLocation();
      } else {
        Fluttertoast.showToast(
            msg: 'Location permission is required!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black26,
            textColor: Colors.white,
            fontSize: 14.0
        );
      }
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings().then((value) {
        _getLocation();
      }).catchError((e) {
        Fluttertoast.showToast(
            msg: 'Location permission is required!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black26,
            textColor: Colors.white,
            fontSize: 14.0
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(52.0),
        child: AppBar(
          backgroundColor: kWhiteColor,
          titleSpacing: 0.0,
          title: Text(
            'Address detail\'s',
            style: TextStyle(
                fontSize: 18, color: black_color, fontWeight: FontWeight.w400),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 10.0, top: 10, bottom: 10.0),
              child: Text(
                'Sender Address',
                style: TextStyle(
                    fontSize: 18,
                    color: black_color,
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Sender Name',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: sendername,
                        decoration: InputDecoration(
                          hintText: 'Sender Name',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Sender Contact No.',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: sendercontact,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        decoration: InputDecoration(
                          hintText: 'Sender Contact No.',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Address',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      getPlaces(context);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Card(
                      elevation: 2,
                      color: kWhiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(left: 10.0),
                        child: TextFormField(
                          maxLines: 5,
                          controller: address,
                          enabled: (address.text.length == 0) ? false : true,
                          decoration: InputDecoration(
                            hintText: 'Enter your address',
                            hintStyle: TextStyle(fontSize: 15),
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          onChanged: (value) {
                            if(value.length==1){
                              getPlaces(context);
                            }
                          },
                          onTap: () {},
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'House No/Flat No',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: houseno,
                        decoration: InputDecoration(
                          hintText: 'House No/Flat No',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text(
                                'Pin Code',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: black_color,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Card(
                              elevation: 2,
                              color: kWhiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Container(
                                height: 52,
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                child: TextFormField(
                                  maxLines: 1,
                                  controller: pincode,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Pin Code',
                                    hintStyle: TextStyle(fontSize: 15),
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text(
                                'City',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: black_color,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Card(
                              elevation: 2,
                              color: kWhiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Container(
                                height: 52,
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                child: TextFormField(
                                  maxLines: 1,
                                  controller: city,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'City',
                                    enabled: false,
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(fontSize: 15),
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Landmark',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: landmark,
                        decoration: InputDecoration(
                          hintText: 'Landmark',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'State',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: state,
                        decoration: InputDecoration(
                          hintText: 'State',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: GestureDetector(
                onTap: () {
                  if (houseno.text != null &&
                      pincode.text != null &&
                      city.text != null &&
                      landmark.text != null &&
                      address.text != null &&
                      state.text != null &&
                      lat != null &&
                      lng != null &&
                      sendername.text != null &&
                      sendercontact.text != null) {
                    ParcelAddress parcelAddress = ParcelAddress(
                        houseno.text,
                        pincode.text,
                        city.text,
                        landmark.text,
                        address.text,
                        state.text,
                        lat,
                        lng,
                        sendername.text,
                        sendercontact.text);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddressTo(
                                widget.vendor_name,
                                widget.vendor_id,
                                widget.distance,
                                parcelAddress)));
                  } else {
                    Fluttertoast.showToast(
                        msg: 'please enter all details to continue!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black26,
                        textColor: Colors.white,
                        fontSize: 14.0
                    );
                  }
                },
                child: Card(
                  elevation: 2,
                  color: kMainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Container(
                    height: 52,
                    padding: EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Submit',
                      style: TextStyle(fontSize: 18, color: kWhiteColor),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  void getPlaces(context) async {
    // PlacesAutocomplete.show(
    //   context: context,
    //   apiKey: apiKey,
    //   mode: Mode.fullscreen,
    //   sessionToken: Uuid().generateV4(),
    //   onError: (response) {
    //     print('${response.errorMessage}');
    //   },
    //   language: "en",
    // ).then((value) {
    //   displayPrediction(value!);
    // }).catchError((e) {
    //   print(e);
    // });
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;
      _getCameraMoveLocation(
          LatLng(lat, lng), '${detail.result.formattedAddress}');
    }
  }

  void _getCameraMoveLocation(LatLng data, addressd) async {
    setState(() {
      currentAddress = '${addressd}';
      lat = data.latitude;
      lng = data.longitude;
    });
    GeoData addres = await Geocoder2.getDataFromCoordinates(
        latitude: lat,
        longitude: lng,
        googleMapApiKey:apiKey);

    if (addres.address.length > 1) {
      setState(() {
        city.text = addres.city;
        pincode.text = addres.postalCode;
        state.text = addres.state;
        currentAddress =
            currentAddress.replaceAll('${addres.city},', '');
        currentAddress = currentAddress.replaceAll('${pincode.text},', '');
        currentAddress = currentAddress.replaceAll('${state.text},', '');
        currentAddress =
            currentAddress.replaceAll('${addres.city}', '');
        currentAddress = currentAddress.replaceAll('${pincode.text}', '');
        currentAddress = currentAddress.replaceAll('${state.text}', '');
        currentAddress =
            currentAddress.replaceAll('${addres.country}', '');
        address.text = currentAddress;
      });

    }
  }
}
