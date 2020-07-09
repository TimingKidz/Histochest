import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BorderDetailsField extends StatefulWidget {
  final String labelText;
  final String text;

  BorderDetailsField({
    this.labelText,
    this.text
  });

  BorderDetailsFieldState createState() => BorderDetailsFieldState();
}

class BorderDetailsFieldState extends State<BorderDetailsField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
            color: Colors.grey.shade500, style: BorderStyle.solid, width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.labelText, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.0),
          Text(
              '${widget.text}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)
          ),
        ],
      ),
    );
  }

}