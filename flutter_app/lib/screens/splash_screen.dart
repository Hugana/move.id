import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:move_id/screens/home_screen.dart';
import 'package:move_id/screens/signin_screen.dart';
import 'package:move_id/utils/color_utils.dart';

class SplashScreen extends StatefulWidget {
  final MqttServerClient client;
  const SplashScreen({super.key, required this.client});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}



class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkEmail();
  }

  Future<void> _checkEmail() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate a delay
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen(client: widget.client)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(client: widget.client)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/move_id_logo_green.png"),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Colors.white,),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> saveEmail(String email) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('email', email);
}