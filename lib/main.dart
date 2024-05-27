import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hills_robot_app/pages/controls_page.dart';
import 'package:hills_robot_app/pages/settings_page.dart';
import 'package:hills_robot_app/pages/tasks_page.dart';
import 'package:hills_robot_app/utils/device_info.dart';
import 'package:hills_robot_app/utils/constants.dart';

void main() {
  runApp(const LorobotApp());
}

class LorobotApp extends StatelessWidget {
  const LorobotApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(brightness:  Brightness.light),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _LorobotApp();
}

class _LorobotApp extends State<MainPage> {
  int _gIndex = 0;

  void onTapNavBar(int index){
    setState(() {
      _gIndex = index;
    });
  }

  @override
  Widget build(BuildContext context){
    devinfo = DeviceInfo(context: context);
    final List<BottomNavigationBarItem> navBarItems = [
      const BottomNavigationBarItem(icon: Icon(CupertinoIcons.game_controller), label: 'Control'),
      // arrow_2_squarepath
      const BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Operating'),
      const BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: 'Settings'),
    ];
    final List<Widget> screens = [const ControlsWidget(), const TasksWidget(), const SettingsWidget()];

    return Scaffold(
      appBar: AppBar(title: Text(navBarItems.elementAt(_gIndex).label.toString())),
      body: screens[_gIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: navBarItems,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        useLegacyColorScheme: false,
        currentIndex: _gIndex,
        onTap: onTapNavBar,
      )
    );
  }
}

//TODO see getx package for state management.
//links here https://pub.dev/packages/get