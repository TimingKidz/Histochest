import 'package:buyinglist/CustomItems/borderDetailsField.dart';
import 'package:buyinglist/CustomItems/statusEditDialog.dart';
import 'package:buyinglist/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BoughtDetails extends StatefulWidget {
  final int id;
  final String cateName;
  final IconData iconData;

  BoughtDetails({
    this.id,
    this.cateName,
    this.iconData
  });

  BoughtDetailsState createState() => BoughtDetailsState();
}

class BoughtDetailsState extends State<BoughtDetails> {
  final dbHelper = DatabaseHelper.instance;
  Map<String, dynamic> _list = {};
  Map<String, dynamic> _infoList = {};
  Map<String, dynamic> _statusInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _query();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteDialog();
            },
          ),
          IconButton(icon: Icon(Icons.clear), onPressed: Navigator.of(context).pop)
        ],
      ),
      body: isLoading ? loading() : detailBody()
    );
  }

  Widget loading() {
    return Text('Loading...');
  }

  Widget detailBody() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16.0),
//            margin: EdgeInsets.only(top: 2.0,left: 16.0, right: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
//              borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 2.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(_list[DatabaseHelper.columnName], style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 8.0),
                  GestureDetector(
                    onTap: () async {
                      debugPrint('WORKS');
                      await _conditionEditDialog();
                      await _query();
                    },
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: condition()
                    ),
                  )
                ],
              ),
              SizedBox(height: 32.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text('CATEGORY : ', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                              padding: EdgeInsets.only(top: 4.0, bottom: 4.0, left: 6.0, right: 8.0),
                              color: Colors.indigo,
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    child: Icon(widget.iconData != null ? widget.iconData : Icons.block, size: 16.0, color: Colors.white),
                                    margin: EdgeInsets.only(bottom: 2.0),
                                  ),
                                  SizedBox(width: 4.0),
                                  Text(widget.cateName.toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              )
                          )
                      ),
                    ],
                  ),
                  Text(
                      numberFormat(_list[DatabaseHelper.columnPrice]),
                      style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 24.0)
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Text(
                  'Purchase Date : ${dateFormat(_list[DatabaseHelper.columnBuyDate])}',
                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)
              ),
              SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  warrantyText(),
                  warrantyLabel(),
                ],
              )
            ],
          ),
        ),
        statusInfo(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: infoRow(),
          ),
        )
      ],
    );
  }

  Widget statusInfo() {
    Color color = statusColor(_list[DatabaseHelper.columnStatus]);
    if(_list[DatabaseHelper.columnStatus] == 'IN-USE'){
      return Container();
    }else if(_list[DatabaseHelper.columnStatus] == 'SOLD'){
      return Container(
        padding: EdgeInsets.all(16.0),
        color: color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Sold Date : ${dateFormat(_statusInfo[DatabaseHelper.columnSoldDate])}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text('Sold Price : ${numberFormat(_statusInfo[DatabaseHelper.columnSoldPrice])}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ],
        ),
      );
    }else if(_list[DatabaseHelper.columnStatus] == 'LOST'){
      return Container(
        color: color,
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('Lost Date : ${dateFormat(_statusInfo[DatabaseHelper.columnLostDate])}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }else if(_list[DatabaseHelper.columnStatus] == 'BROKEN'){
      return Container(
        padding: EdgeInsets.all(16.0),
        color: color,
        child: Center(
          child: Text('Broken Date : ${dateFormat(_statusInfo[DatabaseHelper.columnBrokenDate])}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }else{
      return Container(
        padding: EdgeInsets.all(16.0),
        color: color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Given Date : ${dateFormat(_statusInfo[DatabaseHelper.columnGivenDate])}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text('Given to : ${_statusInfo[DatabaseHelper.columnGivenTo]}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ],
        ),
      );
    }
  }

  Widget warrantyText() {
    String textShown = '${_list[DatabaseHelper.columnWarrantyPeriod]} months warranty';

    if(_list[DatabaseHelper.columnWarrantyPeriod] == '')
      textShown = 'No warranty';
    else if(_list[DatabaseHelper.columnWarrantyPeriod] % 12 == 0)
      textShown = '${(_list[DatabaseHelper.columnWarrantyPeriod]/12).toInt()} years warranty';

    return Text(
      textShown,
      style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)
    );
  }

  Widget warrantyLabel() {
    String textShown;
    bool isGood = true;

    if(_list[DatabaseHelper.columnWarrantyPeriod] == '') {
      textShown = 'No Warranty';
      isGood = false;
    }else{
      var dateFromDB = DateTime.parse(_list[DatabaseHelper.columnBuyDate]);
      var warrantyEndDate = DateTime(dateFromDB.year, dateFromDB.month + _list[DatabaseHelper.columnWarrantyPeriod], dateFromDB.day);
      var remainingWarranty = warrantyEndDate.difference(DateTime.now()).inDays.floor();
      textShown = '$remainingWarranty days left';
      debugPrint('$warrantyEndDate');

      if(remainingWarranty < 31) {
        isGood = false;
        if(remainingWarranty == 1) textShown = 'Last Day';
        else if(remainingWarranty <= 0) textShown = 'Warranty Expired';
      }
    }

    return Container(
      padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
            color: isGood ? Colors.green : Colors.red, style: BorderStyle.solid, width: 2.0),
      ),
      child: Text(textShown, style: TextStyle(color: isGood ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
    );
  }

  Widget condition(){
    Color color = statusColor(_list[DatabaseHelper.columnStatus]);

    return Container(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 8.0, right: 8.0),
      color: color,
      child: Row(
        children: <Widget>[
          Text(_list[DatabaseHelper.columnStatus], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(width: 4.0),
          Icon(Icons.edit, size: 16.0, color: Colors.white),
        ],
      )
    );
  }

  String dateFormat(String dateString) {
    var dateFromDB = dateString.split('-');
    Map<String, String> date = {};
    date['day'] = dateFromDB[2];
    date['month'] = dateFromDB[1];
    date['year'] = dateFromDB[0];
    return '${date['day']}/${date['month']}/${date['year']}';
  }

  String numberFormat(int number){
    return NumberFormat.simpleCurrency(locale: 'th', decimalDigits: 0).format(number);
  }

  Color statusColor(String status) {
    if(status == 'IN-USE'){
      return Colors.green;
    }else if(status == 'SOLD'){
      return Colors.amber;
    }else if(status == 'LOST'){
      return Colors.black38;
    }else if(status == 'BROKEN'){
      return Colors.red;
    }else{
      return Colors.pinkAccent;
    }
  }

  List<Widget> infoRow() {
    List<Widget> row = <Widget>[];
    for(int i = 0; i < _infoList.length; i++){
      if(!(_infoList.keys.elementAt(i) == DatabaseHelper.columnId ||
          _infoList.keys.elementAt(i) == DatabaseHelper.columnCateId) &&
          _infoList.values.elementAt(i) != ''){
        row.add(
          BorderDetailsField(
            labelText: _infoList.keys.elementAt(i),
            text: _infoList.values.elementAt(i),
          ),
        );
        row.add(
          SizedBox(height: 16.0)
        );
      }
    }
    if(_list[DatabaseHelper.columnNotes] != ''){
      row.add(
        BorderDetailsField(
          labelText: 'Note',
          text: _list[DatabaseHelper.columnNotes],
        )
      );
    }
    return row;
  }

  Future<void> _conditionEditDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatusEditDialog(id: widget.id, statusNow: _list[DatabaseHelper.columnStatus]);
      }
    );
  }

  Future<void> _deleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to remove ?'),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('REMOVE'),
              onPressed: () async {
                await _delete();
                Navigator.of(context).pop();
                Navigator.of(context).pop('deleted');
              },
            )
          ],
        );
      },
    );
  }

  Future _query() async {
    await dbHelper.boughtItemStaticValueQuery(widget.id).then((notes) {
      notes.forEach((note) {
        _list = note;
      });
    });
    await dbHelper.boughtItemDynamicValueQuery(widget.id, widget.cateName).then((notes) {
      notes.forEach((note) {
        _infoList = note;
      });
    });
    if(_list[DatabaseHelper.columnStatus] != 'IN-USE'){
      await dbHelper.boughtItemStatusValueQuery(widget.id, _list[DatabaseHelper.columnStatus]).then((value) {
        value.forEach((item) {
          _statusInfo = item;
        });
      });
    }
    isLoading = false;
    debugPrint('BoughtDetails Query Successful');
    setState(() {});
  }

  Future _delete() async {
    final rowsDeleted = await dbHelper.boughtDelete(widget.id);
    print('deleted $rowsDeleted row(s): row ${widget.id}');
  }
}