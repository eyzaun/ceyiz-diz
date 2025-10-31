/// Excel Export Service V3 - Professional Design with Images
///
/// Özellikler:
/// ✅ Gerçek ürün görselleri (URL'den indirme ve gömme)
/// ✅ Uygulama tema renkleri ile uyumlu tasarım
/// ✅ Optimize edilmiş kolon genişlikleri
/// ✅ Türkçe binlik ayırıcılar (1.234,56)
/// ✅ Profesyonel formatlama ve düzen
///
/// Syncfusion XlsIO kullanılarak geliştirilmiştir

library;

import 'dart:io';
import 'dart:typed_data';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../../data/models/trousseau_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';

class ExcelExportServiceV3 {
  // Uygulama tema renkleri
  static const String _primaryColorHex = '#2563EB'; // Primary blue
  static const String _secondaryColorHex = '#3B82F6'; // Secondary blue
  static const String _successColorHex = '#10B981'; // Success green
  static const String _dangerColorHex = '#EF4444'; // Danger red
  static const String _surfaceColorHex = '#F8FAFC'; // Light surface

  /// Excel dosyası oluştur ve paylaş
  static Future<void> exportAndShareTrousseau({
    required TrousseauModel trousseau,
    required List<ProductModel> products,
    required List<CategoryModel> categories,
    required Map<String, String> userEmailMap,
  }) async {
    // Yeni workbook oluştur
    final xlsio.Workbook workbook = xlsio.Workbook();

    // Ana sayfa: Tüm ürünler
    await _createProductsSheet(
      workbook,
      'Tüm Ürünler',
      products,
      categories,
      userEmailMap,
      isFirstSheet: true,
    );

    // Kategori başına sayfalar oluştur
    final categorizedProducts = <String, List<ProductModel>>{};
    for (final product in products) {
      if (!categorizedProducts.containsKey(product.category)) {
        categorizedProducts[product.category] = [];
      }
      categorizedProducts[product.category]!.add(product);
    }

    for (final categoryId in categorizedProducts.keys) {
      CategoryModel? category;
      try {
        category = categories.firstWhere((c) => c.id == categoryId);
      } catch (e) {
        continue; // Kategori bulunamazsa atla
      }

      final categoryProducts = categorizedProducts[categoryId]!;
      if (categoryProducts.isNotEmpty) {
        // Sayfa adını 31 karakterle sınırla (Excel limiti)
        final sheetName = category.displayName.length > 31
            ? category.displayName.substring(0, 31)
            : category.displayName;

        await _createProductsSheet(
          workbook,
          sheetName,
          categoryProducts,
          categories,
          userEmailMap,
        );
      }
    }

    // Özet sayfası
    _createSummarySheet(workbook, trousseau, products, categories);

    // İstatistik sayfası
    _createStatisticsSheet(workbook, trousseau, products, categories);

    // Dosyayı kaydet ve paylaş
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${trousseau.name}_$timestamp.xlsx';
    final filePath = '${directory.path}/$fileName';

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    // Dosyayı paylaş
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: '${trousseau.name} - Çeyiz Listesi',
      text: 'Excel formatında çeyiz listeniz ektedir.',
    );
  }

  /// Ürün listesi sayfası oluştur
  static Future<void> _createProductsSheet(
    xlsio.Workbook workbook,
    String sheetName,
    List<ProductModel> products,
    List<CategoryModel> categories,
    Map<String, String> userEmailMap, {
    bool isFirstSheet = false,
  }) async {
    // Sayfa oluştur veya al
    final xlsio.Worksheet sheet = isFirstSheet
        ? workbook.worksheets[0]
        : workbook.worksheets.add();

    if (!isFirstSheet) {
      sheet.name = sheetName;
    } else {
      sheet.name = sheetName;
    }

    // Satır yüksekliklerini ayarla
    sheet.setRowHeightInPixels(1, 35); // Başlık satırı

    // BAŞLIK SATIRI (Satır 1)
    final headers = [
      '#',
      'Fotoğraf',
      'Ürün Adı',
      'Kategori',
      'Adet',
      'Birim Fiyat',
      'Toplam Fiyat',
      'Alındı mı?',
      'Ekleme Tarihi',
      'Ekleyen',
      'Açıklama',
      'Link 1',
      'Link 2',
      'Link 3',
    ];

    // Kolon genişliklerini ayarla
    sheet.setColumnWidthInPixels(1, 30);   // #
    sheet.setColumnWidthInPixels(2, 100);  // Fotoğraf
    sheet.setColumnWidthInPixels(3, 180);  // Ürün Adı
    sheet.setColumnWidthInPixels(4, 100);  // Kategori
    sheet.setColumnWidthInPixels(5, 50);   // Adet
    sheet.setColumnWidthInPixels(6, 90);   // Birim Fiyat
    sheet.setColumnWidthInPixels(7, 90);   // Toplam Fiyat
    sheet.setColumnWidthInPixels(8, 80);   // Alındı mı?
    sheet.setColumnWidthInPixels(9, 90);   // Ekleme Tarihi
    sheet.setColumnWidthInPixels(10, 150); // Ekleyen
    sheet.setColumnWidthInPixels(11, 200); // Açıklama
    sheet.setColumnWidthInPixels(12, 180); // Link 1
    sheet.setColumnWidthInPixels(13, 180); // Link 2
    sheet.setColumnWidthInPixels(14, 180); // Link 3

    // Başlıkları ekle ve stillendir
    for (int col = 0; col < headers.length; col++) {
      final cell = sheet.getRangeByIndex(1, col + 1);
      cell.setText(headers[col]);
      cell.cellStyle.bold = true;
      cell.cellStyle.fontSize = 11;
      cell.cellStyle.backColor = _primaryColorHex;
      cell.cellStyle.fontColor = '#FFFFFF';
      cell.cellStyle.hAlign = xlsio.HAlignType.center;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;
      cell.cellStyle.wrapText = true;
    }

    // ÜRÜN SATIRLARI
    int row = 2; // Excel satırları 1'den başlar, başlık 1. satırda
    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      CategoryModel? category;
      try {
        category = categories.firstWhere((c) => c.id == product.category);
      } catch (e) {
        // Kategori bulunamazsa null bırak
      }

      // Satır yüksekliği (görsel için)
      sheet.setRowHeightInPixels(row, 80);

      int col = 1;

      // # (Sıra No)
      var cell = sheet.getRangeByIndex(row, col++);
      cell.setNumber((i + 1).toDouble());
      cell.cellStyle.hAlign = xlsio.HAlignType.center;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      // Fotoğraf
      cell = sheet.getRangeByIndex(row, col++);
      if (product.images.isNotEmpty) {
        try {
          // Görseli indir ve boyutlandır
          final imageBytes = await _downloadAndResizeImage(product.images.first, 640);
          if (imageBytes != null) {
            // Görseli Excel'e ekle
            final xlsio.Picture picture = sheet.pictures.addStream(
              row,
              col - 1,
              imageBytes,
            );
            // Görsel boyutunu ayarla (hücre içine sığdır)
            picture.height = 70;
            picture.width = 90;
          }
        } catch (e) {
          // Görsel yüklenemezse URL'yi yaz
          cell.setText(product.images.first);
          cell.cellStyle.fontSize = 8;
        }
      }
      cell.cellStyle.hAlign = xlsio.HAlignType.center;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      // Ürün Adı
      cell = sheet.getRangeByIndex(row, col++);
      cell.setText(product.name);
      cell.cellStyle.bold = true;
      cell.cellStyle.hAlign = xlsio.HAlignType.left;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      // Kategori
      cell = sheet.getRangeByIndex(row, col++);
      cell.setText(category == null ? 'Diğer' : category.displayName);
      cell.cellStyle.bold = true;
      cell.cellStyle.fontSize = 9;
      cell.cellStyle.backColor = _secondaryColorHex;
      cell.cellStyle.fontColor = '#FFFFFF';
      cell.cellStyle.hAlign = xlsio.HAlignType.center;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      // Adet
      cell = sheet.getRangeByIndex(row, col++);
      cell.setNumber(product.quantity.toDouble());
      cell.cellStyle.hAlign = xlsio.HAlignType.center;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      // Birim Fiyat
      cell = sheet.getRangeByIndex(row, col++);
      cell.setText(_formatCurrency(product.price));
      cell.cellStyle.hAlign = xlsio.HAlignType.right;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      // Toplam Fiyat
      cell = sheet.getRangeByIndex(row, col++);
      final totalPrice = product.price * product.quantity;
      cell.setText(_formatCurrency(totalPrice));
      cell.cellStyle.bold = true;
      cell.cellStyle.hAlign = xlsio.HAlignType.right;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      // Alındı mı?
      cell = sheet.getRangeByIndex(row, col++);
      cell.setText(product.isPurchased ? '✓ Evet' : '✗ Hayır');
      cell.cellStyle.bold = true;
      cell.cellStyle.backColor = product.isPurchased ? '#D1FAE5' : '#FEE2E2';
      cell.cellStyle.fontColor = product.isPurchased ? _successColorHex : _dangerColorHex;
      cell.cellStyle.hAlign = xlsio.HAlignType.center;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      // Ekleme Tarihi
      cell = sheet.getRangeByIndex(row, col++);
      cell.setText(DateFormat('dd.MM.yyyy').format(product.createdAt));
      cell.cellStyle.hAlign = xlsio.HAlignType.center;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      // Ekleyen
      cell = sheet.getRangeByIndex(row, col++);
      final addedBy = userEmailMap[product.addedBy] ?? product.addedBy;
      cell.setText(addedBy);
      cell.cellStyle.fontSize = 9;
      cell.cellStyle.hAlign = xlsio.HAlignType.left;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      // Açıklama
      cell = sheet.getRangeByIndex(row, col++);
      cell.setText(product.description.isEmpty ? '-' : product.description);
      cell.cellStyle.fontSize = 9;
      cell.cellStyle.wrapText = true;
      cell.cellStyle.hAlign = xlsio.HAlignType.left;
      cell.cellStyle.vAlign = xlsio.VAlignType.top;

      // Link 1
      cell = sheet.getRangeByIndex(row, col++);
      if (product.link.isNotEmpty) {
        cell.setText(product.link);
        cell.cellStyle.fontSize = 8;
        cell.cellStyle.fontColor = _primaryColorHex;
        cell.cellStyle.underline = true;
      } else {
        cell.setText('-');
        cell.cellStyle.fontSize = 9;
      }
      cell.cellStyle.hAlign = xlsio.HAlignType.left;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      // Link 2
      cell = sheet.getRangeByIndex(row, col++);
      if (product.link2.isNotEmpty) {
        cell.setText(product.link2);
        cell.cellStyle.fontSize = 8;
        cell.cellStyle.fontColor = _primaryColorHex;
        cell.cellStyle.underline = true;
      } else {
        cell.setText('-');
        cell.cellStyle.fontSize = 9;
      }
      cell.cellStyle.hAlign = xlsio.HAlignType.left;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      // Link 3
      cell = sheet.getRangeByIndex(row, col++);
      if (product.link3.isNotEmpty) {
        cell.setText(product.link3);
        cell.cellStyle.fontSize = 8;
        cell.cellStyle.fontColor = _primaryColorHex;
        cell.cellStyle.underline = true;
      } else {
        cell.setText('-');
        cell.cellStyle.fontSize = 9;
      }
      cell.cellStyle.hAlign = xlsio.HAlignType.left;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      row++;
    }

    // TOPLAM SATIRI
    if (products.isNotEmpty) {
      sheet.setRowHeightInPixels(row, 30);

      // "TOPLAM" etiketi
      var cell = sheet.getRangeByIndex(row, 1, row, 3);
      cell.merge();
      cell.setText('TOPLAM:');
      cell.cellStyle.bold = true;
      cell.cellStyle.fontSize = 11;
      cell.cellStyle.backColor = _surfaceColorHex;
      cell.cellStyle.hAlign = xlsio.HAlignType.center;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      // Toplam Adet
      cell = sheet.getRangeByIndex(row, 5);
      final totalQuantity = products.fold<int>(0, (sum, p) => sum + p.quantity);
      cell.setNumber(totalQuantity.toDouble());
      cell.cellStyle.bold = true;
      cell.cellStyle.fontSize = 11;
      cell.cellStyle.backColor = _surfaceColorHex;
      cell.cellStyle.hAlign = xlsio.HAlignType.center;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      // Boş hücre
      cell = sheet.getRangeByIndex(row, 6);
      cell.cellStyle.backColor = _surfaceColorHex;

      // Toplam Planlanan Bütçe
      cell = sheet.getRangeByIndex(row, 7);
      final totalPlanned = products.fold<double>(0, (sum, p) => sum + (p.price * p.quantity));
      cell.setText(_formatCurrency(totalPlanned));
      cell.cellStyle.bold = true;
      cell.cellStyle.fontSize = 11;
      cell.cellStyle.backColor = '#DBEAFE';
      cell.cellStyle.hAlign = xlsio.HAlignType.right;
      cell.cellStyle.vAlign = xlsio.VAlignType.center;

      // Kalan hücreler
      for (int i = 8; i <= 14; i++) {
        cell = sheet.getRangeByIndex(row, i);
        cell.cellStyle.backColor = _surfaceColorHex;
      }
    }
  }

  /// Özet sayfası oluştur
  static void _createSummarySheet(
    xlsio.Workbook workbook,
    TrousseauModel trousseau,
    List<ProductModel> products,
    List<CategoryModel> categories,
  ) {
    final xlsio.Worksheet sheet = workbook.worksheets.add();
    sheet.name = 'Özet';

    // Başlık
    var cell = sheet.getRangeByIndex(1, 1, 1, 4);
    cell.merge();
    cell.setText(trousseau.name);
    cell.cellStyle.bold = true;
    cell.cellStyle.fontSize = 18;
    cell.cellStyle.fontColor = _primaryColorHex;
    cell.cellStyle.hAlign = xlsio.HAlignType.center;
    cell.cellStyle.vAlign = xlsio.VAlignType.center;
    sheet.setRowHeightInPixels(1, 40);

    // Genel istatistikler
    int row = 4;
    final totalPlanned = products.fold<double>(0, (sum, p) => sum + (p.price * p.quantity));
    final totalSpent = products.where((p) => p.isPurchased).fold<double>(0, (sum, p) => sum + (p.price * p.quantity));

    final stats = [
      ['Toplam Ürün Sayısı', products.length.toString()],
      ['Toplam Adet', products.fold<int>(0, (sum, p) => sum + p.quantity).toString()],
      ['Planlanan Bütçe', _formatCurrency(totalPlanned)],
      ['Harcanan Tutar', _formatCurrency(totalSpent)],
      ['Kalan Bütçe', _formatCurrency(totalPlanned - totalSpent)],
      ['Alınan Ürün Sayısı', products.where((p) => p.isPurchased).length.toString()],
      ['Alınmayan Ürün Sayısı', products.where((p) => !p.isPurchased).length.toString()],
    ];

    for (final stat in stats) {
      // Etiket
      cell = sheet.getRangeByIndex(row, 1);
      cell.setText(stat[0]);
      cell.cellStyle.bold = true;
      cell.cellStyle.fontSize = 11;
      cell.cellStyle.hAlign = xlsio.HAlignType.left;

      // Değer
      cell = sheet.getRangeByIndex(row, 2);
      cell.setText(stat[1]);
      cell.cellStyle.fontSize = 11;
      cell.cellStyle.backColor = _surfaceColorHex;
      cell.cellStyle.hAlign = xlsio.HAlignType.right;

      row++;
    }

    // Kategori başına istatistikler
    row += 2;
    cell = sheet.getRangeByIndex(row, 1, row, 4);
    cell.merge();
    cell.setText('Kategori Bazında İstatistikler');
    cell.cellStyle.bold = true;
    cell.cellStyle.fontSize = 12;
    cell.cellStyle.fontColor = _primaryColorHex;

    row += 2;
    final categoryHeaders = ['Kategori', 'Ürün Sayısı', 'Planlanan', 'Harcanan'];
    for (int col = 0; col < categoryHeaders.length; col++) {
      cell = sheet.getRangeByIndex(row, col + 1);
      cell.setText(categoryHeaders[col]);
      cell.cellStyle.bold = true;
      cell.cellStyle.fontSize = 10;
      cell.cellStyle.backColor = _surfaceColorHex;
      cell.cellStyle.hAlign = xlsio.HAlignType.center;
    }

    row++;
    for (final category in categories) {
      final categoryProducts = products.where((p) => p.category == category.id).toList();
      if (categoryProducts.isEmpty) continue;

      final planned = categoryProducts.fold<double>(0, (sum, p) => sum + (p.price * p.quantity));
      final spent = categoryProducts.where((p) => p.isPurchased).fold<double>(
        0,
        (sum, p) => sum + (p.price * p.quantity),
      );

      int col = 1;

      // Kategori adı
      cell = sheet.getRangeByIndex(row, col++);
      cell.setText(category.displayName);
      cell.cellStyle.fontSize = 10;

      // Ürün sayısı
      cell = sheet.getRangeByIndex(row, col++);
      cell.setNumber(categoryProducts.length.toDouble());
      cell.cellStyle.fontSize = 10;
      cell.cellStyle.hAlign = xlsio.HAlignType.center;

      // Planlanan
      cell = sheet.getRangeByIndex(row, col++);
      cell.setText(_formatCurrency(planned));
      cell.cellStyle.fontSize = 10;
      cell.cellStyle.hAlign = xlsio.HAlignType.right;

      // Harcanan
      cell = sheet.getRangeByIndex(row, col++);
      cell.setText(_formatCurrency(spent));
      cell.cellStyle.fontSize = 10;
      cell.cellStyle.hAlign = xlsio.HAlignType.right;

      row++;
    }

    // Kolon genişlikleri
    sheet.setColumnWidthInPixels(1, 180);
    sheet.setColumnWidthInPixels(2, 100);
    sheet.setColumnWidthInPixels(3, 100);
    sheet.setColumnWidthInPixels(4, 100);
  }

  /// İstatistik sayfası oluştur (Detaylı Analiz)
  static void _createStatisticsSheet(
    xlsio.Workbook workbook,
    TrousseauModel trousseau,
    List<ProductModel> products,
    List<CategoryModel> categories,
  ) {
    final xlsio.Worksheet sheet = workbook.worksheets.add();
    sheet.name = 'İstatistikler';

    // Sayfa başlığı
    var cell = sheet.getRangeByIndex(1, 1, 1, 4);
    cell.merge();
    cell.setText('📊 DETAYLI İSTATİSTİK ANALİZİ');
    cell.cellStyle.bold = true;
    cell.cellStyle.fontSize = 20;
    cell.cellStyle.fontColor = _primaryColorHex;
    cell.cellStyle.hAlign = xlsio.HAlignType.center;
    cell.cellStyle.vAlign = xlsio.VAlignType.center;
    sheet.setRowHeightInPixels(1, 45);

    int row = 3;

    // ═══════════════════════════════════════════════════════════════════
    // BÖLÜM 1: GENEL BAKIŞ
    // ═══════════════════════════════════════════════════════════════════
    cell = sheet.getRangeByIndex(row, 1);
    cell.setText('📈 GENEL BAKIŞ');
    cell.cellStyle.bold = true;
    cell.cellStyle.fontSize = 14;
    cell.cellStyle.fontColor = _primaryColorHex;
    row += 2;

    final totalBudget = trousseau.totalBudget;
    final totalSpent = products.where((p) => p.isPurchased).fold<double>(0, (sum, p) => sum + (p.price * p.quantity));
    final totalPlanned = products.fold<double>(0, (sum, p) => sum + (p.price * p.quantity));
    final remainingBudget = totalBudget - totalSpent;
    final totalProducts = products.length;
    final purchasedProducts = products.where((p) => p.isPurchased).length;
    final notPurchasedProducts = totalProducts - purchasedProducts;
    final totalQuantity = products.fold<int>(0, (sum, p) => sum + p.quantity);

    final overviewStats = [
      ['Toplam Bütçe', _formatCurrency(totalBudget)],
      ['Harcanan Tutar', _formatCurrency(totalSpent)],
      ['Kalan Bütçe', _formatCurrency(remainingBudget)],
      ['Planlanan Toplam', _formatCurrency(totalPlanned)],
      ['Bütçe Kullanım Oranı', totalBudget > 0 ? '%${((totalSpent / totalBudget) * 100).toStringAsFixed(1)}' : '%0'],
      ['', ''],
      ['Toplam Ürün Sayısı', totalProducts.toString()],
      ['Alınan Ürünler', purchasedProducts.toString()],
      ['Alınmayan Ürünler', notPurchasedProducts.toString()],
      ['Tamamlanma Oranı', totalProducts > 0 ? '%${((purchasedProducts / totalProducts) * 100).toStringAsFixed(1)}' : '%0'],
      ['Toplam Adet', totalQuantity.toString()],
    ];

    for (final stat in overviewStats) {
      if (stat[0].isEmpty) {
        row++;
        continue;
      }

      // Etiket
      cell = sheet.getRangeByIndex(row, 1);
      cell.setText(stat[0]);
      cell.cellStyle.bold = true;
      cell.cellStyle.fontSize = 11;

      // Değer
      cell = sheet.getRangeByIndex(row, 2);
      cell.setText(stat[1]);
      cell.cellStyle.fontSize = 11;
      cell.cellStyle.backColor = _surfaceColorHex;
      cell.cellStyle.hAlign = xlsio.HAlignType.right;

      row++;
    }

    row += 2;

    // ═══════════════════════════════════════════════════════════════════
    // BÖLÜM 2: FİYAT ANALİZİ
    // ═══════════════════════════════════════════════════════════════════
    cell = sheet.getRangeByIndex(row, 1);
    cell.setText('💰 FİYAT ANALİZİ');
    cell.cellStyle.bold = true;
    cell.cellStyle.fontSize = 14;
    cell.cellStyle.fontColor = _primaryColorHex;
    row += 2;

    // Fiyat hesaplamaları
    final productPrices = products.map((p) => p.price * p.quantity).toList();
    final averagePrice = totalProducts > 0 ? totalPlanned / totalProducts : 0;
    final maxPrice = productPrices.isEmpty ? 0.0 : productPrices.reduce((a, b) => a > b ? a : b);
    final minPrice = productPrices.isEmpty ? 0.0 : productPrices.reduce((a, b) => a < b ? a : b);

    final mostExpensiveProduct = products.isEmpty ? null : products.reduce((a, b) =>
      (a.price * a.quantity) > (b.price * b.quantity) ? a : b);
    final cheapestProduct = products.isEmpty ? null : products.reduce((a, b) =>
      (a.price * a.quantity) < (b.price * b.quantity) ? a : b);

    final priceStats = [
      ['Ortalama Ürün Fiyatı', _formatCurrency(averagePrice.toDouble())],
      ['En Yüksek Fiyat', _formatCurrency(maxPrice.toDouble())],
      ['En Düşük Fiyat', _formatCurrency(minPrice.toDouble())],
      ['', ''],
      ['En Pahalı Ürün', mostExpensiveProduct?.name ?? '-'],
      ['  → Fiyat', mostExpensiveProduct != null ? _formatCurrency(mostExpensiveProduct.price * mostExpensiveProduct.quantity) : '-'],
      ['', ''],
      ['En Ucuz Ürün', cheapestProduct?.name ?? '-'],
      ['  → Fiyat', cheapestProduct != null ? _formatCurrency(cheapestProduct.price * cheapestProduct.quantity) : '-'],
    ];

    for (final stat in priceStats) {
      if (stat[0].isEmpty) {
        row++;
        continue;
      }

      cell = sheet.getRangeByIndex(row, 1);
      cell.setText(stat[0]);
      cell.cellStyle.bold = !stat[0].startsWith('  →');
      cell.cellStyle.fontSize = 11;

      cell = sheet.getRangeByIndex(row, 2);
      cell.setText(stat[1]);
      cell.cellStyle.fontSize = 11;
      cell.cellStyle.backColor = _surfaceColorHex;
      cell.cellStyle.hAlign = xlsio.HAlignType.right;

      row++;
    }

    row += 2;

    // ═══════════════════════════════════════════════════════════════════
    // BÖLÜM 3: KATEGORİ BAZINDA DETAYLI ANALİZ
    // ═══════════════════════════════════════════════════════════════════
    cell = sheet.getRangeByIndex(row, 1);
    cell.setText('📦 KATEGORİ BAZINDA DETAYLI ANALİZ');
    cell.cellStyle.bold = true;
    cell.cellStyle.fontSize = 14;
    cell.cellStyle.fontColor = _primaryColorHex;
    row += 2;

    // Başlık satırı
    final categoryAnalysisHeaders = [
      'Kategori',
      'Ürün Sayısı',
      'Toplam Adet',
      'Planlanan',
      'Harcanan',
      'Kalan',
      'Tamamlanma %',
    ];

    for (int col = 0; col < categoryAnalysisHeaders.length; col++) {
      cell = sheet.getRangeByIndex(row, col + 1);
      cell.setText(categoryAnalysisHeaders[col]);
      cell.cellStyle.bold = true;
      cell.cellStyle.fontSize = 10;
      cell.cellStyle.backColor = _secondaryColorHex;
      cell.cellStyle.fontColor = '#FFFFFF';
      cell.cellStyle.hAlign = xlsio.HAlignType.center;
    }

    row++;

    // Kategori verileri
    for (final category in categories) {
      final categoryProducts = products.where((p) => p.category == category.id).toList();
      if (categoryProducts.isEmpty) continue;

      final catTotalQuantity = categoryProducts.fold<int>(0, (sum, p) => sum + p.quantity);
      final catPlanned = categoryProducts.fold<double>(0, (sum, p) => sum + (p.price * p.quantity));
      final catSpent = categoryProducts.where((p) => p.isPurchased).fold<double>(
        0,
        (sum, p) => sum + (p.price * p.quantity),
      );
      final catRemaining = catPlanned - catSpent;
      final catPurchased = categoryProducts.where((p) => p.isPurchased).length;
      final catCompletion = categoryProducts.isNotEmpty
        ? (catPurchased / categoryProducts.length) * 100
        : 0;

      int col = 1;

      // Kategori adı
      cell = sheet.getRangeByIndex(row, col++);
      cell.setText(category.displayName);
      cell.cellStyle.fontSize = 10;
      cell.cellStyle.bold = true;

      // Ürün sayısı
      cell = sheet.getRangeByIndex(row, col++);
      cell.setNumber(categoryProducts.length.toDouble());
      cell.cellStyle.fontSize = 10;
      cell.cellStyle.hAlign = xlsio.HAlignType.center;

      // Toplam adet
      cell = sheet.getRangeByIndex(row, col++);
      cell.setNumber(catTotalQuantity.toDouble());
      cell.cellStyle.fontSize = 10;
      cell.cellStyle.hAlign = xlsio.HAlignType.center;

      // Planlanan
      cell = sheet.getRangeByIndex(row, col++);
      cell.setText(_formatCurrency(catPlanned));
      cell.cellStyle.fontSize = 10;
      cell.cellStyle.hAlign = xlsio.HAlignType.right;

      // Harcanan
      cell = sheet.getRangeByIndex(row, col++);
      cell.setText(_formatCurrency(catSpent));
      cell.cellStyle.fontSize = 10;
      cell.cellStyle.hAlign = xlsio.HAlignType.right;
      cell.cellStyle.backColor = '#D1FAE5';

      // Kalan
      cell = sheet.getRangeByIndex(row, col++);
      cell.setText(_formatCurrency(catRemaining));
      cell.cellStyle.fontSize = 10;
      cell.cellStyle.hAlign = xlsio.HAlignType.right;

      // Tamamlanma %
      cell = sheet.getRangeByIndex(row, col++);
      cell.setText('%${catCompletion.toStringAsFixed(1)}');
      cell.cellStyle.fontSize = 10;
      cell.cellStyle.hAlign = xlsio.HAlignType.center;
      cell.cellStyle.backColor = catCompletion >= 80
        ? '#D1FAE5'
        : catCompletion >= 50
          ? '#FEF3C7'
          : '#FEE2E2';

      row++;
    }

    row += 2;

    // ═══════════════════════════════════════════════════════════════════
    // BÖLÜM 4: EN ÇOK HARCAMA YAPILAN KATEGORİLER (TOP 5)
    // ═══════════════════════════════════════════════════════════════════
    cell = sheet.getRangeByIndex(row, 1);
    cell.setText('🔝 EN ÇOK HARCAMA YAPILAN 5 KATEGORİ');
    cell.cellStyle.bold = true;
    cell.cellStyle.fontSize = 14;
    cell.cellStyle.fontColor = _primaryColorHex;
    row += 2;

    // Kategorileri harcamaya göre sırala
    final categorySpending = categories.map((category) {
      final categoryProducts = products.where((p) => p.category == category.id).toList();
      final spent = categoryProducts.where((p) => p.isPurchased).fold<double>(
        0,
        (sum, p) => sum + (p.price * p.quantity),
      );
      return {'category': category, 'spent': spent};
    }).toList();

    categorySpending.sort((a, b) => (b['spent'] as double).compareTo(a['spent'] as double));

    final topCategories = categorySpending.take(5).toList();

    for (int i = 0; i < topCategories.length; i++) {
      final categoryData = topCategories[i];
      final category = categoryData['category'] as CategoryModel;
      final spent = categoryData['spent'] as double;

      if (spent == 0) continue;

      // Sıra
      cell = sheet.getRangeByIndex(row, 1);
      cell.setText('${i + 1}.');
      cell.cellStyle.bold = true;
      cell.cellStyle.fontSize = 12;

      // Kategori adı
      cell = sheet.getRangeByIndex(row, 2);
      cell.setText(category.displayName);
      cell.cellStyle.fontSize = 11;
      cell.cellStyle.bold = true;

      // Harcama
      cell = sheet.getRangeByIndex(row, 3);
      cell.setText(_formatCurrency(spent));
      cell.cellStyle.fontSize = 11;
      cell.cellStyle.hAlign = xlsio.HAlignType.right;
      cell.cellStyle.backColor = i == 0 ? '#DBEAFE' : _surfaceColorHex;

      row++;
    }

    row += 2;

    // ═══════════════════════════════════════════════════════════════════
    // BÖLÜM 5: DURUM ANALİZİ
    // ═══════════════════════════════════════════════════════════════════
    cell = sheet.getRangeByIndex(row, 1);
    cell.setText('⚠️ DURUM ANALİZİ');
    cell.cellStyle.bold = true;
    cell.cellStyle.fontSize = 14;
    cell.cellStyle.fontColor = _primaryColorHex;
    row += 2;

    // Durum mesajları
    final statusMessages = <String>[];

    if (remainingBudget < 0) {
      statusMessages.add('🔴 UYARI: Bütçe ${_formatCurrency(-remainingBudget)} aşıldı!');
    } else if (remainingBudget < totalBudget * 0.1) {
      statusMessages.add('🟡 DİKKAT: Bütçenin %90\'ı kullanıldı.');
    } else {
      statusMessages.add('🟢 İYİ: Bütçe kontrolü sağlanmış.');
    }

    final completionRate = totalProducts > 0 ? (purchasedProducts / totalProducts) * 100 : 0;
    if (completionRate >= 80) {
      statusMessages.add('🟢 MÜKEMMEL: %${completionRate.toStringAsFixed(0)} tamamlandı!');
    } else if (completionRate >= 50) {
      statusMessages.add('🟡 DEVAM EDİYOR: %${completionRate.toStringAsFixed(0)} tamamlandı.');
    } else if (completionRate > 0) {
      statusMessages.add('🔴 BAŞLANGIÇ: Daha %${completionRate.toStringAsFixed(0)} tamamlandı.');
    } else {
      statusMessages.add('⚪ BAŞLANMADI: Henüz ürün alınmadı.');
    }

    if (totalPlanned > totalBudget) {
      final excess = totalPlanned - totalBudget;
      statusMessages.add('🔴 PLANLAMA: Planlanan ${_formatCurrency(excess)} bütçeyi aşıyor!');
    }

    for (final message in statusMessages) {
      cell = sheet.getRangeByIndex(row, 1, row, 3);
      cell.merge();
      cell.setText(message);
      cell.cellStyle.fontSize = 11;
      cell.cellStyle.bold = true;

      if (message.startsWith('🔴')) {
        cell.cellStyle.backColor = '#FEE2E2';
        cell.cellStyle.fontColor = _dangerColorHex;
      } else if (message.startsWith('🟡')) {
        cell.cellStyle.backColor = '#FEF3C7';
        cell.cellStyle.fontColor = '#D97706';
      } else {
        cell.cellStyle.backColor = '#D1FAE5';
        cell.cellStyle.fontColor = _successColorHex;
      }

      row++;
    }

    // Kolon genişlikleri
    sheet.setColumnWidthInPixels(1, 220);
    sheet.setColumnWidthInPixels(2, 100);
    sheet.setColumnWidthInPixels(3, 100);
    sheet.setColumnWidthInPixels(4, 100);
    sheet.setColumnWidthInPixels(5, 100);
    sheet.setColumnWidthInPixels(6, 100);
    sheet.setColumnWidthInPixels(7, 100);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // YARDIMCI FONKSİYONLAR
  // ─────────────────────────────────────────────────────────────────────────

  /// Görseli indir ve boyutlandır (max 640px)
  static Future<Uint8List?> _downloadAndResizeImage(String url, int maxSize) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode != 200) return null;

      // Görseli decode et
      img.Image? image = img.decodeImage(response.bodyBytes);
      if (image == null) return null;

      // Boyutlandır (en-boy oranını koru, max 640px)
      if (image.width > maxSize || image.height > maxSize) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? maxSize : null,
          height: image.height > image.width ? maxSize : null,
        );
      }

      // PNG formatında encode et
      return Uint8List.fromList(img.encodePng(image));
    } catch (e) {
      // Görsel yüklenemezse null döndür
      return null;
    }
  }

  /// Para birimi formatla (Türkçe: 1.234,56)
  static String _formatCurrency(double value) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    return '₺${formatter.format(value).replaceAll(',', '.')}';
  }
}
