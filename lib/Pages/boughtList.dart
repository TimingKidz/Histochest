import 'package:buyinglist/CustomItems/cardTile.dart';
import 'package:buyinglist/Pages/boughtDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'package:flutter_iconpicker/Serialization/iconDataSerialization.dart';

class BoughtList extends StatefulWidget {
  static final GlobalKey<BoughtListState> boughtListKey = GlobalKey<BoughtListState>();

  BoughtList() : super(key: boughtListKey);

  @override
  BoughtListState createState() => BoughtListState();
}

class BoughtListState extends State<BoughtList> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dbHelper = DatabaseHelper.instance;
  final _list = <Map<String, dynamic>>[];
  Map<int, Map<String, dynamic>> _categoryIcon = {};
  int selectedBarIndex = 0;
  bool isPageBlank = true;
  String pageBlank = '';

  @override
  void initState() {
    super.initState();
    query();
    debugPrint('boughtList init');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Bought History'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
          )
        ],
      ),
      body: isPageBlank ? blankPage() : _buildSuggestions(),
    );
  }

  Widget blankPage() {
    return Center(
      child: Text(pageBlank),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        itemCount: _list.length,
        itemBuilder: /*1*/ (context, i) {
          return _buildRow(_list[i]);
        });
  }

  Widget _buildRow(Map<String, dynamic> data) {
    IconData cateIcon;
    try {
      cateIcon = mapToIconData(_categoryIcon[data[DatabaseHelper.columnCateId]]);
    } on Exception catch (e) { debugPrint(e.toString()); }

    return CardTile(
      data: data,
      iconData: cateIcon,
      onCardPressed: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => BoughtDetails(id: data[DatabaseHelper.columnId], cateName: data[DatabaseHelper.columnCateName], iconData: cateIcon))).then((value) {
          query();
        });
      },
    );
  }

  // Database
  Future query() async {
    _list.clear();
    await dbHelper.boughtListQuery().then((notes) {
      notes.forEach((note) {
        _list.add(note);
      });
    });
    _list.sort((a,b) => b[DatabaseHelper.columnBuyDate].compareTo(a[DatabaseHelper.columnBuyDate]));
    if(_list.isNotEmpty){
      isPageBlank = false;
      await dbHelper.queryAllRows(DatabaseHelper.table_categoriesIcon).then((list) {
        list.forEach((item) {
          bool mtd;
          if(item['matchTextDirection'] == '0') mtd = false;
          else mtd = true;
          Map<String, dynamic> justIcon = {
            'codePoint' : int.parse(item['codePoint']),
            'fontFamily' : item['fontFamily'].toString(),
            'fontPackage' : item['fontPackage'].toString(),
            'matchTextDirection' : mtd
          };
          justIcon.remove(DatabaseHelper.columnCateId);
          _categoryIcon[item[DatabaseHelper.columnCateId]] = justIcon;
        });
      });
    }
    else{
      isPageBlank = true;
      pageBlank = 'No bought list';
    }
    debugPrint('BoughtList Query Successful');
    setState(() {});
  }
}