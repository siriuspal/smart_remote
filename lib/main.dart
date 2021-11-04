import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttClient {
  late final MqttServerClient mqClient;
  final String _mqClientID = 'siriuspal_mqtt';
  MqttClient() {
    mqClient = MqttServerClient('192.168.1.200', _mqClientID);
    _connectMqtt();
  }

  Future<void> _connectMqtt() async {
    mqClient.autoReconnect = true;
    mqClient.keepAlivePeriod = 60;
    mqClient.resubscribeOnAutoReconnect = true;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(_mqClientID)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    mqClient.connectionMessage = connMess;

    try {
      await mqClient.connect();
    } on Exception {
      mqClient.disconnect();
    }
  }

  void publish(String topic, String msg) {
    var builder = MqttClientPayloadBuilder();
    builder.addString(msg);
    try {
      mqClient.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    } catch (_) {}
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Remote',
      darkTheme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[900],
        primarySwatch: Colors.blue,
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Smart Remote'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  final mqttClient = MqttClient();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map commands = {
    const Icon(Icons.power_settings_new).toString(): 'combopower',
    const Icon(Icons.volume_off_rounded).toString(): 'yamamute',
    const Icon(Icons.volume_down_rounded).toString(): 'yamavolm',
    const Icon(Icons.volume_up_rounded).toString(): 'yamavolp',
    const Icon(Icons.tv_off_rounded).toString(): 'lgtvpower',
    const Icon(Icons.speaker_group).toString(): 'yamapower',
    const Icon(Icons.fast_rewind_rounded).toString(): 'lgtvrewind',
    const Icon(Icons.play_arrow_rounded).toString(): 'lgtvplay',
    const Icon(Icons.pause_rounded).toString(): 'lgtvpause',
    const Icon(Icons.stop_rounded).toString(): 'lgtvstop',
    const Icon(Icons.fast_forward_rounded).toString(): 'lgtvforward',
    const Icon(MaterialCommunityIcons.emby).toString(): 'comboemby',
    const Icon(MaterialCommunityIcons.netflix).toString(): 'combonetflix',
    const Icon(MaterialCommunityIcons.amazon).toString(): 'comboamazon',
    const Icon(MaterialCommunityIcons.microsoft_xbox).toString(): 'comboxbox',
    const Icon(FontAwesome5Brands.chromecast).toString(): 'combochromecast',
    const Icon(Icons.settings_input_hdmi_rounded).toString(): 'lgtvinputs',
    const Icon(Icons.keyboard_arrow_up_rounded).toString(): 'lgtvuparrow',
    const Icon(Icons.settings_rounded).toString(): 'lgtvsett',
    const Icon(Icons.keyboard_arrow_left_rounded).toString(): 'lgtvleftarrow',
    const Icon(Icons.check_circle).toString(): 'lgtvok',
    const Icon(Icons.keyboard_arrow_right_rounded).toString(): 'lgtvrightarrow',
    const Icon(Icons.undo).toString(): 'lgtvback',
    const Icon(Icons.keyboard_arrow_down_rounded).toString(): 'lgtvdownarrow',
    const Icon(Icons.horizontal_rule).toString(): 'yamastraight',
    const Icon(Icons.graphic_eq).toString(): 'yamaprogright',
    const Icon(Icons.auto_graph).toString(): 'yamaenhancer',
    const Icon(MaterialCommunityIcons.music_clef_bass).toString(): 'yamabass',
    const Icon(Icons.vpn_lock).toString(): 'openvpn/restart',
    const Icon(Icons.restart_alt).toString(): 'emby/restart',
    const Icon(Icons.tune_rounded).toString(): 'lgtvezadj',
    const Icon(Icons.build_rounded).toString(): 'lgtvinstart',
  };

  List<Widget> spacers(int count) {
    List<Widget> listOfWidgets = [];
    for (int i = 0; i <= count; i++) {
      listOfWidgets.add(const SizedBox(height: 0));
    }
    return listOfWidgets;
  }

  void sendMqttCommand(String command) {
    if (command.contains('/')) {
      List<String> topicPayload = command.split('/');
      widget.mqttClient.publish(topicPayload[0], topicPayload[1]);
    } else {
      widget.mqttClient.publish('irremote', command);
    }
  }

  Widget iconButton(Icon icon, {Color? color, String? tooltip}) {
    return Container(
      child: IconButton(
        icon: icon,
        padding: const EdgeInsets.all(0),
        iconSize: 36.0,
        color: color ?? Theme.of(context).primaryColorLight,
        tooltip: tooltip,
        splashRadius: 36,
        splashColor: Colors.black45,
        onPressed: () {
          HapticFeedback.lightImpact();
          sendMqttCommand(commands[icon.toString()]);
        },
      ),
      decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 0),
              blurRadius: 0.3,
              color: Colors.lightBlueAccent,
            )
          ]),
      alignment: Alignment.centerLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text(widget.title),
      ),
      body: Center(
        child: GridView.count(
          padding: const EdgeInsets.all(20),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          crossAxisCount: 7,
          children: [
            ...spacers(1),
            iconButton(const Icon(Icons.power_settings_new),
                color: Colors.redAccent, tooltip: 'Power All'),
            ...spacers(0),
            iconButton(const Icon(Icons.volume_off_rounded)),
            ...spacers(2),
            iconButton(const Icon(Icons.tv_off_rounded),
                color: Colors.redAccent, tooltip: 'Power TV'),
            iconButton(const Icon(Icons.speaker_group),
                color: Colors.redAccent, tooltip: 'Power Yamaha'),
            ...spacers(0),
            iconButton(const Icon(Icons.volume_down_rounded)),
            iconButton(const Icon(Icons.volume_up_rounded)),
            ...spacers(8),
            iconButton(const Icon(Icons.fast_rewind_rounded)),
            iconButton(const Icon(Icons.play_arrow_rounded)),
            iconButton(const Icon(Icons.pause_rounded)),
            iconButton(const Icon(Icons.stop_rounded)),
            iconButton(const Icon(Icons.fast_forward_rounded)),
            ...spacers(6),
            ...spacers(1),
            iconButton(const Icon(MaterialCommunityIcons.emby),
                color: Colors.green),
            iconButton(const Icon(MaterialCommunityIcons.netflix),
                color: Colors.red),
            iconButton(const Icon(MaterialCommunityIcons.amazon),
                color: Colors.cyan),
            iconButton(const Icon(MaterialCommunityIcons.microsoft_xbox),
                color: Colors.grey[200]),
            iconButton(const Icon(FontAwesome5Brands.chromecast),
                color: Colors.grey[100]),
            ...spacers(8),
            iconButton(const Icon(Icons.settings_input_hdmi_rounded),
                tooltip: 'Video Input'),
            ...spacers(0),
            iconButton(const Icon(Icons.keyboard_arrow_up_rounded)),
            ...spacers(0),
            iconButton(const Icon(Icons.settings_rounded), tooltip: 'Settings'),
            ...spacers(2),
            iconButton(const Icon(Icons.keyboard_arrow_left_rounded)),
            iconButton(const Icon(Icons.check_circle), tooltip: 'Okay'),
            iconButton(const Icon(Icons.keyboard_arrow_right_rounded)),
            ...spacers(2),
            iconButton(const Icon(Icons.undo), tooltip: 'Back'),
            ...spacers(0),
            iconButton(const Icon(Icons.keyboard_arrow_down_rounded)),
            ...spacers(9),
            iconButton(const Icon(Icons.horizontal_rule), tooltip: 'Straight'),
            iconButton(const Icon(Icons.auto_graph), tooltip: 'Enhancer'),
            iconButton(const Icon(Icons.graphic_eq), tooltip: 'Audio Program'),
            iconButton(const Icon(MaterialCommunityIcons.music_clef_bass),
                tooltip: 'Bass'),
            ...spacers(0),
            iconButton(const Icon(Icons.vpn_lock),
                color: Colors.amberAccent, tooltip: 'Restart VPN'),
            iconButton(const Icon(Icons.restart_alt),
                color: Colors.green, tooltip: 'Restart Emby'),
            ...spacers(22),
            iconButton(const Icon(Icons.tune_rounded),
                color: Colors.grey[500], tooltip: 'Ez Adj Menu'),
            ...spacers(0),
            iconButton(const Icon(Icons.build_rounded),
                color: Colors.grey[500], tooltip: 'Inset Menu'),
          ],
        ),
      ),
    );
  }
}
