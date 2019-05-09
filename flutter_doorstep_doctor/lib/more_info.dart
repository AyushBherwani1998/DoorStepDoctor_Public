import 'package:flutter/material.dart';
import 'package:flutter_doorstep_doctor/doctors_dashboard.dart';

class Details extends StatelessWidget {
  final String hospitalId;

  const Details({Key key, this.hospitalId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(
          "Details",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: DetailsHomePage(hospitalId: hospitalId,),
    );
  }
}

class DetailsHomePage extends StatefulWidget {
  final String hospitalId;

  const DetailsHomePage({Key key, this.hospitalId}) : super(key: key);
  @override
  _DetailsHomePageState createState() => _DetailsHomePageState(hospitalId: hospitalId);
}

class _DetailsHomePageState extends State<DetailsHomePage> {
  final String hospitalId;

  _DetailsHomePageState({this.hospitalId});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        padding: EdgeInsets.all(8.0),
        children: <Widget>[
          SizedBox(
            height: 8.0,
          ),
          Card(
            elevation: 4.0,
            color: Colors.blueAccent,
            child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DoctorsDashboard(hospitalId: hospitalId,)));
                print("Doctors");
              },
              contentPadding: EdgeInsets.all(14.0),
              title: Text(
                "Doctors",
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
