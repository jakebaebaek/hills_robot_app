import 'dart:core';
import 'package:flutter/material.dart';
import 'package:hills_robot_app/utils/constants.dart';

enum WhenObstacleDetects {avoid, stop}

class InformationWidget extends StatefulWidget{
  const InformationWidget({super.key});

  @override
  State<InformationWidget> createState() => _InformationWidget();
}

class _InformationWidget extends State<InformationWidget>{
  //TODO 파일에서 읽어오는 것으로 처리하기.
  

  @override
  Widget build(BuildContext context){
    return Container(
      child: Column(
        children: [
          Text('SW version : $kVersion'),
          Text('Model Name : $kModelName'),
          const Text('HillsRobotics Inc.'),
        ],
      ),
    );
  }
}