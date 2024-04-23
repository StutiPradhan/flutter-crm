import 'dart:convert';
import 'dart:io';

import 'package:fl_query/fl_query.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController _oldPwdController = TextEditingController();
  final TextEditingController _newPwdController = TextEditingController();

  void dispose() {
    _oldPwdController.dispose();
    _newPwdController.dispose();
    super.dispose();
  }

  @override
  bool passwordvisible = true;
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.1, vertical: height * 0.00),
            child: const Text("Change Password"),
          ),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.045, vertical: height * 0.06),
                child: MutationBuilder<
                        Map<String, dynamic>,
                        dynamic,
                        Map<String, dynamic>,
                        dynamic>('create-deliverable-thread',
                    refreshQueries: const ['deliverable-threads'],
                    (variables) async {
                  final SharedPreferences sharedPrefs =
                      await SharedPreferences.getInstance();

                  debugPrint('🧠🧠🧠🧠🧠🧠🧠🧠🧠🧠🧠');

                  return http.post(
                      Uri.parse(
                          "https://lipsum.smalltowntalks.com/v1/emp/graphql"),
                      body: jsonEncode({
                        "query":
                            "mutation X(\$old_pwd: String!, \$new_pwd: String!) { updateEmployeePwdFlutter(old_pwd: \$old_pwd, new_pwd: \$new_pwd) { payload success message} }",
                        "variables": {
                          "old_pwd": _oldPwdController.text,
                          "new_pwd": _newPwdController.text,
                        }
                      }),
                      headers: {
                        HttpHeaders.contentTypeHeader: "application/json",
                        HttpHeaders.authorizationHeader:
                            "Bearer ${sharedPrefs.getString("jwt")}"
                      }).then((response) {
                    debugPrint(response.body);
                    debugPrint('🧠🧠🧠🧠🧠🧠🧠🧠🧠🧠🧠${response.body}');
                    return Map<String, dynamic>.from(jsonDecode(response.body));
                  });
                }, onData: (data, recoveryData) {
                  debugPrint('🧠🧠🧠🧠🧠🧠🧠🧠🧠🧠🧠${data.toString()}');
                  if (!data['data']['updateEmployeePwdFlutter']['success']) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Verification failed'),
                            content: const Text('Current password is invalid'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Continue Browsing'),
                              ),
                            ],
                          );
                        });
                  } // can you push this file's changes?
                  else // *poke poke*
                  {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Password changed'),
                            content:
                                const Text('Password was changed successfully'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Continue Browsing'),
                              ),
                            ],
                          );
                        });
                  }
                }, builder: (context, mutation) {
                  return Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enter current Password",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          TextFormField(
                            controller: _oldPwdController,
                            decoration: InputDecoration(
                                hintText: "",
                                hintStyle:
                                    TextStyle(fontSize: 13, color: Colors.grey),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 10, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10))),
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.0, vertical: height * 0.09),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /* const (RAWR WW) */ Text(
                              "Enter new password",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            TextFormField(
                              controller: _newPwdController,
                              obscureText: passwordvisible,
                              decoration: InputDecoration(
                                  hintText: "***********",
                                  hintStyle: TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        passwordvisible = !passwordvisible;
                                      });
                                    },
                                    icon: Icon(passwordvisible
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                  ),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 10, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10))),
                            )
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          mutation.mutate({});
                        },
                        child: Text(
                          "Send",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 99, 180, 246),
                            fixedSize: Size(500, 50)),
                      )
                    ],
                  );
                }))));
  }
}
