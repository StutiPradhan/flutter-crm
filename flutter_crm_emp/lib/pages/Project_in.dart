import 'package:flutter_crm_emp/pages/TaskTab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ProjectIn extends StatefulWidget {
  final dynamic projects;
  const ProjectIn({super.key, required this.projects});

  @override
  State<ProjectIn> createState() => _ProjectInState(projects);
}

class _ProjectInState extends State<ProjectIn> {
  Color containerColor = const Color.fromARGB(255, 176, 176, 176);
  final dynamic projects;
  _ProjectInState(this.projects);

  @override
  Widget build(BuildContext context) {
    String dt = projects['startdate'];
    String dt2 = projects['tentative_enddate'];
    DateTime dateTime2 = DateTime.parse(dt2);
    DateTime dateTime = DateTime.parse(dt);
    int day = dateTime.day;
    int day2 = dateTime2.day;
    int month = dateTime.month;
    int year = dateTime.year;

    String monthAbbreviation = DateFormat('MMM').format(dateTime);
    String monthAbbreviation2 = DateFormat('MMM').format(dateTime2);
    String formattedDate = "$monthAbbreviation-${day.toString().padLeft(2, '0')}";
    String formattedDate2 = "$monthAbbreviation2-${day2.toString().padLeft(2, '0')}";

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    //To use prettystagename
    Map<String, String> prettifyStageName = {"scoping_and_design": "Scoping & Design", "execution_dev_monitoring": "Execution, Development & Monitoring", "testing_qa": "Testing/QA", "delivery_invoicing": "Delivery & Invoicing", "payment_process_confirmation": "Payment Process & Confirmation"};
    // String stagename=this.projects["stages"][0]["name"];
    // String prettyfied=prettifyStageName[stagename]??stagename;

    //double _percentagecomplete = 0.0;
    final List<dynamic> allTasks = projects["stages"].fold<List<dynamic>>(
      [],
      (List<dynamic> acc, dynamic stage) =>
          acc +
          stage["tasks"]
              .map(
                (task) => {...task, 'stage': stage["name"]},
              )
              .toList(),
    );

    final List<dynamic> completedTasks = allTasks.where((task) => task['is_complete']).toList();

    final List<dynamic> remainingTasks = allTasks.where((task) => !task['is_complete']).toList();

    double _percentagecomplete = allTasks.isNotEmpty ? (completedTasks.length / allTasks.length) * 100 : 0.0;

    Color getColorForStage(int index) {
      // Check if the current stage is complete
      bool isComplete = this.projects["stages"][index]["is_complete"];
      // Check if the previous stage is complete
      bool prevStageComplete = index > 0 ? this.projects["stages"][index - 1]["is_complete"] : false;

      if (isComplete) {
        // If the current stage is complete, set the color to blue
        return Color.fromARGB(255, 85, 204, 247);
      } else if (!isComplete && prevStageComplete) {
        // If the current stage is not complete but the previous one is, set the color to green
        return Color.fromARGB(255, 98, 226, 69);
      } else {
        // Otherwise, set the color to grey
        return Color.fromARGB(255, 176, 176, 176);
      }
    }

    Widget statusWidget;
    if (this.projects['status'] == 'completed') {
      statusWidget = Container(
        decoration: BoxDecoration(color: Color.fromARGB(255, 119, 203, 245), borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.01),
          child: Text(
            this.projects['status'],
            style: TextStyle(color: Color.fromARGB(255, 3, 142, 216), fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      );
    }
    if (this.projects['status'] == 'active') {
      statusWidget = Container(
        decoration: BoxDecoration(color: Color.fromARGB(255, 176, 237, 178), borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.005),
          child: Text(
            this.projects['status'],
            style: TextStyle(color: Color.fromARGB(255, 1, 130, 5), fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      );
    } else {
      statusWidget = Container(
        decoration: BoxDecoration(color: Color.fromARGB(255, 250, 141, 141), borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.01),
          child: Text(
            this.projects['status'],
            style: TextStyle(color: Color.fromARGB(255, 193, 13, 13), fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      );
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Your Projects",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text(
                          this.projects['title'],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
                Card(
                  elevation: 1,
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          //         gradient: LinearGradient(
                          //   begin: Alignment.topRight,
                          //   end: Alignment.bottomLeft,
                          //   colors: [

                          //     Color.fromARGB(255, 155, 235, 249),
                          //      Color.fromARGB(255, 95, 205, 245),
                          //   ],
                          // )
                          color: Colors.white),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.02, vertical: height * 0.01),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image.asset(
                            //           this.projects["pfpurl"].toString(),
                            //           height: 40,
                            //           width: 40,
                            //         ),
                            Text(this.projects["client"]["name"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black)),
                            Text(
                              this.projects["client"]["company"],
                              style: TextStyle(color: Colors.grey),
                            ),

                            // Text(this.projects["assignees"].toString()),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: width * 0.0, vertical: height * 0.03),
                                  child: Text(this.projects["payment"]["currency"].toString() + " " + this.projects["payment"]["projected_cost"].toString(), style: TextStyle(fontSize: 25, letterSpacing: 3, fontWeight: FontWeight.w500)),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text("Amount Paid:", style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 194, 192, 192))),
                                        Row(
                                          children: [
                                            Text(this.projects["payment"]["currency"].toString() + "  " + this.projects["payment"]["amount_paid"].toString(), style: TextStyle(fontSize: 20, letterSpacing: 3, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text("Pyment status:", style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 194, 192, 192))),
                                        Container(
                                            decoration: BoxDecoration(color: const Color.fromARGB(255, 235, 234, 234), borderRadius: BorderRadius.circular(20)),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.01),
                                              child: Text(
                                                this.projects["payment"]["status"],
                                                style: TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                            )),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Progress",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      statusWidget
                    ],
                  ),
                ),
                Column(children: <Widget>[
                  Column(
                    children: [
                      ClipRRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: 0.9,
                          child: SfRadialGauge(axes: <RadialAxis>[
                            RadialAxis(
                                showLabels: false,
                                showTicks: true,
                                startAngle: 130,
                                endAngle: 45,
                                radiusFactor: 0.7,
                                canScaleToFit: false,
                                axisLineStyle: AxisLineStyle(
                                  thickness: 0.1,
                                  color: Color.fromARGB(30, 182, 152, 243),
                                  thicknessUnit: GaugeSizeUnit.factor,
                                  cornerStyle: CornerStyle.startCurve,
                                ),
                                pointers: <GaugePointer>[
                                  RangePointer(value: _percentagecomplete, color: Color.fromARGB(255, 71, 120, 232), width: 0.1, sizeUnit: GaugeSizeUnit.factor, cornerStyle: CornerStyle.bothCurve)
                                ],
                                annotations: <GaugeAnnotation>[
                                  GaugeAnnotation(
                                    widget: Container(child: Text('${completedTasks.length}/${allTasks.length}', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
                                  )
                                ])
                          ]),
                        ),
                      ),
                    ],
                  ),
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Start Date",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        Container(
                            decoration: BoxDecoration(color: Color.fromARGB(255, 227, 230, 230), borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: width * 0.02, vertical: height * 0.01),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("$formattedDate" " " "$year"),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Icon(CupertinoIcons.clock_fill, size: 15),
                                  )
                                ],
                              ),
                            )),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "Close Date",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        Container(
                            decoration: BoxDecoration(color: Color.fromARGB(255, 227, 230, 230), borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: width * 0.02, vertical: height * 0.01),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("$formattedDate2" " " "$year"),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Icon(CupertinoIcons.clock_fill, size: 15),
                                  )
                                ],
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.0, vertical: height * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: height * 0.02),
                        child: Text(
                          "Description",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        this.projects["description"],
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.02),
                      child: Text(
                        "Project stages",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                //  containerColor=Colors.blue;
                                //   if (this.projects["stages"][0]["is_complete"] == true) {
                                //    containerColor =  getColorForStage(0);
                                //   //  iconchange=Icon(Icons.verified_outlined);
                                //   } else {

                                //    containerColor = const Color.fromARGB(255, 176, 176, 176);
                                //  }
                                containerColor = getColorForStage(0);
                              });
                            },
                            child: Container(
                                width: getColorForStage(0) == Color.fromARGB(255, 98, 226, 69) ? 150 : 80,
                                decoration: BoxDecoration(color: getColorForStage(0), borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30))),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(prettifyStageName[this.projects["stages"][0]["name"]] ?? [this.projects["stages"][0]["name"]].toString())),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  //  containerColor=Colors.blue;
                                  //   if (this.projects["stages"][0]["is_complete"] == true) {
                                  //   containerColor = getColorForStage(1);
                                  //   } else {

                                  //    containerColor = const Color.fromARGB(255, 176, 176, 176);
                                  //  }
                                  containerColor = getColorForStage(1);
                                });
                              },
                              child: Container(
                                  width: getColorForStage(1) == Color.fromARGB(255, 98, 226, 69) ? 150 : 80,
                                  decoration: BoxDecoration(color: getColorForStage(1), borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30))),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(prettifyStageName[this.projects["stages"][1]["name"]] ?? [this.projects["stages"][1]["name"]].toString())),
                                  )),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                //  containerColor=Colors.blue;
                                //   if (this.projects["stages"][0]["is_complete"] == true) {
                                //    containerColor = getColorForStage(2);
                                //   } else {

                                //    containerColor = const Color.fromARGB(255, 176, 176, 176);
                                //  }
                                containerColor = getColorForStage(2);
                              });
                            },
                            child: Container(
                                width: getColorForStage(2) == Color.fromARGB(255, 98, 226, 69) ? 150 : 80,
                                decoration: BoxDecoration(color: getColorForStage(2), borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30))),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(prettifyStageName[this.projects["stages"][2]["name"]] ?? [this.projects["stages"][2]["name"]].toString())),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  //  containerColor=Colors.blue;
                                  //   if (this.projects["stages"][0]["is_complete"] == true) {
                                  //    containerColor = getColorForStage(3);
                                  //   } else {

                                  //    containerColor = const Color.fromARGB(255, 176, 176, 176);
                                  //  }
                                  containerColor = getColorForStage(3);
                                });
                              },
                              child: Container(
                                  width: getColorForStage(3) == Color.fromARGB(255, 98, 226, 69) ? 150 : 80,
                                  decoration: BoxDecoration(color: getColorForStage(3), borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30))),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(prettifyStageName[this.projects["stages"][3]["name"]] ?? [this.projects["stages"][3]["name"]].toString())),
                                  )),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                //  containerColor=Colors.blue;
                                //   if (this.projects["stages"][0]["is_complete"] == true) {
                                //     containerColor = getColorForStage(4);
                                //   } else {

                                //    containerColor = const Color.fromARGB(255, 176, 176, 176);
                                //  }
                                containerColor = getColorForStage(4);
                              });
                            },
                            child: Container(
                                width: getColorForStage(4) == Color.fromARGB(255, 98, 226, 69) ? 150 : 80,
                                decoration: BoxDecoration(color: getColorForStage(4), borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30))),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(prettifyStageName[this.projects["stages"][4]["name"]] ?? [this.projects["stages"][4]["name"]].toString())),
                                )),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.0, vertical: height * 0.04),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TaskTab()));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "View tasks",
                                style: TextStyle(color: Colors.white),
                              ),
                              Icon(Icons.arrow_forward_ios, color: Colors.white)
                            ],
                          ),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 71, 120, 232), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), fixedSize: Size(250, 50)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
