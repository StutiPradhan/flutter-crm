import 'dart:convert';
import 'dart:io';

import 'package:flutter_crm_emp/pages/DeliverForm.dart';
import 'package:flutter_crm_emp/pages/thread.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;

class Deliverables extends HookWidget {
  const Deliverables({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final threadListQuery = useQuery('thread_list', () async {
      final k = jsonEncode({'query': "query { getDeliverables { payload } }"});
      final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

      final serverResponse = await http.post(Uri.parse("https://lipsum.smalltowntalks.com/v1/emp/graphql"), body: k, headers: {HttpHeaders.contentTypeHeader: "application/json", HttpHeaders.authorizationHeader: "Bearer ${sharedPrefs.getString("jwt")}"});

      final jsonMap = Map<String, dynamic>.from(jsonDecode(serverResponse.body)['data']['getDeliverables']['payload']);
      jsonMap["threads"] = (jsonMap["threads"] as List<dynamic>).reversed.toList();
      return jsonMap;
    }, onData: (value) {
      debugPrint('onData: $value');
    }, onError: (error) {
      debugPrint('onError: $error');
    });

    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DeliverForm()));
          },
          backgroundColor: const Color.fromARGB(255, 246, 136, 202),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          icon: const Icon(Icons.edit),
          label: const Text('New Thread'),
        ),
        body: threadListQuery.isLoading || threadListQuery.isInitial
            ? const Center(child: CircularProgressIndicator())
            : threadListQuery.hasError
                ? Center(child: Text(threadListQuery.error.toString()))
                : threadListQuery.hasData
                    ? RefreshIndicator(
                        onRefresh: () async => await threadListQuery.refresh(),
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: (threadListQuery.data?["threads"] ?? []).length,
                            itemBuilder: (context, index) {
                              final threadList = (threadListQuery.data?["threads"] ?? []);

                              String dt = threadList[index]["created_at"];
                              DateTime dateTime = DateTime.parse(dt);
                              int day = dateTime.day;
                              // int month = dateTime.month;
                              String monthAbbreviation = DateFormat('MMM').format(dateTime);
                              String formattedDate = "${day.toString().padLeft(2, '0')}-$monthAbbreviation";

                              Widget sender;
                              if (threadList[index]["comments"][0]["author"] == "employee") {
                                sender = Row(
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        // child: Image.asset(
                                        //   "assets/images/profilepic.png",
                                        //   height: 20,
                                        //   width: 20,
                                        //   color: Colors.blue.shade500,
                                        child: Icon(CupertinoIcons.person_circle_fill,color: Color.fromARGB(255, 4, 116, 201),),
                                        ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text("You",style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                sender = Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      // child: Image.asset(
                                      //   "assets/images/admin_shield.png",
                                      //   height: 20,
                                      //   width: 20,
                                      child:Icon(CupertinoIcons.checkmark_shield_fill,color:Color.fromARGB(223, 223, 169, 8)),
                                      
                                       // color: const Color.fromARGB(255, 252, 201, 49),
                                      ),
                                    
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                      //  child: Text(threadList[index]['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                      child:Text("Admin",style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: width * 0.0, vertical: height * 0.005),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ThreadPage(threadId: threadList[index]["_id"], key: ValueKey(threadList[index]["_id"]))));
                                  },
                                  child: Container(
                                    width: width,
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0 ? Colors.white : const Color.fromARGB(255, 247, 247, 247),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: ListTile(
                                          title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              sender,
                                              Text(//to get the formatted created_at date
                                                formattedDate,
                                                style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                           Text(threadList[index]['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            threadList[index]["comments"][0]["content"].toString().trim().isEmpty ? "No description provided" : threadList[index]["comments"][0]["content"],
                                            softWrap: false,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: threadList[index]["comments"][0]["content"].toString().trim().isEmpty ? const Color.fromARGB(255, 183, 183, 183) : Colors.black,
                                                fontSize: threadList[index]["comments"][0]["content"].toString().trim().isEmpty ? 12 : 15,
                                                fontWeight: threadList[index]["comments"][0]["content"].toString().trim().isEmpty ? FontWeight.w600 : FontWeight.w400,
                                                fontStyle: threadList[index]["comments"][0]["content"].toString().trim().isEmpty ? FontStyle.italic : FontStyle.normal),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                              decoration: BoxDecoration(
                                                color: index % 2 == 0 ? const Color.fromARGB(255, 247, 247, 247) : const Color.fromARGB(255, 255, 255, 255),
                                                borderRadius: const BorderRadius.all(Radius.circular(100)),
                                              ),
                                              padding: const EdgeInsets.all(10),
                                              child: Row(children: [
                                                Text(
                                                  threadList[index]["comments"][threadList[index]["comments"].length - 1]["author"] == "employee" ? "You: " : "Admin: ",
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                  maxLines: 1,
                                                ),
                                                Expanded(
                                                    child: Text(
                                                  threadList[index]["comments"][threadList[index]["comments"].length - 1]["content"],
                                                  softWrap: false,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.grey),
                                                )),
                                              ]))
                                        ],
                                      )),
                                    ),
                                  ),
                                ),
                              );
                            }))
                    : Container());
  }
}
