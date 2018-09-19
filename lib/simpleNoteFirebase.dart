import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';
import 'package:flutter_simple_note/model/noteItem.dart';
import 'package:flutter_simple_note/dialog/addDialog.dart';
import 'package:flutter_simple_note/dialog/editDialog.dart';

class MySimpleNoteFirebase extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
      title: 'simpleNoteFirebase',
      theme: new ThemeData.light(),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  DateFormat formatter = new DateFormat('EEEE, dd/MM/y h:mm a');

  TextStyle titleStyle = new TextStyle(
    fontSize: 20.0,
    color: Colors.red,
    fontWeight: FontWeight.bold,);

  TextStyle contentStyle = new TextStyle(
    fontSize: 15.0,);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget _listItem(BuildContext context, DocumentSnapshot document){
    DateTime documentDatetime =  DateTime.parse(document['datetime']);
    return Column(
      children: <Widget>[
        Divider(height: 10.0),
        ListTile(
            title: Row(
              children: <Widget>[
                Text(
                  document['title'],
                  style: titleStyle,
                ),

              ],
            ),
            subtitle: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                          height: 80.0,
                          child: Text(
                            document['content'],
                            style: contentStyle,)
                      ),
                      Divider(height: 5.0),
                      Text(formatter.format(documentDatetime)),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    IconButton(
                        icon: new Icon(Icons.delete),
                        onPressed: () {
                          _deleteItem(document);
                        }),
                    IconButton(
                      icon: new Icon(Icons.edit),
                      onPressed: () {
                        NoteItem thisItem = new NoteItem(document['title'], document['content'], documentDatetime, document['kind']);
                        _openEditDialog(thisItem,document);
                      },
                    ),
                  ],
                ),
              ],
            ),
            leading: Column(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  radius: 35.0,
                  child: Text(
                    document['kind'],
                    style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
        ),
      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
          title: new Text("Simple Note Firebase"),
          actions: <Widget>[
            IconButton(icon: new Icon(Icons.add, color: Colors.white),
                onPressed: _openAddDialog)
          ],
        ),
        body: new Container(
          padding: const EdgeInsets.only(top: 10.0),
          alignment: Alignment.center,
          child: FutureBuilder(
              future: SharedPreferences.getInstance(),
              builder: (context,result){
                if (result.hasData){
                  SharedPreferences prefs = result.data;
                  if (prefs.getString('userEmail') == 'unknown email from SharedPreferences')
                    return new Text('you must log in to see online database');
                  else
                    return StreamBuilder(
                      stream: Firestore.instance.collection(prefs.getString('userEmail')).snapshots(),
                      builder: (context,AsyncSnapshot snapshot){
                        if (!snapshot.hasData)
                          return new Container(alignment: AlignmentDirectional.center,child: new CircularProgressIndicator(),);

                        return ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, position) => _listItem(context, snapshot.data.documents[position]),
                        );
                      }
                    );
                }
                else
                  return new Container(alignment: AlignmentDirectional.center,child: new CircularProgressIndicator(),);
          })
        ),
    );
  }

  Future _openAddDialog() async {
    NoteItem newItem = await Navigator.of(context).push(
        new MaterialPageRoute<NoteItem>(
            builder: (BuildContext context) {
              return new AddDialog();
            },
            fullscreenDialog: true
        ));

    if (newItem != null) {
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(Firestore.instance.collection("NoteItem").document(), {
          'title': newItem.title,
          'content': newItem.content,
          'datetime': newItem.datetime.toString(),
          'kind': newItem.kind
        });
      });
      _showSnackBar("Data added successfully");
    }
  }

  Future _openEditDialog(NoteItem item,DocumentSnapshot document) async {
    NoteItem newItem = await Navigator.of(context).push(
        new MaterialPageRoute<NoteItem>(
          builder: (BuildContext context) {
            return new EditDialog(Item: item);
          },
          fullscreenDialog: true,
        ));

    if (newItem != null) {
      Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap = await transaction.get(document.reference);
        await transaction.update(freshSnap.reference,{
          'title': newItem.title,
          'content': newItem.content,
          'datetime': newItem.datetime.toString(),
          'kind': newItem.kind
        });
      });
      _showSnackBar("Data edited successfully");
    }
  }


  void _deleteItem(DocumentSnapshot document){
    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(document.reference);
      await transaction.delete(freshSnap.reference);
    });
    _showSnackBar("Data deleted successfully");
  }

  //pop up snackbar with text
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }
}