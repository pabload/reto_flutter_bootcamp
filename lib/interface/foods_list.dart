import 'package:flutter/material.dart';
import 'package:reto_flutter_bootcamp/api.dart';
import 'package:reto_flutter_bootcamp/interface/form_page.dart';
import 'package:reto_flutter_bootcamp/local_database.dart';
import 'package:reto_flutter_bootcamp/models/food.dart';
import 'package:reto_flutter_bootcamp/utils/utilis.dart';
import 'package:sqflite/sqflite.dart';

class FoodsList extends StatefulWidget {
  @override
  _FoodsListState createState() => _FoodsListState();
}

class _FoodsListState extends State<FoodsList> {
  List<Food>? listFoods;
  AppBar _appBar() {
    return AppBar(
      title: Text('Food List'),
    );
  }

  Widget _body() {
    if (listFoods == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (listFoods!.isEmpty) {
      return Center(
        child: Text('No data'),
      );
    }
    return ListView(
      children: listFoods!
          .map((food) => Card(
                child: ListTile(
                  leading: Icon(Icons.food_bank_rounded),
                  title: Text('Name: ${food.name}'),
                  subtitle: Text('Calories: ${food.calories}'),
                  trailing: IconButton(
                    icon: Icon(Icons.upload),
                    onPressed: () async{
                      bool res = await Api.checkFoodOnserver(food: food.name!);
                      if(!res){
                          _uploadFoodToServer(name: food.name!, calories: food.calories!);
                         return snackMessage(message: "Food added to the server", context: context);
                      }
                      snackMessage(message: "Food already on server", context: context,isError: true);
                    },
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _fabAddFood() {
    return FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => FormPage()))
            .whenComplete(() => _loadDataFromLocal()),
        label: Text('Add a food'));
  }

  @override
  void initState() {
    super.initState();
    _loadDataFromLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
      floatingActionButton: _fabAddFood(),
    );
  }

  _uploadFoodToServer({required String name, required double calories}) async {
    bool res = await Api.addFoodToServer(name: name, calories: calories);
    print(res);
  }

  

  void _loadDataFromLocal() async {
    final Database? db = await DatabaseHelper.db.database;
    List<dynamic>? results = await db!.query("foods");
    if (results == null || results.isEmpty) {
      return setState(() {
        listFoods = [];
      });
    }
    setState(() {
      listFoods = results.map((food) => Food.fromMapSQL(food)).toList();
    });
  }
}
