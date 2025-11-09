

enum ProductSortOption {
  dateOldToNew,
  dateNewToOld,
  purchasedFirst,
  notPurchasedFirst,
  priceHighToLow,
  priceLowToHigh,
  nameAZ,
  nameZA,
}

extension ProductSortOptionExtension on ProductSortOption {
  String get key {
    switch (this) {
      case ProductSortOption.dateOldToNew:
        return 'dateOldToNew';
      case ProductSortOption.dateNewToOld:
        return 'dateNewToOld';
      case ProductSortOption.purchasedFirst:
        return 'purchasedFirst';
      case ProductSortOption.notPurchasedFirst:
        return 'notPurchasedFirst';
      case ProductSortOption.priceHighToLow:
        return 'priceHighToLow';
      case ProductSortOption.priceLowToHigh:
        return 'priceLowToHigh';
      case ProductSortOption.nameAZ:
        return 'nameAZ';
      case ProductSortOption.nameZA:
        return 'nameZA';
    }
  }
}
