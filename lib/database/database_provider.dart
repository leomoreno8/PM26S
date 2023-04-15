import 'package:flutter/cupertino.dart';
import 'package:turistico/model/ponto.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static const _dbName = 'pontos_turisticos.db';
  static const _dbVersion = 2;

  DatabaseProvider._init();
  static final DatabaseProvider instance = DatabaseProvider._init();

  Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = '$databasesPath/$_dbName';
    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE ${Ponto.NOME_TABLE} (
        ${Ponto.CAMPO_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Ponto.CAMPO_NOME} TEXT NOT NULL,
        ${Ponto.CAMPO_DESCRICAO} TEXT NOT NULL,
        ${Ponto.CAMPO_DIFERENCIAIS} TEXT NOT NULL,
        ${Ponto.CAMPO_DATA} TEXT);
    ''');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
