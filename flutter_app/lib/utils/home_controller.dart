import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:move_id/utils/api_urls.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:move_id/models/models.dart';
import 'package:get/get.dart';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:move_id/Notification/notification_controller.dart';





class HomeController extends GetxController{
  RxString? selectedLocation = RxString('');
  Rx<List<PatientModel>> patients = Rx<List<PatientModel>>([]);
  TextEditingController deviceIDTextEditingController = TextEditingController();
  late PatientModel patientModel;
  var itemCount = 0.obs;
  @override
  void onInit() {
    super.onInit();
    print("Inciair");
    

  }


  @override
  void onClose(){
    super.onClose();
    deviceIDTextEditingController.dispose();
  }
  addPatient(String location, String deviceid){
    patientModel = PatientModel(deviceid: deviceid,location: RxString(location));
    patients.value.add(patientModel);
    itemCount.value = patients.value.length;
    deviceIDTextEditingController.clear();
  }

   
  void addNotifierRequest(String idLocation, String deviceid) async {
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String ip = prefs.getString("ip_http")??"";
  String port = prefs.getString("port_http")??"";

  String url = 'http://'+ip+':'+port+'/' + ApiUrls.addNotifierUrl;

  try {
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email").toString();
    

    final Map<String, String> userData = {
        'email': email,
        'idSensor': deviceid,
        'idLocation': idLocation,
      };

    final http.Response response = await http.post(
      Uri.parse(url),
      body: json.encode(userData),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Notifier added successfully",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        textColor: Colors.black
      );
      
    } else {
      Fluttertoast.showToast(
        msg: "Failed to add Notifier with that id",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        textColor: Colors.black
      );
    }
  } catch (e) {
    print('Exception occurred: $e');
    Fluttertoast.showToast(
      msg: "Failed to add Notifier with that id",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.white,
      textColor: Colors.black
    );
  }
}

void removeNotifierRequest(String deviceid, String idLocation, MqttServerClient client) async {
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String ip = prefs.getString("ip_http")??"";
  String port = prefs.getString("port_http")??"";

  String url = 'http://'+ip+':'+port+'/' + ApiUrls.removeNotifierUrl;

  try {
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email").toString();
    

    final Map<String, String> userData = {
        'email': email,
        'idSensor':deviceid,
        'idLocation': idLocation,
      };

    final http.Response response = await http.delete(
      Uri.parse(url),
      body: json.encode(userData),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      String topic =  "moveID/notification/$idLocation/$deviceid";
      client.unsubscribe(topic);
      Fluttertoast.showToast(
        msg: "Notifier removed successfully",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        textColor: Colors.black
      );

    } else {
      Fluttertoast.showToast(
        msg: "Failed to remove the Notifier with that id",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        textColor: Colors.black
      );



    }
  } catch (e) {
    print('Exception occurred: $e');
    Fluttertoast.showToast(
      msg: "Failed to remove the Notifier with that id",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.white,
      textColor: Colors.black
    );
    
  }
}


final List<String> dropdownOptions = [];

Future<Map<String,String>>  getAllLocationsAndIds() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String ip = prefs.getString("ip_http")??"";
  String port = prefs.getString("port_http")??"";

  String url = 'http://'+ip+':'+port+'/' + ApiUrls.locationGetterUrl; 
  
  try {
    final http.Response response = await http.get(Uri.parse(url));

   

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
       print(responseBody);

      // Assuming the response body is in the format { "locations": [{ "name": "Location1", "id": "ID1" }, { "name": "Location2", "id": "ID2" }, ... ]}
      final List<dynamic> locationsData = responseBody['locations'];

      final Map<String, String> locationsAndIds = {};

      for (final locationData in locationsData) {
        final String locationName = locationData['name'];
        final String locationId = locationData['id'];
        locationsAndIds[locationId] = locationName;
      }

      return locationsAndIds;

    }  
  } catch (e) {
    print('Exception occurred: $e');
  }
  return {};
  
}

Future<Map<String,String>> getAllListeners( MqttServerClient client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String ip = prefs.getString("ip_http")??"";
  String port = prefs.getString("port_http")??"";

  String url = 'http://'+ip+':'+port+'/' + ApiUrls.getListenersUrl; 
  
  try {

      final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email").toString();

    final Map<String, String> userData = {
        'email': email
      };

    final http.Response response = await http.post(
      Uri.parse(url),
      body: json.encode(userData),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Assuming the response body is in the format { "locations": [{ "name": "Location1", "id": "ID1" }, { "name": "Location2", "id": "ID2" }, ... ]}
      final List<dynamic> data = responseBody['listeners'];

      print("data");
      print(data);

      final Map<String, String> idsensorIdlocation = {};

      for (final dt in data) {
        final String id = dt['id_sensor'];
        final String locationId = dt['id_location'];
        idsensorIdlocation[id] = locationId;
        String topic =  "moveID/notification/$locationId/$id";
        print(topic);
        client.subscribe(topic, MqttQos.atLeastOnce);
      }

      print('Listeners saved to SharedPreferences.');

      return idsensorIdlocation;
      
    } else {
      print('Failed to fetch Listeners. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred: $e');
  }
  return {};
}



void refreshData( MqttServerClient client){
  getAllLocationsAndIds();
  getAllListeners(client);

}
  
}