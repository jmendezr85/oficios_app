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

  JobRequest copyWith({String? status}) {
    return JobRequest(
      id: id,
      serviceId: serviceId,
      clientName: clientName,
      clientPhone: clientPhone,
      descripcion: descripcion,
      ciudad: ciudad,
      scheduledAt: scheduledAt,
      status: status ?? this.status,
      creadoEn: creadoEn,
    );
  }
}
