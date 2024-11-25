import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:todo_app/register.dart';




class LoginScreen extends StatefulWidget {
  @override
  _loginscreenState createState() => _loginscreenState();
}

class _loginscreenState extends State<LoginScreen> {
  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();
  bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text("QuickTask Management",style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        backgroundColor: Color.fromARGB(255, 1, 204, 255),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [               
              const SizedBox(
                
                height: 16,
              ),
               
              const SizedBox(
                width: 50,
                height: 16,
                
              ),
              TextFormField(
                controller: controllerUsername,
                enabled: !isLoggedIn,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                decoration:  const InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 157, 155, 155))),
                    labelText: 'UserName',
                    //contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    ),
                    
              ),
              const SizedBox(
                width: 50,
                height: 5,
              ),
              TextField(
                controller: controllerPassword,
                enabled: !isLoggedIn,
                obscureText: true,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                decoration:  const InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 170, 167, 167))),
                    labelText: 'Password'),
              ),
               const SizedBox(
                height: 16,
              ),
              Container(
                height: 50,
                child: TextButton(
                  child: const Text('Login'),
                  onPressed: isLoggedIn ? null : () => doUserLogin(),
                   style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Sets the text color
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 0, 189, 252)), // Sets the background color
                    ),
                ),
              ),
               const SizedBox(
                height: 16,
              ),
              Container(
                height: 50,
                child: TextButton(
                  child: const Text('Logout'),
                  onPressed: !isLoggedIn ? null : () => doUserLogout(),                   
                ),
              ),
              Container(
                height: 50,
                child: TextButton(
                  child: const Text('Sign-Up'),
                  onPressed: () => doUserRegistration(),
                   
              )
              )
            ],
          ),
        ),
      ),
    );
  }  

  void showSuccess(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success!"),
          content: Text(message),
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

  void doUserRegistration() async{
    Navigator.pushNamedAndRemoveUntil(
            context, '/register', ModalRoute.withName('/register'));
  } 
  void doUserLogin() async {
   final username = controllerUsername.text.trim();
  final password = controllerPassword.text.trim();

  final user = ParseUser(username, password, null);

var response = await user.login();

if (response.success) {
  showSuccess("User was successfully login!");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("username", username);
  setState(() {
    isLoggedIn = true;
  });
  Navigator.pushNamedAndRemoveUntil(
            context, '/usertask', ModalRoute.withName('/usertask'));
} else {
  showError(response.error!.message);
}

  }

  void doUserLogout() async {
  final user = await ParseUser.currentUser() as ParseUser;
  var response = await user.logout();

  if (response.success) {
    showSuccess("User was successfully logout!");
    setState(() {
      isLoggedIn = false;
    });
  } else {
    showError(response.error!.message);
  }
}

}