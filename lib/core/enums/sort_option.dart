/// Product Sort Options
///
/// Ürün sıralama seçenekleri:
/// - purchasedFirst: Alınanlar önce (isPurchased = true)
/// - notPurchasedFirst: Alınmayanlar önce (isPurchased = false)
/// - priceHighToLow: Fiyat (Yüksekten Düşüğe)
/// - priceLowToHigh: Fiyat (Düşükten Yükseğe)
/// - nameAZ: İsim (A-Z)
/// - nameZA: İsim (Z-A)

enum ProductSortOption {
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
