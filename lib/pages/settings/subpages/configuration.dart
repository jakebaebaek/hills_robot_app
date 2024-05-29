import 'package:flutter/material.dart';
import 'package:hills_robot_app/utils/utils.dart';

class ConfigureWidget extends StatefulWidget {
  const ConfigureWidget({super.key});

  @override
  State<ConfigureWidget> createState() => _ConfigureWidget();
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

class _ConfigureWidget extends State<ConfigureWidget> {

  List<Item> _data = [
    Item(headerValue: 'Obstacle Settings', expandedValue: 'Obstacle Radio Buttons'),
    Item(headerValue: 'Wheel Direction Settings', expandedValue: 'Wheel Direction Radio Buttons'),
    Item(headerValue: 'Robot Settings', expandedValue: 'Speed and Angular Settings'),
    Item(headerValue: 'Topic Settings', expandedValue: 'Topic Input Fields'),
    Item(headerValue :'Robot Frame ID', expandedValue: 'Robot Frame Select')
  ];

  @override
  void initState() {
    super.initState();
  }

  void spdSliderChanged(double val) {
    setState(() {
      robotSetting.maxSpd = val;
    });
  }

  void angSliderChanged(double val) {
    setState(() {
      robotSetting.maxAng = val;
    });
  }

  Widget singleRadioBtnMaker<obj>(Map radioInfos, gVal, index, Function(obj? value) callback) {
    return RadioListTile<obj>(
      title: Text(radioInfos['title'][index]),
      groupValue: gVal[obj],
      value: radioInfos['value'][index],
      onChanged: callback,
    );
  }

  Widget genericRadioBtnColumnMaker<obj>(Map radioInfos, Map gVal, Function(obj? value) callback) {
    List<Widget> radios = [];
    for (int i = 0; i < radioInfos['title'].length; i++) {
      radios.add(singleRadioBtnMaker(radioInfos, gVal, i, callback));
    }
    return Column(children: radios);
  }

  Container simpleTopicContainer(String label, String hintText, String value, Function(String) onChanged) {
    return Container(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
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

  void _genericRadioCallback<obj>(obj? value) {
    robotSetting.radioOptions[obj] = value;
    if (obj == FrameID) {
      switch (robotSetting.radioOptions[obj]) {
        case FrameID.turtlebot:
          robotSetting.robotFrameList = {
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
      for (int i = 0; i < robotSetting.robotFrameList.length; i++) {
        robotSetting.robotFrameFlags.add(false);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              _data[index].isExpanded = isExpanded;
            });
          },
          children: _data.map<ExpansionPanel>((Item item) {
            return ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(item.headerValue),
                );
              },
              body: _buildPanelBody(item),
              isExpanded: item.isExpanded,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPanelBody(Item item) {
    switch (item.headerValue) {
      case 'Obstacle Settings':
        return Column(
          children: [
            genericRadioBtnColumnMaker<WhenObstacleDetects>(
                obstacleRadioInfos, robotSetting.radioOptions, _genericRadioCallback),
          ],
        );
      case 'Wheel Direction Settings':
        return Column(
          children: [
            genericRadioBtnColumnMaker<WheelDirections>(
                wheelDirectionInfos, robotSetting.radioOptions, _genericRadioCallback),
          ],
        );
      case 'Robot Settings':
        return Column(
          children: [
            const Text("Max Speed"),
            Slider(
              value: robotSetting.maxSpd,
              onChanged: spdSliderChanged,
              label: robotSetting.maxSpd.toString(),
            ),
            const Text("Max Angular"),
            Slider(
              value: robotSetting.maxAng,
              onChanged: angSliderChanged,
              label: robotSetting.maxAng.toString(),
              max: 0.8,
            ),
          ],
        );
      case 'Topic Settings':
        return Column(
          children: [
            const Text('Map Topic'),
            simpleTopicContainer(
              'Map Topic',
              '/map',
              robotSetting.robotMapTopic,
                  (value) => robotSetting.robotMapTopic = value,
            ),
            const Text('Odom Topic'),
            simpleTopicContainer(
              'Odom Topic',
              '/odom',
              robotSetting.robotOdomTopic,
                  (value) => robotSetting.robotOdomTopic = value,
            ),
            const Text('TF Topic'),
            simpleTopicContainer(
              'TF Topic',
              '/tf',
              robotSetting.robotTfTopic,
                  (value) => robotSetting.robotTfTopic = value,
            ),
          ],
        );
      case 'Robot Frame ID':
        return Column(
          children: [
            genericRadioBtnColumnMaker<FrameID>(
              frameIDRadioInfos,
              robotSetting.radioOptions,
              _genericRadioCallback,
            ),
          ],
        );
      default:
        return Container();
    }
  }
}
