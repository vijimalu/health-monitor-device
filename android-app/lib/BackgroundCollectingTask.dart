import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';
//import 'package:path_provider/path_provider.dart';
//import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

  


class DataSample {
 // double latitude;
  //double longitude;
   Uint8List heartbeat;
 // double bodytemp;
  DateTime timestamp;

  DataSample({
   // this.latitude,
    //this.longitude,
    this.heartbeat,
   // this.bodytemp,
    this.timestamp,
  });
}

class BackgroundCollectingTask extends Model {
  static BackgroundCollectingTask of(
    BuildContext context, {
    bool rebuildOnChange = false,
  }) =>
      ScopedModel.of<BackgroundCollectingTask>(
        context,
        rebuildOnChange: rebuildOnChange,
      );

  final BluetoothConnection _connection;
  List<int> _buffer = List<int>();
  SharedPreferences preferences;

  // @TODO , Such sample collection in real code should be delegated
  // (via `Stream<DataSample>` preferably) and then saved for later
  // displaying on chart (or even stright prepare for displaying).
  // @TODO ? should be shrinked at some point, endless colleting data would cause memory shortage.
  List<DataSample> samples = List<DataSample>();

  bool inProgress;
  
  BackgroundCollectingTask._fromConnection(this._connection) {
    _connection.input.listen((data) {
      _buffer += data;
    SharedPreferences.getInstance().then((SharedPreferences sp){
      preferences = sp;
      preferences.setString('stringValue', data.toString());
    
    });

   // print("####################");
    //print(data.toString());
  /* SharedPreferences.getInstance().then((SharedPreferences sp){
      preferences = sp;
      print(preferences.getString('stringValue'));
      
    });*/
    
  
              
    // final DataSample sample = DataSample(heartbeat: data,timestamp: DateTime.now());
     
     //print();
    /* if(data.length == 8){
      final DataSample dataSample =  DataSample(heartbeat:data[4],);
     }*/

   /*while (true) {
        // If there is a sample, and it is full sent
        
        int index = _buffer.indexOf('t'.codeUnitAt(0));
        //print(index);
        if (index >= 0 && _buffer.length - index >= 7) {
          final DataSample sample = DataSample(
              heartbeat: (data),
              //temperature2: (_buffer[index + 3] + _buffer[index + 4] / 100),
              //waterpHlevel: (_buffer[index + 5] + _buffer[index + 6] / 100),
              timestamp: DateTime.now()
              );
          _buffer.removeRange(0, index + 7);

          samples.add(sample);
          notifyListeners(); // Note: It shouldn't be invoked very often - in this example data comes at every second, but if there would be more data, it should update (including repaint of graphs) in some fixed interval instead of after every sample.
          //print("${sample.timestamp.toString()} -> ${sample.temperature1} / ${sample.temperature2}");
        }
        // Otherwise break
        else {
          break;
        }
      }*/
    }).onDone(() {
      inProgress = false;
      notifyListeners();
    });
  }

  static Future<BackgroundCollectingTask> connect(
      BluetoothDevice server) async {
    final BluetoothConnection connection =
        await BluetoothConnection.toAddress(server.address);
    return BackgroundCollectingTask._fromConnection(connection);
  }

  void dispose() {
    _connection.dispose();
  }

  Future<void> start() async {
    inProgress = true;
    _buffer.clear();
    samples.clear();
    notifyListeners();
    _connection.output.add(ascii.encode('start'));
    await _connection.output.allSent;
  }

  Future<void> cancel() async {
    inProgress = false;
    notifyListeners();
    _connection.output.add(ascii.encode('stop'));
    await _connection.finish();
  }

  Future<void> pause() async {
    inProgress = false;
    notifyListeners();
    _connection.output.add(ascii.encode('stop'));
    await _connection.output.allSent;
  }

  Future<void> reasume() async {
    inProgress = true;
    notifyListeners();
    _connection.output.add(ascii.encode('start'));
    await _connection.output.allSent;
  }

  Iterable<DataSample> getLastOf(Duration duration) {
    DateTime startingTime = DateTime.now().subtract(duration);
    int i = samples.length;
    do {
      i -= 1;
      if (i <= 0) {
        break;
      }
    } while (samples[i].timestamp.isAfter(startingTime));
    return samples.getRange(i, samples.length);
  }

 /* Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/text.txt');
}

Future<File> writeFile(String text) async {
  final file = await _localFile;
  return file.writeAsString('$text');
}

Future<String> readFile() async {
  try {
    final file = await _localFile;
    
    String content = await file.readAsString();
    return content;
  } catch (e) {
    return '';
  }
}

Future<File> cleanFile() async {
    final file = await _localFile;
    return file.writeAsString('');
  }*/
addStringToSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('stringValue', "abc");
}


getStringValuesSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return String
  String stringValue = prefs.getString('stringValue');
  return stringValue;
}
}
