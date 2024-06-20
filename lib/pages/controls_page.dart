import 'dart:developer' as dev;
import 'dart:math';
import 'dart:typed_data';

import 'package:dartros_msgs/geometry_msgs/src/msgs/Quaternion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dartros_msgs/geometry_msgs/msgs.dart';
import 'package:flutter/widgets.dart';

import 'package:hills_robot_app/assets/joystick_wt.dart';
import 'package:hills_robot_app/utils/utils.dart';
import 'package:hills_robot_app/assets/ros_map_viewer.dart';

bool debugOffline = false;
double imgSizeModifier = 1.0;

// this implementation assumes normalized quaternion
// converts to Euler angles in 3-2-1 sequence
Quaternion toQuaternion(double roll, double pitch, double yaw) // roll (x), pitch (y), yaw (z), angles are in radians
{
  // Abbreviations for the various angular functions

  double cr = cos(roll * 0.5);
  double sr = sin(roll * 0.5);
  double cp = cos(pitch * 0.5);
  double sp = sin(pitch * 0.5);
  double cy = cos(yaw * 0.5);
  double sy = sin(yaw * 0.5);

  Quaternion q = Quaternion();
  q.w = cr * cp * cy + sr * sp * sy;
  q.x = sr * cp * cy - cr * sp * sy;
  q.y = cr * sp * cy + sr * cp * sy;
  q.z = cr * cp * sy - sr * sp * cy;

  return q;
}
class ControlsWidget extends StatefulWidget {
  const ControlsWidget({super.key});

  @override
  State<ControlsWidget> createState() => _ControlsWidget();

}

class _ControlsWidget extends State<ControlsWidget>{

  late String imgSrc; //should be get throu rosbridge or smth via setting
  bool isTapped = false;
  late Offset offset;
  Offset _pos = const Offset(0, 0);
  Image? mapimg;
  Uint8List? mapData;
  final GlobalKey _gkey = GlobalKey();
  MapImgDetail mapDetail = MapImgDetail(0, 0, 0);
  final Key viewerKey = UniqueKey();
  late Size viewerSize;
  Point robotPos = Point();

  @override
  void dispose(){
    if(nodehandle != null){
      sysLog.d('나감.');
    }
    super.dispose();
  }

  void stickCallback(double x, double y) {
    setState(() {
      double offsetModi = 10;
      _pos = Offset(_pos.dx + x/offsetModi, _pos.dy + y/offsetModi);
      sysLog.i('x: $x, y: $y, dx: ${_pos.dx}, dy: ${_pos.dy}');
      double linX = (y/10).clamp(-robotSetting.maxSpd, robotSetting.maxSpd);
      print(linX);
      double angZ = x.clamp(-robotSetting.maxAng, robotSetting.maxAng);

      Vector3 linear = Vector3(x: -linX, y: 0.0, z: 0.0);
      Vector3 angular = Vector3(x: 0.0, y: 0.0, z: -angZ);
      Twist twist = Twist(linear: linear, angular: angular);
      if(nodehandle != null && pubVel != null){
        pubVel!.publish(twist);
      }
    });
  }
  // void showJoyStick(downDetails){
  //   setState(() {
  //     offset = downDetails.localPosition;
  //     dev.log('controlwidget callback $offset');
  //     isTapped = true;
  //   });
  // }
  // void hideJoyStick(details){
  //   setState(() {
  //     isTapped = false;
  //   });
  // }

  void callbackListener(double x, double y, double yaw){
    robotPos = Point(x: x, y: y, z: yaw);
  }
  void mapDetailCallbackListener(int w, int h, double res){
    mapDetail = MapImgDetail(w, h, res);
  }

  void onTapCallback(TapUpDetails? details){
    if(details != null){
      late Size size;
      if(_gkey.currentContext != null) {
        size = _gkey.currentContext!.size!;
      }

      Quaternion robotQ = toQuaternion(0, 0, robotPos.z);
      double dx = details.localPosition.dx.toDouble();
      double dy = details.localPosition.dy.toDouble();
      double res = mapDetail.res;
      double halfHei = size.height/2;
      double halfWid = size.width/2;
      Point point = Point(x:(dx - halfWid)*res, y:(dy - halfHei)*res, z:0);
      PoseStamped transformedPose = PoseStamped(pose: Pose(position: point, orientation: robotQ));
      print('${transformedPose.pose.position.x}, ${transformedPose.pose.position.y}, ${transformedPose.pose.position.z}');
      if(pubGoal != null && !(pubGoal!.isShutdown)){
        pubGoal!.publish(transformedPose);
      }
    }
  }

  @override
  void initState(){
    super.initState();
    if(nodehandle?.node != null){
      if(pubVel != null && pubVel!.topic.isNotEmpty){
        nodehandle!.unadvertise('/cmd_vel');
      }
      if(pubGoal != null && pubGoal!.topic.isNotEmpty){
        nodehandle!.unadvertise('/move_base_simple/goal');
      }
      pubGoal = nodehandle!.advertise<PoseStamped>('/move_base_simple/goal', PoseStamped.$prototype);
      pubVel = nodehandle!.advertise<Twist>('/cmd_vel', Twist.$prototype);

      sysLog.d('subscribed /map topic successfully!');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(_gkey.currentContext != null) {
        setState((){
          final RenderBox renderBox = _gkey.currentContext!.findRenderObject() as RenderBox;
          viewerSize = renderBox.size;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context){

    double h = devinfo!.height;
    double w = devinfo!.width;
    return Scaffold(
      body: Stack(
        children: [
          // Background map and robot
          GestureDetector(
            key: _gkey,
            onTapUp: onTapCallback,
            child: RosMapViewer(
              mapTopic: robotSetting.robotMapTopic,
              key: viewerKey,
              odomTopic: robotSetting.robotOdomTopic,
              tfTopic: robotSetting.robotTfTopic,
              mapSizeModifier: imgSizeModifier,
              mapDetailCallback: mapDetailCallbackListener,
              posCallback: callbackListener,
            ),
          ),
          Align(
            alignment: (w >= h) ? const Alignment(0.5, 0.2) : Alignment.bottomCenter,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final joystickSize = min(constraints.maxWidth, constraints.maxHeight) * 0.2;
                return Container(
                  width: joystickSize,
                  height: joystickSize,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  margin: EdgeInsets.only(bottom: h * 0.05),
                  child: JoyStick(listener: stickCallback),
                );
              },
            ),
          ),
          // Top-left corner button
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.location_pin, color: Colors.black),
              onPressed: () {},
            ),
          ),
          // Top-center button
          Positioned(
            top: 20,
            left: (w / 2) - 20,
            child: IconButton(
              icon: Icon(Icons.circle, color: Colors.black),
              onPressed: () {},
            ),
          ),
          // Top-right corner button
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.map, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
