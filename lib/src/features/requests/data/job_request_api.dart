import '../../../core/network/api_client.dart';
import '../domain/job_request.dart';

class JobRequestApi {
  static Future<String> create({
    required String serviceId,
    required String clientName,
    required String clientPhone,
    required String descripcion,
    required String ciudad,
    DateTime? scheduledAt,
  }) async {
    final res = await ApiClient.postJson('/requests', {
      'serviceId': serviceId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'descripcion': descripcion,
      'ciudad': ciudad,
      'scheduledAt': scheduledAt?.toIso8601String(),
    });
    return (res['id'] as String);
  }

  static Future<List<JobRequest>> list({String? status}) async {
    final qp = <String, String>{};
    if (status != null && status.isNotEmpty) qp['status'] = status;
    final json = await ApiClient.getJson('/requests', query: qp);
    final items = (json['items'] as List).cast<Map<String, dynamic>>();
    return items
        .map(
          (m) => JobRequest(
            id: m['id'] as String,
            serviceId: m['service_id'] as String,
            clientName: m['client_name'] as String,
            clientPhone: m['client_phone'] as String,
            descripcion: m['descripcion'] as String,
            ciudad: m['ciudad'] as String,
            scheduledAt: (m['scheduled_at'] == null)
                ? null
                : DateTime.parse(m['scheduled_at'] as String),
            status: m['status'] as String,
            creadoEn: DateTime.parse(m['creado_en'] as String),
          ),
        )
        .toList(growable: false);
  }

  static Future<List<JobRequest>> listByClientPhone(
    String phone, {
    String? status,
  }) async {
    final qp = <String, String>{'clientPhone': phone};
    if (status != null && status.isNotEmpty) {
      qp['status'] = status;
    }
    final json = await ApiClient.getJson('/requests', query: qp);
    final items = (json['items'] as List).cast<Map<String, dynamic>>();
    return items
        .map(
          (m) => JobRequest(
            id: m['id'] as String,
            serviceId: m['service_id'] as String,
            clientName: m['client_name'] as String,
            clientPhone: m['client_phone'] as String,
            descripcion: m['descripcion'] as String,
            ciudad: m['ciudad'] as String,
            scheduledAt: (m['scheduled_at'] == null)
                ? null
                : DateTime.parse(m['scheduled_at'] as String),
            status: m['status'] as String,
            creadoEn: DateTime.parse(m['creado_en'] as String),
          ),
        )
        .toList(growable: false);
  }

  static Future<void> updateStatus({
    required String id,
    required String status, // 'pending' | 'accepted' | 'rejected' | 'completed'
  }) async {
    await ApiClient.postJson('/requests/update_status', {
      'id': id,
      'status': status,
    });
  }
}
