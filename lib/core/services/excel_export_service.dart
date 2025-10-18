library;

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/trousseau_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';

/// Excel Export Service
/// Çeyiz listelerini Excel formatında export eder ve paylaşır
class ExcelExportService {
  /// Çeyiz listesini Excel dosyası olarak export eder ve paylaşır
  static Future<void> exportAndShareTrousseau({
    required TrousseauModel trousseau,
    required List<ProductModel> products,
    required List<CategoryModel> categories,
    Map<String, String> userEmailMap = const {}, // userId -> email mapping
  }) async {
    try {
      // Excel dosyası oluştur
      final excel = Excel.createExcel();

      // ÖNEMLI: Ürün Listesi'ni ilk sayfa olarak oluştur (böylece Sheet1 otomatik silinir)
      // Ürün Listesi Sayfası - 1. SAYFA
      _createProductListSheet(excel, products, categories, userEmailMap);

      // Varsayılan Sheet1'i sil
      if (excel.sheets.keys.contains('Sheet1')) {
        excel.delete('Sheet1');
      }

      // Çeyiz Özet Sayfası - 2. SAYFA
      _createSummarySheet(excel, trousseau, products);

      // Kategori Bazlı Sayfa - 3. SAYFA
      _createCategorySheet(excel, products, categories);

      // İstatistik Sayfası - 4. SAYFA
      _createStatisticsSheet(excel, products, categories);

      // Dosyayı kaydet
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/${_sanitizeFileName(trousseau.name)}_ceyiz_listesi.xlsx';
      final file = File(filePath);

      // Excel'i byte array'e çevir ve kaydet
      final bytes = excel.encode();

      if (bytes != null) {
        await file.writeAsBytes(bytes);

        // Dosyayı paylaş
        await Share.shareXFiles(
          [XFile(filePath)],
          text: '${trousseau.name} - Çeyiz Listesi',
          subject: 'Çeyiz Listesi - ${trousseau.name}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Çeyiz özet sayfası oluşturur
  static void _createSummarySheet(
    Excel excel,
    TrousseauModel trousseau,
    List<ProductModel> products,
  ) {
    final sheet = excel['Çeyiz Özeti'];

    // Başlık stili
    final headerStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#2563EB'),
    );

    final labelStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.black,
    );

    // Başlık
    var cell = sheet.cell(CellIndex.indexByString('A1'));
    cell.value = TextCellValue('ÇEYİZ LİSTESİ');
    cell.cellStyle = headerStyle;
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('D1'));

    // Çeyiz Bilgileri
    int row = 3;

    _addInfoRow(sheet, row++, 'Çeyiz Adı:', trousseau.name, labelStyle);
    _addInfoRow(sheet, row++, 'Açıklama:', trousseau.description, labelStyle);
    _addInfoRow(sheet, row++, 'Oluşturma Tarihi:', _formatDate(trousseau.createdAt), labelStyle);

    row++; // Boş satır

    // İstatistikler
    final totalProducts = products.length;
    final purchasedProducts = products.where((p) => p.isPurchased).length;
    final totalPrice = products.fold<double>(0, (sum, p) => sum + (p.price * p.quantity));
    final purchasedPrice = products
        .where((p) => p.isPurchased)
        .fold<double>(0, (sum, p) => sum + (p.price * p.quantity));

    cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    cell.value = TextCellValue('İSTATİSTİKLER');
    cell.cellStyle = headerStyle;
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row),
    );
    row++;
    row++; // Boş satır

    _addInfoRow(sheet, row++, 'Toplam Ürün:', '$totalProducts', labelStyle);
    _addInfoRow(sheet, row++, 'Alınan Ürün:', '$purchasedProducts', labelStyle);
    _addInfoRow(sheet, row++, 'Kalan Ürün:', '${totalProducts - purchasedProducts}', labelStyle);
    _addInfoRow(sheet, row++, 'Tamamlanma:', '${totalProducts > 0 ? ((purchasedProducts / totalProducts) * 100).toStringAsFixed(1) : 0}%', labelStyle);

    row++; // Boş satır

    _addInfoRow(sheet, row++, 'Toplam Bütçe:', '₺${totalPrice.toStringAsFixed(2)}', labelStyle);
    _addInfoRow(sheet, row++, 'Harcanan:', '₺${purchasedPrice.toStringAsFixed(2)}', labelStyle);
    _addInfoRow(sheet, row++, 'Kalan:', '₺${(totalPrice - purchasedPrice).toStringAsFixed(2)}', labelStyle);

    // Sütun genişlikleri
    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 30);
  }

  /// Ürün listesi sayfası oluşturur
  static void _createProductListSheet(
    Excel excel,
    List<ProductModel> products,
    List<CategoryModel> categories,
    Map<String, String> userEmailMap,
  ) {
    final sheet = excel['Ürün Listesi'];

    // Başlık stili
    final headerStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#2563EB'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final purchasedStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#D1FAE5'),
    );

    // Başlıklar
    int col = 0;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
      ..value = TextCellValue('Ürün Adı')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
      ..value = TextCellValue('Kategori')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
      ..value = TextCellValue('Açıklama')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
      ..value = TextCellValue('Birim Fiyat')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
      ..value = TextCellValue('Adet')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
      ..value = TextCellValue('Toplam')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
      ..value = TextCellValue('Durum')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
      ..value = TextCellValue('Ekleyen')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
      ..value = TextCellValue('Link')
      ..cellStyle = headerStyle;

    // Ürünler
    int row = 1;
    for (final product in products) {
      final category = categories.firstWhere(
        (c) => c.id == product.category,
        orElse: () => CategoryModel.defaultCategories.last, // 'other' category
      );

      col = 0;

      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = TextCellValue(product.name);
      if (product.isPurchased) cell.cellStyle = purchasedStyle;

      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = TextCellValue(category.name);
      if (product.isPurchased) cell.cellStyle = purchasedStyle;

      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = TextCellValue(product.description);
      if (product.isPurchased) cell.cellStyle = purchasedStyle;

      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = DoubleCellValue(product.price);
      if (product.isPurchased) cell.cellStyle = purchasedStyle;

      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = IntCellValue(product.quantity);
      if (product.isPurchased) cell.cellStyle = purchasedStyle;

      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = DoubleCellValue(product.price * product.quantity);
      if (product.isPurchased) cell.cellStyle = purchasedStyle;

      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = TextCellValue(product.isPurchased ? 'Alındı' : 'Bekliyor');
      if (product.isPurchased) cell.cellStyle = purchasedStyle;

      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      // userId'yi email'e çevir, yoksa userId'yi göster
      final addedByEmail = userEmailMap[product.addedBy] ?? product.addedBy;
      cell.value = TextCellValue(addedByEmail);
      if (product.isPurchased) cell.cellStyle = purchasedStyle;

      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = TextCellValue(product.link);
      if (product.isPurchased) cell.cellStyle = purchasedStyle;

      row++;
    }

    // Sütun genişlikleri
    sheet.setColumnWidth(0, 25); // Ürün Adı
    sheet.setColumnWidth(1, 15); // Kategori
    sheet.setColumnWidth(2, 35); // Açıklama
    sheet.setColumnWidth(3, 12); // Birim Fiyat
    sheet.setColumnWidth(4, 8);  // Adet
    sheet.setColumnWidth(5, 12); // Toplam
    sheet.setColumnWidth(6, 10); // Durum
    sheet.setColumnWidth(7, 20); // Ekleyen
    sheet.setColumnWidth(8, 30); // Link
  }

  /// Kategori bazlı sayfa oluşturur
  static void _createCategorySheet(
    Excel excel,
    List<ProductModel> products,
    List<CategoryModel> categories,
  ) {
    final sheet = excel['Kategoriler'];

    // Başlık stili
    final headerStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#2563EB'),
      horizontalAlign: HorizontalAlign.Center,
    );

    final categoryHeaderStyle = CellStyle(
      bold: true,
      fontSize: 12,
      fontColorHex: ExcelColor.black,
      backgroundColorHex: ExcelColor.fromHexString('#E0E7FF'),
    );

    // Başlıklar
    int col = 0;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
      ..value = TextCellValue('Kategori')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
      ..value = TextCellValue('Toplam Ürün')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
      ..value = TextCellValue('Alınan')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
      ..value = TextCellValue('Kalan')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
      ..value = TextCellValue('Toplam Tutar')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
      ..value = TextCellValue('Harcanan')
      ..cellStyle = headerStyle;

    // Kategoriler
    int row = 1;
    for (final category in categories) {
      final categoryProducts = products.where((p) => p.category == category.id).toList();
      if (categoryProducts.isEmpty) continue;

      final totalProducts = categoryProducts.length;
      final purchasedProducts = categoryProducts.where((p) => p.isPurchased).length;
      final totalPrice = categoryProducts.fold<double>(0, (sum, p) => sum + (p.price * p.quantity));
      final purchasedPrice = categoryProducts
          .where((p) => p.isPurchased)
          .fold<double>(0, (sum, p) => sum + (p.price * p.quantity));

      col = 0;
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = TextCellValue(category.name);
      cell.cellStyle = categoryHeaderStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value = IntCellValue(totalProducts);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value = IntCellValue(purchasedProducts);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value = IntCellValue(totalProducts - purchasedProducts);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value = DoubleCellValue(totalPrice.isFinite ? totalPrice : 0.0);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row)).value = DoubleCellValue(purchasedPrice.isFinite ? purchasedPrice : 0.0);

      row++;
    }

    // Sütun genişlikleri
    sheet.setColumnWidth(0, 20); // Kategori
    sheet.setColumnWidth(1, 15); // Toplam Ürün
    sheet.setColumnWidth(2, 12); // Alınan
    sheet.setColumnWidth(3, 12); // Kalan
    sheet.setColumnWidth(4, 15); // Toplam Tutar
    sheet.setColumnWidth(5, 15); // Harcanan
  }

  /// İstatistik sayfası oluşturur
  static void _createStatisticsSheet(
    Excel excel,
    List<ProductModel> products,
    List<CategoryModel> categories,
  ) {
    final sheet = excel['İstatistikler'];

    // Başlık stili
    final headerStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#2563EB'),
    );

    final labelStyle = CellStyle(
      bold: true,
      fontSize: 11,
    );

    int row = 0;

    // Genel İstatistikler
    var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    cell.value = TextCellValue('GENEL İSTATİSTİKLER');
    cell.cellStyle = headerStyle;
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row),
    );
    row += 2;

    final totalProducts = products.length;
    final purchasedProducts = products.where((p) => p.isPurchased).length;
    final pendingProducts = totalProducts - purchasedProducts;
    final completionRate = totalProducts > 0 ? (purchasedProducts / totalProducts) * 100 : 0;

    _addInfoRow(sheet, row++, 'Toplam Ürün Sayısı:', '$totalProducts', labelStyle);
    _addInfoRow(sheet, row++, 'Alınan Ürünler:', '$purchasedProducts', labelStyle);
    _addInfoRow(sheet, row++, 'Bekleyen Ürünler:', '$pendingProducts', labelStyle);
    _addInfoRow(sheet, row++, 'Tamamlanma Oranı:', '${completionRate.toStringAsFixed(1)}%', labelStyle);

    row += 2;

    // Fiyat İstatistikleri
    cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    cell.value = TextCellValue('FİYAT İSTATİSTİKLERİ');
    cell.cellStyle = headerStyle;
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row),
    );
    row += 2;

    final totalBudget = products.fold<double>(0, (sum, p) => sum + (p.price * p.quantity));
    final spentBudget = products
        .where((p) => p.isPurchased)
        .fold<double>(0, (sum, p) => sum + (p.price * p.quantity));
    final remainingBudget = totalBudget - spentBudget;

    _addInfoRow(sheet, row++, 'Toplam Bütçe:', '₺${totalBudget.toStringAsFixed(2)}', labelStyle);
    _addInfoRow(sheet, row++, 'Harcanan Tutar:', '₺${spentBudget.toStringAsFixed(2)}', labelStyle);
    _addInfoRow(sheet, row++, 'Kalan Bütçe:', '₺${remainingBudget.toStringAsFixed(2)}', labelStyle);

    if (products.isNotEmpty) {
      final avgPrice = totalBudget / totalProducts;
      _addInfoRow(sheet, row++, 'Ortalama Ürün Fiyatı:', '₺${avgPrice.toStringAsFixed(2)}', labelStyle);

      final maxPriceProduct = products.reduce((a, b) =>
        (a.price * a.quantity) > (b.price * b.quantity) ? a : b
      );
      final minPriceProduct = products.reduce((a, b) =>
        (a.price * a.quantity) < (b.price * b.quantity) ? a : b
      );

      row += 2;
      _addInfoRow(sheet, row++, 'En Pahalı Ürün:', maxPriceProduct.name, labelStyle);
      _addInfoRow(sheet, row++, 'Fiyatı:', '₺${(maxPriceProduct.price * maxPriceProduct.quantity).toStringAsFixed(2)}', labelStyle);

      row++;
      _addInfoRow(sheet, row++, 'En Ucuz Ürün:', minPriceProduct.name, labelStyle);
      _addInfoRow(sheet, row++, 'Fiyatı:', '₺${(minPriceProduct.price * minPriceProduct.quantity).toStringAsFixed(2)}', labelStyle);
    }

    row += 2;

    // Kategori İstatistikleri
    cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    cell.value = TextCellValue('KATEGORİ İSTATİSTİKLERİ');
    cell.cellStyle = headerStyle;
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row),
    );
    row += 2;

    final totalCategories = categories.where((c) =>
      products.any((p) => p.category == c.id)
    ).length;
    _addInfoRow(sheet, row++, 'Toplam Kategori:', '$totalCategories', labelStyle);

    // En çok ürün içeren kategori
    if (categories.isNotEmpty && products.isNotEmpty) {
      var maxCategory = categories.first;
      var maxCount = 0;

      for (final category in categories) {
        final count = products.where((p) => p.category == category.id).length;
        if (count > maxCount) {
          maxCount = count;
          maxCategory = category;
        }
      }

      if (maxCount > 0) {
        row++;
        _addInfoRow(sheet, row++, 'En Çok Ürün İçeren:', maxCategory.name, labelStyle);
        _addInfoRow(sheet, row++, 'Ürün Sayısı:', '$maxCount', labelStyle);
      }
    }

    // Sütun genişlikleri
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 25);
  }

  /// Bilgi satırı ekler
  static void _addInfoRow(Sheet sheet, int row, String label, String value, CellStyle? labelStyle) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue(label)
      ..cellStyle = labelStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      .value = TextCellValue(value);
  }

  /// Tarihi formatlar
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Dosya adını temizler (geçersiz karakterleri kaldırır)
  static String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }
}
