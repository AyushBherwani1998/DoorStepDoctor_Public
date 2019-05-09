import 'dart:async';
import 'package:flutter_doorstep_doctor/dialogflow.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'place_detail.dart';

const kGoogleApiKey = "";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

void main() {
  runApp(MaterialApp(
    title: "DoorStep Doctor",
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController mapController;
  List<PlacesSearchResult> places = [];
  bool isLoading = false;
  String errorMessage;
  int areaRadius =2500;

  @override
  Widget build(BuildContext context) {
    Widget expandedChild;
    if (isLoading) {
      expandedChild = Center(child: CircularProgressIndicator(value: null));
    } else if (errorMessage != null) {
      expandedChild = Center(
        child: Text(errorMessage),
      );
    } else {
      expandedChild = buildPlacesList();
    }

    return Scaffold(
      backgroundColor: Colors.white,
        key: homeScaffoldKey,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 8.0,
          title: const Text("Doorstep Doctor",style: TextStyle(color: Colors.black),),
          actions: <Widget>[
            isLoading
                ? IconButton(
              icon: Icon(Icons.timer,color: Colors.black,),
              onPressed: () {},
            )
                : IconButton(
              icon: Icon(Icons.refresh,color: Colors.black,),
              onPressed: () {
                refresh();
              },
            ),
            IconButton(
              icon: Icon(Icons.search,color: Colors.black,),
              onPressed: () {
                _handlePressButton();
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(backgroundColor:Colors.blue,child: IconButton(icon: Icon(Icons.chat,color: Colors.white,), onPressed: (){
          Navigator.push(context,
              MaterialPageRoute(builder: (context)=>HomePageDialogflow()));
        }),onPressed:(){
          Navigator.push(context,
              MaterialPageRoute(builder: (context)=>HomePageDialogflow()));
        }),
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                  height: 300.0,
                  child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      options: GoogleMapOptions(
                          myLocationEnabled: true,
                          cameraPosition:
                          const CameraPosition(target: LatLng(0.0, 0.0))))),
            ),
            Expanded(child: expandedChild)
          ],
        ));
  }

  void refresh() async {
    final center = await getUserLocation();

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: center == null ? LatLng(0, 0) : center, zoom: 15.0)));
    getNearbyPlaces(center);
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    refresh();
  }

  Future<LatLng> getUserLocation() async {
    var currentLocation = <String, double>{};
    final location = LocationManager.Location();
    try {
      currentLocation = await location.getLocation();
      final lat = currentLocation["latitude"];
      final lng = currentLocation["longitude"];
      final center = LatLng(lat, lng);
      return center;
    } on Exception {
      currentLocation = null;
      return null;
    }
  }

  void getNearbyPlaces(LatLng center) async {
    setState(() {
      this.isLoading = true;
      this.errorMessage = null;
    });

    final location = Location(center.latitude, center.longitude);
    final result = await _places.searchNearbyWithRadius(location, areaRadius,type:"hospital");
    setState(() {
      this.isLoading = false;
      if (result.status == "OK") {
        this.places = result.results;
        result.results.forEach((f) {
          final markerOptions = MarkerOptions(
              position:
              LatLng(f.geometry.location.lat, f.geometry.location.lng),
              infoWindowText: InfoWindowText("${f.name}", "${f.types?.first}"));
          mapController.addMarker(markerOptions);
        });
      } else {
        this.errorMessage = result.errorMessage;
      }
    });
  }

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  Future<void> _handlePressButton() async {
    try {
      final center = await getUserLocation();
      Prediction p = await PlacesAutocomplete.show(
          context: context,
          strictbounds: center == null ? false : true,
          apiKey: kGoogleApiKey,
          onError: onError,
          mode: Mode.fullscreen,
          language: "en",
          location: center == null
              ? null
              : Location(center.latitude, center.longitude),
          radius: center == null ? null : 100000);

      showDetailPlace(p.placeId);
    } catch (e) {
      return;
    }
  }

  Future<Null> showDetailPlace(String placeId) async {
    if (placeId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlaceDetailWidget(placeId)),
      );
    }
  }

  ListView buildPlacesList() {
    final placesWidget = places.map((f) {
      List<Widget> list = [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            f.name,
            style: Theme.of(context).textTheme.subtitle,
          ),
        )
      ];
      if (f.formattedAddress != null) {
        list.add(Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            f.formattedAddress,
            style: Theme.of(context).textTheme.title,
          ),
        ));
      }

      if (f.vicinity != null) {
        list.add(Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            f.vicinity,
            style: Theme.of(context).textTheme.subhead,
          ),
        ));
      }

      if (f.types?.first != null) {
        list.add(Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            f.types.first.toUpperCase(),
            style: Theme.of(context).textTheme.caption,
          ),
        ));
      }

      return Padding(
        padding: EdgeInsets.only(top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
        child: Card(
          elevation: 8.0,
          child: InkWell(
            onTap: () {
              print(f.placeId);
              showDetailPlace(f.placeId);
            },
            splashColor: Colors.red,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: list,
              ),
            ),
          ),
        ),
      );
    }).toList();

    return ListView(shrinkWrap: true, children: placesWidget);
  }

}
