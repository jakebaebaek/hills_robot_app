import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

import 'package:dartros/dartros.dart';
import 'package:dartros_msgs/geometry_msgs/msgs.dart';
import 'package:flutter/widgets.dart';

import 'package:hills_robot_app/utils/constants.dart';
import 'package:hills_robot_app/utils/device_info.dart';
import 'package:hills_robot_app/utils/utils.dart';

enum WhenObstacleDetects { avoid, stop }

class NetworkWidget extends StatefulWidget {
  const NetworkWidget({super.key});

  @override
  State<NetworkWidget> createState() => _NetworkWidget();
}

class _NetworkWidget extends State<NetworkWidget> {
  final rmsKey = GlobalKey(debugLabel: 'network_rms');
  final rmsTxtKey = GlobalKey(debugLabel: 'network_rms_text');
  final String initialTextValue = '';
  late TextEditingController _textEditingController;
  late String _oldText;
  late Text? _alertTexts;
  bool _exceed = false;
  static const ipPattern = r'\d[0-9.]+\d';
  final regexp = RegExp(ipPattern);
  List<Text> texts = []; // this will be the List of IP address

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: initialTextValue);
    _oldText = initialTextValue;
    _alertTexts = const Text('');
    returnIPAddressWithInterface();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<Map<String, List<InternetAddress>>> getIPAddress() async {
    final ifaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    Map<String, List<InternetAddress>> ipAddresses = {};
    for (final iface in ifaces) {
      ipAddresses[iface.toString()] = iface.addresses;
    }
    sysLog.d("current IP address: $ipAddresses");
    return ipAddresses;
  }

  Future<List<Text>> returnIPAddressWithInterface() async {
    final ifaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    // List<Text> ipTextWidgets = [Text('My IP address', style: TextStyle(fontSize: 16),),];
    List<Text> ipTextWidgets = [
      Text('My IP address',
          style: TextStyle(fontSize: 24,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey[900]
          )
      ),
      Text('')
    ];

    for (final iface in ifaces) {
      ipTextWidgets.add(Text('${iface.name}: ${iface.addresses.first.address}'));
    }
    print(texts);
    setState(() {
      texts = ipTextWidgets;
    });
    return ipTextWidgets;
  }

  void _connectRos(String uri) async {
    // rh.nh = await initNode(defaultNodeName, [], rosMasterUri: uri);
    List<String> args = [];
    try {
      nodehandle = await initNode(defaultNodeName, args, rosMasterUri: 'http://$uri:11311');
      if (nodehandle!.node.nodeReady.isCompleted) {
        var ipList = getIPAddress();
        // sysLog.d("current IP address: $ipList");
        dev.log("complete with rosmaster_uri ${nodehandle!.node.rosMasterURI}");
        dev.log("node named as ${nodehandle!.node.nodeName}");
        if (pubVel != null && pubVel!.topic.isNotEmpty) {
          nodehandle!.unadvertise('/cmd_vel');
        }
        if (pubGoal != null && pubGoal!.topic.isNotEmpty) {
          nodehandle!.unadvertise('/move_base_simple/goal');
        }
        pubVel = nodehandle!.advertise<Twist>('/cmd_vel', Twist.$prototype);
        pubGoal = nodehandle!.advertise<PoseStamped>('/move_base_simple/goal', PoseStamped.$prototype);
        serverIp = InternetAddress(uri);
        // if(!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)){
        //   showToast('Completed');
        // }
        setState(() {});
      }
    } catch (e) {
      sysLog.d(e);
    }
    // nodehandle = await initNode(defaultNodeName, args, rosMasterUri: 'http://$uri:11311', rosIP: InternetAddress(uri));
    // rh = RosHandler.withIp(defaultNodeName, InternetAddress(uri), args);
  }

  void _connectRMS([String? rTxt]) {
    var wdt = toString();
    var txt = rTxt ?? _textEditingController.text;
    // log(txt);
    // for(var matched in regexp.allMatches(txt)){
    //   log('$wdt got groupt ${matched.groupCount}');
    //   log('$wdt matched ${matched[0]}');
    // }
    // rh = RosHandler.withUri(defaultNodeName, 'http://$txt:11311/', []);
    _connectRos(txt);
  }

  void _formattingIP(String txt) {
    final TextSelection previousCursorPos = _textEditingController.selection;
    TextSelection tempPos;
    List<String> splittedTxt = txt.split('.');
    List txtSublist = [];
    bool dotted = false;
    _exceed = false;
    sysLog.d(splittedTxt.toString());
    _alertTexts = null;

    if (_oldText.length < txt.length) {
      String res = '';
      int index = 0;
      for (String spspTxt in splittedTxt) {
        int? value = int.tryParse(spspTxt) ?? -1;
        int value1 = value ~/ 10;
        bool checked = false;
        if (value > 255) {
          _exceed = true;
          break;
        }
        if (value1 > 2 || value == 0) checked = true;
        if (index < splittedTxt.length) {
          txtSublist = splittedTxt.length > 1 ?
          List.from(splittedTxt.sublist(0, index + 1))
              : List.from(splittedTxt);
          // sysLog.d('1 txtSublist is ${txtSublist}, ${checked}');
          if (checked) {
            txtSublist.add('');
            dotted = true;
          }
        }
        res = txtSublist.join('.');
        index += 1;
      }
      // log('2 txtSublist is ${txtSublist}');
      // log('splittedTxt length is ${splittedTxt.length}');
      if ('.'.allMatches(res).length > 3) {
        int a = res.lastIndexOf('.');
        res = res.substring(0, a); //remove last dot.
      }
      _textEditingController.text = res;
    }
    if (_exceed || dotted) {
      tempPos = TextSelection.fromPosition(TextPosition(offset: _textEditingController.text.length));
    } else {
      tempPos = previousCursorPos;
    }
    _oldText = _textEditingController.text;
    _textEditingController.selection = tempPos;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    var devInfo = DeviceInfo(context: context);
    return SingleChildScrollView(
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        buildSectionEnterIP(devInfo),
      ]),
    );
  }

  Widget buildSectionEnterIP(DeviceInfo devInfo) {

    return Container(
      key: rmsKey,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...texts,
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.all(13.0),
                child: SizedBox(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "RobotSide IP addresss",
                      hintMaxLines: 1,
                      errorText: _exceed ? "Please check again" : null,
                    ),
                    key: rmsTxtKey,
                    keyboardType: const TextInputType.numberWithOptions(),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                    ],
                    controller: _textEditingController,
                    onChanged: _formattingIP,
                  ),
                ),
              ),
              SizedBox(
                width: devInfo.width * 0.95,
                height: devInfo.height * 0.1,
              ),
            ],
          ),
          SizedBox(
            height: devInfo.height * 0.09,
            child: OutlinedButton(
                onPressed: _connectRMS,
                child: Padding(padding: EdgeInsets.all(12.0),
                  child: const Text(
                      style: TextStyle(fontSize: 20), 'Connect to RMS'),)
            ),
          ),
          SizedBox(
            width: devInfo.width,
            height: devInfo.height * 0.1,
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child:
            nodehandle == null ||
                nodehandle!.isShutdown ||
                nodehandle!.node.nodeReady.isCompleted
                ? const Text(style: TextStyle(fontSize: 25), '✖️Disconnected')
                : const Text(style: TextStyle(fontSize: 25), '✔️Connected'),
          ),
        ],
      ),
    );
  }
}
