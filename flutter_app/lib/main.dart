import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:move_id/Notification/notification_controller.dart';
import 'package:move_id/screens/home_screen.dart';
import 'package:move_id/screens/notification_history_screen.dart';
import 'package:move_id/screens/settings_screen.dart';
import 'package:move_id/screens/signin_screen.dart';
import 'package:move_id/screens/splash_screen.dart';
import 'package:move_id/utils/color_utils.dart';
import 'package:move_id/utils/home_controller.dart';
import 'package:get/get.dart';
import 'package:move_id/utils/notification_history_controller.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize controllers
  Get.put(HomeController());
  Get.put(NotificationHistoryController());

  final MqttServerClient client;

  await loadConfig();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  String broker = prefs.getString("ip_mqtt")??"";
  String port = prefs.getString("port_mqtt")??"0";
  String clientId = prefs.getString("email") ?? "teste";

  client = MqttServerClient(broker, clientId);
  client.port = int.parse(port);
  client.secure = false;

  client.onConnected = () => onConnected(client);

  await prefs.setStringList('topic_pause_mqtt', []);

  // Connect to the MQTT broker
    try {
      await client.connect();
      print('Conectou');
      //client.subscribe("moveid/notification",MqttQos.atLeastOnce);
    } catch (e) {
      print('Failed to connect to MQTT broker: $e');
    }

    initializeAwesomeNotifications();
  

  // Run the app
  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final MqttServerClient client;
  MyApp({super.key,required this.client});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkEmail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            title: "Move ID",
            debugShowCheckedModeBanner: false,
            home: SplashScreen(client: client),
          );
        } else {
          if (snapshot.data == true) {
            return MaterialApp(
              title: "Move ID",
              debugShowCheckedModeBanner: false,
              home: Builder(
                builder: (BuildContext context) {
                  return DefaultTabController(
                    length: 3,
                    child: Scaffold(
                      appBar: AppBar(
                        title: const Text("Move ID"),
                        backgroundColor: hexStringToColor("#eff1ed"),
                        bottom: const TabBar(
                          tabs: [
                            Tab(icon: Icon(Icons.home)),
                            Tab(icon: Icon(Icons.assignment)),
                            Tab(icon: Icon(Icons.settings)),
                          ],
                          indicatorColor: Color.fromARGB(255, 183, 228, 199),
                          labelColor: Color.fromARGB(255, 183, 228, 199),
                        ),
                      ),
                      body:  TabBarView(
                        children: <Widget>[
                          HomeScreen(client: client),
                          NotificationHistoryScreen(),
                          SettingsScreen(client: client),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return MaterialApp(
              title: "Move ID",
              debugShowCheckedModeBanner: false,
              home: SignInScreen(client: client),
            );
          }
        }
      },
    );
  }

  Future<bool> _checkEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('email');
  }
}


void onConnected(MqttServerClient client) {
    print('Connected to MQTT broker');
    client.updates?.listen(onMessageReceived);
  }

Future<void> onMessageReceived(List<MqttReceivedMessage<MqttMessage>> event) async {
  final MqttPublishMessage receivedMessage = event[0].payload as MqttPublishMessage;
  final String message = MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);
  
  // Parse the JSON string
  Map<String, dynamic> jsonMessage = jsonDecode(message);
  String patientFirstName = jsonMessage['patient_fname'];
  String patientLastName = jsonMessage['patient_lname'];
  String alert = jsonMessage['alert'];
  String location = jsonMessage['location'];
  String id_sensor = jsonMessage['sensor_id'].toString();
  String id_location = jsonMessage['location_id'].toString();

  // Create notification using parsed information
  String title = "Alert: $alert";
  String body = "Patient: $patientFirstName $patientLastName\nLocation: $location";
  
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final List<String> stringList = prefs.getStringList('topic_pause_mqtt')??[];

  if(!stringList.contains("moveID/notification/"+id_location+"/"+id_sensor)){
    // Create Awesome Notification
  AwesomeNotifications().createNotification(
  content: NotificationContent(
    id: 1, 
    channelKey: "MoveID_Notification_Channel",
    title: title,
    body: body,
  ),
  actionButtons: [
      NotificationActionButton(
        key: 'DISABLE_NOTIFICATIONS',
        label: 'Disable for 2 minutes',
      ),
    ],
);
AwesomeNotifications().setListeners(
    onActionReceivedMethod: (receivedNotification) async {
      if (receivedNotification.buttonKeyPressed == 'DISABLE_NOTIFICATIONS') {
        await pauseMqttSubscription("moveID/notification/"+id_location+"/"+id_sensor);
      }
      
    },
  );
  }

  
  
}


Future<void> pauseMqttSubscription(String topic) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final List<String> stringList = prefs.getStringList('topic_pause_mqtt') ?? [];
  stringList.add(topic);
  await prefs.setStringList('topic_pause_mqtt', stringList);

  await Future.delayed(Duration(minutes: 2));

  final List<String> stringList2 = prefs.getStringList('topic_pause_mqtt') ?? [];
  stringList2.remove(topic);
  await prefs.setStringList('topic_pause_mqtt', stringList2);
}


  void initializeAwesomeNotifications() async {
    // Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: "MoveID_channel_group",
          channelKey: "MoveID_Notification_Channel", 
          channelName: "MoveID Notification", 
          channelDescription: "MoveID Notification Channel",
          playSound: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: "MoveID_channel_group", 
          channelGroupName: "MoveID Group",
        ),
      ],
    );

    // Check if the app is allowed to send notifications
    bool isAllowedToSendNotifications = await AwesomeNotifications().isNotificationAllowed();

    // If notifications are not allowed, request permission
    if(!isAllowedToSendNotifications){
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
    onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
    onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
    );
  }

Future<void> loadConfig() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String configString = await rootBundle.loadString('assets/config.json');
  Map<String, dynamic> dic = jsonDecode(configString);
  prefs.setString("ip_mqtt", dic["MQTT"]["ip"]);
  prefs.setString("port_mqtt", dic["MQTT"]["port"]);
  prefs.setString("ip_http", dic["HTTP"]["ip"]);
  prefs.setString("port_http", dic["HTTP"]["port"]);
}