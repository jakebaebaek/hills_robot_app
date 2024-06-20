import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'joystick.dart';
import 'joystick_controller.dart';
import 'joystick_stick.dart';
import 'joystick_stick_offset_calculator.dart';
import 'package:hills_robot_app/utils/utils.dart';

/// Allow to place the joystick in any place where user click.
/// Just need to place other widgets as child of [JoystickArea] widget.
class JoystickTemp extends StatefulWidget {
  /// The [child] contained by the joystick area.
  final Widget? child;

  /// Callback, which is called with [period] frequency when the stick is dragged.
  final StickDragCallback listener;

  /// Frequency of calling [listener] from the moment the stick is dragged, by default 100 milliseconds.
  final Duration period;

  /// Widget that renders joystick base, by default [JoystickBase].
  final Widget? base;

  /// Widget that renders joystick stick, it places in the center of [base] widget, by default [JoystickStick].
  final Widget stick;

  /// Mode possible direction
  final JoystickMode mode;

  /// Calculate offset of the stick based on the stick drag start position and the current stick position.
  final StickOffsetCalculator stickOffsetCalculator;

  /// Callback, which is called when the stick starts dragging.
  final Function? onStickDragStart;

  /// Callback, which is called when the stick released.
  final Function? onStickDragEnd;

  const JoystickTemp({
    Key? key,
    this.child,
    required this.listener,
    this.period = const Duration(milliseconds: 100),
    this.base,
    this.stick = const JoystickStick(),
    this.mode = JoystickMode.all,
    this.stickOffsetCalculator = const CircleStickOffsetCalculator(),
    this.onStickDragStart,
    this.onStickDragEnd,
  }) : super(key: key);

  @override
  State<JoystickTemp> createState() => _JoystickTempState();
}

class _JoystickTempState extends State<JoystickTemp> {
  final _areaKey = GlobalKey();
  final _joystickKey = GlobalKey();
  final _controller = JoystickController();
  Offset _joystickPos = const Offset(0, 0);
  bool _isTapped  = false;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    double h = devinfo!.height;
    double w = devinfo!.width;

    return GestureDetector(
      key: _areaKey,
      onPanStart: _startDrag,
      onPanUpdate: _updateDrag,
      onPanEnd: _endDrag,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Stack(
          children: [
            if (widget.child != null) Align(child: widget.child),
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Joystick(
                    key: _joystickKey,
                    controller: _controller,
                    listener: widget.listener,
                    period: widget.period,
                    mode: widget.mode,
                    base: widget.base,
                    stick: widget.stick,
                    onStickDragStart: widget.onStickDragStart,
                    onStickDragEnd: widget.onStickDragEnd,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }


  void _startDrag(DragStartDetails details) {
    final localPosition = details.localPosition;
    final globalPosition = details.globalPosition;
    final joystickSize = _joystickKey.currentContext!.size!;

    final areaBox = _areaKey.currentContext!.findRenderObject()! as RenderBox;

    // final halfWidth = areaBox.size.width / 2;
    // final halfHeight = areaBox.size.height / 2;

    final xAlignment =
        (localPosition.dx - (joystickSize.width/2));
    final yAlignment = (localPosition.dy - joystickSize.height/2);
    final size = areaBox.size;
    setState(() {
      _isTapped = true;
      _joystickPos = Offset(xAlignment, yAlignment);
      sysLog.i("아싸아싸아싸아쌌아쌍싸아쌍$xAlignment, $yAlignment\n$globalPosition.dx, $globalPosition.dy, localPosition : $localPosition", );
    });
    _controller.start(details.globalPosition);
  }

  void _updateDrag(DragUpdateDetails details) {
    _controller.update(details.globalPosition);
  }

  void _endDrag(DragEndDetails details) {
    _isTapped = false;
    setState(() {

    });

    _controller.end();
  }
}
