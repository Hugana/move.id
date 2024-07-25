import 'package:flutter/material.dart';
import 'package:move_id/screens/signin_screen.dart';
import 'package:move_id/utils/color_utils.dart';
import 'package:move_id/utils/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:move_id/utils/api_urls.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SignUpScreen extends StatefulWidget {
  final MqttServerClient client;
  const SignUpScreen({super.key, required this.client});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}


Future<Map<String, String>> registerRequest(TextEditingController fnameController, TextEditingController lnameController,
    TextEditingController usernameController, TextEditingController emailController,
    TextEditingController password1Controller) async {
  

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String ip = prefs.getString("ip_http")??"";
  String port = prefs.getString("port_http")??"";

  String url = 'http://'+ip+':'+port+'/' + ApiUrls.registerUrl;
  
  final String firstName = fnameController.text;
  final String lastName = lnameController.text;
  final String username = usernameController.text;
  final String email = emailController.text;
  final String password = password1Controller.text;

  final Map<String, String> userData = {
    'first_name': firstName,
    'last_name': lastName,
    'username': username,
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
      msg: "Account created successfully",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.white,
      textColor: Colors.black
    );
    // Decode the response body
    final Map<String, dynamic> responseBody = json.decode(response.body);
    
    final Map<String, String> responseData = {};
    responseBody.forEach((key, value) {
      responseData[key] = value.toString();
    });
    return responseData;
  } else {
    Fluttertoast.showToast(
      msg: "Email already in use",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.white,
      textColor: Colors.black
    );
    throw Exception('Failed to register user');
  }
}


class _SignUpScreenState extends State<SignUpScreen> {
  
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _password1Controller = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();

  // Dentro do método build de _SignUpScreenState
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Sign Up',
        style: TextStyle(fontFamily: 'RobotoMono'),
      ),
      backgroundColor: hexStringToColor("#eff1ed"),
    ),
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
                  const SizedBox(height: 30),
                  buildInputField(
                    controller: _fnameController,
                    hintText: "First Name",
                    obscureText: false,
                    icon: const Icon(Icons.text_fields),
                  ),
                  const SizedBox(height: 20),
                  buildInputField(
                    controller: _lnameController,
                    hintText: "Last Name",
                    obscureText: false,
                    icon: const Icon(Icons.text_fields),
                  ),
                  const SizedBox(height: 20),
                  buildInputField(
                    controller: _usernameController,
                    hintText: "Username",
                    obscureText: false,
                    icon: const Icon(Icons.account_circle),
                  ),
                  const SizedBox(height: 20),
                  buildInputField(
                    controller: _emailController,
                    hintText: "Email",
                    obscureText: false,
                    icon: const Icon(Icons.email),
                  ),
                  const SizedBox(height: 20),
                  buildInputField(
                    controller: _password1Controller,
                    hintText: "Password",
                    obscureText: true,
                    icon: const Icon(Icons.lock),
                  ),
                  const SizedBox(height: 20),
                  buildInputField(
                    controller: _password2Controller,
                    hintText: "Verify Password",
                    obscureText: true,
                    icon: const Icon(Icons.lock),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInScreen(client: widget.client)),
                      );
                    },
                    child: const Text(
                      "Already have an account? Sign up here!",
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
                      if (_fnameController.text.isEmpty ||
                          _lnameController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _usernameController.text.isEmpty ||
                          _password1Controller.text.isEmpty ||
                          _password2Controller.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Forgot to fill all the fields!",
                          toastLength: Toast.LENGTH_SHORT,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                        );
                      } else if (_password1Controller.text != _password2Controller.text) {
                        Fluttertoast.showToast(
                          msg: "Passwords don't match!",
                          toastLength: Toast.LENGTH_SHORT,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                        );
                      } else {
                        registerRequest(
                          _fnameController,
                          _lnameController,
                          _usernameController,
                          _emailController,
                          _password1Controller,
                        ).then((response) {
                          print("Register successful");
                        }).catchError((error) {
                          print("Error during registration: $error");
                          Fluttertoast.showToast(
                            msg: "Failed to register user: $error",
                            toastLength: Toast.LENGTH_SHORT,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                          );
                        });
                      }
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'RobotoMono'),
                    ),
                  ),
                  const SizedBox(height: 40),
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
