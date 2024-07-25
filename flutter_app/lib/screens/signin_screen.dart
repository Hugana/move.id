import 'package:flutter/material.dart';
import 'package:move_id/screens/home_screen.dart';
import 'package:move_id/utils/color_utils.dart';
import 'package:move_id/screens/signup_screen.dart';
import 'package:move_id/utils/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:move_id/utils/api_urls.dart';


class SignInScreen extends StatefulWidget {
  final MqttServerClient client;
  const SignInScreen({super.key, required this.client});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

Future<Map<String, String>> loginRequest(BuildContext context, emailController,TextEditingController passwordController, MqttServerClient client) async {
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String ip = prefs.getString("ip_http")??"";
  String port = prefs.getString("port_http")??"";

  String url = 'http://'+ip+':'+port+'/' + ApiUrls.loginUrl;

  try {
    final String email = emailController.text;
    final String password = passwordController.text;

    final Map<String, String> userData = {
        'email': email,
        'password': password,
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
        msg: "logged in successfully",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        textColor: Colors.black
      );

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('email', email);

      final Map<String, dynamic> responseBody = json.decode(response.body);
      
      final Map<String, String> responseData = {};
      responseBody.forEach((key, value) {
        responseData[key] = value.toString();
      });

      Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(client: client)),
                  );

      return responseData;
    } else {
      Fluttertoast.showToast(
        msg: "Could not complete login, check password or email.",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        textColor: Colors.black
      );
      return {}; 
    }
  } catch (e) {
    print('Exception occurred: $e');
    Fluttertoast.showToast(
      msg: "Could not complete login, check password or email.",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.white,
      textColor: Colors.black
    );
    return {}; 
  }
}


class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


@override
Widget build(BuildContext context) {
  return Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 100),
                  Image.asset("assets/images/move_id_logo_green.png"),
                  const SizedBox(height: 10),
                  buildInputField(
                    controller: _emailController,
                    hintText: "Email",
                    obscureText: false,
                    icon: const Icon(Icons.account_circle),
                  ),
                  const SizedBox(height: 20),
                  buildInputField(
                    controller: _passwordController,
                    hintText: "Password",
                    obscureText: true,
                    icon: const Icon(Icons.lock),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen(client: widget.client)),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Click here!",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Forgot to fill all the fields",
                          toastLength: Toast.LENGTH_SHORT,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                        );
                      } else {
                        loginRequest(context, _emailController, _passwordController, widget.client).then((response) {}).catchError((error) {
                          print("Error during login: $error");
                        });
                      }
                    },
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'RobotoMono',
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}


}
