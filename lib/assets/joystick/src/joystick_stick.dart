import 'package:flutter/material.dart';

class JoystickStick extends StatelessWidget {
  final double size;

  const JoystickStick({
    this.size = 50,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 66, 66, 66).withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 4,
            offset: const Offset(0, 3),
          )
        ],
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [
        //     Colors.lightBlue.shade900,
        //     Colors.lightBlue.shade400,
        //   ],
        // ),
        color: const Color.fromARGB(255, 66, 66, 66).withOpacity(0.7),
      ),
    );
  }
}
