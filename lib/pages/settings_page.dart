import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hills_robot_app/pages/settings/subpages/configuration.dart';
import 'package:hills_robot_app/pages/settings/subpages/information.dart';
import 'package:hills_robot_app/pages/settings/subpages/network.dart';

class SettingsWidget extends StatefulWidget{
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidget();
}

class _SettingsWidget extends State<SettingsWidget> {
  final List<NavigationRailDestination> navBarItems = [
    const NavigationRailDestination(icon: Icon(CupertinoIcons.gear), label: Text('Configure')),
    const NavigationRailDestination(icon: Icon(CupertinoIcons.wifi), label: Text('Network')),
    const NavigationRailDestination(icon: Icon(CupertinoIcons.info), label: Text('Information')),
  ];
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const ConfigureWidget(),
    const NetworkWidget(),
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
    // double width = MediaQuery.of(context).size.width;
    // log('$width');
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            labelType: NavigationRailLabelType.all,
            groupAlignment: -1.0,
            selectedIndex: _selectedIndex,
            destinations: navBarItems,
            onDestinationSelected: onSelected,
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




