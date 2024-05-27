import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:dartros/dartros.dart';
import 'package:dartros_msgs/geometry_msgs/msgs.dart';

import 'package:hills_robot_app/utils/constants.dart';

class RosHandler {
  
  dynamic node;
  // late Publisher pubVel;
  final Map<String, Node> _nodes = {};
  
  // RosHandler(String nodeName, List<String> args, 
  // {String? masterUri, InternetAddress? ip}){
  //   try{
  //     createNode(nodeName, args, masterUri: masterUri, ip: ip);
  //   } catch (err){
  //     if(kDebugMode){
  //       print('$err');
  //     }
  //   }
  // }
  RosHandler();

  RosHandler.withUri(String nodeName, String masterUri, List<String> args){
    createNode(nodeName, args, masterUri: masterUri);
  }

  RosHandler.withIp(String nodeName, InternetAddress ip, List<String> args){
    var uriIp = 'http://${ip.address}:11311/';
    sysLog.d(uriIp);
    createNode(nodeName, args, masterUri: uriIp);
  }


  bool isExistNodeFromName(String nodeName) => _nodes.containsKey(nodeName);
  bool isExistNodeFromNode(Node node) => _nodes.containsValue(node);
  Node? getNodeFromName(String nodeName) {
    try{
      return _nodes[nodeName];
    } catch(err) {
      return null;
    }
  } 

  Future<NodeHandle> createNode(String nodeName, List<String> args, {InternetAddress? ip, String? masterUri, bool anonymize = false}) async {
    // final NodeHandle node;
    try{
      node = await initNode(nodeName, args, rosIP: ip, rosMasterUri: masterUri);
      // _nodes[nodeName] = nh.node;
      // pubVel = node.advertise<Twist>('/cmd_vel', Twist.$prototype);
      sysLog.d('nodehandle successfully created node: $nodeName!');
      // sysLog.d('nodehandle list is ${_nodes.keys}');
      return node;
    } catch (err){
      if (kDebugMode) {
        print('Caught Error: $err');
      }
      return Future.error(err);
    }
  }

  Future<bool> shutdownNode(String nodeName) async {
    if(isExistNodeFromName(nodeName)) {
      Node tempNode = _nodes[nodeName]!;
      await tempNode.shutdown();
      return tempNode.isShutdown;
    }
    return false;
  }

  Future<bool> startNode(String nodeName) async {
    if(isExistNodeFromName(nodeName)) {
      Node tempNode = _nodes[nodeName]!;
      await tempNode.start();
      return tempNode.isShutdown;
    }
    return false;
  }
}


// Image imgMsg = Image(
//       header: null,
//       height: 600,
//       width: 1024,
//       encoding: 'rgba8',
//       is_bigendian: 0,
//       step: 1024 * 4,
//       data: List.generate(600 * 1024 * 4, (_) => 255));
  
//   final pub = node.advertise('/robot/head_display', Image.$prototype);
//   await Future.delayed(Duration(seconds: 2));
//   while (true) {
//     pub.publish(imgMsg, 1);
//     await Future.delayed(Duration(seconds: 2));
//   }