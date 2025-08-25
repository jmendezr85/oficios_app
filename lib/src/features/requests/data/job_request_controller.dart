import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; // ✅ Asegúrate de tener la dependencia
import '../domain/job_request.dart';
import 'job_request_db.dart';

class JobRequestController extends StateNotifier<List<JobRequest>> {
  JobRequestController(this._db) : super(const []) {
    reload();
  }

  final JobRequestDb _db;

  Future<void> reload({String? status}) async {
    final list = await _db.getAll(status: status);
    state = list;
  }

  Future<void> create({
    required String serviceId,
    required String clientName,
    required String clientPhone,
    required String descripcion,
    required String ciudad,
    DateTime? scheduledAt,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final req = JobRequest(
      id: id,
      serviceId: serviceId,
      clientName: clientName,
      clientPhone: clientPhone,
      descripcion: descripcion,
      ciudad: ciudad,
      scheduledAt: scheduledAt,
      status: 'pending',
      creadoEn: now,
    );
    await _db.insert(req);
    state = [req, ...state];
  }

  Future<void> setStatus(String id, String status) async {
    await _db.updateStatus(id, status);
    state = state
        .map((r) => r.id == id ? r.copyWith(status: status) : r)
        .toList();
  }
}

// Providers
final jobRequestDbProvider = Provider<JobRequestDb>((ref) => JobRequestDb());

final jobRequestControllerProvider =
    StateNotifierProvider<JobRequestController, List<JobRequest>>(
      (ref) => JobRequestController(ref.read(jobRequestDbProvider)),
    );
