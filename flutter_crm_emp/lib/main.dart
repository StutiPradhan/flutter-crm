import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_crm_emp/BottomNavBar.dart';
import 'package:flutter_crm_emp/Login.dart';
import 'package:flutter_crm_emp/pages/Notify/notification.dart';
import 'package:flutter/material.dart';
import 'package:fl_query/fl_query.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:neat_periodic_task/neat_periodic_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import "package:http/http.dart" as http;


const fetchAgenda1HourPeriodicBgTaskKey = "fetchAgenda1HourPeriodicBgTaskKey";

const backgroundLocationUpload = "backgroundLocationUpload";

var notificationService = NotificationService();

fetchAgendaAndScheduleNotif() async {
  debugPrint("${DateTime.now()}: Executing $fetchAgenda1HourPeriodicBgTaskKey");

  final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

  final serverResponse =
      await http.post(Uri.parse("https://lipsum.smalltowntalks.com/v1/emp/graphql"), body: jsonEncode({"query": "query { getAllEmpAgenda { payload } }"}), headers: {HttpHeaders.contentTypeHeader: "application/json", HttpHeaders.authorizationHeader: "Bearer ${sharedPrefs.getString("jwt")}"});

  final List decodedPayloadArray = Map<String, dynamic>.from(jsonDecode(serverResponse.body))["data"]["getAllEmpAgenda"]["payload"];

  for (int i = 0; i < decodedPayloadArray.length; i++) {
    final broadcast = decodedPayloadArray[i];

    debugPrint("Scheduling notif for ${broadcast['title']} @ ${broadcast['datetime']}");

    notificationService.scheduleNotification(id: DateTime.parse(broadcast["created_at"]).millisecondsSinceEpoch ~/ (1000), title: broadcast["title"], body: broadcast["description"], scheduledNotificationDateTime: DateTime.parse(broadcast["datetime"]));
  }
}

makeTokenKnown(String token) async {
  SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  await http.post(Uri.parse("https://lipsum.smalltowntalks.com/v1/emp/graphql"),
      body: jsonEncode({
        "query": "mutation X(\$fcm_token: String!) { updateFCMToken(fcm_token: \$fcm_token) { success } }",
        "variables": {"fcm_token": token}
      }),
      headers: {HttpHeaders.contentTypeHeader: "application/json", HttpHeaders.authorizationHeader: "Bearer ${sharedPrefs.getString("jwt")}"});
}

uploadBackgroundLocation() async {
  debugPrint("${DateTime.now().toString()} Running background location uploader...");

  final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

  if (!(sharedPrefs.getBool("is_checked_in") ?? false)) {
    debugPrint("Not sending location... user not checked in");
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return debugPrint('Location Permissions are denied');
    }
  }

  await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  ).then((Position position) async {
    final serverResponse = await http.post(Uri.parse("https://lipsum.smalltowntalks.com/v1/emp/graphql"),
        body: jsonEncode({
          "query": "mutation X(\$lat: Float!, \$long: Float!) {reportEmpLocation(lat: \$lat, long: \$long) {success}}",
          "variables": {"lat": position.latitude, "long": position.longitude}
        }),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer ${sharedPrefs.getString("jwt")}",
        });

    debugPrint("Loc.upload response: ${serverResponse.body}");
  }).catchError((e) {
    debugPrint(e.toString());
  });
}

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchAgenda1HourPeriodicBgTaskKey:
        await fetchAgendaAndScheduleNotif();
        return true;

      case backgroundLocationUpload:
        final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

        if (sharedPrefs.getBool("is_logged_in") ?? false) {
          await uploadBackgroundLocation();
        }

        return true;
    }

    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await QueryClient.initialize(cachePrefix: 'fl_cache_crm_emp');

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark, statusBarColor: Color.fromARGB(255, 255, 255, 255)));
  WidgetsFlutterBinding.ensureInitialized();

//here
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // final messaging = FirebaseMessaging.instance;

  // final settings = await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );

  // debugPrint('💃💃💃💃💃 Permission granted: ${settings.authorizationStatus}');

  //String? token = await messaging.getToken();

  // 🌸🌸🌸🌸🌸🌸🌸🌸🌸🌸🌸🌸🌸🌸🌸🌸🌸🌸🌸🌸🌸🌸🌸🌸
  //if (token != null) await makeTokenKnown(token);

//  debugPrint('💃💃💃💃💃💃 Registration Token=$token');

  //to here
  runApp(MyApp(isLoggedIn: await isLoggedIn()));

  PermissionStatus notificationStatus = await Permission.notification.status;
  // If notification permission is denied, request it
  if (notificationStatus.isDenied) {
    Permission.notification.request();
  }

  await notificationService.initNotification();

  await fetchAgendaAndScheduleNotif();
  await uploadBackgroundLocation();

  if (Platform.isAndroid) {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    Workmanager().registerPeriodicTask(fetchAgenda1HourPeriodicBgTaskKey, fetchAgenda1HourPeriodicBgTaskKey, constraints: Constraints(networkType: NetworkType.connected));

    Workmanager().registerPeriodicTask(backgroundLocationUpload, backgroundLocationUpload, constraints: Constraints(networkType: NetworkType.connected));
  }

  if (Platform.isIOS) {
    final scheduler = NeatPeriodicTaskScheduler(
      interval: const Duration(minutes: 15),
      name: 'scheduled-notif-bgloc',
      timeout: const Duration(seconds: 20),
      task: () async {
        final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

        if (sharedPrefs.getBool("is_logged_in") ?? false) {
          await uploadBackgroundLocation();
        }

        await fetchAgendaAndScheduleNotif();
      },
      minCycle: const Duration(seconds: 5),
    );

    scheduler.start();
    await ProcessSignal.sigterm.watch().first;
    await scheduler.stop();
  }
}

Future<bool> isLoggedIn() async {
  final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  return (sharedPrefs.getBool("is_logged_in") ?? false);
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return QueryClientProvider(
      refreshInterval: const Duration(minutes: 15),
      retryDelay: const Duration(seconds: 30),
      staleDuration: const Duration(minutes: 90),
      cache: QueryCache(cacheDuration: const Duration(days: 5)),
      child: OfflineGuard(
          child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MSME CRM',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
        home: isLoggedIn ? const BottomNavigationBarExample() : const LogIn(),
      )),
    );
  }
}

class OfflineGuard extends HookWidget {
  final Widget child;
  const OfflineGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isOnline = useState<bool>(true);

    useEffect(() {
      void startPolling() {
        const duration = Duration(seconds: 15);
        Timer.periodic(duration, (Timer timer) async {
          try {
            final response = await http.get(Uri.parse('https://lipsum.smalltowntalks.com/'));
            if (response.statusCode == 200) {
              isOnline.value = true;
            } else {
              isOnline.value = false;
            }
          } catch (e) {
            isOnline.value = false;
          }
        });
      }

      startPolling();
      return null;
    }, []);

    return isOnline.value ? child : _buildOfflineWidget();
  }

  Widget _buildOfflineWidget() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MSME CRM',
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: const Padding(
        padding: EdgeInsets.all(32.0),
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.signal_wifi_statusbar_connected_no_internet_4_outlined,
                color: Colors.white,
                size: 80,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "It seems you're offline. This app will be used only while it's connected to SmallTownTalks CRM servers.",
                style: TextStyle(fontSize: 12, color: Colors.white, decoration: TextDecoration.none),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
