import 'package:buyinglist/CustomItems/borderDropdownButton.dart';
import 'package:buyinglist/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'borderDatePicker.dart';
import 'borderTextField.dart';

class StatusEditDialog extends StatefulWidget {
  final int id;
  final String statusNow;

  StatusEditDialog({
    this.id,
    this.statusNow
  });

  StatusEditDialogState createState() => StatusEditDialogState();
}

class StatusEditDialogState extends State<StatusEditDialog> {
  final _formKey = GlobalKey<FormState>();
  List<String> dropdownItem = ['IN-USE','SOLD','LOST','BROKEN','GIVEN'];
  Map<String, dynamic> statusValue = {};
  String statusName;
  bool isNext = true;
  Text selectStatusText = Text('Select your new status');
  Text informationText = Text('Fill in require information');

  @override
  void initState() {
    super.initState();
    dropdownItem.remove(widget.statusNow);
    statusName = dropdownItem.first;
    debugPrint(widget.statusNow);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: isNext ? selectStatusText : informationText,
      content: isNext ? itemStatusChoose() : itemForm(),
      actions: isNext ? page1() : page2(),
    );
  }

  List<Widget> page1() {
    List<Widget> row = [];
    row.add(
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
    );
    row.add(
        FlatButton(
          child: Text('Next'),
          onPressed: () async {
            isNext = false;
            if(statusName == 'SOLD'){
              statusValue[DatabaseHelper.columnSoldDate] = DateFormat('yyyy-MM-dd').format(DateTime.now());
              statusValue[DatabaseHelper.columnSoldPrice] = TextEditingController();
            }
            else if(statusName == 'LOST')
              statusValue[DatabaseHelper.columnLostDate] = DateFormat('yyyy-MM-dd').format(DateTime.now());
            else if(statusName == 'BROKEN')
              statusValue[DatabaseHelper.columnBrokenDate] = DateFormat('yyyy-MM-dd').format(DateTime.now());
            else if(statusName == 'GIVEN') {
              statusValue[DatabaseHelper.columnGivenDate] = DateFormat('yyyy-MM-dd').format(DateTime.now());
              statusValue[DatabaseHelper.columnGivenTo] = TextEditingController();
            }else{
              await _update();
              Navigator.of(context).pop();
            }
            setState(() {});
            debugPrint(isNext.toString());
          },
        )
    );
    return row;
  }

  List<Widget> page2() {
    List<Widget> row =[];
    row.add(
        FlatButton(
          child: Text('Back'),
          onPressed: () {
            isNext = true;
            statusValue.clear();
            setState(() {});
          },
        )
    );
    row.add(
        FlatButton(
          child: Text('Finish'),
          onPressed: () async {
            if(_formKey.currentState.validate()){
              await _update();
              Navigator.of(context).pop();
            }
          },
        )
    );
    return row;
  }

  Widget itemStatusChoose() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BorderDropdownButton(
          labelText: 'STATUS',
          listItems: dropdownItem,
          onChanged: (value) {
            statusName = value;
          },
        )
      ],
    );
  }

  Widget itemForm() {
    return Form(
      key: _formKey,
      child: itemStatusForm(),
    );
  }

  Widget itemStatusForm() {
    if(statusName == 'SOLD') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
    }else if(statusName == 'LOST') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          BorderDatePicker(
            labelText: 'LOST DATE',
            onDatePick: (value) {
                statusValue[DatabaseHelper.columnLostDate] = DateFormat('yyyy-MM-dd').format(value);
            },
          )
        ],
      );
    }else if(statusName == 'BROKEN') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          BorderDatePicker(
            labelText: 'BROKEN DATE',
            onDatePick: (value) {
                statusValue[DatabaseHelper.columnBrokenDate] = DateFormat('yyyy-MM-dd').format(value);
            },
          )
        ],
      );
    }else{
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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

  Future<void> _update() async {
    Map<String, dynamic> row;
    if(statusName != 'IN-USE'){
      row = {
        DatabaseHelper.columnId : widget.id,
        statusValue.keys.elementAt(0) : statusValue.values.elementAt(0)
      };
      for(int i = 1; i < statusValue.length; i++){
        row.addAll({statusValue.keys.elementAt(i) : statusValue.values.elementAt(i).text});
      }
      debugPrint('$row');
    }
    DatabaseHelper.instance.updateStatus(widget.statusNow, statusName, widget.id, row).then((value) {

    });
  }

}