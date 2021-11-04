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
  static Map commands = {
    'power_settings_new_rounded': [
      const Icon(Icons.power_settings_new_rounded),
      'combopower'
    ],
    'volume_off_rounded': [const Icon(Icons.volume_off_rounded), 'yamamute'],
    'volume_down_rounded': [const Icon(Icons.volume_down_rounded), 'yamavolm'],
    'volume_up_rounded': [const Icon(Icons.volume_up_rounded), 'yamavolp'],
    'tv_off_rounded': [const Icon(Icons.tv_off_rounded), 'lgtvpower'],
    'speaker_group_rounded': [
      const Icon(Icons.speaker_group_rounded),
      'yamapower'
    ],
    'fast_rewind_rounded': [
      const Icon(Icons.fast_rewind_rounded),
      'lgtvrewind'
    ],
    'play_arrow_rounded': [const Icon(Icons.play_arrow_rounded), 'lgtvplay'],
    'pause_rounded': [const Icon(Icons.pause_rounded), 'lgtvpause'],
    'stop_rounded': [const Icon(Icons.stop_rounded), 'lgtvstop'],
    'fast_forward_rounded': [
      const Icon(Icons.fast_forward_rounded),
      'lgtvforward'
    ],
    'emby': [const Icon(MaterialCommunityIcons.emby), 'comboemby'],
    'netflix': [const Icon(MaterialCommunityIcons.netflix), 'combonetflix'],
    'amazon': [const Icon(MaterialCommunityIcons.amazon), 'comboamazon'],
    'microsoft_xbox': [
      const Icon(MaterialCommunityIcons.microsoft_xbox),
      'comboxbox'
    ],
    'chromecast': [
      const Icon(FontAwesome5Brands.chromecast),
      'combochromecast'
    ],
    'settings_input_hdmi_rounded': [
      const Icon(Icons.settings_input_hdmi_rounded),
      'lgtvinputs'
    ],
    'keyboard_arrow_up_rounded': [
      const Icon(Icons.keyboard_arrow_up_rounded),
      'lgtvuparrow'
    ],
    'settings_rounded': [const Icon(Icons.settings_rounded), 'lgtvsett'],
    'keyboard_arrow_left_rounded': [
      const Icon(Icons.keyboard_arrow_left_rounded),
      'lgtvleftarrow'
    ],
    'check_circle_rounded': [const Icon(Icons.check_circle_rounded), 'lgtvok'],
    'keyboard_arrow_right_rounded': [
      const Icon(Icons.keyboard_arrow_right_rounded),
      'lgtvrightarrow'
    ],
    'undo_rounded': [const Icon(Icons.undo_rounded), 'lgtvback'],
    'keyboard_arrow_down_rounded': [
      const Icon(Icons.keyboard_arrow_down_rounded),
      'lgtvdownarrow'
    ],
    'horizontal_rule_rounded': [
      const Icon(Icons.horizontal_rule_rounded),
      'yamastraight'
    ],
    'graphic_eq_rounded': [
      const Icon(Icons.graphic_eq_rounded),
      'yamaprogright'
    ],
    'auto_graph_rounded': [
      const Icon(Icons.auto_graph_rounded),
      'yamaenhancer'
    ],
    'music_clef_bass': [
      const Icon(MaterialCommunityIcons.music_clef_bass),
      'yamabass'
    ],
    'vpn_lock_rounded': [const Icon(Icons.vpn_lock_rounded), 'openvpn/restart'],
    'restart_alt_rounded': [
      const Icon(Icons.restart_alt_rounded),
      'emby/restart'
    ],
    'tune_rounded': [const Icon(Icons.tune_rounded), 'lgtvezadj'],
    'build_rounded': [const Icon(Icons.build_rounded), 'lgtvinstart'],
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

  Widget iconButton(String icon, {Color? color, String? tooltip}) {
    return Container(
      child: IconButton(
        icon: commands[icon][0],
        padding: const EdgeInsets.all(0),
        iconSize: 36.0,
        color: color ?? Theme.of(context).primaryColorLight,
        tooltip: tooltip,
        splashRadius: 36,
        splashColor: Colors.black45,
        onPressed: () {
          HapticFeedback.lightImpact();
          sendMqttCommand(commands[icon][1]);
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
            iconButton('power_settings_new_rounded',
                color: Colors.redAccent, tooltip: 'Power All'),
            ...spacers(0),
            iconButton('volume_off_rounded'),
            ...spacers(2),
            iconButton('tv_off_rounded',
                color: Colors.redAccent, tooltip: 'Power TV'),
            iconButton('speaker_group_rounded',
                color: Colors.redAccent, tooltip: 'Power Yamaha'),
            ...spacers(0),
            iconButton('volume_down_rounded'),
            iconButton('volume_up_rounded'),
            ...spacers(8),
            iconButton('fast_rewind_rounded'),
            iconButton('play_arrow_rounded'),
            iconButton('pause_rounded'),
            iconButton('stop_rounded'),
            iconButton('fast_forward_rounded'),
            ...spacers(6),
            ...spacers(1),
            iconButton('emby', color: Colors.green),
            iconButton('netflix', color: Colors.red),
            iconButton('amazon', color: Colors.cyan),
            iconButton('microsoft_xbox', color: Colors.grey[200]),
            iconButton('chromecast', color: Colors.grey[100]),
            ...spacers(8),
            iconButton('settings_input_hdmi_rounded', tooltip: 'Video Input'),
            ...spacers(0),
            iconButton('keyboard_arrow_up_rounded'),
            ...spacers(0),
            iconButton('settings_rounded', tooltip: 'Settings'),
            ...spacers(2),
            iconButton('keyboard_arrow_left_rounded'),
            iconButton('check_circle_rounded', tooltip: 'Okay'),
            iconButton('keyboard_arrow_right_rounded'),
            ...spacers(2),
            iconButton('undo_rounded', tooltip: 'Back'),
            ...spacers(0),
            iconButton('keyboard_arrow_down_rounded'),
            ...spacers(9),
            iconButton('horizontal_rule_rounded', tooltip: 'Straight'),
            iconButton('auto_graph_rounded', tooltip: 'Enhancer'),
            iconButton('graphic_eq_rounded', tooltip: 'Audio Program'),
            iconButton('music_clef_bass', tooltip: 'Bass'),
            ...spacers(0),
            iconButton('vpn_lock_rounded',
                color: Colors.amberAccent, tooltip: 'Restart VPN'),
            iconButton('restart_alt_rounded',
                color: Colors.green, tooltip: 'Restart Emby'),
            ...spacers(22),
            iconButton('tune_rounded',
                color: Colors.grey[500], tooltip: 'Ez Adj Menu'),
            ...spacers(0),
            iconButton('build_rounded',
                color: Colors.grey[500], tooltip: 'Instart Menu'),
          ],
        ),
      ),
    );
  }
}
