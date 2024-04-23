import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fl_query/fl_query.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ThreadPage extends StatefulWidget {
  final dynamic threadId;
  const ThreadPage({super.key, required this.threadId});

  @override
  State<ThreadPage> createState() => _ThreadPageState(threadId);
}

class Event {
  final String title;

  Event(this.title);
}

class _ThreadPageState extends State<ThreadPage> {
  final dynamic threadId;

  final threadFieldController = TextEditingController();

  _ThreadPageState(this.threadId);

  @override
  void initState() {
    super.initState();
  }

  @override
  build(context) {
    final queryClient = QueryClient.of(context);
    return QueryBuilder<dynamic, dynamic>(
      'thread_list/$threadId',
      () async {
        debugPrint("Fetching thread.dart... 😊😊😊😊");
        final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

        return http.post(Uri.parse("https://lipsum.smalltowntalks.com/v1/emp/graphql"),
            body: jsonEncode({
              "query": "query Q(\$thread_id: String!) { getDeliverableThread(thread_id: \$thread_id) { payload success message } }",
              "variables": {"thread_id": threadId}
            }),
            headers: {HttpHeaders.contentTypeHeader: "application/json", HttpHeaders.authorizationHeader: "Bearer ${sharedPrefs.getString("jwt")}"}).then((response) {
          return response.body;
        });
      },
      builder: (context, query) {
        if (query.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (query.hasError) {
          return Center(
            child: Text(query.error.toString()),
          );
        }

        final jsonBody = Map<String, dynamic>.from(jsonDecode(query.data));

        debugPrint('💜💜 $jsonBody');

        final response = jsonBody["data"]["getDeliverableThread"]["payload"];

        String dt = response?["created_at"];
        DateTime dateTime = DateTime.parse(dt);
        int year = dateTime.year;
        int month = dateTime.month;
        int day = dateTime.day;
        int hour = dateTime.hour;
        int minute = dateTime.minute;
        int second = dateTime.second;
        final height = MediaQuery.of(context).size.height;
        final width = MediaQuery.of(context).size.width;
        //current_time for chat.
        DateTime current_time = DateTime.now();
        int month2 = current_time.month;
        int day2 = current_time.day;

        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black,
                elevation: 0,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.25, vertical: height * 0.0),
                      child: const Text(
                        'Threads',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: Container(
                  decoration: const BoxDecoration(color: Color.fromARGB(255, 255, 255, 255)),
                  height: 90,
                  width: 100,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: MutationBuilder<Map<String, dynamic>, dynamic, Map<String, dynamic>, dynamic>(
                          'thread-push',
                          refreshQueries: const ['thread'],
                          (variables) async {
                            final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

                            return http.post(Uri.parse("https://lipsum.smalltowntalks.com/v1/emp/graphql"),
                                body: jsonEncode({
                                  "query": "mutation X(\$thread_id: String!, \$comment: String!) { submitDeliverable(thread_id: \$thread_id, comment: \$comment) { success } }",
                                  "variables": {
                                    "thread_id": threadId,
                                    "comment": variables["comment"],
                                  }
                                }),
                                headers: {HttpHeaders.contentTypeHeader: "application/json", HttpHeaders.authorizationHeader: "Bearer ${sharedPrefs.getString("jwt")}"}).then((response) {
                              return Map<String, dynamic>.from(jsonDecode(response.body));
                            });
                          },
                          onData: (data, recoveryData) => debugPrint(data.toString()),
                          builder: (context, mutation) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: SizedBox(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 300.0,
                                    ),
                                    child: TextField(
                                      style: const TextStyle(color: Colors.black),
                                      cursorColor: Color.fromARGB(255, 71, 120, 232),
                                      decoration: const InputDecoration(
                                        hintText: "Type your message...",
                                        hintStyle: TextStyle(color: Color.fromARGB(77, 44, 44, 44)),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: BorderSide.none),
                                        filled: true,
                                        fillColor: Color.fromARGB(255, 236, 235, 235),
                                      ),
                                      keyboardType: TextInputType.multiline,
                                      maxLines: 1,
                                      controller: threadFieldController,
                                    ),
                                  ),
                                )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                    height: 50,
                                    width: 50,
                                    decoration: const BoxDecoration(color: Color.fromARGB(255, 71, 120, 232), borderRadius: BorderRadius.all(Radius.circular(30))),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        await mutation.mutate({"comment": threadFieldController.text});
                                        queryClient.refreshQuery('thread_list/$threadId');
                                        threadFieldController.clear();
                                      },
                                    ))
                              ],
                            );
                          }))),
              body: RefreshIndicator(
                  onRefresh: () async => await query.refresh(),
                  child: ListView(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.045, vertical: height * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: const Text(
                                  "Title",
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                )),
                            Text(
                              response["title"],
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            const Divider(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("Posted ", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                const Icon(Icons.fiber_manual_record, size: 5, weight: 100),
                                Text(
                                  " ${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year.toString().padLeft(2, '0')}, ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}",
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Container(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                child: Text(response["comments"][0]["content"].isEmpty ? "No description provided" : response["comments"][0]["content"],
                                    style: TextStyle(fontStyle: response["comments"][0]["content"].isEmpty ? FontStyle.italic : FontStyle.normal, fontSize: response["comments"][0]["content"].isEmpty ? 12 : 15))),
                            const Divider(),
                            const Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: height * 0.02),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: (response["comments"] ?? []).length - 1,
                              itemBuilder: (context, index) {
                                final list = response["comments"];
                                int indexnew = index + 1;
                                String dateago = list[indexnew]["created_at"];
                                DateTime dateagomsg = DateTime.parse(dateago);
                                int hour = dateagomsg.hour;
                                String author = list[indexnew]["author"];
                                bool isEmployee = (author == "employee");

                                return Container(
                                  decoration: BoxDecoration(color: index % 2 == 0 ? Color.fromARGB(255, 247, 247, 247) : Color.fromARGB(255, 255, 255, 255)),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius: BorderRadius.circular(15.0),
                                                          // child: Image.asset(
                                                          //   isEmployee ? "assets/images/profilepic.png" : "assets/images/user.png",
                                                          //   height: 30,
                                                          //   width: 30,
                                                          //   fit: BoxFit.cover,
                                                          // ),
                                                          child:Icon(
                                                            isEmployee?CupertinoIcons.person_circle_fill:CupertinoIcons.checkmark_shield_fill,
                                                            color:isEmployee?Color.fromARGB(255, 4, 116, 201):Color.fromARGB(223, 223, 169, 8)
                                                          )
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Text(
                                                          isEmployee ? "You" : "Admin",
                                                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                "${day2.toString().padLeft(2, '0')}/${month2.toString().padLeft(2, '0')}",
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                              padding: const EdgeInsets.only(left: 40),
                                              child: Text(
                                                list[indexnew]["content"],
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                                              )),
                                        ],
                                      )),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ));
      },
    );
  }
}
