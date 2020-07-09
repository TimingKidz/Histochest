import 'package:buyinglist/Pages/settings.dart';
import 'package:buyinglist/Pages/categoriesManaging.dart';
import 'package:buyinglist/FormPages/infoForm.dart';
import 'package:flutter/material.dart';
import 'package:buyinglist/FormPages/categoriesSelect.dart';
import 'package:flutter/services.dart';

import 'CustomItems/animatedBottomBar.dart';
import 'Pages/boughtList.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(

    // statusBarColor is used to set Status bar color in Android devices.
    statusBarColor: Colors.transparent,

    // To make Status bar icons color white in Android devices.
    statusBarIconBrightness: Brightness.light,

    // statusBarBrightness is used to set Status bar icon color in iOS.
    statusBarBrightness: Brightness.light,
    // Here light means dark color Status bar icons.

    systemNavigationBarColor: Colors.transparent,

  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
        appBarTheme: AppBarTheme(
          elevation: 0.0
        )
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => BottomBarNavigation(),
        '/boughtList': (context) => BoughtList(),
        '/categoriesSelect': (context) => CategoriesSelect(),
        '/infoForm': (context) => InfoForm(),
      },
//      home: BoughtList(),
    );
  }
}

class BottomBarNavigation extends StatefulWidget {
  final List<BarItem> barItems = [
    BarItem(
      text: "Home",
      iconData: Icons.home,
      color: Colors.blueAccent,
    ),
//    BarItem(
//      text: "Bookmarks",
//      iconData: Icons.bookmark_border,
//      color: Colors.brown,
//    ),
    BarItem(
      text: "Categories",
      iconData: Icons.category,
      color: Colors.indigo,
    ),
    BarItem(
      text: "Setting",
      iconData: Icons.settings,
      color: Colors.teal,
    ),
  ];

  @override
  _BottomBarNavigationState createState() =>
      _BottomBarNavigationState();
}

class _BottomBarNavigationState extends State<BottomBarNavigation> {
  int selectedBarIndex = 0;

  final List<Widget> pageRoute = [
    BoughtList(),
    CategoriesManaging(),
    Settings()
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageRoute[selectedBarIndex],
      bottomNavigationBar: AnimatedBottomBar(
          barItems: widget.barItems,
          animationDuration: const Duration(milliseconds: 150),
          barStyle: BarStyle(
              fontSize: 16.0,
              iconSize: 24.0
          ),
          onBarTap: (index) {
            setState(() {
              selectedBarIndex = index;
            });
          },
          onActionButtonPressed: () {
            Navigator.pushNamed(context, '/categoriesSelect').then((value) {
              BoughtList.boughtListKey.currentState.query();
            });
          },
        ),
    );
  }
}