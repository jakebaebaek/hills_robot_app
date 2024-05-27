import 'package:flutter/material.dart';

class OrientationDependsBuilder{
  
}


Widget buildDependsOrientation(List<Widget> widgets, Orientation orientation){
  Widget output;
  List<Widget> temp = [];
  for (var element in widgets) {
    var t = Expanded(child: element);
    temp.add(t);
  }


  if(orientation == Orientation.landscape){
    output = Row(children: temp,);
  } // Wider than tall.
  else {
    output = Column(children: temp,);
  } // Taller than wide == Orientation.portrait
  return output;
}