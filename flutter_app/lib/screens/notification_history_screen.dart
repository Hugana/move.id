import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:move_id/utils/notification_history_controller.dart';
import 'package:move_id/utils/color_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationHistoryScreen extends GetView<NotificationHistoryController> {
  const NotificationHistoryScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification History'),
        backgroundColor: hexStringToColor('#D8F3DC'),
        surfaceTintColor: hexStringToColor('#D8F3DC')
      ),
      body: FutureBuilder<List<dynamic>>(
        future: controller.getNotificationHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final List<dynamic> results = snapshot.data!;
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      hexStringToColor("#D8F3DC"),
                      hexStringToColor("#B7E4C7"),
                      hexStringToColor("#95D5B2"),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final notification = results[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pacient: ${notification['fname']} ${notification['lname']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Location: ${notification['location']}\n'
                                  'Date: ${DateTime.parse(notification['datetime']).toLocal().day}-${DateTime.parse(notification['datetime']).toLocal().month}-${DateTime.parse(notification['datetime']).toLocal().year}\n'
                                  'Hour: ${DateTime.parse(notification['datetime']).toLocal().hour}:${DateTime.parse(notification['datetime']).toLocal().minute}\n'
                                  'Room: ${notification['room']}\n'
                                  'Bed: ${notification['bed']}',
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check, color: Colors.green),
                                      onPressed: () {
                                        
                                        controller.evaluateNotification(notification, true);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () {
                                        controller.evaluateNotification(notification, false);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
