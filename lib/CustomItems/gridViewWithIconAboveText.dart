import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Serialization/iconDataSerialization.dart';

class GridViewWithIconAboveText extends StatefulWidget {
  final int columnCount;
  final List<String> nameList;
  final List<Map<String, dynamic>> iconMapList;
  final Function onGridTap;

  GridViewWithIconAboveText({
    this.columnCount,
    this.nameList,
    this.iconMapList,
    this.onGridTap
  });

  @override
  GridViewWithIconAboveTextState createState() => GridViewWithIconAboveTextState();
}

class GridViewWithIconAboveTextState extends State<GridViewWithIconAboveText> {
  int selectedCard;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: widget.columnCount,
      padding: const EdgeInsets.all(4.0),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      children: _getTiles(),
    );
  }

  List<Widget> _getTiles() {
    final List<Widget> tiles = <Widget>[];
    for (int i = 0; i < widget.nameList.length; i++) {
      IconData cate_icon;
      bool havingIconData = false;
      try {
        cate_icon = mapToIconData(widget.iconMapList[i]);
      } on Exception catch (e) { debugPrint(e.toString()); }
      if(cate_icon != null) havingIconData = true;
      tiles.add(
          GridTile(
              child: InkWell(
                enableFeedback: true,
//            child: Image.file(iconList[i], fit: BoxFit.cover,),
                child: Container(
                    color: selectedCard == i ? Colors.black12 : Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(havingIconData ? cate_icon : Icons.block, size: 48.0,), // icon
                        SizedBox(height: 8.0),
                        Text(widget.nameList[i], style: TextStyle(fontSize: 16.0),), // text
                      ],
                    )
                ),
                onTap: () {
                  setState(() {
                    if (selectedCard == i){
                      selectedCard = null;
                    }else{
                      selectedCard = i;
                    }
                    widget.onGridTap(selectedCard);
                    debugPrint(selectedCard.toString());
                  });
                },
              )
          )
      );
    }
    return tiles;
  }
}