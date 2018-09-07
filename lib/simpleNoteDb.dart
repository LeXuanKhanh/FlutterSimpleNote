import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_simple_note/model/noteItem.dart';
import 'package:flutter_simple_note/dialog/addDialog.dart';
import 'package:flutter_simple_note/dialog/editDialog.dart';
import 'package:flutter_simple_note/model/dbHelper.dart';

//this is simple note using database

class MySimpleNoteDb extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
      title: 'simpleNoteDatabase',
      theme: new ThemeData.light(),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{

  //format datetime display in item
  DateFormat formatter = new DateFormat('EEEE, dd/MM/y h:mm a ');

  //style of the title display in item
  TextStyle titleStyle = new TextStyle(
    fontSize: 20.0,
    color: Colors.blue,
    fontWeight:  FontWeight.bold,);

  //style of the content display in item
  TextStyle contentStyle = new TextStyle(
    fontSize: 15.0,);

  //call dbHelper to interact with database
  var dbHelper = DBHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
          title: new Text("Simple Note Database"),
          actions: <Widget>[
            //ADD BUTTON
            IconButton(icon: new Icon(Icons.add,color: Colors.white),
                onPressed: _openAddDialog)
          ],
        ),
        body: new Container(
            padding: const EdgeInsets.only(top: 10.0),
            child: new FutureBuilder<List<NoteItem>>(
              future: _getData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      padding: const EdgeInsets.all(15.0),
                      itemBuilder: (context,position){
                        return Column(
                          children: <Widget>[
                            Divider(height: 10.0),
                            ListTile(
                                title: Row(
                                  children: <Widget>[
                                    //TITLE
                                    Text(
                                      snapshot.data[position].title,
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
                                              //CONTENT
                                              child: Text(snapshot.data[position].content, style: contentStyle,)
                                          ),
                                          Divider(height: 5.0),
                                          //DATETIME
                                          Text(formatter.format(snapshot.data[position].datetime)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: <Widget>[
                                        //DELETE BUTTON
                                        IconButton(
                                            icon: new Icon(Icons.delete),
                                            onPressed: (){
                                              _deleteItem(position);
                                              setState(() {
                                                snapshot.data.removeAt(position);
                                              });
                                            }),
                                        //EDIT BUTTON
                                        IconButton(
                                          icon: new Icon(Icons.edit),
                                          onPressed: (){
                                            _openEditDialog(snapshot.data,position);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                leading: Column(
                                  children: <Widget>[
                                    //Kind text in round avatar
                                    CircleAvatar(
                                      backgroundColor: Colors.blueAccent,
                                      radius: 35.0,
                                      child: Text(
                                        snapshot.data[position].kind,
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
                      });
                }
                // show loading screen while getting data
                return new Container(alignment: AlignmentDirectional.center,child: new CircularProgressIndicator(),);
              },
            ),
        ),
    );
  }

  //Open item add dialog
  Future _openAddDialog() async{
    NoteItem newItem = await Navigator.of(context).push(new MaterialPageRoute<NoteItem>(
        builder: (BuildContext context) {
          return new AddDialog();
        },
        fullscreenDialog: true
    ));

    if (newItem != null){
      dbHelper.saveItem(newItem);
      _showSnackBar("Data saved successfully");
    }

  }

  //Open item edit dialog
  Future _openEditDialog(List<NoteItem> items,int position) async{
    NoteItem editItem = await Navigator.of(context).push(new MaterialPageRoute<NoteItem>(
      builder: (BuildContext context) {
        NoteItem item = items[position];
        return new EditDialog(Item: item);
      },
      fullscreenDialog: true,
    ));

    if (editItem != null){
      dbHelper.editItem(editItem,position);
      _showSnackBar("Data edited successfully");
    }

  }

  //delete item
  void _deleteItem(int position){
    dbHelper.deleteItem(position);
    _showSnackBar("Data deleted successfully");
  }

  //get data from database
  Future<List<NoteItem>> _getData() async {
    Future<List<NoteItem>> items = dbHelper.getItem();
    return items;
  }

  //pop up snackbar with text
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }
}







