// main.dart file full code
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'joystick/joystick_lib.dart';

//need flutter flutter_joystick package
//flutter pub add flutter_joystick
//flutter pub get -> anyways it's written on dependencies.


const step = 10.0;

class JoyStick extends StatelessWidget{
  final void Function(double x, double y) listener;

  const JoyStick({super.key, 
  required this.listener,});
//   // @override
//   // State<JoyStick> createState() => _JoyStick();
// }

// class _JoyStick extends State<JoyStick>{

  @override
  Widget build(BuildContext context){
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        // alignment: const Alignment(0, 0.8),
        child: JoystickTemp(
          base: const JoystickBase(
            drawArrows: false,
            size: 150,
          ),
          mode: JoystickMode.all,
          listener: (details) {
            listener(details.x, details.y);
          },
        ),
      ),
    );
  }
}