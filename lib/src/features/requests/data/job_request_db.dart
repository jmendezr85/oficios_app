import 'package:sqflite/sqflite.dart';
import '../../../core/db/app_database.dart';
import '../domain/job_request.dart';

class JobRequestDb {
  static const _table = 'job_requests';
  Future<Database> get _db async => AppDatabase.database;

  Map<String, dynamic> _toRow(JobRequest r) => {
    'id': r.id,
    'service_id': r.serviceId,
    'client_name': r.clientName,
    'client_phone': r.clientPhone,
    'descripcion': r.descripcion,
    'ciudad': r.ciudad,
    'scheduled_at': r.scheduledAt?.toIso8601String(),
    'status': r.status,
    'creado_en': r.creadoEn.toIso8601String(),
  };

  JobRequest _fromRow(Map<String, dynamic> m) => JobRequest(
    id: m['id'] as String,
    serviceId: m['service_id'] as String,
    clientName: m['client_name'] as String,
    clientPhone: m['client_phone'] as String,
    descripcion: m['descripcion'] as String,
    ciudad: m['ciudad'] as String,
    scheduledAt: (m['scheduled_at'] as String?) != null
        ? DateTime.parse(m['scheduled_at'] as String)
        : null,
    status: m['status'] as String,
    creadoEn: DateTime.parse(m['creado_en'] as String),
  );

  Future<void> insert(JobRequest r) async {
    final db = await _db;
    await db.insert(
      _table,
      _toRow(r),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<JobRequest>> getAll({String? status}) async {
    final db = await _db;
    final rows = await db.query(
      _table,
      where: status != null ? 'status = ?' : null,
      whereArgs: status != null ? [status] : null,
      orderBy: 'datetime(creado_en) DESC',
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<void> updateStatus(String id, String status) async {
    final db = await _db;
    await db.update(
      _table,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
