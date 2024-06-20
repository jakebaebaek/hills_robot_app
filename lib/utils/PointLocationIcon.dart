import 'package:flutter/material.dart';
import 'package:dartros_msgs/geometry_msgs/msgs.dart' as geo;
import 'package:dartros_msgs/nav_msgs/msgs.dart';


class PointIcon extends StatelessWidget {
  final bool selected;
  final geo.Vector3? CurrentRobotPos;
  final OccupancyGrid? curGrid;
  final Size? renderBoxSize;

  const PointIcon({super.key, required this.selected, required this.CurrentRobotPos, required this.curGrid, required this.renderBoxSize});

  @override
  Widget build(BuildContext context) {
    double? iconSize = 12.0;
    double? ih = renderBoxSize?.height.toDouble();
    double? iw = renderBoxSize?.width.toDouble();

    return Center(
      child: Positioned(
        left: (CurrentRobotPos!.x.toDouble() + curGrid!.info.width/2) * (iw! / curGrid!.info.width) - iconSize/2,
        bottom: (CurrentRobotPos!.y.toDouble() + curGrid!.info.height/2) * (ih! / curGrid!.info.height) - iconSize/2,
        child: Icon(
            Icons.location_on,
            size: 50.0,
            color: (selected == true) ? Colors.red : Colors.blue
        ),
      )
    );
  }
}
