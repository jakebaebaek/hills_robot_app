import 'dart:core';
import 'package:flutter/material.dart';
import 'package:hills_robot_app/utils/constants.dart';
import 'package:hills_robot_app/utils/device_info.dart';

class InformationWidget extends StatefulWidget {
  const InformationWidget({super.key});

  @override
  State<InformationWidget> createState() => _InformationWidgetState();
}

class _InformationWidgetState extends State<InformationWidget> {
  //TODO 파일에서 읽어오는 것으로 처리하기.

  @override
  Widget build(BuildContext context) {
    DeviceInfo devInfo = DeviceInfo(context: context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 상단, 중앙, 하단의 균등 배분
        children: [
          // 상단 텍스트들
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SW version : $kVersion',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Model Name : $kModelName',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          // 하단 로고
          Padding(
            padding: const EdgeInsets.fromLTRB(200, 10, 10, 10),
            child: Column(
              children: [
                Image.asset(
                  'lib/assets/images/logo.png', // 로고 이미지 경로
                  height: 60,
                ),
                SizedBox(
                  width: devInfo.width*0.5,
                  child: Column(
                    children: [
                      const Text('HillsRobotics'),
                      const Text('Inc.')
                    ],
                  )
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}