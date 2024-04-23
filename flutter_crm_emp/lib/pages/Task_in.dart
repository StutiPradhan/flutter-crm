import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskIn extends StatefulWidget {
  final dynamic tasks;
  const TaskIn({super.key, required this.tasks});

  @override
  State<TaskIn> createState() => _TaskInState(tasks);
}

class _TaskInState extends State<TaskIn> {
  final dynamic tasks;
  _TaskInState(this.tasks);

  @override
  Widget build(BuildContext context) {
    //final state=context.watch<TasksCubit>().state;

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    String dt = tasks["duedate"];
    DateTime dateTime = DateTime.parse(dt);
    int day = dateTime.day;
    int month = dateTime.month;
    int year = dateTime.year;
    String monthAbbreviation = DateFormat('MMM').format(dateTime);
    String formattedDate = "$monthAbbreviation-${day.toString().padLeft(2, '0')}";
    //To use prettystagename
    Map<String, String> prettifyStageName = {"scoping_and_design": "Scoping & Design", "execution_dev_monitoring": "Execution, Development & Monitoring", "testing_qa": "Testing/QA", "delivery_invoicing": "Delivery & Invoicing", "payment_process_confirmation": "Payment Process & Confirmation"};

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Task Assigned",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tasks["name"],
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    tasks["description"],
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.0, vertical: height * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(CupertinoIcons.clock, size: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          formattedDate,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.0, vertical: height * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 20, color: tasks["is_complete"].toString() == "true" ? const Color(0xFF1E40AE) : const Color(0xFF0C9488)),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          tasks["is_complete"].toString() == "true" ? "Completed" : "Incomplete",
                          style: TextStyle(color: tasks["is_complete"].toString() == "true" ? const Color(0xFF1E40AE) : const Color(0xFF0C9488), fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
