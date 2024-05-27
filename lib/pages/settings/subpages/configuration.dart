import 'package:flutter/material.dart';
import 'package:hills_robot_app/utils/utils.dart';


enum Examples {exam, ples}

class ConfigureWidget extends StatefulWidget{
  const ConfigureWidget({super.key});
  // const ConfigureWidget({Key? key});
  @override
  State<ConfigureWidget> createState() => _ConfigureWidget();
}

class _ConfigureWidget extends State<ConfigureWidget>{
  final Map exampleInfos = {
    'title': ['exam', 'ples'],
    'value': [Examples.exam, Examples.ples],
  };

  @override
  void initState(){
    super.initState();
  }

  void spdSliderChanged(double val){
    setState((){
      robotSetting.maxSpd = val;
    });
  }

  void angSliderChanged(double val){
    setState((){
      robotSetting.maxAng = val;
    });
  }
  
  Widget singleRadioBtnMaker<obj>(Map radioInfos, gVal, index, 
                                  Function(obj? value) callback){
    late Widget radio;

    radio = RadioListTile<obj>(
      title: Text(radioInfos['title'][index]),
      groupValue: gVal[obj],
      value: radioInfos['value'][index],
      onChanged: callback,
    );
    return radio;
  }

  Widget genericRadioBtnColumnMaker<obj>(Map radioInfos, Map gVal, 
                                          Function(obj? value) callback){
    List<Widget> radios = [];
    for(int i = 0; i < radioInfos['title'].length; i++){
      radios.add(singleRadioBtnMaker(radioInfos, gVal, i, callback),);
    }
    return Column(children: radios,);
  }

  Container simpleTopicContainer(String label, String hintText, String value, Function(String) onChanged){
    return Container(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
          ),
          controller: TextEditingController(text: value),
          onChanged: onChanged,
        ),
      ),
    );
  }
  
  void _genericRadioCallback<obj>(obj? value){
    robotSetting.radioOptions[obj] = value;
    if(obj == FrameID){
      switch(robotSetting.radioOptions[obj]){
        case FrameID.turtlebot:
          robotSetting.robotFrameList = {
            // 'map': 'odom',
            // 'odom': 'base_footprint',
            'map': 'base_footprint',
          };
          break;
        case FrameID.univPlatform:
          robotSetting.robotFrameList = {
            'map': 'odom',
            'odom': 'base_link',
          };
          break;
      }

      robotSetting.robotFrameFlags = [];
      for(int i = 0; i < robotSetting.robotFrameList.length; i++){
        robotSetting.robotFrameFlags.add(false);
      }
    }
    setState(() {
    });
  } //generic also good, but should be seperated for operating each action. or just swithching by object.

  @override
  Widget build(BuildContext context){
    List<Widget> widgets = [
      Container(
        child: Container(
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            children: [
              const Text("Obstacle Settings"),
              genericRadioBtnColumnMaker<WhenObstacleDetects>(obstacleRadioInfos, robotSetting.radioOptions, _genericRadioCallback),
            ],
          ),
        ),
      ),
      Container(
        child: Container(
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            children: [
              const Text("Wheel Direction Settings"),
              genericRadioBtnColumnMaker<WheelDirections>(wheelDirectionInfos, robotSetting.radioOptions, _genericRadioCallback),
            ],
          ),
        ),
      ),
      Container(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              child: const Text('Robot Settings'),
            ),
            const Text("Max Speed"),
            Slider(value: robotSetting.maxSpd, 
            onChanged: spdSliderChanged, 
            label: robotSetting.maxSpd.toString()),
            const Text("Max Angular"),
            Slider(value: robotSetting.maxAng, 
            onChanged: angSliderChanged, 
            label: robotSetting.maxAng.toString(),
            max: 0.8,),
          ],
        ),
      ),
      Container(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              child: const Text('Topic Settings'),
            ),
            const Text('Map Topic'),
            simpleTopicContainer('Map Topic', '/map', robotSetting.robotMapTopic,
             (value) => robotSetting.robotMapTopic = value),
            const Text('Odom Topic'),
            simpleTopicContainer('Odom Topic', '/odom', robotSetting.robotOdomTopic,
             (value) => robotSetting.robotOdomTopic = value),
            const Text('TF Topic'),
            simpleTopicContainer('TF Topic', '/tf', robotSetting.robotTfTopic,
             (value) => robotSetting.robotTfTopic = value),
            const Text('Robot FrameID'),
            genericRadioBtnColumnMaker<FrameID>(frameIDRadioInfos, 
              robotSetting.radioOptions, _genericRadioCallback),
          ],
        ),
      ),
    ];
    return SafeArea(child: 
      LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(child: 
          ConstrainedBox( constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
          ),
          child: Column(children: widgets),
        ));
      }),
    );
  }
}