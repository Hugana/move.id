import 'package:flutter/material.dart';
import 'package:move_id/screens/notification_history_screen.dart';
import 'package:move_id/screens/settings_screen.dart';
import 'package:move_id/utils/color_utils.dart';
import 'package:move_id/utils/home_controller.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class HomeScreen extends GetView<HomeController> {
  final MqttServerClient client;
  HomeScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        controller.getAllLocationsAndIds(),
        controller.getAllListeners(client),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Return an error message if an error occurs
          return Text('Error: ${snapshot.error}');
        } else {
          final List<dynamic> results = snapshot.data!;
          final Map<String, String> idLocation_nameLocation = results[0];
          

          print("LISTENERS LIST");

          final Map<String, String> listeners = results[1];

          print("LISTENERS LIST");

          List<String> keysList = idLocation_nameLocation.keys.toList();

          // If data is successfully fetched, build the widget tree
          final List<String> dropdownOptions = keysList;
          return Scaffold(
            body: SingleChildScrollView(
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
                    const SizedBox(height: 90),
                    TextField(
                      controller: controller.deviceIDTextEditingController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Device ID",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    DropdownButtonFormField<String>(
                      onChanged: (String? value) {
                        controller.selectedLocation = RxString(value!);
                      },
                      items: dropdownOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(idLocation_nameLocation[value]!),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Select a hospital",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: () {
                        String deviceid = controller.deviceIDTextEditingController.text;
                        String location = controller.selectedLocation!.value.toString();
                        
                        if (deviceid.isNotEmpty) {
                          controller.addNotifierRequest(location, deviceid);
                          controller.refreshData(client);
                        } else {
                          Fluttertoast.showToast(
                            msg: "Fill all the device id",
                            toastLength: Toast.LENGTH_SHORT,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                          );
                        }
                      },
                      child: const Text(
                        "Add Notifier",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'RobotoMono',
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Added space here
                    SizedBox(
                        height: 320,
                        child: ListView.builder(
                          itemCount: listeners.entries.toList().length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 5), // Add margin for spacing between items
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 1), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Text(listeners.entries.toList()[index].key),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(idLocation_nameLocation[listeners.entries.toList()[index].value]!),
                                  ],
                                ),
                                trailing: GestureDetector(
                                  child: const Icon(Icons.delete, color: Colors.red),
                                  onTap: () {
                                    controller.removeNotifierRequest(listeners.entries.toList()[index].key, listeners.entries.toList()[index].value,client);
                                    controller.refreshData(client);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
