// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Mock catalogue that backs the Phase 1 navigable prototype.

/// Destinations shown by the redesigned ComfyGo screens.
///
/// The photos are the locally bundled, destination-specific sets that live in
/// `assets/images/<Destination>/`. Each entry keeps every photo so the detail
/// screen can show the full gallery.
class ComfyDestination {
  final int id;
  final String name;
  final String region;
  final String category;
  final int price;
  final String km;
  final String time;
  final String description;
  final List<String> images;

  const ComfyDestination({
    required this.id,
    required this.name,
    required this.region,
    required this.category,
    required this.price,
    required this.km,
    required this.time,
    required this.description,
    required this.images,
  });

  String get cover => images.first;
  String get thumb => images.length > 1 ? images[1] : images.first;
  String get priceLabel => '৳${_thousands(price)}';
  String get locationLine => '$km • $region';
  String get reviews => '5.0 reviews';
  String get dateRange => '20 – 25 May';
}

String _thousands(int value) {
  final digits = value.toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return out.toString();
}

const List<ComfyDestination> comfyDestinations = [
  ComfyDestination(
    id: 1,
    name: 'Sreemangal',
    region: 'Sylhet',
    category: 'Tea',
    price: 3200,
    km: '42km',
    time: '2h 40min',
    description:
        'Rolling emerald tea estates, misty dawns and the quiet of Lawachara '
        'rainforest. Walk the hills, taste seven-layer tea and stay in a '
        'garden bungalow.',
    images: [
      'assets/images/Srimangal/Srimangal_1.jfif',
      'assets/images/Srimangal/Srimangal_2.jfif',
      'assets/images/Srimangal/Srimangal_3.jfif',
      'assets/images/Srimangal/Srimangal_4.jfif',
      'assets/images/Srimangal/Srimangal_5.jfif',
      'assets/images/Srimangal/Srimangal_6.jfif',
    ],
  ),
  ComfyDestination(
    id: 2,
    name: 'Cox’s Bazar',
    region: 'Chattogram',
    category: 'Beach',
    price: 5400,
    km: '390km',
    time: '7h 15min',
    description:
        'The longest natural sea beach in the world. Sunrise walks, fresh '
        'seafood and a calm stretch at Inani.',
    images: [
      'assets/images/Coxs Bazar/Coxs_Bazar.jfif',
      'assets/images/Coxs Bazar/Coxs_Bazar (2).jfif',
      'assets/images/Coxs Bazar/Coxs_Bazar (3).jfif',
      'assets/images/Coxs Bazar/Coxs_Bazar (4).jfif',
      'assets/images/Coxs Bazar/Coxs_Bazar (5).jfif',
      'assets/images/Coxs Bazar/Coxs_Bazar (6).jfif',
    ],
  ),
  ComfyDestination(
    id: 3,
    name: 'Sundarbans',
    region: 'Khulna',
    category: 'Forest',
    price: 6800,
    km: '320km',
    time: '6h 30min',
    description:
        'Drift through the mangrove delta by boat, home of the Royal Bengal '
        'tiger and spotted deer.',
    images: [
      'assets/images/Sundarban/Sundarbans.jfif',
      'assets/images/Sundarban/Sundorbon (2).jfif',
      'assets/images/Sundarban/Sundorbon (3).jfif',
      'assets/images/Sundarban/Sundorbon (4).jfif',
      'assets/images/Sundarban/Sundorbon (5).jfif',
      'assets/images/Sundarban/Sundorbon (6).jfif',
      'assets/images/Sundarban/Sundorbon.jfif',
    ],
  ),
  ComfyDestination(
    id: 4,
    name: 'Bandarban',
    region: 'Chattogram',
    category: 'Mountain',
    price: 4500,
    km: '330km',
    time: '8h 00min',
    description:
        'Cloud-level hill trails, tribal villages and waterfalls above the '
        'Sangu river.',
    images: [
      'assets/images/Bandarban/Bandarban.jfif',
      'assets/images/Bandarban/Bandarban (2).jfif',
      'assets/images/Bandarban/Bandarban (3).jfif',
      'assets/images/Bandarban/Bandarban (4).jfif',
      'assets/images/Bandarban/Bandarban (5).jfif',
      'assets/images/Bandarban/Bandarban (6).jfif',
    ],
  ),
];

/// Horizontal category filters, in reference order.
const List<String> comfyCategories = [
  'All',
  'Beach',
  'Mountain',
  'Forest',
  'Tea',
];

ComfyDestination? comfyDestinationById(int id) {
  for (final item in comfyDestinations) {
    if (item.id == id) return item;
  }
  return null;
}

List<ComfyDestination> comfyDestinationsFor(String category) {
  if (category == 'All') return comfyDestinations;
  return comfyDestinations.where((item) => item.category == category).toList();
}
