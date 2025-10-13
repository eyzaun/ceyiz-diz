import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String displayName;
  final IconData icon;
  final Color color;
  final int sortOrder;
  final bool isCustom;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
    required this.sortOrder,
    this.isCustom = false,
  });

  static const List<CategoryModel> defaultCategories = [
    CategoryModel(
      id: 'livingroom',
      name: 'livingroom',
      displayName: 'Salon',
      icon: Icons.weekend,
      color: Color(0xFF6B4EFF),
      sortOrder: 1,
    ),
    CategoryModel(
      id: 'kitchen',
      name: 'kitchen',
      displayName: 'Mutfak',
      icon: Icons.kitchen,
      color: Color(0xFFFF6B9D),
      sortOrder: 2,
    ),
    CategoryModel(
      id: 'bathroom',
      name: 'bathroom',
      displayName: 'Banyo',
      icon: Icons.bathtub,
      color: Color(0xFF00C896),
      sortOrder: 3,
    ),
    CategoryModel(
      id: 'bedroom',
      name: 'bedroom',
      displayName: 'Yatak Odası',
      icon: Icons.bed,
      color: Color(0xFF2196F3),
      sortOrder: 4,
    ),
    CategoryModel(
      id: 'clothing',
      name: 'clothing',
      displayName: 'Kıyafet',
      icon: Icons.checkroom,
      color: Color(0xFF9C27B0),
      sortOrder: 5,
    ),
    CategoryModel(
      id: 'other',
      name: 'other',
      displayName: 'Diğer',
      icon: Icons.category,
      color: Color(0xFF607D8B),
      sortOrder: 6,
    ),
  ];

  /// Returns a default category by id, or 'other' if not found.
  static CategoryModel getDefaultById(String id) {
    return defaultCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => defaultCategories.last,
    );
  }

  /// Backwards-compatible alias for legacy code.
  static CategoryModel getCategoryById(String id) => getDefaultById(id);

  /// Construct a custom category from Firestore data.
  factory CategoryModel.fromMap(Map<String, dynamic> data, String id) {
    final name = (data['name'] ?? id).toString();
    final displayName = (data['displayName'] ?? name).toString();
    final sortOrder = (data['sortOrder'] is int)
        ? data['sortOrder'] as int
        : int.tryParse('${data['sortOrder']}') ?? 1000;
    
    // BACKWARD COMPATIBILITY: Determine isCustom
    // 1. If field exists, use it
    // 2. If ID contains '__', it's old format custom category
    // 3. If ID is in default list, it's default
    // 4. Otherwise, it's custom
    bool isCustom;
    if (data.containsKey('isCustom') && data['isCustom'] is bool) {
      isCustom = data['isCustom'] as bool;
    } else if (id.contains('__')) {
      // Old format: userId__categoryId
      isCustom = true;
    } else {
      // Check if it's a default category ID
      isCustom = !defaultCategories.any((c) => c.id == id);
    }
    
  // Optional persisted visuals
  final String? iconKey = data['iconKey'] as String?;
  final int? iconCode = data['iconCode'] is int
    ? data['iconCode'] as int
    : int.tryParse('${data['iconCode']}');
  final int? colorValue = data['colorValue'] is int
    ? data['colorValue'] as int
    : int.tryParse('${data['colorValue']}');
    return CategoryModel(
      id: id,
      name: name,
      displayName: displayName,
    icon: _resolveIcon(iconKey: iconKey, iconCode: iconCode),
      color: colorValue != null ? Color(colorValue) : colorFromString(id),
      sortOrder: sortOrder,
      isCustom: isCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'displayName': displayName,
      'sortOrder': sortOrder,
      // Persist visuals for custom categories
      'iconCode': icon.codePoint,
      'iconKey': iconKeyFor(icon),
  'colorValue': color.toARGB32(),
    };
  }

  /// Computes a consistent color from a string.
  static Color colorFromString(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = input.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final double hue = (hash % 360).toDouble();
    final hsv = HSVColor.fromAHSV(1.0, hue, 0.45, 0.85);
    return hsv.toColor();
  }
}

// A curated set of icons that the app supports for custom categories.
// Using const IconData references here keeps the icon font shakeable and avoids
// runtime IconData constructions which break web builds.
const Map<String, IconData> kCategoryIcons = <String, IconData>{
  // Default categories
  'category': Icons.category,
  'kitchen': Icons.kitchen,
  'weekend': Icons.weekend,
  'bathtub': Icons.bathtub,
  'bed': Icons.bed,
  'checkroom': Icons.checkroom,
  
  // Furniture & Home
  'chair_alt': Icons.chair_alt,
  'table_restaurant': Icons.table_restaurant,
  'door_sliding': Icons.door_sliding,
  'window': Icons.window,
  'garage': Icons.garage,
  'deck': Icons.deck,
  'balcony': Icons.balcony,
  'roofing': Icons.roofing,
  'cottage': Icons.cottage,
  'house': Icons.house,
  'apartment': Icons.apartment,
  'stairs': Icons.stairs,
  
  // Kitchen & Dining
  'blender': Icons.blender,
  'coffee_maker': Icons.coffee_maker,
  'microwave': Icons.microwave,
  'soup_kitchen': Icons.soup_kitchen,
  'restaurant': Icons.restaurant,
  'local_dining': Icons.local_dining,
  'dinner_dining': Icons.dinner_dining,
  'breakfast_dining': Icons.breakfast_dining,
  'lunch_dining': Icons.lunch_dining,
  'flatware': Icons.flatware,
  'rice_bowl': Icons.rice_bowl,
  'restaurant_menu': Icons.restaurant_menu,
  'bakery_dining': Icons.bakery_dining,
  'ramen_dining': Icons.ramen_dining,
  'egg': Icons.egg,
  'icecream': Icons.icecream,
  'local_pizza': Icons.local_pizza,
  'local_cafe': Icons.local_cafe,
  'liquor': Icons.liquor,
  'wine_bar': Icons.wine_bar,
  'local_bar': Icons.local_bar,
  'fastfood': Icons.fastfood,
  'set_meal': Icons.set_meal,
  
  // Appliances & Electronics
  'tv': Icons.tv,
  'computer': Icons.computer,
  'phone_android': Icons.phone_android,
  'tablet': Icons.tablet,
  'watch': Icons.watch,
  'headphones': Icons.headphones,
  'speaker': Icons.speaker,
  'wifi': Icons.wifi,
  'iron': Icons.iron,
  'local_laundry_service': Icons.local_laundry_service,
  'air': Icons.air,
  'lightbulb': Icons.lightbulb,
  'light': Icons.light,
  'laptop': Icons.laptop,
  'desktop_windows': Icons.desktop_windows,
  'keyboard': Icons.keyboard,
  'mouse': Icons.mouse,
  'router': Icons.router,
  'devices': Icons.devices,
  'cast': Icons.cast,
  
  // Cleaning & Maintenance
  'cleaning_services': Icons.cleaning_services,
  'shower': Icons.shower,
  'soap': Icons.soap,
  'bathroom': Icons.bathroom,
  'spa': Icons.spa,
  
  // Bedroom & Comfort
  'airline_seat_individual_suite': Icons.airline_seat_individual_suite,
  'nightlight': Icons.nightlight,
  'alarm': Icons.alarm,
  'hotel': Icons.hotel,
  
  // Clothing & Fashion
  'dry_cleaning': Icons.dry_cleaning,
  'shopping_bag': Icons.shopping_bag,
  'backpack': Icons.backpack,
  'watch_outlined': Icons.watch_outlined,
  'diamond': Icons.diamond,
  
  // Living & Entertainment
  'book': Icons.book,
  'music_note': Icons.music_note,
  'sports_esports': Icons.sports_esports,
  'camera_alt': Icons.camera_alt,
  'palette': Icons.palette,
  'brush': Icons.brush,
  'photo_camera': Icons.photo_camera,
  'videocam': Icons.videocam,
  'library_books': Icons.library_books,
  'menu_book': Icons.menu_book,
  'theater_comedy': Icons.theater_comedy,
  
  // Storage & Organization
  'inventory_2': Icons.inventory_2,
  'folder': Icons.folder,
  'archive': Icons.archive,
  'storage': Icons.storage,
  'label': Icons.label,
  
  // Decoration
  'auto_awesome': Icons.auto_awesome,
  'star': Icons.star,
  'favorite': Icons.favorite,
  'celebration': Icons.celebration,
  'cake': Icons.cake,
  'wallet_giftcard': Icons.wallet_giftcard,
  'redeem': Icons.redeem,
  'filter_vintage': Icons.filter_vintage,
  'emoji_events': Icons.emoji_events,
  'workspace_premium': Icons.workspace_premium,
  
  // Miscellaneous
  'extension': Icons.extension,
  'home_work': Icons.home_work,
  'handyman': Icons.handyman,
  'build': Icons.build,
  'settings': Icons.settings,
  'shopping_cart': Icons.shopping_cart,
  'local_mall': Icons.local_mall,
  'construction': Icons.construction,
  'hardware': Icons.hardware,
  'plumbing': Icons.plumbing,
  'electrical_services': Icons.electrical_services,
  'carpenter': Icons.carpenter,
  
  // Garden & Outdoor
  'yard': Icons.yard,
  'grass': Icons.grass,
  'forest': Icons.forest,
  'park': Icons.park,
  'nature': Icons.nature,
  'local_florist': Icons.local_florist,
  'eco': Icons.eco,
  'water_drop': Icons.water_drop,
  'wb_sunny': Icons.wb_sunny,
  'nightlight_round': Icons.nightlight_round,
  'umbrella': Icons.umbrella,
  'beach_access': Icons.beach_access,
  'waves': Icons.waves,
  'terrain': Icons.terrain,
  'landscape': Icons.landscape,
  
  // Baby & Kids
  'child_friendly': Icons.child_friendly,
  'baby_changing_station': Icons.baby_changing_station,
  'toys': Icons.toys,
  'stroller': Icons.stroller,
  'crib': Icons.crib,
  'child_care': Icons.child_care,
  
  // Sports & Fitness
  'fitness_center': Icons.fitness_center,
  'sports_basketball': Icons.sports_basketball,
  'sports_soccer': Icons.sports_soccer,
  'sports_tennis': Icons.sports_tennis,
  'pool': Icons.pool,
  'surfing': Icons.surfing,
  'skateboarding': Icons.skateboarding,
  'hiking': Icons.hiking,
  'rowing': Icons.rowing,
  'sailing': Icons.sailing,
  
  // Pets
  'pets': Icons.pets,
  'cruelty_free': Icons.cruelty_free,
  
  // Health & Medical
  'medical_services': Icons.medical_services,
  'local_hospital': Icons.local_hospital,
  'medication': Icons.medication,
  'health_and_safety': Icons.health_and_safety,
  'sanitizer': Icons.sanitizer,
  'masks': Icons.masks,
  'vaccines': Icons.vaccines,
  
  // Transportation
  'directions_car': Icons.directions_car,
  'directions_bike': Icons.directions_bike,
  'directions_bus': Icons.directions_bus,
  'flight': Icons.flight,
  'luggage': Icons.luggage,
  'local_shipping': Icons.local_shipping,
  
  // Communication & Social
  'phone': Icons.phone,
  'email': Icons.email,
  'chat': Icons.chat,
  'forum': Icons.forum,
  'groups': Icons.groups,
  'person': Icons.person,
  'people': Icons.people,
  'family_restroom': Icons.family_restroom,
  
  // Time & Calendar
  'calendar_today': Icons.calendar_today,
  'event': Icons.event,
  'schedule': Icons.schedule,
  'access_time': Icons.access_time,
  'timer': Icons.timer,
  'hourglass_empty': Icons.hourglass_empty,
  
  // Weather
  'cloud': Icons.cloud,
  'cloud_queue': Icons.cloud_queue,
  'thunderstorm': Icons.thunderstorm,
  'ac_unit': Icons.ac_unit,
  
  // Money & Finance
  'attach_money': Icons.attach_money,
  'euro_symbol': Icons.euro_symbol,
  'currency_lira': Icons.currency_lira,
  'credit_card': Icons.credit_card,
  'account_balance': Icons.account_balance,
  'account_balance_wallet': Icons.account_balance_wallet,
  'savings': Icons.savings,
  'paid': Icons.paid,
  'payment': Icons.payment,
  'point_of_sale': Icons.point_of_sale,
  
  // Education & Learning
  'school': Icons.school,
  'class_': Icons.class_,
  'auto_stories': Icons.auto_stories,
  'bookmark': Icons.bookmark,
  'science': Icons.science,
  
  // Art & Creativity
  'draw': Icons.draw,
  'edit': Icons.edit,
  'create': Icons.create,
  'color_lens': Icons.color_lens,
  'format_paint': Icons.format_paint,
  'gradient': Icons.gradient,
  
  // Navigation & Location
  'location_on': Icons.location_on,
  'place': Icons.place,
  'map': Icons.map,
  'explore': Icons.explore,
  'navigation': Icons.navigation,
  
  // Security
  'lock': Icons.lock,
  'vpn_key': Icons.vpn_key,
  'security': Icons.security,
  'shield': Icons.shield,
  'verified': Icons.verified,
  'verified_user': Icons.verified_user,
  
  // Business & Office
  'business': Icons.business,
  'business_center': Icons.business_center,
  'work': Icons.work,
  'badge': Icons.badge,
  'print': Icons.print,
  'description': Icons.description,
  'article': Icons.article,
  'receipt': Icons.receipt,
  
  // Miscellaneous Extended
  'dashboard': Icons.dashboard,
  'widgets': Icons.widgets,
  'apps': Icons.apps,
  'grid_view': Icons.grid_view,
  'view_list': Icons.view_list,
  'flag': Icons.flag,
  'whatshot': Icons.whatshot,
  'new_releases': Icons.new_releases,
  'tips_and_updates': Icons.tips_and_updates,
  'emoji_objects': Icons.emoji_objects,
  'sentiment_satisfied': Icons.sentiment_satisfied,
  'mood': Icons.mood,
  'bolt': Icons.bolt,
  'power': Icons.power,
};

IconData _resolveIcon({String? iconKey, int? iconCode}) {
  if (iconKey != null) {
    final v = kCategoryIcons[iconKey];
    if (v != null) return v;
  }
  if (iconCode != null) {
    // Best-effort: find matching const icon by codePoint
    for (final entry in kCategoryIcons.entries) {
      if (entry.value.codePoint == iconCode) return entry.value;
    }
  }
  return Icons.category;
}

String? iconKeyFor(IconData icon) {
  for (final entry in kCategoryIcons.entries) {
    if (entry.value.codePoint == icon.codePoint && entry.value.fontFamily == icon.fontFamily) {
      return entry.key;
    }
  }
  return null;
}