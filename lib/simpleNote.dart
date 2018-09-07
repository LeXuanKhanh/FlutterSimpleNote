import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_simple_note/model/noteItem.dart';
import 'package:flutter_simple_note/dialog/addDialog.dart';
import 'package:flutter_simple_note/dialog/editDialog.dart';

//this simple note without using any database
class MySimpleNote extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
      title: 'simpleNote',
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
  List<NoteItem> items = new List();

  DateFormat formatter = new DateFormat('EEEE, dd/MM/y');

  TextStyle titleStyle = new TextStyle(
    fontSize: 20.0,
    color: Colors.red,
    fontWeight:  FontWeight.bold,);

  TextStyle contentStyle = new TextStyle(
    fontSize: 15.0,);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      items.add( new NoteItem('hello 1','this is item 1 ',DateTime(2018,12,2,2,19),'home'));
      items.add( new NoteItem('hello 2','this is item 2',DateTime(2018,12,12,2,20),'work'));
      items.add( new NoteItem('hello 3 ','this is item 3 ',DateTime(2018,12,21,2,21),'work'));
      items.add( new NoteItem('hello 4','this is item 4 ',DateTime(2018,10,30,2,22),'home'));
      items.add( new NoteItem('hello 5','this is item 5 ',DateTime(2018,11,21,2,23),'work'));
    });
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Simple Note"),
        actions: <Widget>[
          IconButton(icon: new Icon(Icons.add,color: Colors.white),
              onPressed: _openAddDialog)
        ],
      ),
      body: new Container(
          padding: const EdgeInsets.only(top: 10.0),
          child: new Container(
          alignment: Alignment.center,
          child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.all(15.0),
              itemBuilder: (context,position){
                return Column(
                  children: <Widget>[
                    Divider(height: 10.0),
                    ListTile(
                      title: Row(
                        children: <Widget>[
                          Text(
                            '${items[position].title}',
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
                                    child: Text('${items[position].content}', style: contentStyle,)
                                ),
                                Divider(height: 5.0),
                                Text(' ${formatter.format(items[position].datetime)} ${items[position].datetime.hour}:${items[position].datetime.minute}'),
                              ],
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              IconButton(
                                  icon: new Icon(Icons.delete),
                                  onPressed: (){
                                    setState(() {
                                      items.removeAt(position);
                                    });
                                  }),
                              IconButton(
                                icon: new Icon(Icons.edit),
                                onPressed: (){
                                  _openEditDialog(position);
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
                              '${items[position].kind}',
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
          }),
        )
      )
    );
  }

  Future _openAddDialog() async{

    NoteItem newItem = await Navigator.of(context).push(new MaterialPageRoute<NoteItem>(
        builder: (BuildContext context) {
          return new AddDialog();
        },
        fullscreenDialog: true
    ));

    if (newItem != null){
      setState(() {
        items.add(newItem);
      });
    }
  }

  Future _openEditDialog(int position) async{

    NoteItem newItem = await Navigator.of(context).push(new MaterialPageRoute<NoteItem>(
        builder: (BuildContext context) {
          NoteItem item = items[position];
          return new EditDialog(Item: item);
        },
        fullscreenDialog: true,
    ));

    if (newItem != null){
      setState(() {
        items[position]=newItem;
      });
    }
  }

}







