import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_crm_emp/BottomNavBar.dart';
import 'package:flutter_crm_emp/emphome.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import "package:http/http.dart" as http;

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final emailFormController = TextEditingController();

  final pwdFormController = TextEditingController();

  Future<bool> signInWithCredentials(String email, String password) async {
    final serverResponse = await http.post(Uri.parse("https://lipsum.smalltowntalks.com/v1/emp/session/login"),
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
        headers: {HttpHeaders.contentTypeHeader: "application/json"});

    final responseBody = jsonDecode(serverResponse.body);

    if (responseBody["success"]) {
      final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

      await sharedPrefs.setString("jwt", responseBody["payload"]["jwt"]);
      await sharedPrefs.setString("jwt_refresh", responseBody["payload"]["jwt_refresh"]);
      await sharedPrefs.setString("who_am_i", jsonEncode(responseBody["payload"]["user_obj"]));
    }

    return responseBody["success"];
  }

  void showIncorrectCredentialsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Incorrect Credentials'),
          content: Text('The username or password you entered is incorrect. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
        body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            primary: true,
            child: Stack(
              children: [
                Container(
                  height: height, // Use the height of the screen
                  width: width, // Use the width of the screen
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/loginbg.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  child: Column(
                    children: [
                      Padding(
                        padding:  EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: width * 0.0, vertical: height * 0.02),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text('Log In', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:  EdgeInsets.only(
                          top: 200.0,
                          bottom: 10,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Email",
                                  style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      //color: Ecocolors.selectionBlack,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextField(
                                      controller: emailFormController,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        hintText: 'email@example.com',
                                        filled: true,
                                        fillColor: Color.fromARGB(51, 0, 0, 0),
                                        border: OutlineInputBorder(
                                          // Use OutlineInputBorder with BorderSide.none
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Color.fromARGB(255, 51, 82, 236), width: 2.0),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                        hintStyle: TextStyle(color: Color.fromARGB(69, 223, 237, 255), fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding:  EdgeInsets.only(top: 32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Password",
                                    style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        //color: Ecocolors.selectionBlack,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: TextField(
                                        obscureText: true,
                                        controller: pwdFormController,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: const InputDecoration(
                                          hintText: '***************',
                                          filled: true,
                                          fillColor: Color.fromARGB(51, 0, 0, 0), // Same background color as the first TextField
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color.fromARGB(255, 51, 82, 236), width: 2.0), // Same focused border color as the first TextField
                                          ),
                                          contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10), // Same content padding as the first TextField
                                          hintStyle: TextStyle(
                                            color: Color.fromARGB(69, 223, 237, 255), // Same hint text color as the first TextField
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  final resp = await signInWithCredentials(emailFormController.text, pwdFormController.text);

                                  if (resp) {
                                    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

                                    sharedPrefs.setBool("is_logged_in", true);

                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigationBarExampleApp()));
                                  } else {
                                    // ...
                                    showIncorrectCredentialsDialog(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 50, 85, 237),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                  //side: const BorderSide(
                                  //  width: 2.0, color: Colors.black),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 20, vertical: MediaQuery.of(context).size.height / 90),
                                  child: Text('Log In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20)),
                                ))
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Use of this tracking app requires data consent.By logging in,you agree to live location tracking on demand and attendance registration for work-related purposes. Your privacy is essential to us.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 10),
                            )),
                      )
                    ],
                  ),
                ),
              ],
            )));
  }
}
