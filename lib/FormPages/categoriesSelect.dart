import 'package:buyinglist/CustomItems/gridViewWithIconAboveText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'infoForm.dart';

class CategoriesSelect extends StatefulWidget {
  @override
  CategoriesSelectState createState() => CategoriesSelectState();
}

class CategoriesSelectState extends State<CategoriesSelect> {
  final dbHelper = DatabaseHelper.instance;
  final _categoriesID = <int>[];
  final _categoriesName = <String>[];
  final _categoriesIconMap = <Map<String, dynamic>>[];
  int _selectedCard;
  bool isPageBlank = true;

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
        title: Text('Choose Your Category'),
        leading: IconButton(
          icon: Icon(Icons.clear, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('NEXT'),
            onPressed: () {
              if (_selectedCard == null){
                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please Select Category First")));
              }else{
                Navigator.push(context, MaterialPageRoute(builder: (context) => InfoForm(cateID : _categoriesID[_selectedCard])));
              }
            },
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          )
        ],
      ),
      body: isPageBlank ? blankPage() : gridView()
    );
  }

  Widget blankPage() {
    return Center(
      child: Text('No category'),
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
    setState(() {});
    debugPrint(_categoriesID.toString());
    debugPrint(_categoriesName.toString());
    debugPrint(_categoriesIconMap.toString());
  }
}
