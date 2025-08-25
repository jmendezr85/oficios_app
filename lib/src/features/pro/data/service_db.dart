import 'package:sqflite/sqflite.dart';
import '../../../core/db/app_database.dart';
import '../domain/service.dart';
import '../../search/domain/search_filters.dart';

class ServiceDb {
  static const _table = 'services';
  Future<Database> get _db async => AppDatabase.database;

  Map<String, dynamic> _toRow(Service s) => {
    'id': s.id,
    'titulo': s.titulo,
    'categoria': s.categoria,
    'ciudad': s.ciudad,
    'precio_por_hora': s.precioPorHora,
    'descripcion': s.descripcion,
    'disponible': s.disponible ? 1 : 0,
    'creado_en': s.creadoEn.toIso8601String(),
  };

  Service _fromRow(Map<String, dynamic> m) {
    return Service(
      id: m['id'] as String,
      titulo: m['titulo'] as String,
      categoria: m['categoria'] as String,
      ciudad: m['ciudad'] as String,
      precioPorHora: (m['precio_por_hora'] as num).toDouble(),
      descripcion: m['descripcion'] as String,
      disponible: (m['disponible'] as int) == 1,
      creadoEn: DateTime.parse(m['creado_en'] as String),
    );
  }

  Future<List<Service>> getAll() async {
    final db = await _db;
    final rows = await db.query(_table, orderBy: 'datetime(creado_en) DESC');
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<void> insert(Service s) async {
    final db = await _db;
    await db.insert(
      _table,
      _toRow(s),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateDisponible(String id, bool disponible) async {
    final db = await _db;
    await db.update(
      _table,
      {'disponible': disponible ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isEmpty() async {
    final db = await _db;
    final res = await db.rawQuery('SELECT COUNT(*) as c FROM $_table');
    final count = (res.first['c'] as int?) ?? 0;
    return count == 0;
  }

  Future<void> insertMany(List<Service> list) async {
    if (list.isEmpty) return;
    final db = await _db;
    await db.transaction((txn) async {
      for (final s in list) {
        await txn.insert(
          _table,
          _toRow(s),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  String _orderByFor(SortBy sortBy) => switch (sortBy) {
    SortBy.precioAsc => 'precio_por_hora ASC, datetime(creado_en) DESC',
    SortBy.precioDesc => 'precio_por_hora DESC, datetime(creado_en) DESC',
    SortBy.recientes => 'datetime(creado_en) DESC',
  };

  /// Búsqueda con filtros (paginada y orden configurable)
  Future<List<Service>> search(SearchFilters f) async {
    final db = await _db;
    final where = <String>[];
    final args = <Object?>[];

    if (f.query != null && f.query!.trim().isNotEmpty) {
      final q = '%${f.query!.trim().toLowerCase()}%';
      where.add(
        '(LOWER(titulo) LIKE ? OR LOWER(categoria) LIKE ? OR LOWER(ciudad) LIKE ?)',
      );
      args.addAll([q, q, q]);
    }
    if (f.categoria != null && f.categoria!.trim().isNotEmpty) {
      where.add('LOWER(categoria) = ?');
      args.add(f.categoria!.trim().toLowerCase());
    }
    if (f.ciudad != null && f.ciudad!.trim().isNotEmpty) {
      where.add('LOWER(ciudad) = ?');
      args.add(f.ciudad!.trim().toLowerCase());
    }
    if (f.disponible != null) {
      where.add('disponible = ?');
      args.add(f.disponible! ? 1 : 0);
    }
    if (f.minPrecio != null) {
      where.add('precio_por_hora >= ?');
      args.add(f.minPrecio);
    }
    if (f.maxPrecio != null) {
      where.add('precio_por_hora <= ?');
      args.add(f.maxPrecio);
    }

    final whereClause = where.isEmpty ? null : where.join(' AND ');
    final orderBy = _orderByFor(f.sortBy);

    final rows = await db.query(
      _table,
      where: whereClause,
      whereArgs: args,
      orderBy: orderBy,
      limit: f.limit,
      offset: f.offset,
    );

    return rows.map(_fromRow).toList(growable: false);
  }

  /// (Opcional) seed de datos demo
  Future<void> seedDemoIfEmpty() async {
    if (!await isEmpty()) return;
    final now = DateTime.now();
    final demo = <Service>[
      Service(
        id: 's1',
        titulo: 'Instalación de enchufes y luminarias',
        categoria: 'Electricista',
        ciudad: 'Bogotá',
        precioPorHora: 60000,
        descripcion: 'Más de 5 años de experiencia residencial.',
        disponible: true,
        creadoEn: now,
      ),
      Service(
        id: 's2',
        titulo: 'Muebles a medida en MDF',
        categoria: 'Carpintero',
        ciudad: 'Medellín',
        precioPorHora: 80000,
        descripcion: 'Closets, cocinas, puertas. Trabajo garantizado.',
        disponible: true,
        creadoEn: now.subtract(const Duration(hours: 2)),
      ),
      Service(
        id: 's3',
        titulo: 'Reparación de fugas y grifería',
        categoria: 'Plomero',
        ciudad: 'Cali',
        precioPorHora: 50000,
        descripcion: 'Rápido y limpio. Materiales incluidos según el caso.',
        disponible: false,
        creadoEn: now.subtract(const Duration(days: 1)),
      ),
      Service(
        id: 's4',
        titulo: 'Mecánico a domicilio - diagnóstico',
        categoria: 'Mecánico',
        ciudad: 'Bogotá',
        precioPorHora: 70000,
        descripcion: 'Scanner, cambios de aceite, frenos.',
        disponible: true,
        creadoEn: now.subtract(const Duration(days: 2)),
      ),
    ];
    await insertMany(demo);
  }
}
