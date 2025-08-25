import 'dart:convert';

class Service {
  final String id;
  final String titulo;
  final String categoria;
  final String ciudad;
  final double precioPorHora;
  final String descripcion;
  final bool disponible;
  final DateTime creadoEn;

  const Service({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.ciudad,
    required this.precioPorHora,
    required this.descripcion,
    required this.disponible,
    required this.creadoEn,
  });

  Service copyWith({
    String? id,
    String? titulo,
    String? categoria,
    String? ciudad,
    double? precioPorHora,
    String? descripcion,
    bool? disponible,
    DateTime? creadoEn,
  }) {
    return Service(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      categoria: categoria ?? this.categoria,
      ciudad: ciudad ?? this.ciudad,
      precioPorHora: precioPorHora ?? this.precioPorHora,
      descripcion: descripcion ?? this.descripcion,
      disponible: disponible ?? this.disponible,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'titulo': titulo,
    'categoria': categoria,
    'ciudad': ciudad,
    'precioPorHora': precioPorHora,
    'descripcion': descripcion,
    'disponible': disponible,
    'creadoEn': creadoEn.toIso8601String(),
  };

  static Service fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] as String,
      titulo: map['titulo'] as String,
      categoria: map['categoria'] as String,
      ciudad: map['ciudad'] as String,
      precioPorHora: (map['precioPorHora'] as num).toDouble(),
      descripcion: map['descripcion'] as String,
      disponible: map['disponible'] as bool,
      creadoEn: DateTime.parse(map['creadoEn'] as String),
    );
  }

  String toJson() => jsonEncode(toMap());
  static Service fromJson(String s) =>
      fromMap(jsonDecode(s) as Map<String, dynamic>);
}

List<Map<String, dynamic>> servicesToMaps(List<Service> list) =>
    list.map((e) => e.toMap()).toList(growable: false);

List<Service> servicesFromMaps(List<dynamic> list) => list
    .map((e) => Service.fromMap(e as Map<String, dynamic>))
    .toList(growable: false);
