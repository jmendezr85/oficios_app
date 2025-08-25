enum SortBy { rating, name }

class SearchParams {
  final String? query;
  final double minRating;
  final SortBy sortBy;

  const SearchParams({
    this.query,
    this.minRating = 0.0,
    this.sortBy = SortBy.rating,
  });

  SearchParams copyWith({String? query, double? minRating, SortBy? sortBy}) {
    return SearchParams(
      query: query ?? this.query,
      minRating: minRating ?? this.minRating,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
