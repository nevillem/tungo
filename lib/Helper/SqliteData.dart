import 'dart:async';
import 'dart:io';
import 'package:agritungotest/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

//this class use for connect with sql database and insert data and fetch data from database

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String CART_TABLE = 'tblcart';
  final String SAVEFORLATER_TABLE = 'tblsaveforlater';
  final String FAVORITE_TABLE = 'tblfavorite';
  final String FAVORITE_CROP_TABLE = 'tblfavoritecrops';

  final String PID = 'PID';
  final String VID = 'VID';
  final String QTY = 'QTY';
  final String CROP_SELECTED_ID = 'crop_selected_id';

  static Database? _db;

  DatabaseHelper.internal();

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  //connect with sql database
  Future<Database> initDb() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, 'agritungo.db');

    // Check if the database exists
    var exists = await databaseExists(path);
    if (!exists) {

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join('assets', 'agritungo.db'));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {

    }
    // open the database
    var db = await openDatabase(path, readOnly: false);

    return db;
  }

  Future<bool?> getFavById(String pid) async {
    bool count = false;
    final db1 = await db;
    var result = await db1!.rawQuery(
        'SELECT * FROM $FAVORITE_TABLE WHERE $PID = ?', [pid]);

    if (result.isNotEmpty) {
      count = true;
    }
    return count;
  }

  addAndRemoveFav(String pid, bool isAdd) async {
    final db1 = await db;
    if (isAdd) {
      addFavorite(pid);
    } else {

      db1!.rawQuery(
          'DELETE FROM $FAVORITE_TABLE WHERE $PID = $pid');

      getFav();
    }
  }

  // addAndRemoveCrop(String cid, bool isAdd) async {
  //   final db1 = await db;
  //   if (isAdd) {
  //     addFavoriteCrop(cid);
  //   } else {
  //     db1!.rawQuery(
  //         'DELETE FROM $FAVORITE_CROP_TABLE WHERE $CROP_SELECTED_ID = $cid');
  //   }
  //   getFavCrops();
  //
  // }
 removeCrop(String cid) async {
    final db1 = await db;
      db1!.rawQuery(
          'DELETE FROM $FAVORITE_CROP_TABLE WHERE $CROP_SELECTED_ID = $cid');
      getFavCrops();
  }

  addFavorite(String pid) async {
    final db1 = await db;
    Map<String, dynamic> row = {
      DatabaseHelper._instance.PID: pid,
    };
    db1!.insert(FAVORITE_TABLE, row);
  }

  addCrop(String cid) async {
      final db1 = await db;
      var result = await db1!.rawQuery(
          'SELECT * FROM $FAVORITE_CROP_TABLE WHERE $CROP_SELECTED_ID = ?', [cid]);
      if(result.isEmpty) {
        Map<String, dynamic> row = {
          DatabaseHelper._instance.CROP_SELECTED_ID: cid,
        };
        db1!.insert(FAVORITE_CROP_TABLE, row);
      }
      else{
       return "exists";
      }
      getFavCrops();

  }

  Future<List<Map>> getOffFav() async {
    final db1 = await db;

    List<Map> result =
    await db1!.query(DatabaseHelper._instance.FAVORITE_TABLE);

    return result;
  }

  Future<List<String>?> getFav() async {
    List<String> ids = [];
    final db1 = await db;

    List<Map> result =
    await db1!.query(DatabaseHelper._instance.FAVORITE_TABLE);

    for (var row in result) {
      ids.add(row[PID]);
    }
    return ids;
  }

  // Future<List<Map>> getFavCrops() async {
  //     final db1 = await db;
  //
  //   List<Map> result =
  //   await db1!.query(DatabaseHelper._instance.FAVORITE_CROP_TABLE);
  //
  //   return result;
  // }

  Future<List<int>?> getFavCrops() async {
    List<int> ids = [];
    final db1 = await db;

    List<Map> result = await db1!.query(DatabaseHelper._instance.FAVORITE_CROP_TABLE);

    for (var row in result) {
      ids.add(row[CROP_SELECTED_ID]);
    }
    return ids;
  }


  clearFav() async {
    final db1 = await db;
    db1!.execute('DELETE FROM $FAVORITE_TABLE');
  }

  //insert cart data in table
  insertCart(String pid,String qty, BuildContext context) async {
    var dbClient = await db;
    String? check;

    check = await checkCartItemExists(pid);

    if (check != '0') {
      updateCart(pid, qty);
    } else {
      String query =
          "INSERT INTO $CART_TABLE ($PID,$QTY) SELECT '$pid','$qty' WHERE NOT EXISTS(SELECT $PID FROM $CART_TABLE WHERE $PID = '$pid')";
      dbClient!.execute(query);
      await getTotalCartCount(context);
    }
  }

  updateCart(String pid,  String qty) async {
    final db1 = await db;
    Map<String, dynamic> row = {
      DatabaseHelper._instance.QTY: qty,
    };

    db1!.update(CART_TABLE, row,
        where: '$PID = ?', whereArgs: [pid]);
    //isCheck=true;
  }

  removeCart(String pid, BuildContext context) async {
    final db1 = await db;

    db1!.rawQuery(
        'DELETE FROM $CART_TABLE WHERE $PID = ?',
        [pid]);
    await getTotalCartCount(context);
  }

  clearCart() async {
    final db1 = await db;
    db1!.execute('DELETE FROM $CART_TABLE');
  }

  Future<String?> checkCartItemExists(String pid) async {
    final db1 = await db;
    var result = await db1!.rawQuery(
        'SELECT * FROM $CART_TABLE WHERE   $PID = ?',
        [pid]);
    if (result.isNotEmpty) {
      return result[0][QTY].toString();
    } else {
      return '0';
    }
  }

  /* Future<String?> getVID(String pid) async
  {
    String vid="";
    final db1 = await db;
    var result = await db1!.rawQuery(
        "SELECT * FROM " +
            CART_TABLE +
            " WHERE " +
            PID +
            " = ?",
        [pid]);
    vid=result![0][VID]!;
    return vid;

  }*/

  Future<List<String>?> getCart() async {
    List<String> ids = [];
    final db1 = await db;

    List<Map> result = await db1!.query(DatabaseHelper._instance.CART_TABLE);

    for (var row in result) {
      ids.add(row[PID]);
    }

    return ids;
  }

  getTotalCartCount(BuildContext context) async {
    final db1 = await db;

    List<Map> result = await db1!.query(DatabaseHelper._instance.CART_TABLE);

    context.read<UserProvider>().setCartCount(result.length.toString());
  }

  Future<List<Map>> getOffCart() async {
    final db1 = await db;

    List<Map> result = await db1!.query(DatabaseHelper._instance.CART_TABLE);

    return result;
  }

  Future<List<Map>> getOffSaveLater() async {
    final db1 = await db;

    List<Map> result =
    await db1!.query(DatabaseHelper._instance.SAVEFORLATER_TABLE);

    return result;
  }

  Future<List<String>?> getSaveForLater() async {
    List<String> ids = [];
    final db1 = await db;

    List<Map> result =
    await db1!.query(DatabaseHelper._instance.SAVEFORLATER_TABLE);

    for (var row in result) {
      ids.add(row[VID]);
    }

    return ids;
  }

  addToSaveForLater(String pid,  String qty) async {
    var dbClient = await db;
    /*  var result = await dbClient!.rawQuery(
        "SELECT * FROM " +
            CART_TABLE +
            " WHERE " +
            VID +
            " = ? AND " +
            PID +
            " = ?",
        [vid, pid]);
    if (result.isEmpty) {*/
    String query =
        "INSERT INTO $SAVEFORLATER_TABLE ($PID,$VID,$QTY) SELECT '$pid','$qty' WHERE NOT EXISTS(SELECT $PID FROM $CART_TABLE WHERE $PID = '$pid')";
    dbClient!.execute(query);
    // }
  }

  Future<String?> checkSaveForLaterExists(String pid) async {
    final db1 = await db;
    var result = await db1!.rawQuery(
        'SELECT * FROM $SAVEFORLATER_TABLE WHERE $PID = ?',
        [pid]);

    if (result.isNotEmpty) {
      return result[0][QTY].toString();
    } else {
      return '0';
    }
  }

  moveToCartOrSaveLater(
      String from, String pid, BuildContext context) async {
    String? qty = '';
    if (from == 'cart') {
      qty = await checkCartItemExists(pid);
      addToSaveForLater(pid, qty!);
      await removeCart( pid, context);
    } else {
      qty = await checkSaveForLaterExists(pid);
      insertCart(pid, qty!, context);
      await removeSaveForLater( pid);
    }
  }

  removeSaveForLater(String pid) async {
    final db1 = await db;
    db1!.rawQuery(
        'DELETE FROM $SAVEFORLATER_TABLE WHERE   $PID = ?',
        [pid]);
  }

  clearSaveForLater() async {
    final db1 = await db;
    db1!.execute('DELETE FROM $SAVEFORLATER_TABLE');
  }

  //close connection of database
  Future close() async {
    var dbClient = await db;
    return dbClient!.close();
  }
}
