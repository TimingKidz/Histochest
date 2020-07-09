import 'package:buyinglist/CustomItems/gridViewWithIconAboveText.dart';
import 'package:buyinglist/FormPages/categoryAddForm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../database_helper.dart';

class CategoriesManaging extends StatefulWidget {
  @override
  CategoriesManagingState createState() => CategoriesManagingState();
}

class CategoriesManagingState extends State<CategoriesManaging> {
  final dbHelper = DatabaseHelper.instance;
  final _categoriesID = <int>[];
  final _categoriesName = <String>[];
  final _categoriesIconMap = <Map<String, dynamic>>[];
  int _selectedCard;
  bool isPageBlank = true;
  String pageBlank = '';

  @override
  void initState() {
    super.initState();
    _query();
  }

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Categories'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add new category',
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryAdd()));
              if(result == true){
                await _query();
              }
            },
          ),
//          IconButton(
//            icon: Icon(Icons.edit),
//            tooltip: 'Edit selected category',
//            onPressed: () {
//              if (_selectedCard == null){
//                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please Select Category First")));
//              }else{
//
//              }
//            },
//          ),
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Delete selected category',
            onPressed: () async {
              if (_selectedCard == null){
                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please Select Category First")));
              }else{
                _deleteDialog();
              }
            },
          )
        ],
      ),
      body: isPageBlank ? blankPage() : gridView()
    );
  }

  Widget blankPage() {
    return Center(
      child: Text(pageBlank),
    );
  }

  Widget gridView() {
    return GridViewWithIconAboveText(
      columnCount: 3,
      nameList: _categoriesName,
      iconMapList: _categoriesIconMap,
      onGridTap: (value) {
        _selectedCard = value;
        if(_selectedCard != null) debugPrint(_categoriesID[_selectedCard].toString());
      },
    );
  }

  Future<void> _deleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to remove ?'),
          content: Text('your data with this category will be lost'),
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
                await _delete(_categoriesID[_selectedCard]);
                _selectedCard = null;
                _query();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future _query() async {
    _categoriesIconMap.clear();
    _categoriesName.clear();
    _categoriesID.clear();
    await dbHelper.queryAllRows(DatabaseHelper.table_categoriesIcon).then((notes) {
      notes.forEach((note) {
        bool mtd;
        if(note['matchTextDirection'] == '0') mtd = false;
        else mtd = true;
        Map<String, dynamic> justIcon = {
          'codePoint' : int.parse(note['codePoint']),
          'fontFamily' : note['fontFamily'].toString(),
          'fontPackage' : note['fontPackage'].toString(),
          'matchTextDirection' : mtd
        };
        justIcon.remove(DatabaseHelper.columnCateId);
        _categoriesIconMap.add(justIcon);
      });
    });
    await dbHelper.queryAllRows(DatabaseHelper.table_categories).then((notes) {
      notes.forEach((note) {
        _categoriesID.add(note[DatabaseHelper.columnCateId]);
        _categoriesName.add(note[DatabaseHelper.columnCateName].toString());
      });
    });
    if(_categoriesName.isNotEmpty) isPageBlank = false;
    else{
      isPageBlank = true;
      pageBlank = 'No category';
    }
    setState(() {});
    debugPrint(_categoriesID.toString());
    debugPrint(_categoriesName.toString());
    debugPrint(_categoriesIconMap.toString());
  }

  Future _delete(id) async {
    final rowsDeleted = await dbHelper.categoryDelete(id);
    print('deleted $rowsDeleted row(s): row $id');
  }

}