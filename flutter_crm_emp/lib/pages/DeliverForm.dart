import 'dart:convert';
import 'dart:io';

import 'package:flutter_crm_emp/pages/Deliver.dart';
import 'package:fl_query/fl_query.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeliverForm extends StatefulWidget {
  const DeliverForm({super.key});

  @override
  State<DeliverForm> createState() => _DeliverFormState();
}

class _DeliverFormState extends State<DeliverForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _paragraphController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _paragraphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final queryClient = QueryClient.of(context);

    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.045, vertical: height * 0.05),
          child: MutationBuilder<Map<String, dynamic>, dynamic, Map<String, dynamic>, dynamic>('create-deliverable-thread', refreshQueries: const ['deliverable-threads'], (variables) async {
            final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

            return http.post(Uri.parse("https://lipsum.smalltowntalks.com/v1/emp/graphql"),
                body: jsonEncode({
                  "query": "mutation X(\$title: String!, \$comment: String!) { createDeliverableThread(title: \$title, comment: \$comment) { payload success } }",
                  "variables": {
                    "title": _nameController.text,
                    "comment": _paragraphController.text,
                  }
                }),
                headers: {HttpHeaders.contentTypeHeader: "application/json", HttpHeaders.authorizationHeader: "Bearer ${sharedPrefs.getString("jwt")}"}).then((response) {
              debugPrint(response.body);
              return Map<String, dynamic>.from(jsonDecode(response.body));
            });
          }, builder: (context, mutation) {
            return Column(
              children: [
                Row(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Deliver(),
                              ));
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                    ),
                    const Text("Create a new thread", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.0, vertical: height * 0.03),
                    child: TextField(
                      controller: _nameController,
                      maxLength: 40,
                      decoration: const InputDecoration(hintText: 'Title', hintStyle: TextStyle(color: Color.fromARGB(255, 160, 160, 160)), filled: true, fillColor: Color.fromARGB(255, 250, 250, 250)),
                    )),
                Expanded(
                  child: TextField(
                    controller: _paragraphController,
                    minLines: 30,
                    maxLines: null, // Set maxLines to null to allow unlimited expansion
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: 'Enter description...', //2000 character
                      filled: true,
                      fillColor: Color.fromARGB(255, 250, 250, 250),
                      hintStyle: TextStyle(color: Color.fromARGB(255, 160, 160, 160)),
                      border: OutlineInputBorder(
                        // Use OutlineInputBorder with BorderSide.none
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
                    ),
                    keyboardType: TextInputType.multiline,
                    scribbleEnabled: true,
                    maxLength: 2000,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: ElevatedButton(
                        onPressed: () async {
                          mutation.mutate({}).then((result) {
                            Navigator.pop(context);
                            queryClient.refreshQuery('thread_list', exact: true).then((value) => debugPrint('${value.toString()} 💜💜💜💜💜💜💜💜💜💜💜💜💜💜💜💜'));
                          });
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 0, 123, 255), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))), elevation: 1),
                        child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center, children: [Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Icon(Icons.send, color: Colors.white)), SizedBox(width: 15), Text("Create thread", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                      )),
                ),
              ],
            );
          }),
        ));
  }
}
