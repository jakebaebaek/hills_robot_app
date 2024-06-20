import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hills_robot_app/utils/constants.dart';
import 'package:hills_robot_app/utils/device_info.dart';

class InformationWidget extends StatefulWidget {
  const InformationWidget({super.key});

  @override
  State<InformationWidget> createState() => _InformationWidgetState();
}

class _InformationWidgetState extends State<InformationWidget> {
  @override
  Widget build(BuildContext context) {
    DeviceInfo devInfo = DeviceInfo(context: context);
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
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
          ),
          Positioned(
            bottom: 20,
            right: 20,// 오른쪽 패딩 추가
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    'lib/assets/images/logo.png', // 로고 이미지 경로
                    height: 60,
                  ),
                  SizedBox(
                    width: devInfo.width * 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text('HillsRobotics'),
                        Text('Inc.'),
                      ],
                    ),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }
}
