import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

class Api {
  static final String mainUrl = "http://192.168.1.44:8000/foods/";


  //Method with simulation
   static Future<int> addFoodToSimulationAServer(
      {required String name, required double calories}) async {
    Map<String, dynamic> _jsonFood = {"name": name, "calories": calories};
    int serverId = Random().nextInt(100);
    await Future.delayed(Duration(seconds: 1));
    return serverId;
    
  }

  //Method with a real server 
  static Future<bool> addFoodToServer(
      {required String name, required double calories}) async {
    Map<String, dynamic> _jsonFood = {"name": name, "calories": calories};
    http.Response _response = await http.post(Uri.parse(mainUrl),
        body: json.encode(_jsonFood),
        headers: {"Content-Type": "application/json"},
        encoding: Encoding.getByName("utf-8"));
    if (_response.statusCode == 201) {
      print(utf8.decode(_response.bodyBytes));
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> checkFoodOnserver({required String food}) async {
    List<dynamic>? _list;
    bool exist=false;
    try {
      http.Response _response = await http.get(Uri.parse(mainUrl), headers: {
        "Content-Type": "application/json"
      }).timeout(Duration(seconds: 20));
      if (_response.statusCode == 200) {
        _list = await json.decode(utf8.decode(_response.bodyBytes));
        _list!.forEach((element) {
          if((element['name'])==food){
            exist=true;
          }
         });
      } 
      print(exist);
      return exist;
    } catch (error) {
      return exist;
    }
  }
}
