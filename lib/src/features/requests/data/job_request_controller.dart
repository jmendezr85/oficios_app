import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/job_request.dart';
import 'job_request_api.dart';

/// Controller that manages job requests and delegates persistence to the
/// backend API. It keeps the current list in memory and can be extended with a
/// local cache if offline support is required.
class JobRequestController extends StateNotifier<List<JobRequest>> {
  JobRequestController() : super(const []);

  Future<void> reload({String? status}) async {
    final list = await JobRequestApi.list(status: status);
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
    await JobRequestApi.create(
      serviceId: serviceId,
      clientName: clientName,
      clientPhone: clientPhone,
      descripcion: descripcion,
      ciudad: ciudad,
      scheduledAt: scheduledAt,
    );
    await reload();
  }

  Future<void> setStatus(String id, String status) async {
    await JobRequestApi.updateStatus(id: id, status: status);
    state = state
        .map((r) => r.id == id ? r.copyWith(status: status) : r)
        .toList();
  }
}

// Provider
final jobRequestControllerProvider =
    StateNotifierProvider<JobRequestController, List<JobRequest>>(
      (ref) => JobRequestController(),
    );
