//import 'dart:typed_data';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
//import './DiscoveryPage.dart';
import 'SelectBondedDevicePage.dart';
import 'BackgroundCollectingTask.dart';
//import 'package:scoped_model/scoped_model.dart';
//import 'package:path_provider/path_provider.dart';
//import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';


  


import 'dart:async';
void main()=>runApp(
  MaterialApp(
    title:"fit",
    home:MainScreen(),
  )
);

class MainScreen  extends StatefulWidget {
  @override
  MainScreen_State createState() => MainScreen_State();
}

class MainScreen_State extends State<MainScreen> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  
String spData,heartRate,latitude,longitude,bodyTemperature,buttonStatus;
var fitData ;
  DateTime alarmDate;
 FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
 String _address = "...";
  String _name = "...";
  Timer _discoverableTimeoutTimer;
   int _discoverableTimeoutSecondsLeft = 0;
  BackgroundCollectingTask _collectingTask;
   bool _autoAcceptPairingRequests = false;
   DateTime timestamp;
   List<int> data ; 
SharedPreferences preferences;
 @override
  void initState() {

    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences sp){
      preferences = sp;
      preferences.setString('stringValue','[0, 44, 0, 44, 0, 44, 36, 44, 1]');
    
    });
    //get the current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });

    Timer.periodic(Duration(seconds: 1), (Timer t) {
      checkForAlarm();
      print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
      SharedPreferences.getInstance().then((SharedPreferences sp) {
        preferences = sp;
        spData = preferences.getString('stringValue');
       var  dataArray = json.decode(spData);
        setState(() {
          /*latitude = dataArray[0].toString();
          longitude = dataArray[2].toString();
          heartRate = dataArray[4];
          bodyTemperature = dataArray[6].toString();
          buttonStatus = dataArray[8].toString();*/
          fitData = dataArray;
          
        });
       print(fitData);
       if(fitData[8].toString()=='0'){
         _showNotificationWithDefaultSoundEmergency();
       }
       
      });
      
    
    } );
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher'); 
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }
Future _showNotificationWithDefaultSound() async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max, priority: Priority.High);
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'Reminder',
    'Its time for medicine:)',
    platformChannelSpecifics,
    payload: 'Medicine',
  );
}

Future _showNotificationWithDefaultSoundEmergency() async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max, priority: Priority.High);
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'Emergency',
    'Emergency button is pressed by the patient',
    platformChannelSpecifics,
    payload: 'Emergency button pressed by patient',
  );
}

void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
   
     Size size = MediaQuery.of(context).size;
    return SafeArea(
      top:true,
      child:Container(
      height: size.height,
      width: size.width,
      color: Colors.blue[50],
      child: new Stack(
        children:[
          new Positioned(
            
            child:SizedBox(width: size.width,
            height: size.height/3,
            child: new DecoratedBox(decoration: 
            const BoxDecoration(color: Colors.blue)),)
          ),
          new Positioned(
            top: size.height/4,
            bottom: size.height/7,
            left: size.width/8,
            right: size.width/8,
            child: Container(
              child: Card(
                elevation: 10,
                child:new Container(
                  margin: const EdgeInsets.only(top:60.0,bottom: 10.0,left: 10.0,right: 10.0),
                  alignment: Alignment.topCenter,
                  //color: Colors.orange,
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:<Widget>[
                      new Row(
                        
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:<Widget> [
                          new Container(
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:<Widget>[
                                Container(
                                  height:50,
                                  width:50,
                                  decoration: BoxDecoration(
                                    image:DecorationImage(image: AssetImage("assets/image/heatbeat.gif"),fit:BoxFit.fill)
                                  ),
                                ),
                                Text( fitData[4].toString(),style: TextStyle(fontSize:20,color:Colors.grey),),
                                Text( "BPM",style: TextStyle(fontSize:20,color:Colors.grey),),
                              ]
                            ),
                            height:100,
                            width:150,
                            
                          ),
                          new Container(
                            height: 100,
                            width:100,
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Container(
                                  height:50,
                                  width:50,
                                  decoration: BoxDecoration(
                                    image:DecorationImage(image: AssetImage("assets/image/bodyTemp.jpg"),fit: BoxFit.fill)
                                  ),
                                ),
                                Text(fitData[6].toString(),style: TextStyle(fontSize:20,color:Colors.grey),),
                                Text("°C",style: TextStyle(fontSize:20,color:Colors.grey),),
                              ],
                            ),
                          )

                        ],
                      ),
                      SizedBox(height:35),
                      new Row(mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap:(){
                            setState(() {
                              launchMap(fitData[0].toString(),fitData[3].toString());
                            });
                          },
                          child:new Container(
                            alignment: Alignment.center,
                            height: 40,
                            width: 100,
                            decoration: BoxDecoration(shape:BoxShape.rectangle,
                            color: Colors.pink,
                            borderRadius:BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color:Colors.grey,blurRadius:10)]),
                            child: Text("LOCATE",style: TextStyle(fontWeight:FontWeight.bold,color:Colors.white),),
                            
                          )
                        )
                      ],)
                     // 
                      //
                    ]
                  )
                )

              ),
            ),
          ),
          new Positioned(
            top:size.height/4-50,
            left: size.width/2-50,
            child:Container(
              decoration: new BoxDecoration(shape: BoxShape.circle,
              image: DecorationImage(image: AssetImage("assets/image/profile.jpg"),fit:BoxFit.cover),
              boxShadow: [BoxShadow(color:Colors.grey,blurRadius:5)]
                                ),
                                height:100,
              width:100,
            )
          ),

          new Positioned(
            top: size.height/1.26,
            left: size.width/1.5,
              child:new Container(
                height:60,
                width:60,
                decoration:BoxDecoration(shape: BoxShape.circle,
                color:Colors.blue[50],
                boxShadow:[BoxShadow(blurRadius: 10,color:Colors.grey)]),
                child:FlatButton(onPressed: (){
                   DatePicker.showTime12hPicker(context,
                              showTitleActions: true,
                               onChanged: (date) {
                            print('change $date');
                          }, onConfirm: (date) {
                            //_showNotificationWithDefaultSound();
                            setState(() {
                              alarmDate = date;
                            });
                            print('confirm $date');
                            print(DateTime.now());
                          }, currentTime: DateTime.now(), locale: LocaleType.en);
                }, child: Icon(Icons.alarm_add,color: Colors.blue[800],))
              )
            ),

            new Positioned(
              right: size.width/35,
              top:10,
              
              child:new Container(
                padding: const EdgeInsets.all(8.0),
               height:75,
                width:205,
               // color:Colors.orange,
                child: Material(
                  color: Colors.transparent,
                  child:Container(

                    child:Row(
                      children:<Widget>[
                        Icon(Icons.bluetooth,color: Colors.white,),
                        Switch(value: _bluetoothState.isEnabled,
                         onChanged:(bool value){
                           future() async {
                             if(value){
                               await FlutterBluetoothSerial.instance.requestEnable();
                             }
                             else{
                               await FlutterBluetoothSerial.instance.requestDisable();
                             }
                           }
                           future().then((_) {
                  setState(() {});
                });
                         } ),
                         RaisedButton(
                           color: Colors.blue[400],
                           child: ((_collectingTask != null && _collectingTask.inProgress)
                    ? const Text('Disconnect',style: TextStyle(color:Colors.white),)
                    : const Text('Connect',style:TextStyle(color:Colors.white),)),
                           onPressed:()async{
                             if (_collectingTask != null && _collectingTask.inProgress) {
                    await _collectingTask.cancel();
                    setState(() {
                      /* Update for `_collectingTask.inProgress` */
                    });
                  } else {
                    final BluetoothDevice selectedDevice =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SelectBondedDevicePage(
                              checkAvailability: false);
                        },
                      ),
                    );

                    if (selectedDevice != null) {
                      await _startBackgroundTask(context, selectedDevice);
                      setState(() {
                        /* Update for `_collectingTask.inProgress` */
                      });
                    }
                  }
                           })
                      ]
                    )
                  )
                )
              )
            )
          
          
          
        ]
      ),
      
    )
    );
    
  }

    Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("Emergency"),
          content: Text(payload),
        );
      },
    );
  }
  Future checkForAlarm() async{
     // final difference  = DateTime.now().difference(alarmDate).inSeconds;
      final hour = DateTime.now().hour;
      final minute = DateTime.now().minute;
      final second  = DateTime.now().second;
      final alarmHour = alarmDate.hour;
      final alarmMinute = alarmDate.minute;
      
     if(hour == alarmHour){
       if(minute == alarmMinute && second == 0){
         _showNotificationWithDefaultSound();
       }
     }
     else{
       print("time not reached");
     }
  }
   Future<void> _startBackgroundTask(
    BuildContext context,
    BluetoothDevice server,
  ) async {
    try {
      _collectingTask = await BackgroundCollectingTask.connect(server);
      await _collectingTask.start();
    } catch (ex) {
      if (_collectingTask != null) {
        _collectingTask.cancel();
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occured while connecting'),
            content: Text("${ex.toString()}"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

 getStringValuesSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return String
  String stringValue = prefs.getString('stringValue');
  return stringValue;
}

launchMap(String lat , String long ) async{
  var mapSchema = 'geo:$lat,$long';
  if (await canLaunch(mapSchema)) {
    await launch(mapSchema);
  } else {
    throw 'Could not launch $mapSchema';
  }
}
}
