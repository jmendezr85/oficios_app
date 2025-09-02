enum ProfessionalSortBy { rating, name }

class SearchParams {
  final String? query;
  final double minRating;
  final ProfessionalSortBy sortBy;

  const SearchParams({
    this.query,
    this.minRating = 0.0,
    this.sortBy = ProfessionalSortBy.rating,
  });

  SearchParams copyWith({
    String? query,
    double? minRating,
    ProfessionalSortBy? sortBy,
  }) {
    return SearchParams(
      query: query ?? this.query,
      minRating: minRating ?? this.minRating,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
