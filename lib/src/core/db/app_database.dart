import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _dbName = 'oficios.db';
  static const _dbVersion = 3; // ⬅️ subimos versión

  static Database? _instance;

  static Future<Database> get database async {
    final existing = _instance;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    _instance = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        // v1: tabla services
        await db.execute('''
          CREATE TABLE services(
            id TEXT PRIMARY KEY,
            titulo TEXT NOT NULL,
            categoria TEXT NOT NULL,
            ciudad TEXT NOT NULL,
            precio_por_hora REAL NOT NULL,
            descripcion TEXT NOT NULL,
            disponible INTEGER NOT NULL,
            creado_en TEXT NOT NULL
          );
        ''');
        await db.execute(
          'CREATE INDEX idx_services_categoria ON services(categoria);',
        );
        await db.execute(
          'CREATE INDEX idx_services_ciudad ON services(ciudad);',
        );
        await db.execute(
          'CREATE INDEX idx_services_disponible ON services(disponible);',
        );

        // v2: tabla job_requests
        await _createJobRequests(db);

        // v3: tabla sync_meta
        await _createSyncMeta(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createJobRequests(db);
        }
        if (oldVersion < 3) {
          await _createSyncMeta(db);
        }
      },
    );

    return _instance!;
  }
}

Future<void> _createJobRequests(Database db) async {
  await db.execute('''
    CREATE TABLE job_requests(
      id TEXT PRIMARY KEY,
      service_id TEXT NOT NULL,
      client_name TEXT NOT NULL,
      client_phone TEXT NOT NULL,
      descripcion TEXT NOT NULL,
      ciudad TEXT NOT NULL,
      scheduled_at TEXT,               -- puede ser null
      status TEXT NOT NULL,            -- pending/accepted/rejected/completed
      creado_en TEXT NOT NULL,
      FOREIGN KEY(service_id) REFERENCES services(id)
    );
  ''');
  await db.execute(
    'CREATE INDEX idx_requests_service ON job_requests(service_id);',
  );
  await db.execute('CREATE INDEX idx_requests_status ON job_requests(status);');
  await db.execute('CREATE INDEX idx_requests_ciudad ON job_requests(ciudad);');
}

Future<void> _createSyncMeta(Database db) async {
  await db.execute('''
    CREATE TABLE sync_meta(
      table_name TEXT PRIMARY KEY,
      last_sync TEXT
    );
  ''');
}

/// Guarda la fecha/hora del último sincronizado para [table].
Future<void> setLastSync(String table, DateTime moment) async {
  final db = await AppDatabase.database;
  await db.insert('sync_meta', {
    'table_name': table,
    'last_sync': moment.toIso8601String(),
  }, conflictAlgorithm: ConflictAlgorithm.replace);
}

/// Obtiene la fecha/hora del último sincronizado para [table].
Future<DateTime?> getLastSync(String table) async {
  final db = await AppDatabase.database;
  final res = await db.query(
    'sync_meta',
    where: 'table_name = ?',
    whereArgs: [table],
    limit: 1,
  );
  if (res.isEmpty) return null;
  final value = res.first['last_sync'] as String?;
  return value != null ? DateTime.parse(value) : null;
}
