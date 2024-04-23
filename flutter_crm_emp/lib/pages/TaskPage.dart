// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter_crm_emp/pages/Task_in.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;

final Map<String, dynamic> stageColourConfig = {
  "scoping_and_design": Color.fromARGB(255, 211, 232, 248),
  "execution_dev_monitoring": Color.fromARGB(255, 209, 247, 213),
  "testing_qa": Color.fromARGB(255, 255, 233, 235),
  "delivery_invoicing": Color.fromARGB(255, 246, 236, 221),
  "payment_process_confirmation": Color.fromARGB(255, 251, 224, 255),
};

final Map<String, dynamic> stagenameColourConfig = {
  "scoping_and_design": Color.fromARGB(255, 87, 176, 249),
  "execution_dev_monitoring": Color.fromARGB(255, 71, 218, 76),
  "testing_qa": const Color.fromARGB(255, 244, 99, 88),
  "delivery_invoicing": Color.fromARGB(255, 248, 157, 82),
  "payment_process_confirmation": Color.fromARGB(255, 222, 97, 245),
};
final Map<String, String> prettifyStageName = {
  "scoping_and_design": "Scoping",
  "execution_dev_monitoring": "Execution",
  "testing_qa": "Testing",
  "delivery_invoicing": "Delivery",
  "payment_process_confirmation": "Payment",
};

class TaskPage extends HookWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final tasksQuery = useQuery<List<dynamic>, dynamic>('tasks', () async {
      final k = jsonEncode({'query': "query { getClientProjects { payload } }"});
      final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

      final serverResponse = await http.post(Uri.parse("https://lipsum.smalltowntalks.com/v1/emp/graphql"), body: k, headers: {HttpHeaders.contentTypeHeader: "application/json", HttpHeaders.authorizationHeader: "Bearer ${sharedPrefs.getString("jwt")}"});

      final jsonMap = List<dynamic>.from(jsonDecode(serverResponse.body)['data']['getClientProjects']['payload']);

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String userDataJson = sharedPreferences.getString("who_am_i") ?? "{}";
      final employeeId = Map<String, dynamic>.from(jsonDecode(userDataJson))['_id'];

      final filteredJsonMap = jsonMap
          .where((project) {
            final assignees = List<dynamic>.from(project['assignees']).map((e) => e['_id']);
            return assignees.contains(employeeId) && (project['status'] == "active" || project['status'] == "completed");
          })
          .toList()
          .reversed
          .toList();

      final List<dynamic> prettyProjects = filteredJsonMap.fold<List<dynamic>>(
          [],
          (List<dynamic> accProjects, project) =>
              accProjects +
              [
                {
                  'project_id': project['_id'],
                  'project_title': project['title'],
                  'status_update': project['status'],
                  'completed_tasks': project['stages'].fold<List<dynamic>>(
                    [],
                    (List<dynamic> accTasks, stage) =>
                        accTasks +
                        stage['tasks']
                            .where(
                              (task) => (task['is_complete'] as bool),
                            )
                            .toList(),
                  ),
                  'remaining_tasks': project['stages'].fold<List<dynamic>>(
                    [],
                    (List<dynamic> accTasks, stage) =>
                        accTasks +
                        stage['tasks']
                            .where(
                              (task) => !(task['is_complete'] as bool),
                            )
                            .toList(),
                  ),
                  'all_tasks': project['stages'].fold<List<dynamic>>([], (List<dynamic> accTasks, stage) => accTasks + stage['tasks'].map((dynamic task) => {...task, 'project_stage': stage['name'], 'is_complete': task['is_complete']}).toList())
                }
              ]);
      return prettyProjects;
    }, onData: (value) {
      debugPrint('onData: $value');
    }, onError: (error) {
      debugPrint('onError: $error');
    });

    return Scaffold(
        backgroundColor: Colors.white,
        body: tasksQuery.isLoading || tasksQuery.isInitial || tasksQuery.isInactive
            ? const Center(child: CircularProgressIndicator())
            : tasksQuery.hasError
                ? Center(child: Text(tasksQuery.error.toString()))
                : tasksQuery.hasData
                    ? Column(children: [
                        Expanded(
                            child: RefreshIndicator(
                                onRefresh: () async => await tasksQuery.refresh(),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: tasksQuery.data?.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(color: index % 2 == 0 ? const Color.fromARGB(255, 247, 247, 247) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                                            child: ExpansionTile(
                                              tilePadding: EdgeInsets.symmetric(horizontal: width * 0.05),
                                              title: Text(tasksQuery.data?[index]?['project_title']),
                                              subtitle: Text(
                                                tasksQuery.data?[index]?['status_update']?.toString()=="active"?"Active":"Completed" ?? "No status updates",
                                                style: TextStyle(color: tasksQuery.data?[index]?['status_update'].toString() == "active" ? Colors.blue : Colors.green),
                                              ),
                                              children: <Widget>[
                                                for (int indexstage = 0; indexstage < tasksQuery.data?[index]["all_tasks"].length; indexstage++)
                                                  ListTile(
                                                    title: Container(
                                                      // height: height*0.13,
                                                      decoration: BoxDecoration(color: stageColourConfig[tasksQuery.data?[index]['all_tasks'][indexstage]["project_stage"]], borderRadius: BorderRadius.circular(10)),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                                        child: InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => TaskIn(
                                                                          tasks: tasksQuery.data?[index]['all_tasks'][indexstage],
                                                                        )));
                                                          },
                                                          child: SizedBox(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    Icon(
                                                                      tasksQuery.data?[index]["all_tasks"][indexstage]["is_complete"].toString() == "true" ? Icons.check_box : Icons.check_box_outline_blank,
                                                                      color: stagenameColourConfig[tasksQuery.data?[index]['all_tasks'][indexstage]["project_stage"]],
                                                                    ),
                                                                    const SizedBox(width: 5),
                                                                    Expanded(
                                                                        child: Text(
                                                                      tasksQuery.data?[index]['all_tasks'][indexstage]["name"],
                                                                      maxLines: 1,
                                                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: stagenameColourConfig[tasksQuery.data?[index]['all_tasks'][indexstage]["project_stage"]]),
                                                                    )),
                                                                    Container(
                                                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: stagenameColourConfig[tasksQuery.data?[index]['all_tasks'][indexstage]["project_stage"]]),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                                                          child: Text(
                                                                            prettifyStageName[tasksQuery.data?[index]['all_tasks'][indexstage]["project_stage"]] ?? tasksQuery.data?[index]['all_tasks'][indexstage]["project_stage"],
                                                                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                                                          ),
                                                                        )),
                                                                  ],
                                                                ),
                                                                const SizedBox(height: 10),
                                                                Row(children: [
                                                                  Expanded(
                                                                      child: Container(
                                                                          padding: const EdgeInsets.all(5),
                                                                          decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(6)), color: stagenameColourConfig[tasksQuery.data?[index]['all_tasks'][indexstage]["project_stage"]]),
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.all(5.0),
                                                                            child: Text(
                                                                              tasksQuery.data?[index]['all_tasks'][indexstage]["description"],
                                                                              softWrap: false,
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white),
                                                                            ),
                                                                          )))
                                                                ]),
                                                                const SizedBox(height: 10),
                                                                Text('Due ${DateFormat('d MMM').format(DateTime.parse(tasksQuery.data?[index]['all_tasks'][indexstage]["duedate"]))}',
                                                                    style: TextStyle(fontSize: 13, color: stagenameColourConfig[tasksQuery.data?[index]['all_tasks'][indexstage]["project_stage"]]))
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                              ],
                                            ),
                                          )
                                        ],
                                      );
                                    })))
                      ])
                    : Container());
  }
}
