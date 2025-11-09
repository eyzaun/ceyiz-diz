enum TrousseauSortType {
  manual,
  oldestFirst,
  newestFirst,
}

extension TrousseauSortTypeExtension on TrousseauSortType {
  String get value {
    switch (this) {
      case TrousseauSortType.manual:
        return 'manual';
      case TrousseauSortType.oldestFirst:
        return 'oldest_first';
      case TrousseauSortType.newestFirst:
        return 'newest_first';
    }
  }

  static TrousseauSortType fromValue(String value) {
    switch (value) {
      case 'manual':
        return TrousseauSortType.manual;
      case 'oldest_first':
        return TrousseauSortType.oldestFirst;
      case 'newest_first':
        return TrousseauSortType.newestFirst;
      default:
        return TrousseauSortType.manual;
    }
  }
}
