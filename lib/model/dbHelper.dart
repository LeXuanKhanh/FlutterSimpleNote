import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'noteItem.dart';

class DBHelper{

  static Database _db;

  //detect if database exist or not whenever create new DBHelper
  Future<Database> get db async {
    if(_db != null)
      return _db;
    _db = await initDb();
    return _db;
  }

  //Creating a database with name simplenote.db in your directory
  //android: /data/user/0/com.atom.flutterapp/app_flutter/simplenote.db
  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "simplenote.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    print("created database");
    return theDb;
  }

  // Creating a table name NoteItem with fields
  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE NoteItem(id INTEGER PRIMARY KEY, title TEXT, content TEXT, date Text, time Text, kind TEXT)");
    print("Created tables");
  }

  // Retrieving noteitem from NoteItem Tables
  Future<List<NoteItem>> getItem() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM NoteItem');
    List<NoteItem> items = new List();
    print( "this is database data ");
    for (int i = 0; i < list.length; i++) {
      NoteItem newItem = new NoteItem(list[i]["title"], list[i]["content"], DateTime.parse(list[i]["date"]), list[i]["kind"]);
      items.add(newItem);
      print(newItem.title + ' || ' + newItem.content + " || " + newItem.datetime.toString() + " || " + newItem.kind);
    }
    return  items;
  }

  //add an item to database
  void saveItem(NoteItem noteitem) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO NoteItem(title, content, date, kind ) VALUES(' +
              '\'' +
              noteitem.title +
              '\'' +
              ',' +
              '\'' +
              noteitem.content +
              '\'' +
              ',' +
              '\'' +
              noteitem.datetime.toString() +
              '\'' +
              ',' +
              '\'' +
              noteitem.kind +
              '\'' +
              ')');
    });
    print("added");
  }

  //edit an item in database
  void editItem(NoteItem noteitem, int position) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'UPDATE NoteItem SET title = ?, content = ?, date = ?, kind = ? WHERE id = ?',
          [noteitem.title, noteitem.content,  noteitem.datetime.toString(),noteitem.kind,position+1]);
    });
    print("edited");
  }

  //delete an item in database
  void deleteItem(int position) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'DELETE FROM NoteItem WHERE id = ?',
          [position+1]);
    });
    print("deleted");
  }
}