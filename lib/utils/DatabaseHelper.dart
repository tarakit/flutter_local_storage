import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/car.dart';

class DataBaseHelper {

    static const String databaseName = 'cardb.db';
    static const int databaseVersion = 1;
    static const String tableName = 'car_table';

    static const String columnId = 'id';
    static const String columnName = 'name';
    static const String columnMiles = 'miles';

    // create a private constructor to use in DatabaseHelper class
    DataBaseHelper._privateConstructor();
    static final DataBaseHelper instance = DataBaseHelper._privateConstructor();

    Future<Database?> get database async {
      return await _initDatabase();
    }

  _initDatabase() async{
        String path = join(await getDatabasesPath(), databaseName);
        return await openDatabase(path,
        version: databaseVersion,
        onCreate: _onCreate);
  }

    Future<void> _onCreate(Database db, int version) async {
      return await db.execute('''
           CREATE TABLE $tableName(
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnName TEXT NOT NULL,
            $columnMiles INTEGER NOT NULL
           )
        ''');
    }

    Future<int?> insert(Car car) async {
      Database? db = await instance!.database;
      return await db?.insert(tableName, {'name': car.name, 'miles': car.miles});
    }

    // Query All Row of Car
    Future<List<Map<String, dynamic>>?> queryAllRows() async {
      Database? db = await instance!.database;
      return await db?.query(tableName);
    }

    // Query By Car's Name
    Future<List<Map<String, dynamic>>?> queryByCarName(name) async {
      Database? db = await instance.database;
      return await db?.query(tableName, where: "$columnName LIKE '%$name%'");
    }

    Future<int?> updateCarById(Car car) async{
      Database? db = await instance.database;
      return await db?.update(tableName, car.toMap() , where: "$columnId= ?", whereArgs: [car.id]);
    }

    Future<int?> deleteCarById(id) async {
      Database? db = await instance.database;
      return await db?.delete(tableName, where: "$columnId = ?", whereArgs: [id]);
    }
}









