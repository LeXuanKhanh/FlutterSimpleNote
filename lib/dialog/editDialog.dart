import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_simple_note/model/noteItem.dart';

//dialog for adding infomation of the item
class EditDialog extends StatefulWidget {
  NoteItem Item;
  EditDialog({Key key, @required this.Item}) : super(key: key);

  @override
  EditDialogState createState() => new EditDialogState(Item);
  

}

class EditDialogState extends State<EditDialog> {
  NoteItem stateItem;
  EditDialogState(this.stateItem);


  TextStyle titleStyle = new TextStyle(
    fontSize: 20.0,
    color: Colors.red,
    fontWeight:  FontWeight.bold,);

  final myControllerTitle = TextEditingController();
  final myControllerContent = TextEditingController();



  @override
  void initState() {
    _date = stateItem.datetime;
    _time = TimeOfDay(hour: stateItem.datetime.hour, minute: stateItem.datetime.minute);
    _currentNoteKind = stateItem.kind;
    myControllerTitle.text = stateItem.title;
    myControllerContent.text = stateItem.content;

    _dropDownMenuItems = getDropDownMenuItems();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is dispose
    myControllerTitle.dispose();
    myControllerContent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Add new note'),
        actions: [
          new FlatButton(
              onPressed: () {
                //TODO: Handle save
                Navigator
                    .of(context)
                    .pop(new NoteItem(myControllerTitle.text,myControllerContent.text,DateTime(_date.year,_date.month,_date.day,_time.hour,_time.minute),_currentNoteKind));
              },
              child: new Text('SAVE',
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white))),
        ],
      ),
      body: Column(
        children: <Widget>[
          new ListTile(
            leading: Container(
              width: 80.0,
              child: new Text('Title:',style: titleStyle),
            ),
            title: new TextField(
              decoration: new InputDecoration(
                hintText: 'title',
              ),
              controller: myControllerTitle,
            ),
          ),
          new ListTile(
            leading: Container(
              width: 80.0,
              child: new Text('Content:',style: titleStyle),
            ),
            title: new TextField(
              maxLines: 5,
              decoration: new InputDecoration(
                hintText: 'content',
              ),
              controller: myControllerContent,
            ),
          ),
          new ListTile(
            leading: new Text('Date Finished:',style: titleStyle),
            title: new RaisedButton(
                child: new Text('${formatter.format(_date)}'),
                onPressed:(){selectDate(context);}),
          ),
          new ListTile(
            leading: new Text('Time Finished:',style: titleStyle),
            title: new RaisedButton(
                child: new Text('${_time.hour}:${_time.minute}'),
                onPressed:(){selectTime(context);}),
          ),
          new ListTile(
              leading: new Text('Note Kind',style: titleStyle),
              title: new DropdownButton(
                value: _currentNoteKind,
                items: _dropDownMenuItems,
                onChanged: changedDropDownItem,
              )
          ),
        ],
      ),
    );
  }

  /*Begin DateTimePicker*/
  DateTime _date = new DateTime.now();
  TimeOfDay _time = new TimeOfDay.now();
  DateFormat formatter = new DateFormat('EEEE, dd/MM/y');

  Future<Null> selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: stateItem.datetime,
        firstDate: new DateTime(2018),
        lastDate: new DateTime(9999)
    );

    if (picked != null && picked != _date){
      print('Date Selected: ${picked.toString()}');
      setState((){
        _date = picked;
      });
    }
  }
  Future<Null> selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: stateItem.datetime.hour, minute: stateItem.datetime.minute));

    if (picked != null && picked != _time){
      print('Time Selected: ${picked.hour} : ${picked.minute}');
      setState((){
        _time = picked;
      });
    }
  }
  /*End DateTimePicker*/

  /*Begin Dropdown Button*/
  List _noteKinds = ["work", "home"];
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentNoteKind;

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String noteKind in _noteKinds) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(new DropdownMenuItem(
          value: noteKind,
          child: new Text(noteKind)
      ));
    }
    return items;
  }

  void changedDropDownItem(String selectedKind) {
    print("Selected $selectedKind, we are going to refresh the UI");
    setState(() {
      _currentNoteKind = selectedKind;
    });
  }
/*End Dropdown Button*/


}