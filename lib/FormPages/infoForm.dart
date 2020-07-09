import 'package:buyinglist/CustomItems/borderDatePicker.dart';
import 'package:buyinglist/CustomItems/borderDropdownButton.dart';
import 'package:buyinglist/CustomItems/borderTextField.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database_helper.dart';

class InfoForm extends StatefulWidget {
  final cateID;
  InfoForm({this.cateID});

  @override
  InfoFormState createState() => InfoFormState(cateID);
}

class InfoFormState extends State<InfoForm> {
  final cateID;
  InfoFormState(this.cateID);
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> statusValue = {};

  final dbHelper = DatabaseHelper.instance;
  var _infoName = <String>[];
  Map<String, dynamic> boughtListValueField = {};
  Map<String, dynamic> categoryListValueField = {};
  List<String> dropdownItem = ['IN-USE','SOLD','LOST','BROKEN','GIVEN'];
  bool isFocus = false;

  @override
  void initState() {
    super.initState();
    debugPrint("You tapped on cateID $cateID");
    _query();
    boughtListValueField[DatabaseHelper.columnStatus] = dropdownItem[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Info'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              if(_formKey.currentState.validate()) {
                if(boughtListValueField[DatabaseHelper.columnStatus] != 'IN-USE'){
                  await _itemStatusDialog();
                }else{
                  await _boughtInsert();
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                }
              }
            },
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: buildForm(),
        ),
      )
    );
  }

  List<Widget> buildForm() {
    final List<Widget> input = <Widget>[];

    input.add(
      BorderTextField(
        labelText: 'NAME',
        notNull: true,
        focusColor: Colors.orange,
        inputType: TextInputType.text,
        maxLines: 1,
        controller: boughtListValueField[DatabaseHelper.columnName],
      )
    );
    input.add(SizedBox(height: 16));
    input.add(
      Row(
        children: <Widget>[
          Flexible(
            child: BorderDatePicker(
              labelText: 'BUYING DATE',
              onDatePick: (value) {
                boughtListValueField[DatabaseHelper.columnBuyDate] = DateFormat('yyyy-MM-dd').format(value);
              },
            ),
          ),
          SizedBox(width: 16.0),
          Flexible(
            child: BorderDropdownButton(
              labelText: 'CONDITION',
              listItems: dropdownItem,
              onChanged: (value) {
                boughtListValueField[DatabaseHelper.columnStatus] = value;
                debugPrint(boughtListValueField[DatabaseHelper.columnStatus]);
              },
            ),
          )
        ],
      )
    );
    input.add(SizedBox(height: 16));
    input.add(
      Row(
        children: <Widget>[
          Flexible(
            child: BorderTextField(
              labelText: 'PRICE (฿)',
              notNull: true,
              focusColor: Colors.orange,
              inputType: TextInputType.number,
              maxLines: 1,
              controller: boughtListValueField[DatabaseHelper.columnPrice],
            ),
          ),
          SizedBox(width: 16.0),
          Flexible(
            child:  BorderTextField(
              notNull: false,
              labelText: 'WARRANTY (Month)',
              focusColor: Colors.orange,
              inputType: TextInputType.number,
              maxLines: 1,
              controller: boughtListValueField[DatabaseHelper.columnWarrantyPeriod],
            ),
          )
        ],
      )
    );
    input.add(SizedBox(height: 16));
    for (int i = 0; i < _infoName.length; i++) {
      input.add(
        BorderTextField(
          labelText: _infoName[i],
          notNull: false,
          focusColor: Colors.orange,
          inputType: TextInputType.text,
          maxLines: 1,
          controller: categoryListValueField[_infoName[i]],
        )
      );
      input.add(SizedBox(height: 16));
    }
    input.add(
      BorderTextField(
        labelText: 'NOTE',
        notNull: false,
        focusColor: Colors.orange,
        inputType: TextInputType.multiline,
        controller: boughtListValueField[DatabaseHelper.columnNotes],
      )
    );
    return input;
  }

  Future<void> _itemStatusDialog() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('There is one more step left'),
          content: itemStatusForm(),
          actions: <Widget>[
            FlatButton(
              child: Text('CLOSE'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                await _boughtInsert();
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            )
          ],
        );
      },
    );
  }

  Widget itemStatusForm() {
    if(boughtListValueField[DatabaseHelper.columnStatus] == 'SOLD') {
      statusValue[DatabaseHelper.columnSoldDate] = DateFormat('yyyy-MM-dd').format(DateTime.now());
      statusValue[DatabaseHelper.columnSoldPrice] = TextEditingController();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Base on your chosen status we would like to know more information'),
          SizedBox(height: 24.0),
          BorderDatePicker(
            labelText: 'SOLD DATE',
            onDatePick: (value) {
                statusValue[DatabaseHelper.columnSoldDate] = DateFormat('yyyy-MM-dd').format(value);
            },
          ),
          SizedBox(height: 24.0),
          BorderTextField(
            labelText: 'SOLD PRICE (฿)',
            focusColor: Colors.orange,
            notNull: true,
            inputType: TextInputType.number,
            controller: statusValue[DatabaseHelper.columnSoldPrice],
          )
        ],
      );
    }else if(boughtListValueField[DatabaseHelper.columnStatus] == 'LOST') {
      statusValue[DatabaseHelper.columnLostDate] = DateFormat('yyyy-MM-dd').format(DateTime.now());
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Base on your chosen status we would like to know more information'),
          SizedBox(height: 24.0),
          BorderDatePicker(
            labelText: 'LOST DATE',
            onDatePick: (value) {
                statusValue[DatabaseHelper.columnLostDate] = DateFormat('yyyy-MM-dd').format(value);
            },
          )
        ],
      );
    }else if(boughtListValueField[DatabaseHelper.columnStatus] == 'BROKEN') {
      statusValue[DatabaseHelper.columnBrokenDate] = DateFormat('yyyy-MM-dd').format(DateTime.now());
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Base on your chosen status we would like to know more information'),
          SizedBox(height: 24.0),
          BorderDatePicker(
            labelText: 'BROKEN DATE',
            onDatePick: (value) {
                statusValue[DatabaseHelper.columnBrokenDate] = DateFormat('yyyy-MM-dd').format(value);
            },
          )
        ],
      );
    }else{
      statusValue[DatabaseHelper.columnGivenDate] = DateFormat('yyyy-MM-dd').format(DateTime.now());
      statusValue[DatabaseHelper.columnGivenTo] = TextEditingController();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Base on your chosen status we would like to know more information'),
          SizedBox(height: 24.0),
          BorderDatePicker(
            labelText: 'GIVEN DATE',
            onDatePick: (value) {
                statusValue[DatabaseHelper.columnGivenDate] = DateFormat('yyyy-MM-dd').format(value);
            },
          ),
          SizedBox(height: 24.0),
          BorderTextField(
            labelText: 'GIVEN TO',
            focusColor: Colors.orange,
            notNull: true,
            inputType: TextInputType.text,
            controller: statusValue[DatabaseHelper.columnGivenTo],
          )
        ],
      );
    }
  }

  Future _boughtInsert() async {
    // row to insert
    Map<String, dynamic> boughtListRow = {
      DatabaseHelper.columnCateId  : cateID,
      DatabaseHelper.columnName : boughtListValueField[DatabaseHelper.columnName].text,
      DatabaseHelper.columnStatus : boughtListValueField[DatabaseHelper.columnStatus],
      DatabaseHelper.columnBuyDate : boughtListValueField[DatabaseHelper.columnBuyDate],
      DatabaseHelper.columnPrice : boughtListValueField[DatabaseHelper.columnPrice].text,
      DatabaseHelper.columnWarrantyPeriod : boughtListValueField[DatabaseHelper.columnWarrantyPeriod].text,
      DatabaseHelper.columnNotes : boughtListValueField[DatabaseHelper.columnNotes].text
    };

    //---------------------debugPrint---------------------
    debugPrint(boughtListRow.toString());
    Map<String, dynamic> debugList = {};
    for(int i = 0; i < categoryListValueField.length; i++) {
      debugList[_infoName[i]] = categoryListValueField[_infoName[i]].text;
    }
    debugPrint(debugList.toString());
    //----------------------------------------------------

    final id = await dbHelper.boughtInsert(cateID, boughtListRow, categoryListValueField);
    print('inserted row id: $id');

    Map<String, dynamic> row;
    if(boughtListValueField[DatabaseHelper.columnStatus] != 'IN-USE'){
      row = {
        DatabaseHelper.columnId : id,
        statusValue.keys.elementAt(0) : statusValue.values.elementAt(0)
      };
      for(int i = 1; i < statusValue.length; i++){
        row.addAll({statusValue.keys.elementAt(i) : statusValue.values.elementAt(i).text});
      }
      debugPrint('$row');
      await dbHelper.statusInsert(boughtListValueField[DatabaseHelper.columnStatus], id, row);
    }
  }

  Future _query() async {
    await dbHelper.queryByID(cateID, DatabaseHelper.table_categories).then((notes) {
      notes.forEach((note) {
        debugPrint(note.values.elementAt(0).toString());
        _infoName = note.values.elementAt(0).toString().split(',');
      });
      boughtListValueField[DatabaseHelper.columnName] = TextEditingController();
      boughtListValueField[DatabaseHelper.columnStatus] = dropdownItem[0];
      boughtListValueField[DatabaseHelper.columnBuyDate] = DateFormat('yyyy-MM-dd').format(DateTime.now());
      boughtListValueField[DatabaseHelper.columnPrice] = TextEditingController();
      boughtListValueField[DatabaseHelper.columnWarrantyPeriod] = TextEditingController();
      boughtListValueField[DatabaseHelper.columnNotes] = TextEditingController();
      for(int i = 0; i < _infoName.length; i++){
        categoryListValueField[_infoName[i]] = TextEditingController();
      }
    });
    setState(() {});
  }

}