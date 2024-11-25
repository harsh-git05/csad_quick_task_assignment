
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget{

  @override
  _SignupUserState createState() => _SignupUserState();
}

class _SignupUserState extends State<Signup>{

  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerEmail = TextEditingController();

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('QuickTask User registration'),
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [             
             const SizedBox(
              height: 16,
            ),
             
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller: controllerUsername,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 175, 170, 170))),
                  labelText: 'Username'),
            ),
            const SizedBox(
              height: 8,
            ),
            TextField(
              controller: controllerEmail,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 192, 186, 186))),
                  labelText: 'E-mail'),
            ),
            const SizedBox(
              height: 8,
            ),
            TextField(
              controller: controllerPassword,
              obscureText: true,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 191, 182, 182))),
                  labelText: 'Password'),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              height: 50,
              child: TextButton(
                child: const Text('Sign Up'),
                onPressed: () => doUserRegistration(),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

void showSuccess() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Success!"),
        content: const Text("User was successfully created!"),
        actions: <Widget>[
          new TextButton(
            child: const Text("OK"),
            onPressed: () {
              
              Navigator.pushNamedAndRemoveUntil(
             context, '/usertask', ModalRoute.withName('/usertask'));

            },
          ),
        ],
      );
    },
  );
}

void showError(String errorMessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Error!"),
        content: Text(errorMessage),
        actions: <Widget>[
          new TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
              
            },
          ),
        ],
      );
    },
  );
}

 
  void doUserRegistration() async {
    
  final username = controllerUsername.text.trim();
  final email = controllerEmail.text.trim();
  final password = controllerPassword.text.trim();

  final user = ParseUser.createUser(username, password, email);

  var response = await user.signUp();

  if (response.success) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("username", username);
    showSuccess();
  } else {
    showError(response.error!.message);
  }
}

}