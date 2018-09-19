import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'model/dbHelper.dart';
import 'model/noteItem.dart';


class SyncDatabase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String str ='a';
  var dbHelper = DBHelper();

  //get firestore data to list
  Future<List<NoteItem>> _getDataFromFireStore() async {
    QuerySnapshot querySnapshot = await Firestore.instance.collection("NoteItem").getDocuments();
    var raw = querySnapshot.documents;
    List<NoteItem> items = new List();

    print('this is firestore');
    for (int i = 0; i < raw.length; i++) {
      NoteItem newItem = new NoteItem(raw[i]["title"], raw[i]["content"], DateTime.parse(raw[i]["datetime"]), raw[i]["kind"]);
      items.add(newItem);
      print(newItem.title + ' || ' + newItem.content + " || " + newItem.datetime.toString() + " || " + newItem.kind);
    }
    return  items;
  }

  //get database data to list
  Future<List<NoteItem>> _getDataFromDatabase() async {
    Future<List<NoteItem>> items = dbHelper.getItem();
    return items;
  }

  Future compare() async{
    //get firestore and database data into list for comparing
    List<NoteItem> firestore = await _getDataFromFireStore();
    List<NoteItem> database = await _getDataFromDatabase();

    //comparing, if  a item is identical then remove it, leave only those different items
    for (int i = 0; i < firestore.length; i++){
      bool Equal = false;
      int j = 0;
      for (j = 0; j < database.length; j++)
        if (  ( firestore[i].title == database[j].title )
            && ( firestore[i].content == database[j].content )
            && ( firestore[i].datetime.toString() == database[j].datetime.toString() )
            && ( firestore[i].kind == database[j].kind ) ){

          Equal = true;
          break;

        }
      if  (Equal == true) {
        firestore.removeAt(i);
        database.removeAt(j);
      }
    }

    //print remaining items after compare
    print('\nthis is firestore not equal to database');
    for (int i = 0; i < firestore.length; i++)
      print(firestore[i].title + ' || ' + firestore[i].content + ' || ' + firestore[i].datetime.toString() + ' || ' + firestore[i].kind);

    print('this is database not equal to firestore');
    for (int i = 0; i < database.length; i++)
      print(database[i].title + ' || ' + database[i].content + ' || '  + database[i].datetime.toString() + ' || ' + database[i].kind);

    //syncing firebase data to database data
    for (int i = 0; i < firestore.length; i++)
      dbHelper.saveItem(firestore[i]);

    //syncting database data to firebase data
    for (int i = 0; i < database.length; i++)
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(Firestore.instance.collection("NoteItem").document(), {
          'title': database[i].title,
          'content': database[i].content,
          'datetime': database[i].datetime.toString(),
          'kind': database[i].kind
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(
        children: <Widget>[
          new ListTile(
            title: new Text('Firebase Data'),
            trailing: new RaisedButton(
              child: new Text("get"),
              onPressed: _getDataFromFireStore,
            ),
          ),
          new ListTile(
            title: new Text('Database Data'),
            trailing: new RaisedButton(
              child: new Text("get"),
              onPressed: _getDataFromDatabase,
            ),
          ),
          new ListTile(
            title: new Text('Compare'),
            trailing: new RaisedButton(
              child: new Text("sync"),
              onPressed: compare,
            ),
          ),
        ],
      ),
    );
  }

}