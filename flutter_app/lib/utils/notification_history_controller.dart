import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:move_id/utils/api_urls.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationHistoryController extends GetxController {
  List<dynamic> allNotifications = [];
  List<dynamic> filteredNotifications = [];

  Future<List<dynamic>> getNotificationHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  String ip = prefs.getString("ip_http")??"";
  String port = prefs.getString("port_http")??"";

  String url = 'http://'+ip+':'+port+'/' + ApiUrls.getNotificationHistoryUrl;

  print(url);
  
    String email = prefs.getString("email").toString();
    String? startHour = prefs.getString('startHour');
    String? endHour = prefs.getString('endHour');
    String? nameFilter = prefs.getString('nameFilter');
    bool? groupFilter =  prefs.getBool('groupNotifications');

    DateTime? start;
    DateTime? end;

    try {
      final Map<String, String> userData = {'email': email};

      final http.Response response = await http.post(
        Uri.parse(url),
        body: json.encode(userData),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        print('Notification history saved to SharedPreferences.');

        if (startHour != null && startHour.isNotEmpty && endHour != null && endHour.isNotEmpty) {
          start = DateFormat("HH:mm").parse(startHour);
          end = DateFormat("HH:mm").parse(endHour);
        }

        
        return filterNotifications(responseBody['notifications'], start: start, end: end, nameFilter: nameFilter, group: groupFilter);
        

      } else {
        print('Failed to fetch notification history. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }

    return [];
  }

  void evaluateNotification(Map<String,dynamic> infos, bool classification) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  String ip = prefs.getString("ip_http")??"";
  String port = prefs.getString("port_http")??"";

  String url = 'http://'+ip+':'+port+'/' + ApiUrls.notificationHistoryUrl;

    try {
      final prefs = await SharedPreferences.getInstance();
      String email = prefs.getString("email").toString();
      bool groupFilter =  prefs.getBool('groupNotifications') ?? false;

      if(groupFilter){
        print("Nao faz nada!");
        
      }
      else{
        
        final Map<String, String> notification = {
          'id': infos['id']!,
          'email': email,
          'classification': classification.toString(),
        };

        final http.Response response = await http.post(
          Uri.parse(url),
          body: json.encode(notification),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: "Notification classified successfully",
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.white,
            textColor: Colors.black,
          );
        } else {
          Fluttertoast.showToast(
            msg: "Failed to classify the notification with that id",
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.white,
            textColor: Colors.black,
          );
        }
      
      
      
      }
    } catch (e) {
      print('Exception occurred: $e');
      Fluttertoast.showToast(
        msg: "Failed to classify the notification with that id",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
    }
  }

  List<dynamic> filterNotifications(List<dynamic> notifications, {DateTime? start, DateTime? end, String? nameFilter, bool? group}) {
    List<String> hours = [];
    return notifications.where((notification) {
      bool matchesTime = true;
      bool matchesName = true;
      bool already = true;

      DateTime notificationTime = DateTime.parse(notification['datetime']).toLocal();


      if (start != null && end != null) {
        int notificationHour = notificationTime.hour;
        int notificationMinute = notificationTime.minute;
        int startHour = start.hour;
        int startMinute = start.minute;
        int endHour = end.hour;
        int endMinute = end.minute;

        matchesTime = (notificationHour > startHour && notificationHour < endHour) ||
            (notificationHour == startHour && notificationMinute >= startMinute) ||
            (notificationHour == endHour && notificationMinute <= endMinute);
      }

      if (nameFilter != null && nameFilter.isNotEmpty) {
        String fullName = '${notification['fname']} ${notification['lname']}';
        matchesName = fullName.toLowerCase().contains(nameFilter.toLowerCase());
      }

      if(group!){
        String date = notificationTime.day.toString() + "_" + notificationTime.month.toString() + "_" + notificationTime.year.toString() + "_" + notificationTime.hour.toString() + "_" + notificationTime.minute.toString();

      already = hours.contains(date);

      if(!already){
        hours.add(date);
      }

      return matchesTime && matchesName && !already;
      }
      else{
        return matchesTime && matchesName;

      }
      
    }).toList();
  }

  
}