import 'package:buyinglist/CustomItems/borderTextField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_iconpicker/Serialization/iconDataSerialization.dart';
import '../database_helper.dart';

class CategoryAdd extends StatefulWidget {
  @override
  CategoryAddState createState() => CategoryAddState();
}

class CategoryAddState extends State<CategoryAdd> {
  final _datatableFont = const TextStyle(fontSize: 16.0);
  final dbHelper = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();
  List<String> _userField = <String>[];
  final name = TextEditingController();
  IconData _icon;

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('New category'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              if(_formKey.currentState.validate()){
                await _categoryInsert();
                Navigator.of(context).pop(true);
              }else{
                if(name.text.isEmpty && _userField.length == 0)
                  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please fill in category name & add some field.")));
                else if(name.text.isEmpty)
                  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please fill in category name.")));
                else if(_userField.length == 0)
                  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please add some field.")));
              }
//              if(name.text.isEmpty && _userField.length == 0)
//                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please fill in category name & add some field.")));
//              else if(name.text.isEmpty)
//                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please fill in category name.")));
//              else if(_userField.length == 0)
//                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please add some field.")));
//              else {
//                await _categoryInsert();
//                Navigator.of(context).pop(true);
//              }
            },
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: buildForm(),
        ),
      )
    );
  }

  _pickIcon() async {
    IconData icon = await FlutterIconPicker.showIconPicker(context,
        iconSize: 50,
        iconPackMode: IconPack.lineAwesomeIcons,
        title: Text('Pick an icon',
            style: TextStyle(fontWeight: FontWeight.bold)),
        closeChild: Text(
          'Close',
          textScaleFactor: 1.25,
        ),
        searchHintText: 'Search icon...',
        noResultsText: 'No results for:'
    );
    _icon = icon;
    setState((){});

    debugPrint('Picked Icon:  $icon');
  }

  List<Widget> buildForm() {
    final List<Widget> input = [];
    final field = TextEditingController();

    input.add(
      SizedBox(
        width: 100.0,
        height: 100.0,
        child: RaisedButton(
          onPressed: _pickIcon,
          child: Icon(_icon, size: 48.0,),
          shape: CircleBorder(side: BorderSide(width: 2.0, color: Colors.grey.shade500)),
          color: Colors.white,
        ),
      )
    );
    input.add(SizedBox(height: 32));
    input.add(
      BorderTextField(
        labelText: 'CATEGORY NAME',
        notNull: true,
        focusColor: Colors.orange,
        inputType: TextInputType.text,
        maxLines: 1,
        controller: name,
      )
    );
    input.add(SizedBox(height: 24));
    input.add(
      BorderTextField(
        labelText: 'FIELD YOU WANT TO ADD',
        notNull: false,
        focusColor: Colors.orange,
        controller: field,
        inputType: TextInputType.text,
        maxLines: 1,
        suffixIcon: Icon(Icons.add),
        onSuffixIconPress: () {
          if (field.text.isNotEmpty){
            _userField.add(field.text);
            Future.delayed(
              Duration(milliseconds: 50),
            ).then(
                  (_) {
                field.clear();
              },
            );
          }
          debugPrint(_userField.toString());
          setState(() {});
        },
      )
    );
    input.add(SizedBox(height: 24));
    input.add(
        DataTable(
          columns: <DataColumn>[
            DataColumn(label: Text('Field name', style: _datatableFont))
          ],
          rows: buildRow(_userField),
        )
    );
    return input;
  }

  List<DataRow> buildRow(List<String> fieldList) {
    List<DataRow> input = [];
    for(int i = 0; i < fieldList.length; i++){
      input.add(
          DataRow(
              cells: <DataCell>[
                DataCell(
                  Row(
                    children: <Widget>[
                      Text(_userField[i], style: _datatableFont),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _userField.remove(fieldList[i]);
                          });
                        },
                      )
                    ],
                  )
                )
              ]
          )
      );
    }
    return input;
  }

  Future _categoryInsert() async {
    String data = '';
    for(int i = 0; i < _userField.length; i++){
      if(i == _userField.length-1) data += _userField[i];
      else data += _userField[i] + ',';
    }
    debugPrint(data);
    Map<String, dynamic> row = {
      DatabaseHelper.columnCateName : name.text,
      DatabaseHelper.columnCateInfo : data
    };
    Map<String, dynamic> iconrow;
    try {
      iconrow = iconDataToMap(_icon);
    } on NoSuchMethodError catch (e) { debugPrint(e.toString()); }
    debugPrint(iconrow.toString());
    final id = await dbHelper.categoryInsert(row, iconrow);
    print('inserted category: $id');
  }

}