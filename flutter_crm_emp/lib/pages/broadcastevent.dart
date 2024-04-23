import 'package:flutter_crm_emp/emphome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_crm_emp/BottomNavBar.dart';

class BroadCast extends StatefulWidget {
  final dynamic agenda;

  BroadCast({super.key, required this.agenda});

  @override
  State<BroadCast> createState() => _BroadCastState(agenda);
}

class Event {
  final String title;

  Event(this.title);
}

class _BroadCastState extends State<BroadCast> {
  final dynamic agenda;

  DateTime _focusedDay = DateTime.now();
             

  _BroadCastState(this.agenda);

  @override
  void initState() {
    super.initState();
  }
      
  @override
  Widget build(BuildContext context) {
    String dt=agenda["datetime"];
      DateTime dateTime=DateTime.parse(dt);
        int year=dateTime.year;
        int month=dateTime.month;
        int day=dateTime.day;
        int hour=dateTime.hour;
        int minute=dateTime.minute;
        int second=dateTime.second;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
   appBar: AppBar(
            backgroundColor: Colors.black,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNavigationBarExample(),));
                    }),
                const Text(
                  'Broadcast Information',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                 IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                     
                    }),
             
              ],
            ),
          ),
      body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.045, vertical: height * 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
               
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 0.0, vertical: height * 0.005),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.0,
                                  vertical: height * 0.05),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)),
                                color:
                                 Color.fromARGB(255, 255, 191, 135)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.02,
                                  vertical: height * 0.0005),
                              child: Row(
                                children: [
                                  Icon(Icons.account_balance,
                                      size: 15,
                                      color: Color.fromARGB(255, 255, 255, 255)),
                                  Text(
                                    this.agenda["to"],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: Color.fromARGB(255, 255, 255, 255)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Text(
                          this.agenda["title"],
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 25,
                              color: Colors.black),
                        ),
                        Padding(
                         padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.0,
                                  vertical: height * 0.005),
                          child: Container(
                            height: 0.5,
                            width: width,
                            color: const Color.fromARGB(255, 210, 210, 210),
                          ),
                        ),
                     
                        Row(
                        
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                   
                        
                             children: [
                            Text("Broadcast Title ",
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            Icon(Icons.fiber_manual_record, size: 5,weight: 100,),
                            Text(" $day""/""$month""/""$year"" , ""$hour"":""$minute"":""$second"" am ", 
                             style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Padding(
                        padding: EdgeInsets.symmetric(
                                horizontal: width * 0.0,
                                vertical: height * 0.05),
                          child: Container(
                     
                        
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              color: Color.fromRGBO(62, 116, 252, 0.675),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.02,
                                  vertical: height * 0.0005),
                              child: Row(
                                children: [
                                  Icon(Icons.vpn_lock,
                                      color: Colors.white, size: 12),
                                  Text("Company Broadcast",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        ), 
                        Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 218, 217, 217),borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:Radius.circular(10) )),
                            
                                child: Padding(
                                   padding: EdgeInsets.symmetric(
                                horizontal: width * 0.04,
                                vertical: height * 0.005),
                                  child: Text("Description",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),    
                        Container(
                          width: width,
                          height: 300,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border.all(width: 1,color: Colors.grey.shade400),
                             borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                             
                              Padding(
                                padding: EdgeInsets.symmetric(
                                horizontal: width * 0.02,
                                vertical: height * 0.005),
                                child: Text(
                                  this.agenda["description"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                      color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]))),
    ));
  }
}
