import 'package:flutter/material.dart';
import 'package:reto_flutter_bootcamp/local_database.dart';
import 'package:reto_flutter_bootcamp/models/food.dart';
import 'package:reto_flutter_bootcamp/utils/utilis.dart';
import 'package:sqflite/sqflite.dart';

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _name = "";
  String _calories = "";
  AppBar _appbar() {
    return AppBar(
      title: Text('Example 2'),
    );
  }

  Widget _inputName() {
    return Container(
      child: TextFormField(
        keyboardType: TextInputType.name,
        onSaved: (val) => _name = val ?? '',
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
        keyboardType: TextInputType.number,
        onSaved: (val) => _calories = val ?? '',
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
              Text(
                'Add a food to your local database',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
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

  Widget _fabSaveFood() {
    return FloatingActionButton.extended(
      onPressed: _saveData,
      label: Text('Save food'),
      icon: Icon(Icons.plus_one_outlined),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      body: _formTask(),
      floatingActionButton: _fabSaveFood(),
    );
  }

  void _saveData() async {
    final FormState? _formState = _formKey.currentState;
    if (_formState != null && _formState.validate()) {
      _formState.save();
      try {
        Food _food = Food(name: _name, calories: double.parse(_calories));
        await _insertData(_food);
        snackMessage(message: 'data saved', context: context);
        Navigator.of(context).pop();
      } catch (error) {
        snackMessage(
            message: '${error.toString()}', context: context, isError: true);
      }
    } else {
      print(_formState!.validate());
      snackMessage(
          message: 'Issue inside the form', context: context, isError: true);
    }
  }

  Future<void> _insertData(Food food) async {
    final Database? db = await DatabaseHelper.db.database;
    await db!.insert('foods', food.toMapSQL());
  }
}
