import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hills_robot_app/pages/settings/subpages/configuration.dart';
import 'package:hills_robot_app/pages/settings/subpages/information.dart';
import 'package:hills_robot_app/pages/settings/subpages/network.dart';
import 'package:hills_robot_app/pages/settings/subpages/map.dart';
import 'package:hills_robot_app/utils/constants.dart';
import 'package:hills_robot_app/utils/device_info.dart';

class SettingsWidget extends StatefulWidget{
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidget();
}

class _SettingsWidget extends State<SettingsWidget> {
  final List<NavigationRailDestination> navBarItems = [
    const NavigationRailDestination(icon: Icon(CupertinoIcons.gear), label: Text('Config')),
    const NavigationRailDestination(icon: Icon(CupertinoIcons.wifi), label: Text('Network')),
    const NavigationRailDestination(icon: Icon(CupertinoIcons.map), label: Text('Map')),
    const NavigationRailDestination(icon: Icon(CupertinoIcons.info), label: Text('Info')),
  ];
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const ConfigureWidget(),
    const NetworkWidget(),
    const MapWidget(),
    const InformationWidget(),
  ];


  void onSelected(int index){
    _selectedIndex = index;
    setState(() {
      var wdt = toString();
      log('[$wdt] Index Selected $index');
    });
  }

  @override
  Widget build(BuildContext context){
    DeviceInfo devInfo = DeviceInfo(context: context);
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: devInfo.width*0.18,
            child:  NavigationRail(
              trailing: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
              ),
              backgroundColor: Colors.grey[50],
              selectedIconTheme: IconThemeData(size: 30),
              unselectedIconTheme: IconThemeData(size: 20),
              selectedLabelTextStyle: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelTextStyle: TextStyle(
                  fontFamily: 'Pretendart',
                  color: Colors.grey,
                  fontWeight: FontWeight.w400
              ),
              labelType: NavigationRailLabelType.all,
              groupAlignment: -1.0,
              selectedIndex: _selectedIndex,
              destinations: navBarItems,
              onDestinationSelected: onSelected,
            ),
          ),
          Flexible(
            child: Scaffold(
              body: _screens[_selectedIndex],)
          ),
        ],
      ),
    );
  }



}




