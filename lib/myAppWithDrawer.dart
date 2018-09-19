import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'simpleNote.dart';
import 'simpleNoteDb.dart';
import 'simpleNoteFirebase.dart';
import 'syncDatabase.dart';
import 'loginScreen.dart';

class MyAppWithDrawer extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class DrawerItem {
  String title;
  DrawerItem(this.title);
}

class MyHomePage extends StatefulWidget {

  String title = "Simple Note No Database";

  final drawerItems = [
    new DrawerItem("Simple Note No Database"),
    new DrawerItem("Simple Note Database"),
    new DrawerItem("Simple Note Firebase"),
    new DrawerItem("Simple Note Sync"),
    new DrawerItem('Test'),
  ];

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new MySimpleNote();
      case 1:
        return new MySimpleNoteDb();
      case 2:
        return new MySimpleNoteFirebase();
      case 3:
        return new SyncDatabase();
      case 4:
        return new LoginScreen();
      default:
        return new Text("Error");
  }
  }

  _onSelectItem(int index) {
    setState(() {
      _selectedDrawerIndex = index;
      widget.title = widget.drawerItems[index].title;
    });
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(
          new ListTile(
            title: new Text(d.title),
            selected: i == _selectedDrawerIndex,
            onTap: () => _onSelectItem(i),
          )
      );
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),

      drawer: new Drawer(
        child: new Column(
          children: <Widget>[
            new FutureBuilder(
                future: SharedPreferences.getInstance(),
                builder: (context,snapshot){
                  if (snapshot.hasData){
                    SharedPreferences prefs = snapshot.data;
                    if (prefs.getString('userAvatarUrl') != '')
                      return UserAccountsDrawerHeader(
                        accountName: new Text(prefs.getString("userDisplayName")),
                        accountEmail: new Text(prefs.getString("userEmail")),
                        currentAccountPicture: new CircleAvatar( backgroundImage: new NetworkImage(prefs.getString("userAvatarUrl")) ),
                      );
                    else
                      return UserAccountsDrawerHeader(
                        accountName: new Text(prefs.getString("userDisplayName")),
                        accountEmail: new Text(prefs.getString("userEmail")),
                        currentAccountPicture: new CircleAvatar( backgroundImage: new AssetImage('assets/avatar.png') ),
                      );
                  }
                  else
                    return UserAccountsDrawerHeader(
                      accountName: new Text('loading...'),
                      accountEmail: new Text('loading...'),
                      currentAccountPicture: new CircleAvatar( backgroundImage: new AssetImage('assets/avatar.png') ),
                    );
                }
            ),
            new Column(children: drawerOptions)
          ],
        ),
      ),

      body: _getDrawerItemWidget(_selectedDrawerIndex),
    );
  }
}