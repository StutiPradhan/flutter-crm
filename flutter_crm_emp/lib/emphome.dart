// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter_crm_emp/Login.dart';
import 'package:flutter_crm_emp/dialogues/checkin_dialog.dart';
import 'package:flutter_crm_emp/dialogues/checkout_dialog.dart';
import 'package:flutter_crm_emp/main.dart';
import 'package:flutter_crm_emp/pages/UserProfile/PasswordPage.dart';
import 'package:flutter_crm_emp/pages/broadcastevent.dart';

import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

class Emp_home extends HookWidget {
  Future<void> clearSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  Future<Position> _determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permissions are denied');
      }
    }
    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always) {
        return Future.error('Location Permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  void showCheckInDialog(BuildContext context, Function callback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CheckInDialog(callback: callback);
      },
    );
  }

  void showCheckOutDialog(BuildContext context, Function callback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CheckOutDialog(callback: callback);
      },
    );
  }

  String greeting(String userName) {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning, ${userName.split(' ')[0]}!';
    }
    if (hour < 17) {
      return 'Good Afternoon, ${userName.split(' ')[0]}!';
    }
    return 'Good Evening, ${userName.split(' ')[0]}!';
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final focussedDayState = useState(DateTime.now());
    final endDate = focussedDayState.value;

    final isCheckedin = useState(false);
    final checkin_out = useState<String>("");

    void checked_in() {
      final now = DateTime.now();
      final formattedDate = DateFormat('MMM dd   HH:mm:ss').format(now);
      checkin_out.value = 'Last check-in at $formattedDate';
    }

    void checked_out() {
      final now = DateTime.now();
      final formattedDate = DateFormat('MMM dd   HH:mm:ss').format(now);
      checkin_out.value = 'Last check-out at $formattedDate';
    }

    useEffect(() {
      void getCheckedInStateFromSharedPrefs() async {
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        debugPrint('🦖🦖🦖🦖🦖🦖🦖 ${sharedPreferences.getBool("is_checked_in") ?? false}');
        isCheckedin.value = sharedPreferences.getBool("is_checked_in") ?? false;
      }

      // void makeTokenKnownSideEffect() async {
      //   final messaging = FirebaseMessaging.instance;
      //   String? token = await messaging.getToken();
      //   if (token != null) await makeTokenKnown(token);
      //   debugPrint('💃💃💃💃💃💃 Registration Token=$token');
      // }

      getCheckedInStateFromSharedPrefs();
     // makeTokenKnownSideEffect();
      return null;
    }, []);

    final query = useQuery<Map<String, dynamic>, Map<String, dynamic>>(
      'emp_home',
      initial: {
        "__drawer__": {"user_name": "User", "user_email": "Loading...", "user_profurl": "https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg", "org_handle": "@user3451bdc9231f9f012e"}
      },
      () async {
        try {
          debugPrint("Fetching emphome.dart...");
          final k = jsonEncode({'query': "query { getAllEmpAgendaDart { payload } }"});
          final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

          String userDataJson = sharedPrefs.getString("who_am_i") ?? "{}";
          final decodedUserDataJson = Map<String, dynamic>.from(jsonDecode(userDataJson));

          final serverResponse = await http.post(Uri.parse("https://lipsum.smalltowntalks.com/v1/emp/graphql"), body: k, headers: {HttpHeaders.contentTypeHeader: "application/json", HttpHeaders.authorizationHeader: "Bearer ${sharedPrefs.getString("jwt")}"});

          if (serverResponse.statusCode == 200) {
            final jsonMap = Map<String, dynamic>.from(jsonDecode(serverResponse.body));
            if (jsonMap.containsKey('data')) {
              final payload = jsonMap['data']['getAllEmpAgendaDart']['payload'];
              payload['__drawer__'] = {
                "user_profurl": decodedUserDataJson['pfpurl'],
                "user_name": decodedUserDataJson['name'],
                "user_email": decodedUserDataJson['contact']['email'],
                "org_handle": decodedUserDataJson['org']['name'],
              };
              return payload;
            } else {
              throw Exception('Data not found in response');
            }
          } else {
            throw Exception('Failed to fetch data: ${serverResponse.statusCode}');
          }
        } catch (e) {
          throw Exception('Error fetching data: $e');
        }
      },
      onData: (value) {
        debugPrint('onData: $value');
      },
      onError: (error) {
        debugPrint('onError: $error');
      },
    );

    return Scaffold(
      key: _key,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [Container()],
        title: const Text(
          "MSME CRM",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      body: RefreshIndicator(
          onRefresh: () async => await query.refresh(),
          child: Stack(children: [
            ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
              query.isLoading
                  ? SizedBox(height: height - 60, child: const Center(child: CircularProgressIndicator()))
                  : query.hasError
                      ? const Center(child: Text("An error occurred, check back later :("))
                      : query.hasData
                          ? SingleChildScrollView(
                              child: Container(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: width * 0.02, right: width * 0.02, bottom: height * 0.02),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "MSME CRM",
                                            style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
                                          ),
                                          InkWell(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(20.0),
                                              child: Image.network(query.data?['__drawer__']['user_profurl'], height: 40, width: 40, fit: BoxFit.cover),
                                            ),
                                            onTap: () {
                                              _key.currentState!.openEndDrawer();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color.fromARGB(90, 158, 158, 158), // Shadow color
                                              spreadRadius: 1, // Spread radius
                                              blurRadius: 5, // Blur radius
                                              offset: Offset(0, 2), // Offset in x and y directions
                                            )
                                          ],
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                          gradient: LinearGradient(
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomLeft,
                                            colors: [
                                              Color.fromARGB(255, 245, 149, 4),
                                              Color.fromARGB(255, 231, 85, 12),
                                            ],
                                          )),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('${greeting(query.data?['__drawer__']['user_name'])} 😊',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    )),
                                                Text(!isCheckedin.value ? "Check in to allow centralised location data collection." : "Check out to stop sending location updates.", key: ValueKey(isCheckedin), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w300)),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: ElevatedButton(
                                                key: ValueKey(isCheckedin),
                                                onPressed: () async {
                                                  final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
                                                  debugPrint("🪷🪷🪷🪷");
                                                  dynamic currPosition;
                                                  try {
                                                    currPosition = await _determinePosition();
                                                  } catch (e) {
                                                    debugPrint("🍿🍿🍿");
                                                    debugPrint(e.toString());
                                                  }

                                                  if (!(sharedPrefs.getBool("is_checked_in") ?? false)) {
                                                    showCheckInDialog(context, () async {
                                                      await http.post(Uri.parse("https://lipsum.smalltowntalks.com/v1/emp/graphql"),
                                                          body: jsonEncode({
                                                            "query": "mutation X(\$lat: Float!, \$long: Float!) { reportCheckin(lat: \$lat, long: \$long) { success } }",
                                                            "variables": {
                                                              "lat": currPosition.latitude,
                                                              "long": currPosition.longitude,
                                                            }
                                                          }),
                                                          headers: {
                                                            HttpHeaders.contentTypeHeader: "application/json",
                                                            HttpHeaders.authorizationHeader: "Bearer ${sharedPrefs.getString("jwt")}",
                                                          });

                                                      await uploadBackgroundLocation();
                                                      await sharedPrefs.setBool("is_checked_in", true);
                                                      isCheckedin.value = true;
                                                      checked_in();
                                                    });
                                                  } else {
                                                    showCheckOutDialog(
                                                      context,
                                                      () async {
                                                        await http.post(Uri.parse("https://lipsum.smalltowntalks.com/v1/emp/graphql"),
                                                            body: jsonEncode({
                                                              "query": "mutation Mutation(\$lat: Float!, \$long: Float!) { reportCheckout(lat: \$lat, long: \$long) { success } }",
                                                              "variables": {"lat": currPosition.latitude, "long": currPosition.longitude}
                                                            }),
                                                            headers: {
                                                              HttpHeaders.contentTypeHeader: "application/json",
                                                              HttpHeaders.authorizationHeader: "Bearer ${sharedPrefs.getString("jwt")}",
                                                            });

                                                        await sharedPrefs.setBool("is_checked_in", false);
                                                        isCheckedin.value = false;
                                                        checked_out();
                                                      },
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 11, 48, 235), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))), elevation: 5),
                                                child: Text(
                                                  isCheckedin.value ? "Check Out" : "Check In",
                                                  style: const TextStyle(color: Colors.white, fontSize: 15),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: width * 0.0, vertical: height * 0.02),
                                      child: Column(
                                        children: [
                                          Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              decoration: const BoxDecoration(color: Color.fromARGB(255, 241, 241, 241), borderRadius: BorderRadius.all(Radius.circular(10))),
                                              child: query.hasData && !query.isLoading
                                                  ? TableCalendar(
                                                      calendarStyle: const CalendarStyle(holidayTextStyle: TextStyle(fontWeight: FontWeight.bold), weekendTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                                                      holidayPredicate: (DateTime day) {
                                                        if (day.weekday == 6 || day.weekday == 7) return true;
                                                        return false;
                                                      },
                                                      calendarFormat: CalendarFormat.week,
                                                      locale: "en_US",
                                                      calendarBuilders: CalendarBuilders(
                                                        markerBuilder: (context, day, events) {
                                                          return Stack(
                                                            alignment: AlignmentDirectional.bottomCenter,
                                                            children: [
                                                              for (var event in events)
                                                                Positioned(
                                                                  key: ValueKey(event.hashCode),
                                                                  child: Container(
                                                                    decoration: const BoxDecoration(
                                                                      shape: BoxShape.circle,
                                                                      color: Color.fromARGB(255, 87, 108, 197), // Customize marker color
                                                                    ),
                                                                    width: 6,
                                                                    height: 6,
                                                                  ),
                                                                ),
                                                            ],
                                                          );
                                                        },
                                                        defaultBuilder: (context, day, focusedDay) => Center(
                                                          child: Text(
                                                            key: ValueKey(day.toString()),
                                                            day.day.toString(),
                                                            style: const TextStyle(color: Color.fromARGB(255, 147, 147, 147)),
                                                          ),
                                                        ),
                                                        dowBuilder: (context, day) {
                                                          final String text = DateFormat.E().format(day);
                                                          if (day.weekday == DateTime.sunday || day.weekday == DateTime.saturday) {
                                                            return Center(
                                                              child: Text(
                                                                text,
                                                                style: const TextStyle(color: Color.fromARGB(255, 123, 74, 183), fontWeight: FontWeight.bold),
                                                              ),
                                                            );
                                                          } else {
                                                            return Center(
                                                              child: Text(
                                                                text,
                                                                style: const TextStyle(color: Color.fromARGB(255, 147, 147, 147)),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        holidayBuilder: (context, day, focusedDay) {
                                                          if (day.weekday == DateTime.sunday || day.weekday == DateTime.saturday) {
                                                            return Center(
                                                              child: Text(
                                                                '${day.day}',
                                                                style: const TextStyle(
                                                                  color: Color.fromARGB(255, 123, 74, 183),
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            );
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                      ),
                                                      eventLoader: (DateTime day) {
                                                        final year = day.year.toString();
                                                        final month = day.month.toString();
                                                        final dayOfMonth = day.day.toString();

                                                        if (query.data!.containsKey(year) && query.data?[year].containsKey(month) && query.data?[year][month].containsKey(dayOfMonth)) {
                                                          return query.data?[year][month][dayOfMonth] ?? [];
                                                        } else {
                                                          return [];
                                                        }
                                                      },
                                                      headerStyle: HeaderStyle(
                                                          titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                          formatButtonVisible: false,
                                                          titleCentered: true,
                                                          leftChevronIcon: Icon(CupertinoIcons.arrowtriangle_left_circle_fill, color: Colors.blue.shade400),
                                                          rightChevronIcon: Icon(CupertinoIcons.arrowtriangle_right_circle_fill, color: Colors.blue.shade400)),
                                                      availableGestures: AvailableGestures.all,
                                                      selectedDayPredicate: (day) => isSameDay(day, focussedDayState.value),
                                                      focusedDay: focussedDayState.value,
                                                      firstDay: DateTime.utc(focussedDayState.value.year, focussedDayState.value.month, 1),
                                                      lastDay: DateTime.utc(focussedDayState.value.year + 1, 12, 31),
                                                      onDaySelected: (DateTime day, DateTime focusedDay) {
                                                        focussedDayState.value = focusedDay;
                                                      })
                                                  : Container()),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 20),
                                              const Center(
                                                child: Text(
                                                  "Broadcasts",
                                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              Container(
                                                decoration: const BoxDecoration(color: Color.fromARGB(255, 246, 246, 246), borderRadius: BorderRadius.all(Radius.circular(10))),
                                                child: !query.isInitial && !query.isLoading
                                                    ? ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount: (query.data?[endDate.year.toString()]?[endDate.month.toString()]?[endDate.day.toString()] ?? []).length,
                                                        itemBuilder: (context, index) {
                                                          final evtList = query.data?[endDate.year.toString()]?[endDate.month.toString()]?[endDate.day.toString()] ?? [];

                                                          String dateTimeString = evtList[index]['datetime'];
                                                          DateTime dateTime = DateTime.parse(dateTimeString);

                                                          int hour = dateTime.toLocal().hour; //lol.hour;
                                                          int minute = dateTime.toLocal().minute;
                                                          List<Color> colors = [
                                                            const Color.fromARGB(255, 247, 94, 214),
                                                            const Color.fromARGB(255, 101, 197, 238),
                                                            const Color.fromARGB(255, 240, 211, 94),
                                                            const Color.fromARGB(255, 50, 182, 10),
                                                          ];
                                                          int colorIndex = index % colors.length;
                                                          return InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => BroadCast(
                                                                    agenda: evtList[index],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: ListTile(
                                                              contentPadding: EdgeInsets.symmetric(horizontal: width * 0.02, vertical: height * 0.000005),
                                                              title: Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                                                                        child: Icon(Icons.circle, color: colors[colorIndex], size: 20),
                                                                      ),
                                                                      Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            evtList[index]["title"],
                                                                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black),
                                                                          ),
                                                                          Text(
                                                                            "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}",
                                                                            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 13),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : Container(),
                                              ), // Placeholder for other cases
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ])),
                            )
                          : const Center(child: Text("Something went wromg :("))
            ])
          ])),
      endDrawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(0), bottomRight: Radius.circular(0)),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Color.fromARGB(255, 46, 8, 143)),
                currentAccountPicture: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.network(
                    query.data?['__drawer__']['user_profurl'],
                    key: ValueKey(query.isLoading),
                  ),
                ),
                accountName: Text(query.data?['__drawer__']['user_name'], style: const TextStyle(fontWeight: FontWeight.bold), key: ValueKey(query.data?['__drawer__']['user_name'])),
                accountEmail: Text(query.data?['__drawer__']['user_email'], style: const TextStyle(fontWeight: FontWeight.bold), key: ValueKey(query.data?['__drawer__']['user_email']))),
            ListTile(
              leading: const Icon(
                Icons.badge,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Organisation'),
                  Text(
                    '@${query.data?['__drawer__']['org_handle']}',
                    style: const TextStyle(
                      fontSize: 12, // Adjust the font size as needed
                      color: Colors.grey, // Adjust the color as needed
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.lock,
              ),
              title: const Text('Change Password'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PasswordPage(),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_sharp),
              title: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Do you want to Logout?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Clear SharedPreferences
                            clearSharedPreferences().then((_) {
                              // Navigate to login page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LogIn()),
                              );
                            });
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
