import 'dart:convert';
import 'dart:io';

import 'package:flutter_crm_emp/pages/Project_in.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';

class Projects extends HookWidget {
  const Projects({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final projectQuery = useQuery('projects', () async {
      debugPrint("Fetching Project.dart...");

      final k = jsonEncode({'query': "query { getClientProjects { payload } }"});
      final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
      final serverResponse = await http.post(Uri.parse("https://lipsum.smalltowntalks.com/v1/emp/graphql"), body: k, headers: {HttpHeaders.contentTypeHeader: "application/json", HttpHeaders.authorizationHeader: "Bearer ${sharedPrefs.getString("jwt")}"});

      if (serverResponse.statusCode == 200) {
        final jsonMap = Map<String, dynamic>.from(jsonDecode(serverResponse.body));
        if (jsonMap.containsKey('data')) {
          final jsonMap = List<dynamic>.from(jsonDecode(serverResponse.body)['data']['getClientProjects']['payload']);

          String userDataJson = sharedPrefs.getString("who_am_i") ?? "{}";
          final employeeId = Map<String, dynamic>.from(jsonDecode(userDataJson))['_id'];

          final filteredJsonMap = jsonMap
              .where((project) {
                final assignees = List<dynamic>.from(project['assignees']).map((e) => e['_id']);
                return assignees.contains(employeeId) && (project['status'] == "active" || project['status'] == "completed");
              })
              .toList()
              .reversed
              .toList();

          final rearrangedFilteredJsonMap = [...filteredJsonMap.where((project) => project['status'] == "active"), ...filteredJsonMap.where((project) => project['status'] == "completed")];
          return rearrangedFilteredJsonMap;
        } else {
          throw Exception('Data not found in response');
        }
      } else {
        throw Exception('Failed to fetch data: ${serverResponse.statusCode}');
      }
    }, onData: (value) {
      debugPrint('onData: $value');
    }, onError: (error) {
      debugPrint('onError: $error');
    });

    return Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async => await projectQuery.refresh(),
          child: projectQuery.isLoading
              ? const Center(child: CircularProgressIndicator())
              : projectQuery.hasError
                  ? const Center(child: Text("An error occurred :("))
                  : projectQuery.hasData
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: projectQuery.data!.length,
                          itemBuilder: (context, index) {
                            String dt = projectQuery.data![index]['startdate'];
                            String dt2 = projectQuery.data![index]['tentative_enddate'];
                            DateTime dateTime2 = DateTime.parse(dt2);
                            DateTime dateTime = DateTime.parse(dt);
                            int day = dateTime.day;
                            int day2 = dateTime2.day;
                            // int month = dateTime.month;
                            int year = dateTime.year;

                            String monthAbbreviation = DateFormat('MMM').format(dateTime);
                            String monthAbbreviation2 = DateFormat('MMM').format(dateTime2);
                            String formattedDate = "$monthAbbreviation-${day.toString().padLeft(2, '0')}";
                            String formattedDate2 = "$monthAbbreviation2-${day2.toString().padLeft(2, '0')}";

                            Widget statusWidget;
                            if (projectQuery.data![index]['status'] == 'active') {
                              statusWidget = Text(
                                "Active",
                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
                              );
                            } else if (projectQuery.data![index]['status'] == 'completed') {
                              statusWidget = Text("Completed", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13));
                            } else {
                              statusWidget = Text(
                                projectQuery.data![index]['status'],
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                              );
                            }

                            return Container(
                              key: ValueKey(index),
                              decoration: BoxDecoration(color: (index % 2 == 0) ? Colors.transparent : Color.fromARGB(130, 238, 238, 238)),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectIn(projects: projectQuery.data![index])));
                                },
                                child: SizedBox(
                                  width: width,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  projectQuery.data![index]['title'],
                                                  style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  "$formattedDate - $formattedDate2 $year",
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(vertical: height * 0.01),
                                                  child: statusWidget,
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  child: Image.network(
                                                    projectQuery.data![index]['client']['pfpurl'],
                                                    height: 50,
                                                    width: 50,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Text(
                                                  (projectQuery.data![index]['client']['name'] as String).split(' ')[0],
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(),
        ));
  }
}
