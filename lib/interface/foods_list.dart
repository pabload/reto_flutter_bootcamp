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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _nameToEdit = "";
  String _caloriesToEdit = "";
  List<Food>? listFoods;
  int? foodSelect;
  Widget _inputName() {
    return Container(
      child: TextFormField(
        initialValue: listFoods![foodSelect!].name,
        keyboardType: TextInputType.name,
        onSaved: (val) => _nameToEdit = val ?? '',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        validator: (val) =>
            (val != null && val.length > 5) ? null : 'Issue in Name',
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            prefixIcon: Icon(Icons.person),
            labelText: 'Name',
            hintText: 'Add a name'),
      ),
    );
  }

  Widget _inputCalories() {
    return Container(
      child: TextFormField(
        initialValue: listFoods![foodSelect!].calories.toString(),
        keyboardType: TextInputType.number,
        onSaved: (val) => _caloriesToEdit = val ?? '',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        validator: (val) =>
            (val != null && val.isNotEmpty && double.tryParse(val) != null)
                ? null
                : 'Issue in calories',
        decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            prefixIcon: Icon(Icons.person),
            labelText: 'calories',
            hintText: 'Add a calories'),
      ),
    );
  }

  Widget _formTask() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              _inputName(),
              SizedBox(
                height: 20,
              ),
              _inputCalories()
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    if (foodSelect == null) {
      return snackMessage(
          message: "You need to select a food",
          context: context,
          isError: true);
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit your food features'),
          content: SingleChildScrollView(
            child: _formTask(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Edit'),
              onPressed: () {
                _updateFoodFromLocal();
              },
            ),
          ],
        );
      },
    );
  }

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
    return ListView.builder(
        itemCount: listFoods!.length,
        itemBuilder: (BuildContext context, int index) {
          Food food = listFoods![index];
          return GestureDetector(
            onTap: () => _selectFood(index),
            child: Card(
              color: foodSelect == index ? Colors.red : null,
              child: ListTile(
                leading: Icon(Icons.food_bank_rounded),
                title: Text('Name: ${food.name}'),
                subtitle: Text('Calories: ${food.calories}'),
                trailing: food.idServer == null
                    ? IconButton(
                        icon: Icon(Icons.upload),
                        onPressed: () async {
                          _uploadFoodToServer(
                              name: food.name!, calories: food.calories!);
                        },
                      )
                    : Text('server id: ${food.idServer}'),
              ),
            ),
          );
        });
  }

  Widget _fabAddFood() {
    return FloatingActionButton.extended(
      heroTag: 1,
      onPressed: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => FormPage()))
          .whenComplete(() => _loadDataFromLocal()),
      label: Text('Add a food'),
      icon: Icon(Icons.add),
    );
  }

  Widget _fabEditFood() {
    return FloatingActionButton.extended(
      heroTag: 2,
      onPressed: _showMyDialog,
      label: Text('Edit food'),
      icon: Icon(Icons.edit),
    );
  }

  Widget _fabDeleteFood() {
    return FloatingActionButton.extended(
      heroTag: 3,
      onPressed: _deleteFoodFromlocal,
      label: Text('Delete food'),
      icon: Icon(Icons.delete),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDataFromLocal();
    //DatabaseHelper.deleteDatabase("db_foods2.db");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _fabAddFood(),
          SizedBox(height: 12),
          _fabEditFood(),
          SizedBox(height: 12),
          _fabDeleteFood(),
        ],
      ),
    );
  }

  _selectFood(int index) {
    setState(() {
      foodSelect = index;
    });
  }

  _uploadFoodToServer({required String name, required double calories}) async {
    final Database? db = await DatabaseHelper.db.database;
    int res =
        await Api.addFoodToSimulationAServer(name: name, calories: calories);
    await db!.rawUpdate(
        'UPDATE foods SET idServer = ? WHERE name = ?', [res.toString(), name]);
    _loadDataFromLocal();
    return snackMessage(message: "Food added to the server", context: context);
  }

  _updateFoodFromLocal() async {
    final Database? db = await DatabaseHelper.db.database;
    final FormState? _formState = _formKey.currentState;
    if (_formState != null) {
      _formState.save();
      try {
        bool isNumeric() => num.tryParse(_caloriesToEdit) != null;
        await db!.rawUpdate(
            'UPDATE foods SET name = ?, calories = ? WHERE name = ?',
            [_nameToEdit,isNumeric()?_caloriesToEdit:"0.0", listFoods![foodSelect!].name]);
        _loadDataFromLocal();
        Navigator.of(context).pop();
        return snackMessage(
            message: "Food updated successfully", context: context);
      } catch (error) {
        snackMessage(
            message: '${error.toString()}', context: context, isError: true);
      }
    } else {
      snackMessage(
          message: 'Issue inside the form', context: context, isError: true);
    }
  }

  _deleteFoodFromlocal() async {
    if (foodSelect != null) {
      final Database? db = await DatabaseHelper.db.database;
      String? name = listFoods![foodSelect!].name;
      int count =
          await db!.rawDelete('DELETE FROM foods WHERE name = ?', [name]);
      _loadDataFromLocal();
      return snackMessage(
          message: "Food deleted successfully", context: context);
    }
    return snackMessage(
        message: "You need to select a food", context: context, isError: true);
  }

  void _loadDataFromLocal() async {
    final Database? db = await DatabaseHelper.db.database;
    List<dynamic>? results = await db!.query("foods");
    if (results == null || results.isEmpty) {
      return setState(() {
        foodSelect = null;
        listFoods = [];
      });
    }
    setState(() {
      foodSelect = null;
      listFoods = results.map((food) => Food.fromMapSQL(food)).toList();
    });
  }
}
