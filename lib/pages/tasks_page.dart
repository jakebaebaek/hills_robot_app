import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hills_robot_app/assets/tasks/pointList.dart';
import 'package:hills_robot_app/assets/ros_map_viewer.dart';
import 'package:hills_robot_app/utils/utils.dart';

// final List headersData = ['Task', 'Goal', 'Assigned'];
// final List<List> rowsData =
//     List.generate(30, (index) => ['A$index', 'B$index', 'Apollo_$index']);

class TasksWidget extends StatefulWidget{
  const TasksWidget({super.key});

  @override
  State<TasksWidget> createState() => _TasksWidget();
}


class _TasksWidget extends State<TasksWidget> {
  // const _TasksWidget({super.key});  
  void callbackListener(double x, double y, double rad){
    setState((){
    });
  }

  void onTapCallback(TapUpDetails? details){
    if(details != null){
      var dx = details.localPosition.dx;
      var dy = details.localPosition.dy;
      print('${dx}, ${dy}');
    }
  }

  Widget buildTextButton(String text, Color backgroundColor, double width) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(
        text,
        style: TextStyle(fontSize: 25, color: Colors.grey[300]),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: const StadiumBorder(),
        minimumSize: Size(width, 55), // Size 생성자를 올바르게 사용
      ),
    );
  }


  @override
  void dispose(){
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    double h = devinfo!.height;
    double w = devinfo!.width;
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        List<Widget> widgets = [
          Container(
            height: orientation == Orientation.portrait ? h - h/2 : null,
            width: orientation == Orientation.landscape ? w - w/2 : null,
            child: GestureDetector(
              onTapUp: onTapCallback,
              child: nodehandle == null || nodehandle!.isShutdown ? 
              Image.asset('lib/assets/images/loading.gif', fit: BoxFit.contain,) : 
              RosMapViewer(posCallback: callbackListener),
            ),
          ),
          SizedBox(
                height: 400 * h / 720,
                child:Stack(
                      children: <Widget>[
                        PointsTableWidget(),
                        Positioned(
                          top: 0,
                          left: w * 0.02,
                          child: buildTextButton('GO', Colors.green, 110),
                        ),
                        Positioned(
                          top: 0,
                          right: w * 0.02,
                            child: buildTextButton('STOP', Colors.pink,110),
                        )
                      ],
                )
          ),
              //,STOP BUTTONS
        ];
        return buildDependsOrientation(widgets, orientation);
      });
    });
  }
}


