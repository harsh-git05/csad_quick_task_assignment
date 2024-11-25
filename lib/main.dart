import 'package:csad_assignment_quick_task/userRegister.dart';
import 'package:csad_assignment_quick_task/user_task.dart';
import 'package:csad_assignment_quick_task/usertask.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:csad_assignment_quick_task/loginscreen.dart';
//import 'package:sembast/sembast_memory.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
//import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() 
  
  async {
      
      
      const keyApplicationId = 'S7VeiYlQCQdvLQRF6w0qfkkYyuWwO4wt7k3i4Y40';
      const keyClientKey = 'hIgEOqiBRR7S9njVGoRCaZY6SaNJSd3X3VYkOXZf';
      const keyParseServerUrl = 'https://parseapi.back4app.com';

     await Parse().initialize(keyApplicationId, keyParseServerUrl,
       clientKey: keyClientKey, debug: true);
   

  var firstObject = ParseObject('FirstClass')
    ..set(
        'message', 'Hey, Parse is now connected!🙂');
  await firstObject.save();
  
  print('done');

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false, 
      initialRoute: '/', 
      routes: 
      {'/': (context) => LoginScreen (),
        '/usertask': (context) => UserTask1(),
        '/userlogin' : (context) => Signup(),
      }, 



  ));

  }

