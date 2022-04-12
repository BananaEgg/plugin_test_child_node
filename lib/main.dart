import 'package:flutter/material.dart';

import 'geiger_connector.dart';

GeigerApiConnector pluginApiConnector =
    GeigerApiConnector(pluginId: 'geiger_test_plugin');
late BuildContext context;

Future<bool> initExternalPlugin() async {
  final bool initGeigerAPI = await pluginApiConnector.connectToGeigerAPI();
  if (initGeigerAPI == false) return false;
  bool initLocalStorage = await pluginApiConnector.connectToLocalStorage();
  if (initLocalStorage == false) return false;
  return true;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initExternalPlugin();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Flutter FlatButton Example'),
        ),
        body: Center(
            child: Column(children: <Widget>[
          Container(
            margin: EdgeInsets.all(25),
            child: FlatButton(
              child: const Text(
                'Prepare node',
                style: TextStyle(fontSize: 20.0),
              ),
              onPressed: () =>
                  pluginApiConnector.prepareDataNode(':', "testNode"),
            ),
          ), 
          Container(
            margin: EdgeInsets.all(25),
            child: FlatButton(
              child: const Text(
                'Insert data',
                style: TextStyle(fontSize: 20.0),
              ),
              onPressed: () => pluginApiConnector.insertDummyData(":testNode"),
            ),
          ),
          Container(
            margin: EdgeInsets.all(25),
            child: FlatButton(
              child: const Text(
                'Get child',
                style: TextStyle(fontSize: 20.0),
              ),
              color: Colors.blueAccent,
              textColor: Colors.white,
              onPressed: () => pluginApiConnector.getChild(":testNode:0"),
            ),
          ),
          Container(
            margin: EdgeInsets.all(25),
            child: FlatButton(
              child: const Text(
                'Get parent then children',
                style: TextStyle(fontSize: 20.0),
              ),
              color: Colors.blueAccent,
              textColor: Colors.white,
              onPressed: () =>
                  pluginApiConnector.getParentThenChildren(":testNode"),
            ),
          ),
        ])));
  }
}
