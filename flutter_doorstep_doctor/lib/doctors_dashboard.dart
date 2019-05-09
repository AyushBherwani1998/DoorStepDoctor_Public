import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_doorstep_doctor/doctor_details.dart';
class DoctorsDashboard extends StatelessWidget{
  final String hospitalId;

  const DoctorsDashboard({Key key, this.hospitalId}) : super(key: key);
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
      body: DashBoard(hospitalId: hospitalId,),
    );
  }
}

class DashBoard extends StatefulWidget {
  final String hospitalId;

  const DashBoard({Key key, this.hospitalId}) : super(key: key);
  @override
  _DashBoardState createState() => _DashBoardState(hospitalId: hospitalId);
}

class _DashBoardState extends State<DashBoard> {
  final String hospitalId;
  var doctorsList=[];
  _DashBoardState({this.hospitalId});
  @override
  void initState() {
    super.initState();
    getDocumentsOfDoctor();
  }
  @override
  Widget build(BuildContext context) {
    return doctorsList.isEmpty?Center(
      child: CircularProgressIndicator(
      ) ,
    ):ListView.builder(
        itemCount: doctorsList.length,
        itemBuilder: (context,position){
          var url = doctorsList[position]['photo'].toString();
          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(0.0),
                child: Card(
                  elevation: 8.0,
                  color: Colors.white,
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DoctorDetails(doctorsList[position])));
                      print("Doctors");
                    },
                    contentPadding: EdgeInsets.all(14.0),
                    title: Text(
                      doctorsList[position]['name'].toString(),
                      style: Theme.of(context).textTheme.title,
                    ),
                    leading: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage( fit: BoxFit.fill,image: NetworkImage(url))
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }

  void getDocumentsOfDoctor()async {
    await Firestore.instance.collection('hospitals').document("$hospitalId").collection('doctors').getDocuments().then((QuerySnapshot docs){
      for(var i=0;i<docs.documents.length;i++){
        setState(() {
          doctorsList.add(docs.documents[i].data);
        });
      }
      print(doctorsList);
    });
  }
}
