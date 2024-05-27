import 'dart:developer' as dev;
import 'dart:math';
import 'dart:typed_data';

import 'package:dartros_msgs/geometry_msgs/src/msgs/Quaternion.dart';
import 'package:flutter/material.dart';

import 'package:dartros_msgs/geometry_msgs/msgs.dart';

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
      // dev.log('controlwidget callback x => $x and y $y');
      _pos = Offset(_pos.dx + x/offsetModi, _pos.dy + y/offsetModi);
      sysLog.i('x: $x, y: $y, dx: ${_pos.dx}, dy: ${_pos.dy}'); 
      //x,y for cmd_vel, dx, dy for total move.
      //anyways, dx dy doesn't need at least now.
      double linX = (y/10).clamp(-robotSetting.maxSpd, robotSetting.maxSpd);
      print(linX);
      double angZ = x.clamp(-robotSetting.maxAng, robotSetting.maxAng);

      Vector3 linear = Vector3(x: -linX, y: 0.0, z: 0.0);
      Vector3 angular = Vector3(x: 0.0, y: 0.0, z: -angZ);
      Twist twist = Twist(linear: linear, angular: angular);
      if(nodehandle != null && pubVel != null){
        pubVel!.publish(twist);
        // sysLog.d('namespace: ${nodehandle!.node.namespace}\nip address: ${nodehandle!.node.ipAddress}\nnode name: ${nodehandle!.node.nodeName}\nis completed: ${nodehandle!.node.nodeReady.isCompleted}\n\n x: ${twist.linear.x}   y: ${twist.angular.z}');
      }
      //좀 정리가 필요할듯;;
    });
  }
  void showJoyStick(downDetails){
    setState(() {
      offset = downDetails.localPosition;
      dev.log('controlwidget callback $offset');
      isTapped = true;
    });
  }
  void hideJoyStick(details){
    setState(() {
      isTapped = false;
    });
  }

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
        // print('size: ${size.width}, ${size.height}');
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
        // print('published goal pose!');
        //TODO position match with map on application, quaternion match.
        // quarternion from current robot pose or direction...
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
        // print("viewerSize1: ${viewerSize.width}, ${viewerSize.height}");
      }
    });
  }
 
  @override
  Widget build(BuildContext context){
    double h = devinfo!.height;
    double w = devinfo!.width;
    // print(h);
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        List<Widget> widgets = [
          GestureDetector(
            key: _gkey,
            onTapUp: onTapCallback,
            child: RosMapViewer(mapTopic: robotSetting.robotMapTopic,
                    key: viewerKey,
                    odomTopic: robotSetting.robotOdomTopic,
                    tfTopic: robotSetting.robotTfTopic,
                    mapSizeModifier: imgSizeModifier, 
                    mapDetailCallback: mapDetailCallbackListener,
                    posCallback: callbackListener,),
          ),
          SizedBox(
              width: w - w/3,
              height: h*0.05,
              child: Slider.adaptive(value: imgSizeModifier,
                onChanged: (value) {
                  setState(() {
                    imgSizeModifier = value;
                    print(imgSizeModifier);
                  });
                },
                min: 0.2, max: 2.0, label: imgSizeModifier.toString(),),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(30),
            ),
            width: orientation == Orientation.landscape ? w - w/3 : null,
            height: orientation == Orientation.portrait ? h - h/3 : null,
            child: JoyStick(listener: stickCallback,),
          ),
        ];
        return buildDependsOrientation(widgets, orientation);
      });
    });
  }
}