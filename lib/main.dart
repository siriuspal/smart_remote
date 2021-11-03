import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

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
      home: const MyHomePage(title: 'Smart Remote'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map commands = {
    const Icon(Icons.power_settings_new).toString(): 'combopower',
    const Icon(Icons.volume_off_rounded).toString(): 'yamamute',
    const Icon(Icons.volume_down_rounded).toString(): 'yamavolm',
    const Icon(Icons.volume_up_rounded).toString(): 'yamavolp',
  };

  List<Widget> spacers(int count) {
    List<Widget> listOfWidgets = [];
    for (int i = 0; i <= count; i++) {
      listOfWidgets.add(const SizedBox(height: 0));
    }
    return listOfWidgets;
  }

  Widget iconButton(Icon icon, {Color? color}) {
    return IconButton(
      icon: icon,
      color: color ?? Theme.of(context).primaryColorLight,
      enableFeedback: true,
      splashRadius: 25,
      onPressed: () {
        HapticFeedback.lightImpact();
        //print(commands[icon.toString()]);
      },
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
            iconButton(const Icon(Icons.power_settings_new), color: Colors.red),
            ...spacers(0),
            iconButton(const Icon(Icons.volume_off_rounded)),
            ...spacers(1),
            iconButton(const Icon(Icons.volume_down_rounded)),
            iconButton(const Icon(Icons.volume_up_rounded)),
            ...spacers(1),
            iconButton(const Icon(Icons.tv_off_rounded), color: Colors.red),
            iconButton(const Icon(Icons.speaker_group), color: Colors.red),
            ...spacers(1),
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
            iconButton(const Icon(Icons.settings_input_hdmi_rounded)),
            ...spacers(0),
            iconButton(const Icon(Icons.keyboard_arrow_up_rounded)),
            ...spacers(0),
            iconButton(const Icon(Icons.settings_rounded)),
            ...spacers(2),
            iconButton(const Icon(Icons.keyboard_arrow_left_rounded)),
            iconButton(const Icon(Icons.check_circle)),
            iconButton(const Icon(Icons.keyboard_arrow_right_rounded)),
            ...spacers(2),
            iconButton(const Icon(Icons.undo)),
            ...spacers(0),
            iconButton(const Icon(Icons.keyboard_arrow_down_rounded)),
            ...spacers(9),
            iconButton(const Icon(Icons.horizontal_rule)),
            iconButton(const Icon(Icons.graphic_eq)),
            iconButton(const Icon(Icons.auto_graph)),
            iconButton(const Icon(MaterialCommunityIcons.music_clef_bass)),
            ...spacers(0),
            iconButton(const Icon(Icons.vpn_lock), color: Colors.amberAccent),
            iconButton(const Icon(Icons.restart_alt),
                color: Colors.amberAccent),
            ...spacers(22),
            iconButton(const Icon(Icons.tune_rounded), color: Colors.grey[500]),
            ...spacers(0),
            iconButton(const Icon(Icons.build_rounded),
                color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}
