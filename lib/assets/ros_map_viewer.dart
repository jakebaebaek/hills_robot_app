import 'dart:math';

import 'package:dartros/dartros.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dartros_msgs/geometry_msgs/msgs.dart' as geo;
import 'package:dartros_msgs/nav_msgs/msgs.dart';
import 'package:dartros_msgs/tf2_msgs/msgs.dart';
import 'package:image/image.dart' as imglib;

import 'package:hills_robot_app/utils/utils.dart';

	
class ImageDetail {

  final int width;
  final int height;
  final Uint8List? bytes;

  ImageDetail({required this.width, required this.height, this.bytes});
}

class MapImgDetail{
  final int _originWidth;
  final int _originHeight;
  final double _resolution;

  int get width => _originWidth;
  int get height => _originHeight;
  double get res => _resolution;

  MapImgDetail(this._originWidth, this._originHeight, this._resolution);
}

class FrameInfos{
  final String parent;
  final String child;

  FrameInfos(this.parent, this.child);

  FrameInfos.extractFromTransform(geo.TransformStamped transform) : parent = transform.header.frame_id, child = transform.child_frame_id;
  FrameInfos.extractFromOdometry(Odometry odom) : parent = odom.header.frame_id, child = odom.child_frame_id;
  FrameInfos.extractFromTFMessage(TFMessage tf) : parent = tf.transforms[0].header.frame_id, child = tf.transforms[0].child_frame_id;

  FrameInfos? extractFrame<T>(T element){
    if(T is geo.TransformStamped){
      return FrameInfos((element as geo.TransformStamped).header.frame_id, element.child_frame_id);
    } else if(T is Odometry){
      return FrameInfos((element as Odometry).header.frame_id, element.child_frame_id);
    } else if(T is TFMessage){
      var frames = (element as TFMessage).transforms;
      return FrameInfos(frames[0].header.frame_id, frames[0].child_frame_id);
    }
    return null;
  }

  bool isSameFrameId(String parentFrameId, String childFrameId){
    return (parent == parentFrameId && child == childFrameId) ? true : false;
  }
}

class RosMapViewer extends StatefulWidget{
  final String mapTopic;
  final String odomTopic;
  final String tfTopic;
  final double mapSizeModifier;
  final void Function(int mapWidth, int mapHeight, double mapResolution)? mapDetailCallback;
  final void Function(double x, double y, double yaw)? posCallback;
  // final void Function(Image image, Uint8List imgData) imgCallback;
  const RosMapViewer({super.key, 
                      this.mapTopic = '/map', this.odomTopic = '/odom', this.tfTopic = '/tf',
                      this.mapSizeModifier = 1.0, // mapsizemodifier needs to be refer address not value. reference by value makes map not inteded size.
                      this.mapDetailCallback,
                      this.posCallback,});

  @override
  State<RosMapViewer> createState() => _RosMapViewer();
}

class _RosMapViewer extends State<RosMapViewer>{
  geo.Vector3? robotPos; //tf 로봇 데이터
  geo.Vector3 robotVec = geo.Vector3(x:0,y:0,z:0);
  late String mapTopic;
  // late String odomTopic;
  // late String tfTopic;
  late String mapToRobotTopic;
  // Image mapImg = Image.asset('lib/assets/images/loading.gif', fit: BoxFit.fill,);
  late Image mapImg;
  Uint8List? mapData;
  // late Subscriber subOdom;
  // late Subscriber subTf;
  late Subscriber subMapToRobotTf;
  OccupancyGrid? curGrid;
  late double mapSizeModifier;
  final GlobalKey _key = GlobalKey();
  Size? renderBoxSize;
  final loadingImg = const Image(image: AssetImage('lib/assets/images/loading.gif'), fit: BoxFit.contain,);

  void gridCallback(OccupancyGrid gridmap) {
    curGrid = gridmap;
    convertGridtoImage();
    if(widget.mapDetailCallback != null){
      widget.mapDetailCallback!(curGrid!.info.width, curGrid!.info.height, curGrid!.info.resolution);
    }
  }

  void convertGridtoImage(){
    if(curGrid == null) return;
    var data = curGrid!.data;
    imglib.Image ii = imglib.Image(
      width: curGrid!.info.width, 
      height: curGrid!.info.height, 
      numChannels: 1, 
      format: imglib.Format.uint8);

    for(int h = 0; h<(curGrid!.info.height); h++){
      for(int w = 0; w < curGrid!.info.width; w++){
        int idx = w + h*(curGrid!.info.width);
        num d = data[idx] != -1 ? (data[idx]/100 * 200) + 50 : 0; // for coloring data
        if(inverseMap){
          ii.setPixelRgb(w, h, 255-d, 255-d, 255-d);
        } else {
          if(w%curGrid!.info.width/10 == 0 || h%curGrid!.info.height/10 == 0){
            print(h);
            ii.setPixelRgb(w, curGrid!.info.height - h - 1, 255,255,255);
          }else{

          ii.setPixelRgb(w, curGrid!.info.height - h - 1, 255-d, 255-d, 255-d);
          }
        }
      }
    }

    setState((){
      ii = imglib.copyResize(ii, height: ii.height*mapSizeModifier.toInt(), width: ii.width*mapSizeModifier.toInt());
      mapData = ii.toUint8List();
      var iii = imglib.encodePng(ii);
      mapImg = Image.memory(iii);
    });
    // print('height: ${curGrid!.info.height}, width: ${curGrid!.info.width}');
    // print('height: ${mapImg.height}');
  }

  void pointRobotPos(){
    if(robotSetting.robotFrameFlags == []) return;
    if(curGrid == null) return;
    if(robotSetting.robotFrameFlags.where((element) => element == false).toList().isNotEmpty) return;
    var res = curGrid!.info.resolution;
    robotSetting.robotFrameFlags = robotSetting.robotFrameFlags.map((e) => e = false).toList();
    setState(() {
      robotPos = geo.Vector3(x: (robotVec.x / res), y: (robotVec.y / res), z:-robotVec.z/2);
      // robotVec = geo.Vector3(x:0,y:0,z:0);
    });
    if(widget.posCallback != null) widget.posCallback!(robotVec.x, robotVec.y, robotVec.z);
  }

  void m2RTfCallback(geo.TransformStamped tf){
    robotSetting.robotFrameList.forEach((key, value) {
      FrameInfos frame = FrameInfos.extractFromTransform(tf);
      if(frame.isSameFrameId(key, value)){
        var currentFlag = robotSetting.robotFrameFlags[robotSetting.robotFrameList.keys.toList().indexOf(key)];
        if(currentFlag == true) return;
        var poseData = tf.transform.translation;
        var rot = tf.transform.rotation;
        double yaw = atan2(2 * (rot.z*rot.w), 1 - 2 * (rot.z * rot.z));
        // robotVec = geo.Vector3(x: robotVec.x + poseData.x, y: robotVec.y + poseData.y, z: robotVec.z + yaw);
        robotVec = geo.Vector3(x: poseData.x, y: poseData.y, z: yaw);
        robotSetting.robotFrameFlags[robotSetting.robotFrameList.keys.toList().indexOf(key)] = true;
      }
    });
    pointRobotPos();
  }

  @override
  void initState(){
    mapTopic = widget.mapTopic;
    // odomTopic = widget.odomTopic;
    // tfTopic = widget.tfTopic;
    mapToRobotTopic = "map_to_robot_tf";
    mapSizeModifier = widget.mapSizeModifier;
    super.initState();
    if(nodehandle?.node != null){
      subImg = nodehandle!.subscribe<OccupancyGrid>(mapTopic, OccupancyGrid.$prototype, gridCallback);
      // subOdom = nodehandle!.subscribe<Odometry>(odomTopic, Odometry.$prototype, odomCallback);
      // subTf = nodehandle!.subscribe<TFMessage>(tfTopic, TFMessage.$prototype, tfCallback);
      subMapToRobotTf = nodehandle!.subscribe<geo.TransformStamped>(mapToRobotTopic, geo.TransformStamped.$prototype, m2RTfCallback);
      sysLog.d('subscribed /map topic successfully!');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(_key.currentContext != null) {
        setState((){
          final RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
          renderBoxSize = renderBox.size;
        });
        // print("renderBoxSize: ${renderBoxSize!.width}, ${renderBoxSize!.height}");
      }
    });
  }

  @override
  void dispose(){
    if(nodehandle != null){ 
      nodehandle!.unsubscribe(mapTopic);
      // nodehandle!.unsubscribe(odomTopic);
      // nodehandle!.unsubscribe(tfTopic);
      nodehandle!.unsubscribe(mapToRobotTopic);
      sysLog.d('unsubscribed /map topic successfully!');
    }
    super.dispose();
  }

  //Scale should be calculated through device width or height.
  @override
  Widget build(BuildContext context) {
    var flag = nodehandle == null || nodehandle!.isShutdown || curGrid == null;
    double? iconSize = 12.0;
    // double? ih = size ?? size.height.toDouble();

    double? ih = renderBoxSize?.height.toDouble();
    double? iw = renderBoxSize?.width.toDouble();
    // var img = flag ? loadingImg : mapImg;
    return SizedBox(
          child: Stack(
            // alignment: Alignment.center,
            key: _key,
            children: [
              flag ? loadingImg : Image(image: mapImg.image, fit: BoxFit.contain, width: iw, height: ih,),
              if(robotPos != null && curGrid != null)
                Positioned(
                  left: (robotPos!.x.toDouble() + curGrid!.info.width/2) * (iw! / curGrid!.info.width) - iconSize/2,
                  bottom: (robotPos!.y.toDouble() + curGrid!.info.height/2) * (ih! / curGrid!.info.height) - iconSize/2,
                  child: Transform.rotate(
                    angle: robotPos!.z,
                    child: Icon(Icons.smart_toy, size: iconSize, color: Colors.purple,)),
                ),
              if(robotPos != null)
                Text("${robotPos!.x*0.05}, ${robotPos!.y*0.05}\n${robotPos!.x + (iw ?? 0.0)/2}, ${robotPos!.y + (ih ?? 0.0)/2}\n${robotPos!.x}, ${robotPos!.y}"),
            ],
          ),
    );
  }
}