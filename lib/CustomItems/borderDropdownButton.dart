import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BorderDropdownButton extends StatefulWidget {
  final String labelText;
  final List<String> listItems;
  final Function onChanged;

  BorderDropdownButton({
    this.labelText,
    this.listItems,
    this.onChanged
  });

  @override
  BorderDropdownButtonState createState() => BorderDropdownButtonState();
}

class BorderDropdownButtonState extends State<BorderDropdownButton> {
  String dropdownValue;

  @override
  void initState() {
    dropdownValue = widget.listItems[0];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
            color: Colors.grey.shade500, style: BorderStyle.solid, width: 2.0),
      ),
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.labelText, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold))
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: dropdownValue,
              elevation: 16,
              style: TextStyle(color: Colors.black),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                  widget.onChanged(dropdownValue);
                });
              },
              items: widget.listItems
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}