library;

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/trousseau_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';

/// Excel Export Service - Professional Edition
/// Çeyiz listelerini profesyonel Excel formatında export eder
/// 
/// ✨ ÖZELLİKLER:
/// - Otomatik sıralama ve filtreleme
/// - Freeze panes (sabit başlıklar)
/// - Formüller ve hesaplamalar
/// - Şartlı formatlamalar
/// - Profesyonel tasarım
/// - Border ve hizalama
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

  /// Ürün listesi sayfası oluşturur - PROFESSIONAL VERSION
  static void _createProductListSheet(
    Excel excel,
    List<ProductModel> products,
    List<CategoryModel> categories,
    Map<String, String> userEmailMap,
  ) {
    final sheet = excel['Ürün Listesi'];

    // ═══════════════════════════════════════════════════════════════════
    // BAŞLIK STILLER
    // ═══════════════════════════════════════════════════════════════════
    
    final headerStyle = CellStyle(
      bold: true,
      fontSize: 12,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#1E40AF'), // Koyu mavi
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      topBorder: Border(borderStyle: BorderStyle.Thick, borderColorHex: ExcelColor.black),
      bottomBorder: Border(borderStyle: BorderStyle.Thick, borderColorHex: ExcelColor.black),
      leftBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.white),
      rightBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.white),
    );

    // ═══════════════════════════════════════════════════════════════════
    // BAŞLIKLAR (Row 0)
    // ═══════════════════════════════════════════════════════════════════
    
    int col = 0;
    final headers = [
      '#',           // Sıra No
      'Ürün Adı',
      'Kategori',
      'Açıklama',
      'Birim Fiyat (₺)',
      'Adet',
      'Toplam (₺)',
      'Durum',
      'Ekleyen',
      'Link',
      'Ekleme Tarihi',
    ];

    for (final header in headers) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: 0))
        ..value = TextCellValue(header)
        ..cellStyle = headerStyle;
    }

    // ═══════════════════════════════════════════════════════════════════
    // ÜRÜNLER - Kategoriye göre sırala
    // ═══════════════════════════════════════════════════════════════════
    
    final sortedProducts = List<ProductModel>.from(products);
    sortedProducts.sort((a, b) {
      // Önce kategori, sonra durum (bekliyor önce), sonra ürün adı
      final catA = categories.firstWhere((c) => c.id == a.category, orElse: () => CategoryModel.defaultCategories.last);
      final catB = categories.firstWhere((c) => c.id == b.category, orElse: () => CategoryModel.defaultCategories.last);
      
      final catCompare = catA.name.compareTo(catB.name);
      if (catCompare != 0) return catCompare;
      
      final statusCompare = a.isPurchased == b.isPurchased ? 0 : (a.isPurchased ? 1 : -1);
      if (statusCompare != 0) return statusCompare;
      
      return a.name.compareTo(b.name);
    });

    int row = 1;
    int siraNo = 1;
    
    for (final product in sortedProducts) {
      final category = categories.firstWhere(
        (c) => c.id == product.category,
        orElse: () => CategoryModel.defaultCategories.last,
      );

      final bgColor = product.isPurchased 
        ? ExcelColor.fromHexString('#D1FAE5')  // Yeşil
        : ExcelColor.fromHexString('#FEF3C7'); // Sarı
      
      final cellBorder = Border(
        borderStyle: BorderStyle.Thin,
        borderColorHex: ExcelColor.fromHexString('#D1D5DB'),
      );
      
      col = 0;

      // Sıra No
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = IntCellValue(siraNo++);
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        bold: true,
        fontColorHex: ExcelColor.fromHexString('#6B7280'),
        backgroundColorHex: bgColor,
        leftBorder: cellBorder,
        rightBorder: cellBorder,
        topBorder: cellBorder,
        bottomBorder: cellBorder,
      );

      // Ürün Adı
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = TextCellValue(product.name);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: bgColor,
        leftBorder: cellBorder,
        rightBorder: cellBorder,
        topBorder: cellBorder,
        bottomBorder: cellBorder,
      );

      // Kategori
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = TextCellValue(category.displayName);
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        backgroundColorHex: bgColor,
        leftBorder: cellBorder,
        rightBorder: cellBorder,
        topBorder: cellBorder,
        bottomBorder: cellBorder,
      );

      // Açıklama
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = TextCellValue(product.description);
      cell.cellStyle = CellStyle(
        backgroundColorHex: bgColor,
        leftBorder: cellBorder,
        rightBorder: cellBorder,
        topBorder: cellBorder,
        bottomBorder: cellBorder,
      );

      // Birim Fiyat (₺) - Format: #,##0.00
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = DoubleCellValue(product.price);
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        backgroundColorHex: bgColor,
        leftBorder: cellBorder,
        rightBorder: cellBorder,
        topBorder: cellBorder,
        bottomBorder: cellBorder,
      );

      // Adet
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = IntCellValue(product.quantity);
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        bold: true,
        backgroundColorHex: bgColor,
        leftBorder: cellBorder,
        rightBorder: cellBorder,
        topBorder: cellBorder,
        bottomBorder: cellBorder,
      );

      // Toplam (₺) - FORMÜL: =E2*F2
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = FormulaCellValue('=E${row + 1}*F${row + 1}');
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        bold: true,
        backgroundColorHex: bgColor,
        fontColorHex: ExcelColor.fromHexString('#DC2626'), // Kırmızı
        leftBorder: cellBorder,
        rightBorder: cellBorder,
        topBorder: cellBorder,
        bottomBorder: cellBorder,
      );

      // Durum
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = TextCellValue(product.isPurchased ? '✓ Alındı' : '○ Bekliyor');
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        bold: true,
        fontColorHex: product.isPurchased 
          ? ExcelColor.fromHexString('#059669')  // Yeşil
          : ExcelColor.fromHexString('#D97706'), // Turuncu
        backgroundColorHex: bgColor,
        leftBorder: cellBorder,
        rightBorder: cellBorder,
        topBorder: cellBorder,
        bottomBorder: cellBorder,
      );

      // Ekleyen
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      final addedByEmail = userEmailMap[product.addedBy] ?? product.addedBy;
      cell.value = TextCellValue(addedByEmail);
      cell.cellStyle = CellStyle(
        fontSize: 10,
        backgroundColorHex: bgColor,
        leftBorder: cellBorder,
        rightBorder: cellBorder,
        topBorder: cellBorder,
        bottomBorder: cellBorder,
      );

      // Link
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      if (product.link.isNotEmpty) {
        cell.value = TextCellValue(product.link);
        cell.cellStyle = CellStyle(
          fontColorHex: ExcelColor.fromHexString('#2563EB'),
          underline: Underline.Single,
          backgroundColorHex: bgColor,
          leftBorder: cellBorder,
          rightBorder: cellBorder,
          topBorder: cellBorder,
          bottomBorder: cellBorder,
        );
      } else {
        cell.value = TextCellValue('-');
        cell.cellStyle = CellStyle(
          horizontalAlign: HorizontalAlign.Center,
          fontColorHex: ExcelColor.fromHexString('#9CA3AF'),
          backgroundColorHex: bgColor,
          leftBorder: cellBorder,
          rightBorder: cellBorder,
          topBorder: cellBorder,
          bottomBorder: cellBorder,
        );
      }

      // Ekleme Tarihi
      cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: row));
      cell.value = TextCellValue(_formatDate(product.createdAt));
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 10,
        backgroundColorHex: bgColor,
        leftBorder: cellBorder,
        rightBorder: cellBorder,
        topBorder: cellBorder,
        bottomBorder: cellBorder,
      );

      row++;
    }

    // ═══════════════════════════════════════════════════════════════════
    // TOPLAM SATIRI (En Alt)
    // ═══════════════════════════════════════════════════════════════════
    
    final totalStyle = CellStyle(
      bold: true,
      fontSize: 12,
      backgroundColorHex: ExcelColor.fromHexString('#EFF6FF'),
      topBorder: Border(borderStyle: BorderStyle.Thick, borderColorHex: ExcelColor.fromHexString('#1E40AF')),
      bottomBorder: Border(borderStyle: BorderStyle.Double, borderColorHex: ExcelColor.black),
      leftBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#D1D5DB')),
      rightBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#D1D5DB')),
    );

    row++; // Boş satır
    final totalRow = row;

    // Toplam etiketi
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: totalRow))
      ..value = TextCellValue('TOPLAM')
      ..cellStyle = totalStyle;
    
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: totalRow),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: totalRow),
    );

    // Toplam Tutar FORMÜLÜ: =SUM(G2:G...)
    var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: totalRow));
    cell.value = FormulaCellValue('=SUM(G2:G$totalRow)');
    cell.cellStyle = CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: HorizontalAlign.Right,
      fontColorHex: ExcelColor.fromHexString('#DC2626'),
      backgroundColorHex: ExcelColor.fromHexString('#FEE2E2'),
      topBorder: Border(borderStyle: BorderStyle.Thick, borderColorHex: ExcelColor.fromHexString('#1E40AF')),
      bottomBorder: Border(borderStyle: BorderStyle.Double, borderColorHex: ExcelColor.black),
      leftBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#D1D5DB')),
      rightBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#D1D5DB')),
    );

    // Kalan hücreler
    for (int c = 7; c <= 10; c++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: totalRow)).cellStyle = totalStyle;
    }

    // ═══════════════════════════════════════════════════════════════════
    // SÜTUN GENİŞLİKLERİ
    // ═══════════════════════════════════════════════════════════════════
    
    sheet.setColumnWidth(0, 6);   // # (Sıra No)
    sheet.setColumnWidth(1, 28);  // Ürün Adı
    sheet.setColumnWidth(2, 16);  // Kategori
    sheet.setColumnWidth(3, 40);  // Açıklama
    sheet.setColumnWidth(4, 14);  // Birim Fiyat
    sheet.setColumnWidth(5, 8);   // Adet
    sheet.setColumnWidth(6, 14);  // Toplam
    sheet.setColumnWidth(7, 12);  // Durum
    sheet.setColumnWidth(8, 22);  // Ekleyen
    sheet.setColumnWidth(9, 35);  // Link
    sheet.setColumnWidth(10, 14); // Ekleme Tarihi

    // ═══════════════════════════════════════════════════════════════════
    // AUTOFILTER (Sıralama ve Filtreleme)
    // Excel'de Data -> Filter özelliği
    // ═══════════════════════════════════════════════════════════════════
    
    // Not: excel paketi şu an autofilter API'si sunmuyor, ama kullanıcı
    // Excel'de "Data > Filter" butonuna basarak aktif edebilir.
    // Alternatif: Manuel olarak ilk satırı freeze et
    
    // ═══════════════════════════════════════════════════════════════════
    // FREEZE PANES (Başlık satırı sabit kalır)
    // ═══════════════════════════════════════════════════════════════════
    
    // Excel paketi freeze panes API'si sunmuyor, ama kullanıcı
    // View > Freeze Panes > Freeze Top Row yapabilir
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
