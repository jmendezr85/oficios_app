enum ServiceSortBy {
  recientes, // creado_en DESC (default)
  precioAsc, // precio_por_hora ASC
  precioDesc, // precio_por_hora DESC
}

class SearchFilters {
  final String? query; // texto libre: título/categoría/ciudad
  final String? categoria; // filtro exacto
  final String? ciudad; // filtro exacto
  final bool? disponible; // true/false/null
  final double? minPrecio;
  final double? maxPrecio;
  final int limit; // paginación
  final int offset; // paginación
  final ServiceSortBy sortBy;

  const SearchFilters({
    this.query,
    this.categoria,
    this.ciudad,
    this.disponible,
    this.minPrecio,
    this.maxPrecio,
    this.limit = 20,
    this.offset = 0,
    this.sortBy = ServiceSortBy.recientes,
  });

  SearchFilters copyWith({
    String? query,
    String? categoria,
    String? ciudad,
    bool? disponible,
    double? minPrecio,
    double? maxPrecio,
    int? limit,
    int? offset,
    ServiceSortBy? sortBy,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      categoria: categoria ?? this.categoria,
      ciudad: ciudad ?? this.ciudad,
      disponible: disponible ?? this.disponible,
      minPrecio: minPrecio ?? this.minPrecio,
      maxPrecio: maxPrecio ?? this.maxPrecio,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
