import 'package:flutter/material.dart';
class DoctorDetails extends StatelessWidget{
  var doctorInformation;
  DoctorDetails(this.doctorInformation);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(
          "Doctors",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: DoctorDetailsHomePage(doctorInformation),
    );
  }
}

class DoctorDetailsHomePage extends StatelessWidget {
  var doctorInformation;
  DoctorDetailsHomePage(this.doctorInformation);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 24.0,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Container(
                width: 150.0,
                height: 150.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage( fit: BoxFit.fill,image: NetworkImage(doctorInformation['photo']))
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0,),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(doctorInformation['name'],
              style: Theme.of(context).textTheme.body2,),
            ),
          ),

          SizedBox(height: 30.0,),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text("Overview",
                style: Theme.of(context).textTheme.subtitle,),
            ),
          ),
          SizedBox(height: 10.0,),
          Container(
            padding: EdgeInsets.only(left: 16.0,right: 16.0),
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(doctorInformation['overview'],
                  textAlign: TextAlign.justify,
                style: Theme.of(context).textTheme.subhead,),
            ),
          ),

          SizedBox(height: 30.0,),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text("Services",
                style: Theme.of(context).textTheme.subtitle,),
            ),
          ),
          SizedBox(height: 10.0,),
          Container(
            padding: EdgeInsets.only(left: 16.0,right: 16.0),
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(doctorInformation['services'],
                  textAlign: TextAlign.justify,
                style: Theme.of(context).textTheme.subhead,),
            ),
          ),
          SizedBox(
            height: 16.0,
          )
        ],
      ),
    );
  }
}
