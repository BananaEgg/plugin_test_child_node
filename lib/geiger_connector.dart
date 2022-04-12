import 'dart:developer';

import 'dart:convert';
import 'package:geiger_api/geiger_api.dart';
import 'package:geiger_localstorage/geiger_localstorage.dart';

class GeigerApiConnector {
  GeigerApiConnector({
    required this.pluginId,
  });

  String pluginId; // Unique and assigned by GeigerToolbox
  GeigerApi? pluginApi;
  StorageController? storageController;

  // Get an instance of GeigerApi, to be able to start working with GeigerToolbox
  Future<bool> connectToGeigerAPI() async {
    print('Trying to connect to the GeigerApi');
    if (pluginApi != null) {
      print('Plugin $pluginId has been initialized');
      return true;
    } else {
      try {
        flushGeigerApiCache();
        if (pluginId == GeigerApi.masterId) {
          pluginApi =
              await getGeigerApi('', pluginId, Declaration.doNotShareData);
          print('MasterId: ${pluginApi.hashCode}');
          return true;
        } else {
          pluginApi = await getGeigerApi(
              './$pluginId', pluginId, Declaration.doNotShareData);
          print('pluginApi: ${pluginApi.hashCode}');
          return true;
        }
      } catch (e) {
        print('Failed to get the GeigerAPI');
        print(e.toString());
        return false;
      }
    }
  }

  // Get an instance of GeigerStorage to read/write data
  Future<bool> connectToLocalStorage() async {
    print('Trying to connect to the GeigerStorage');
    if (storageController != null) {
      print(
          'Plugin $pluginId has already connected to the GeigerStorage (${storageController.hashCode})');
      return true;
    } else {
      try {
        storageController = pluginApi!.getStorage();
        print('Connected to the GeigerStorage ${storageController.hashCode}');
        return true;
      } catch (e) {
        print('Failed to connect to the GeigerStorage');
        print(e.toString());
        return false;
      }
    }
  }

  Future<bool> prepareDataNode(String rootPath, String newNodePath) async {
    try {
      await storageController!.addOrUpdate(NodeImpl(newNodePath, '', rootPath));
      return true;
    } catch (e) {
      print('Failed to prepare the sensor node ' + e.toString());
      return false;
    }
  }

  Future insertDummyData(String path) async {
    List data = [
      {
        'message': "Hello and welcome",
      },
      {
        'message': "Good morning",
      },
      {
        'message': "Nothing else matters",
      }
    ];
    for (var i = 0; i < data.length; i++) {
      try {
        await writeToGeigerStorage(data[i], path + ":" + i.toString());
      } catch (e) {
        print("Error adding Storage Data: " + e.toString());
      }
    }
  }

  Future writeToGeigerStorage(Map data, String path) async {
    print('Trying to get the data node');
    try {
      Node node = NodeImpl(path, '');
      data.forEach((key, value) async {
        await node.addOrUpdateValue(NodeValueImpl('message', data['message']));
      });
      await storageController!.addOrUpdate(node);
      Node newNode = await storageController!.get(path);
      print(newNode.getValues());
    } catch (e) {
      print(e.toString());
      print('Cannot find the data node ' + path);
    }
  }

  void getParentThenChildren(path) async {
    print('Trying to get the data node');
    try {
      print('Found the data node - Going to get the data');
      Node node = await storageController!.get(path);
      Map<String, Node> sensorReportNodes = await node.getChildren();

      for (var report_node in sensorReportNodes.values) {
        Map<String, NodeValue> nodeValues = await report_node.getValues();
        print("Node path: " + report_node.path);
        print(nodeValues.values.first);
      }
    } catch (e) {
      print('Failed to retrieve the data node: ' + e.toString());
    }
  }

  void getChild(path) async {
    print('Trying to get the data node');
    try {
      Node node = await storageController!.get(path);
      Map<String, NodeValue> nodeValues = await node.getValues();
      
      print(nodeValues.values.first);
    } catch (e) {
      print('Failed to retrieve the data node: ' + e.toString());
    }
  }
}
