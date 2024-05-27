import 'package:flutter/material.dart';

class TasksTable extends StatelessWidget{
  final List headersData;
  final List<List> rowsData;

  const TasksTable({
    required this.headersData,
    required this.rowsData,
    super.key,});
  // TasksTable({super.key, required asdf, required fdsa});

  TasksRow makeRow(List rData, 
                  [Alignment alignment = Alignment.center, 
                  double? height,
                  ]){
    List<Widget> row = [];
    for(String rd in rData){
      row.add(
        TasksCell(
          alignment: alignment, 
          child: Text(rd),
          )
        );
    }
    return TasksRow(
      children: row
    );
  }

  List<TasksRow> makeRows(List<List> rsData, 
                  {Alignment alignment = Alignment.center, 
                  double? height,
                  }){
    List<TasksRow> result = [];
    for(List rsd in rsData){
      result.add(makeRow(rsd, alignment, height));
    }
    return result;
  }

  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        Table(
          children: [makeRow(headersData)],
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Table(
              children: makeRows(rowsData, alignment: Alignment.center),
            ),
          ),
        ),
      ],
    );
  }
}



class TasksRow extends TableRow{
  
  Widget makeCell(List data){
    return Container();
  }
  const TasksRow({
    LocalKey? key,
    Decoration? decoration,
    required super.children
  });

  List<Widget> build(BuildContext context){
    return children;
  }
}



class TasksCell extends Container{
  final Color? color;
  final Border? border;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final BlendMode? backgroundBlendMode;
  final BoxShape shape;
  final Alignment alignment;
  final double? height;
  final double? width;

  TasksCell({
    super.key,
    this.color,
    this.border = const Border(bottom: BorderSide(width: 0.5, color: Color.fromARGB(255,189,189,189))),
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.backgroundBlendMode,
    this.shape = BoxShape.rectangle,
    this.alignment = Alignment.center,
    this.height,
    this.width,
    required super.child,
  });

  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
      color: color,
      border: border,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      gradient: gradient,
      backgroundBlendMode: backgroundBlendMode,
      shape: shape,
      ),
      height: height ?? 40,
      width: width,
      alignment: alignment,
      child: child,
    );
  }
}