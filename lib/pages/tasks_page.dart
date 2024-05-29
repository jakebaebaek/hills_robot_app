import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hills_robot_app/assets/tasks/remove&edit_Points.dart';
import 'package:hills_robot_app/assets/ros_map_viewer.dart';
import 'package:hills_robot_app/utils/utils.dart';


final List headersData = ['Task', 'Goal', 'Assigned'];
final List<List> rowsData = 
    List.generate(30, (index) => ['A$index', 'B$index', 'Apollo_$index']);

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

  Widget buildVerticalTextButton(String text, Color backgroundColor, double width) {
  return ElevatedButton(
    onPressed: () {},
    child: Text(
      text,
      style: TextStyle(fontSize: 30),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      shape: const StadiumBorder(),
    ).copyWith(
      minimumSize: MaterialStateProperty.all(Size(width, 70)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 280 * w / 480,
                height: 400 * h / 720,
                child:PointsTableWidget(),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildVerticalTextButton('GO', Colors.green, 120 * w / 480),
                  SizedBox(
                    height: h*0.05,
                  ),
                  buildVerticalTextButton('STOP', Colors.pink, 120 * w / 480),
                ],
              )
            ],
          )
        ];
        return buildDependsOrientation(widgets, orientation);
      });
    });
  }
}


