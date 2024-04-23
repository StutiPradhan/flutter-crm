import 'package:flutter_crm_emp/pages/Deliver.dart';
import 'package:flutter_crm_emp/emphome.dart';
import 'package:flutter_crm_emp/pages/ProjectsTab.dart';
import 'package:flutter_crm_emp/pages/TaskTab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(const BottomNavigationBarExampleApp());

class BottomNavigationBarExampleApp extends StatelessWidget {
  const BottomNavigationBarExampleApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavigationBarExample(),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() => _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    Emp_home(),
    ProjectsTab(),
    TaskTab(),
    Deliver(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Theme(
          data: ThemeData(
            canvasColor: Colors.black,
          ),
          child: BottomNavigationBar(
            enableFeedback: true,
            selectedFontSize: 12,
            // backgroundColor: Colors.black,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.collections_bookmark), label: 'Projects'),
              BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
              BottomNavigationBarItem(icon: Icon(Icons.sms), label: 'Threads'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: const Color.fromARGB(255, 56, 56, 56),
            onTap: _onItemTapped,
          )),
    );
  }
}
