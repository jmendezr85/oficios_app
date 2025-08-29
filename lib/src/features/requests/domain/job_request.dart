class JobRequest {
  final String id;
  final String serviceId;
  final String clientName;
  final String clientPhone;
  final String descripcion;
  final String ciudad;
  final DateTime? scheduledAt;
  final String status; // pending | accepted | rejected | completed
  final DateTime creadoEn;

  const JobRequest({
    required this.id,
    required this.serviceId,
    required this.clientName,
    required this.clientPhone,
    required this.descripcion,
    required this.ciudad,
    required this.scheduledAt,
    required this.status,
    required this.creadoEn,
  });

  /// ✅ Agregamos copyWith para que el controller pueda actualizar campos
  JobRequest copyWith({
    String? id,
    String? serviceId,
    String? clientName,
    String? clientPhone,
    String? descripcion,
    String? ciudad,
    DateTime? scheduledAt,
    String? status,
    DateTime? creadoEn,
  }) {
    return JobRequest(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      descripcion: descripcion ?? this.descripcion,
      ciudad: ciudad ?? this.ciudad,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
