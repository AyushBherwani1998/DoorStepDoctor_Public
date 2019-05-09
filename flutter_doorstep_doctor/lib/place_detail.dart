import 'package:flutter_doorstep_doctor/more_info.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

const kGoogleApiKey = "";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class PlaceDetailWidget extends StatefulWidget {
  String placeId;

  PlaceDetailWidget(String placeId) {
    this.placeId = placeId;
  }

  @override
  State<StatefulWidget> createState() {
    return PlaceDetailState();
  }
}

class PlaceDetailState extends State<PlaceDetailWidget> {
  GoogleMapController mapController;
  PlacesDetailsResponse place;
  bool isLoading = false;
  String errorLoading;

  @override
  void initState() {
    fetchPlaceDetail();
    super.initState();
  print(widget.placeId);
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyChild;
    String title;
    if (isLoading) {
      title = "Loading";
      bodyChild = Center(
        child: CircularProgressIndicator(
          value: null,
        ),
      );
    } else if (errorLoading != null) {
      title = "";
      bodyChild = Center(
        child: Text(errorLoading),
      );
    } else {
      final placeDetail = place.result;
      final location = place.result.geometry.location;
      final lat = location.lat;
      final lng = location.lng;
      final center = LatLng(lat, lng);

      title = placeDetail.name;
      bodyChild = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 200.0,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  options: GoogleMapOptions(
                      myLocationEnabled: true,
                      cameraPosition: CameraPosition(target: center, zoom: 15.0)),
                ),
              )),
          Expanded(
            child: buildPlaceDetailList(placeDetail),
          )
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(title,style: TextStyle(color: Colors.black),),
        ),
        body: bodyChild);
  }

  void fetchPlaceDetail() async {
    setState(() {
      this.isLoading = true;
      this.errorLoading = null;
    });

    PlacesDetailsResponse place =
    await _places.getDetailsByPlaceId(widget.placeId);

    if (mounted) {
      setState(() {
        this.isLoading = false;
        if (place.status == "OK") {
          this.place = place;
        } else {
          this.errorLoading = place.errorMessage;
        }
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    final placeDetail = place.result;
    final location = place.result.geometry.location;
    final lat = location.lat;
    final lng = location.lng;
    final center = LatLng(lat, lng);
    var markerOptions = MarkerOptions(
        position: center,
        infoWindowText: InfoWindowText(
            "${placeDetail.name}", "${placeDetail.formattedAddress}"));
    mapController.addMarker(markerOptions);
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: center, zoom: 15.0)));
  }

  String buildPhotoURL(String photoReference) {
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photoReference}&key=${kGoogleApiKey}";
  }

  ListView buildPlaceDetailList(PlaceDetails placeDetail) {
    List<Widget> list = [];
    if (placeDetail.photos != null) {
      final photos = placeDetail.photos;

      list.add(
        Column(
          children: <Widget>[
           Container(
             width: MediaQuery.of(context).size.width,
             child:Padding(
                 padding: EdgeInsets.all(16.0),
                 child: Text(
                   "Photos",
                   textAlign: TextAlign.start,
                   style: Theme.of(context).textTheme.subtitle,
                 )),
           ),
            SizedBox(
              height: 4.0,
            ),
            SizedBox(
                height: 100.0,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: EdgeInsets.all(4.0),
                          child: SizedBox(
                            height: 100,
                            child: Image.network(
                                buildPhotoURL(photos[index].photoReference)),
                          ));
                    }))
          ],
        )
      );
    }

    list.add(
      Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            placeDetail.name,
            style: Theme.of(context).textTheme.title,
          )),
    );
    if (placeDetail.types?.first != null) {
      list.add(
        Padding(
            padding:EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: Text(
              placeDetail.types.first.toUpperCase(),
              style: Theme.of(context).textTheme.caption,
            )),
      );
    }

    if (placeDetail.openingHours != null) {
      final openingHour = placeDetail.openingHours;
      var text = '';
      Color color;
      if (openingHour.openNow) {
        text = 'Opening Now';
        color = Colors.green;
      } else {
        text = 'Closed';
        color = Colors.red;
      }
      list.add(
        Padding(
            padding:
            EdgeInsets.all(16.0),
            child: Text(
              text,
              style: TextStyle(
                  color: color,
                  fontSize: 16.0
              ),
            )),
      );
    }

    if (placeDetail.formattedAddress != null) {
      list.add(
        Padding(
            padding:
            EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.location_on,color: Colors.black,),
                  onPressed: (){
                    print("Location");
                  },
                ),
                SizedBox(height: 8.0,),
                Expanded(
                  child: Text(
                    placeDetail.formattedAddress,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                )
              ],
            )),
      );
    }


    if (placeDetail.formattedPhoneNumber != null) {
      list.add(
        Padding(
            padding:
            EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.phone,color: Colors.black,),
                  onPressed: (){
                    print("Phone Pressed");
                    UrlLauncher.launch('tel: ${placeDetail.formattedPhoneNumber}');
                  },
                ),
                SizedBox(
                  width: 8.0,
                ),
                Text(
                  placeDetail.formattedPhoneNumber,
                  style: Theme.of(context).textTheme.subhead,
                )
              ],
            )),
      );
    }


    if (placeDetail.website != null) {
      list.add(
        Padding(
            padding:
            EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: (){
                UrlLauncher.launch('${placeDetail.website.toString()}',forceWebView: true);
              },
              child: Text(
                placeDetail.website,
                style: Theme.of(context).textTheme.subhead,
              )),
            ),
      );
    }

    if (placeDetail.rating != null) {
      list.add(
        Padding(
            padding:
            EdgeInsets.all(16.0),
            child: Text(
              "Rating: ${placeDetail.rating}",
              style: Theme.of(context).textTheme.subhead,
            )),
      );
    }

    list.add(
      Container(
        width: MediaQuery.of(context).size.width,
        child:Padding(
            padding: EdgeInsets.all(16.0),
            child:GestureDetector(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Details(hospitalId: widget.placeId,)));
                print("More Details");
              },
              child: Text("More Detials",style: Theme.of(context).textTheme.subtitle,),
            ),),
      )
    );

    return ListView(
      shrinkWrap: true,
      children: list,
    );
  }
}
