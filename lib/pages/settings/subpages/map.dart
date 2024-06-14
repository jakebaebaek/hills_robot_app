
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hills_robot_app/assets/tasks/pointList.dart';
import 'package:hills_robot_app/utils/constants.dart';

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


class MapWidget extends StatelessWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double h = devinfo!.height;
    double w = devinfo!.width;
    return Column(
      children: [
        Container(
          width: w * 0.878,
          child:FittedBox(
            child: const Image(image: AssetImage('lib/assets/images/occumap.png'),),
          ),
        ),
        Flexible(
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 280 * w / 480,
                height: 270 * h / 720,
                child:PointsTableWidget(title: 'Map',),
              ),
            ],
          ),
        )

        // Flexible(
        //   child: TasksTable(headersData: headersData, rowsData: rowsData),
        // ),
      ],
    );
  }
}

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}