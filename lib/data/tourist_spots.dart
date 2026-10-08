/// Division-wise tourist spots of Bangladesh.
///
/// Content: description, how to reach, best time to visit and travel tips.
/// Photos are real, locally bundled Bangladesh photography (see
/// `assets/images/spots/`). Spots are for inspiration — the app books
/// hotels and transport, not the spots themselves.
class TouristSpot {
  final String id;
  final String name;
  final String division;
  final String district;
  final String tagline;
  final String description;
  final String howToReach;
  final String bestTime;
  final List<String> highlights;
  final List<String> tips;
  final String photo;

  const TouristSpot({
    required this.id,
    required this.name,
    required this.division,
    required this.district,
    required this.tagline,
    required this.description,
    required this.howToReach,
    required this.bestTime,
    required this.highlights,
    required this.tips,
    required this.photo,
  });
}

const String _bdDivisionsNote =
    'Bus, train and launch services connect most districts; book hotels in '
    'advance during national holidays.';

const List<TouristSpot> touristSpots = [
  // ─── DHAKA ────────────────────────────────────────────────────────────
  TouristSpot(
    id: 'ahsan-manzil',
    name: 'Ahsan Manzil',
    division: 'Dhaka',
    district: 'Dhaka',
    tagline: 'The Pink Palace on the Buriganga',
    description:
        'Ahsan Manzil was the official residence of the Nawab of Dhaka and is '
        'now a national museum. Its bright pink façade, wide river-facing '
        'lawns and colonial architecture make it one of the most recognisable '
        'landmarks of Old Dhaka.',
    howToReach:
        'Take the metro rail to Bangla or Kamalapur station, then a short '
        'rickshaw ride to Sadarghat. From Gulistan, rickshaws and buses run '
        'regularly to the palace gate. $_bdDivisionsNote',
    bestTime: 'October to March, on a cool dry morning',
    highlights: ['Pink palace museum', 'River views', 'Heritage gardens'],
    tips: [
      'Reach early (9:00 AM) to avoid crowds and get soft light for photos.',
      'Carry a valid photo ID for museum entry.',
      'Explore nearby Star Mosque and Armanitola after your visit.',
    ],
    photo: 'assets/images/spots/ahsan_manzil.jpg',
  ),
  TouristSpot(
    id: 'lalbagh-fort',
    name: 'Lalbagh Fort',
    division: 'Dhaka',
    district: 'Dhaka',
    tagline: 'A 17th-century Mughal fortress',
    description:
        'Lalbagh Fort is an unfinished Mughal fort begun in 1678. Inside its '
        'high walls you will find a mosque, the tomb of Pari Bibi, and a '
        'museum of Mughal artefacts, all wrapped in quiet gardens.',
    howToReach:
        'The fort sits in the heart of Old Dhaka. Rickshaws from Gulistan or '
        'Motijheel reach it in minutes; metro to Bangla station is a short '
        'walk away. $_bdDivisionsNote',
    bestTime: 'November to February',
    highlights: ['Mughal architecture', 'Tomb of Pari Bibi', 'Fort museum'],
    tips: [
      'Visit on weekdays — Fridays are very busy with families.',
      'Hire the official guide at the gate for historical context.',
      'Combine with Ahsan Manzil; both are within two kilometres.',
    ],
    photo: 'assets/images/spots/lalbagh.jpg',
  ),
  TouristSpot(
    id: 'sonargaon',
    name: 'Sonargaon & Panam City',
    division: 'Dhaka',
    district: 'Narayanganj',
    tagline: 'Abandoned merchant streets of the medieval era',
    description:
        'Panam City is a ruined street of two-storey Hindu merchant houses '
        'from the 15th to 19th centuries, surrounded by ponds and mango '
        'groves. Nearby Sonargaon holds the Folk Art and Craft Museum.',
    howToReach:
        'About 40 km from Dhaka. Take a bus from Gulistan bound for '
        'Sonargaon or hire a car via the Dhaka–Sylhet highway; the site is a '
        '20-minute walk from Sonargaon bazaar. $_bdDivisionsNote',
    bestTime: 'October to March',
    highlights: ['Panam heritage street', 'Folk Art Museum', 'Goaldi Mosque'],
    tips: [
      'Wear comfortable shoes — the heritage street is long and open.',
      'Carry water and snacks; refreshment stalls are limited.',
      'Goaldi Mosque nearby is a peaceful, crowd-free stop.',
    ],
    photo: 'assets/images/spots/sonargaon.jpg',
  ),

  // ─── CHITTAGONG ───────────────────────────────────────────────────────
  TouristSpot(
    id: 'coxs-bazar',
    name: "Cox's Bazar",
    division: 'Chittagong',
    district: "Cox's Bazar",
    tagline: 'The world’s longest natural sandy sea beach',
    description:
        'Stretching more than 120 km along the Bay of Bengal, Cox’s Bazar is '
        'Bangladesh’s most popular seaside destination. Kalatali beach, '
        'Himchari waterfall and Inani’s crystal-clear rocks are the star '
        'attractions.',
    howToReach:
        'Direct flights from Dhaka land at Cox’s Bazar airport (30 minutes). '
        'Non-stop AC buses run overnight from Gabtoli and Sayedabad (8–9 '
        'hours). By road it is roughly 400 km via Chittagong. '
        '$_bdDivisionsNote',
    bestTime: 'November to February',
    highlights: ['Kalatali beach', 'Himchari waterfall', 'Inani rocks'],
    tips: [
      'Swim only in designated areas and watch the flag warnings.',
      'Book hotels months ahead for Eid and winter holidays.',
      'Take an early-morning trip to Inani to beat the crowds.',
      'Try fresh seafood at Laboni Point in the evening.',
    ],
    photo: 'assets/images/spots/coxs_bazar.jpg',
  ),
  TouristSpot(
    id: 'bandarban',
    name: 'Bandarban',
    division: 'Chittagong',
    district: 'Bandarban',
    tagline: 'Home of Bangladesh’s highest peaks',
    description:
        'Bandarban is a land of cloud-topped hills, winding roads and tribal '
        'villages. Nilgiri, Thiangkhang and Keokradong offer sweeping views, '
        'while the Buddha Dhatu Jadi and Balaghata add calm spiritual stops.',
    howToReach:
        'Buses leave Dhaka’s Sayedabad for Bandarban town (10–11 hours). '
        'From Chittagong, buses and jeeps run daily. Jeeps and pickups hire '
        'out for Nilgiri and Thiangkhang from the town stand. '
        '$_bdDivisionsNote',
    bestTime: 'October to March',
    highlights: ['Nilgiri viewpoint', 'Buddha Dhatu Jadi', 'Thiangkhang peak'],
    tips: [
      'Carry your national ID — army checkpoints verify visitors.',
      'Start viewpoint trips early; fog closes in by afternoon.',
      'Respect village customs and ask before photographing people.',
    ],
    photo: 'assets/images/spots/bandarban.jpg',
  ),
  TouristSpot(
    id: 'nilgiri',
    name: 'Nilgiri',
    division: 'Chittagong',
    district: 'Bandarban',
    tagline: 'Sea of clouds above the hills',
    description:
        'Nilgiri is a rolling hilltop resort on the Bandarban–Thanchi road, '
        'famous for its endless green ridges, bamboo cottages and the '
        'sensation of standing above the clouds at sunrise.',
    howToReach:
        'Jeeps and chander gari leave Bandarban town for Nilgiri (about two '
        'hours on a mountain road). Private cars can make the trip; the last '
        'kilometre is steep and scenic. $_bdDivisionsNote',
    bestTime: 'October to February',
    highlights: ['Sunrise above clouds', 'Hilltop cottages', 'Ridge walks'],
    tips: [
      'Stay overnight — sunrise beats any day visit.',
      'Book resort cottages well in advance for holidays.',
      'Carry a warm layer; nights on the ridge get cold.',
    ],
    photo: 'assets/images/spots/nilgiri.jpg',
  ),
  TouristSpot(
    id: 'sajek',
    name: 'Sajek Valley',
    division: 'Chittagong',
    district: 'Rangamati',
    tagline: 'The queen of hills',
    description:
        'Sajek is a high plateau of bamboo groves and gentle ridges where '
        'sunrise paints the valleys gold. Ruilui Para, Kesalong and Konglak '
        'peak are favourite stops for campers and photographers.',
    howToReach:
        'Fly or bus to Dhaka–Khagrachhari route, then chander gari from '
        'Dighinala or Khagrachhari town to Sajek (roughly 2–3 hours of hill '
        'road). $_bdDivisionsNote',
    bestTime: 'October to March',
    highlights: ['Konglak peak', 'Ruilui Para', 'Valley camping'],
    tips: [
      'Carry an ID card and reach the army camp for entry formalities.',
      'Nights are cold and windy — pack a jacket and a torch.',
      'Go during a full-moon week for the clearest night skies.',
    ],
    photo: 'assets/images/spots/sajek.jpg',
  ),
  TouristSpot(
    id: 'kaptai-lake',
    name: 'Kaptai Lake',
    division: 'Chittagong',
    district: 'Rangamati',
    tagline: 'Bangladesh’s largest artificial lake',
    description:
        'Kaptai Lake is a vast blue reservoir ringed by forested hills. Boat '
        'trips to Shubho Mongol Jhiri, the Hanging Bridge and the Rupharipara '
        'fishing villages make for an easy, beautiful day on the water.',
    howToReach:
        'Buses run from Dhaka and Chittagong to Rangamati town. Tourist boats '
        'and speedboats hire by the hour from the Kaptai jetty near town. '
        '$_bdDivisionsNote',
    bestTime: 'October to March',
    highlights: ['Hanging Bridge', 'Boat cruise', 'Chakma villages'],
    tips: [
      'Wear a life jacket on small boats; ask the operator first.',
      'Start boat trips before 10:00 AM for calm water.',
      'Buy Rangamati’s hand-woven textiles from co-operative shops.',
    ],
    photo: 'assets/images/spots/kaptai.jpg',
  ),
  TouristSpot(
    id: 'patenga',
    name: 'Patenga Beach',
    division: 'Chittagong',
    district: 'Chattogram',
    tagline: 'The city beach at the mouth of the Karnaphuli',
    description:
        'Patenga is a tidy sea beach where the Karnaphuli river meets the '
        'Bay of Bengal, a short drive from Chattogram city. Sunsets over the '
        'container ships and the nearby Naval Academy make it a local favourite.',
    howToReach:
        'From Chattogram city, rickshaws, CNGs and buses run to Patenga via '
        'the airport road (about 20 minutes). It is roughly 15 km from '
        'Kattoli terminal. $_bdDivisionsNote',
    bestTime: 'November to February',
    highlights: ['River-mouth sunset', 'Sea wall promenade', 'Nearby seafood'],
    tips: [
      'Go one hour before sunset for the best colours.',
      'Keep to the paved walkway; currents near the river mouth are strong.',
      'Pair with a visit to the Karnaphuli river bridge area.',
    ],
    photo: 'assets/images/spots/patenga.jpg',
  ),
  TouristSpot(
    id: 'saint-martin',
    name: "St. Martin's Island",
    division: 'Chittagong',
    district: "Cox's Bazar",
    tagline: 'Bangladesh’s only coral island',
    description:
        'A tiny island of coconut palms, white sand and coral rock, St. '
        'Martin’s is known locally as Narikel Jinjira. Life here moves by '
        'bicycle and boat, and the sea turns glassy in winter mornings.',
    howToReach:
        'Take a bus or flight to Teknaf, then a sea truck or trawler from '
        'Teknaf jetty to the island (2–3 hours). Boats run mainly October to '
        'May and stop in rough weather. $_bdDivisionsNote',
    bestTime: 'November to February',
    highlights: ['Coral rocks', 'Sunset point', 'Coconut groves'],
    tips: [
      'Check boat schedules the day before — services weather-dependent.',
      'Stay at a registered eco-resort and carry cash; no ATMs on the island.',
      'Avoid single-use plastics; keep the coral beach clean.',
    ],
    photo: 'assets/images/spots/saint_martin.jpg',
  ),

  // ─── SYLHET ───────────────────────────────────────────────────────────
  TouristSpot(
    id: 'srimangal',
    name: 'Srimangal Tea Gardens',
    division: 'Sylhet',
    district: 'Moulvibazar',
    tagline: 'The greenest corner of Bangladesh',
    description:
        'Srimangal is the tea capital of the country — hill after hill of '
        'trimmed tea bushes, the Lawachara rainforest, rubber plantations and '
        'the seven-cup tea stall. It is also the loveliest place for a slow '
        'weekend.',
    howToReach:
        'Trains from Dhaka reach Srimangal in about 6–7 hours; AC and '
        'non-AC buses run overnight too. From Sylhet it is a 2-hour road '
        'trip. Rickshaws and hired cars reach the gardens. '
        '$_bdDivisionsNote',
    bestTime: 'September to December, after the rains',
    highlights: ['Lawachara rainforest', 'Tea museum', 'Monrai waterfall'],
    tips: [
      'Take a guided forest walk in the morning for birds and gibbons.',
      'Visit a tea processing factory to see leaves being rolled and dried.',
      'Carry a light raincoat — showers can come any time.',
    ],
    photo: 'assets/images/spots/srimangal.jpg',
  ),
  TouristSpot(
    id: 'jaflong',
    name: 'Jaflong',
    division: 'Sylhet',
    district: 'Moulvibazar',
    tagline: 'Where stone-picking meets the mountains',
    description:
        'Jaflong sits on the border with India, where the Dhalai river '
        'tumbles down carrying smooth stones. Boats, bamboo bridges and the '
        'cloud-covered Khasi hills give it a storybook calm.',
    howToReach:
        'From Sylhet town, hire a car or bus to Jaflong (about 2 hours via '
        'Sreepur). Boats cross the river to the stone-collection points and '
        'village markets. $_bdDivisionsNote',
    bestTime: 'October to April',
    highlights: ['Dhalai river', 'Khasi villages', 'Bamboo bridge'],
    tips: [
      'Wear shoes with grip — river stones are slippery.',
      'Hire a local boatman; rates are fixed for the round trip.',
      'Carry small notes for tea stalls and boat fares.',
    ],
    photo: 'assets/images/spots/jaflong.jpg',
  ),
  TouristSpot(
    id: 'ratargul',
    name: 'Ratargul Swamp Forest',
    division: 'Sylhet',
    district: 'Sylhet',
    tagline: 'Bangladesh’s only freshwater swamp forest',
    description:
        'Ratargul is a mirror-still forest of camphor and koroch trees '
        'standing in shallow water. A country-boat glide between the trunks, '
        'with kingfishers overhead, feels like entering another world.',
    howToReach:
        'From Sylhet city, go to Jaflong road and stop at Ghatarchar; boats '
        'to the forest leave from there (about 1.5–2 hours from the city). '
        '$_bdDivisionsNote',
    bestTime: 'June to October, when the forest floods',
    highlights: ['Boat through trees', 'Bird watching', 'Mirror reflections'],
    tips: [
      'Go at 7:00 AM for still water and soft light.',
      'Take a life jacket and keep phones in a waterproof pouch.',
      'Pair with a Jaflong trip — they share the same road.',
    ],
    photo: 'assets/images/spots/ratargul.jpg',
  ),

  // ─── RAJSHAHI ─────────────────────────────────────────────────────────
  TouristSpot(
    id: 'paharpur',
    name: 'Paharpur Buddhist Vihara',
    division: 'Rajshahi',
    district: 'Naogaon',
    tagline: 'A UNESCO World Heritage Site',
    description:
        'Somapura Mahavihara at Paharpur is one of the largest Buddhist '
        'monasteries ever built south of the Himalayas. Its terraced brick '
        'ruins and carved terracotta plaques date back to the 8th century.',
    howToReach:
        'Trains from Dhaka to Naogaon, then a short CNG ride to Paharpur '
        '(around 7–8 hours total). Buses from Rajshahi and Dinajpur also '
        'serve the site. $_bdDivisionsNote',
    bestTime: 'October to March',
    highlights: ['UNESCO ruins', 'Terracotta plaques', 'Site museum'],
    tips: [
      'Hire the on-site guide — the carvings have wonderful stories.',
      'Visit the museum first to understand the layout.',
      'Carry a hat and water; the ruins are open to the sun.',
    ],
    photo: 'assets/images/spots/paharpur.jpg',
  ),
  TouristSpot(
    id: 'bagha-temple',
    name: 'Bagha Mosque',
    division: 'Rajshahi',
    district: 'Rajshahi',
    tagline: 'A masterpiece of terracotta decoration',
    description:
        'Bagha Mosque (1523 AD) is celebrated for its ornate terracotta '
        'facades — floral scrolls, lotus rosettes and geometric panels in '
        'reddish brick, surrounded by a quiet village and mango orchards.',
    howToReach:
        'Take a bus or train from Rajshahi city to Bagha upazila (about 50 '
        'km, roughly 1.5 hours), then a short rickshaw ride to the mosque '
        'complex. $_bdDivisionsNote',
    bestTime: 'November to February',
    highlights: ['Terracotta panels', 'Five-domed structure', 'Village calm'],
    tips: [
      'Visit in the late afternoon for warm light on the brickwork.',
      'Dress modestly; the mosque still holds prayers.',
      'Combine with Paharpur — both are in the same circuit.',
    ],
    photo: 'assets/images/spots/bagha.jpg',
  ),

  // ─── KHULNA ───────────────────────────────────────────────────────────
  TouristSpot(
    id: 'sundarbans',
    name: 'Sundarbans',
    division: 'Khulna',
    district: 'Khulna',
    tagline: 'The world’s largest mangrove forest',
    description:
        'The Sundarbans is a UNESCO-listed maze of tidal rivers, mangrove '
        'channels and mudflats — home to the Royal Bengal tiger, spotted '
        'deer, crocodiles and the shy Irrawaddy dolphin.',
    howToReach:
        'From Khulna or Mongla, forest-department boats and licensed '
        'launches sail into the reserve. From Dhaka, direct buses to Khulna '
        '(9–10 hours) or a flight to Jessore then road transfer. '
        '$_bdDivisionsNote',
    bestTime: 'October to March',
    highlights: ['Mangrove cruise', 'Wildlife spotting', 'Harbari island'],
    tips: [
      'Book through the forest department; permits are required.',
      'Carry mosquito repellent, a hat and motion-sickness tablets.',
      'Start early — dolphins are most active at dawn.',
      'Never venture off the marked channels.',
    ],
    photo: 'assets/images/spots/sundarbans.jpg',
  ),
  TouristSpot(
    id: 'bagerhat',
    name: 'Sixty Dome Mosque, Bagerhat',
    division: 'Khulna',
    district: 'Bagerhat',
    tagline: 'The grand mosque of the Bengal Sultanate',
    description:
        'The Sixty Dome Mosque (Shat Gombuj Masjid) is the largest '
        '15th-century mosque in Bangladesh, a UNESCO World Heritage Site '
        'with 77 domes and 60 stone columns standing beside historic tombs '
        'and tanks.',
    howToReach:
        'Buses from Khulna reach Bagerhat town in about 2 hours; the mosque '
        'is 3 km from the bus terminal by rickshaw or auto-rickshaw. '
        '$_bdDivisionsNote',
    bestTime: 'October to March',
    highlights: ['UNESCO mosque', 'Seven-domed tomb', 'Historic tanks'],
    tips: [
      'Visit the archaeological site office for a quick history briefing.',
      'Combine with the nearby Nine Dome Mosque and Tomb of Khan Jahan Ali.',
      'Remove shoes before stepping onto the mosque plinth.',
    ],
    photo: 'assets/images/spots/bagerhat.jpg',
  ),

  // ─── BARISAL ──────────────────────────────────────────────────────────
  TouristSpot(
    id: 'kuakata',
    name: 'Kuakata Beach',
    division: 'Barisal',
    district: 'Patuakhali',
    tagline: 'The beach where you can watch both sunrise and sunset',
    description:
        'Kuakata is a rare 18 km stretch of Bay of Bengal shore where the '
        'land curves enough to see the sun rise and set over open water. '
        'Fishing boats, floating guava boats and the nearby Rakhine villages '
        'give it a quiet charm.',
    howToReach:
        'From Dhaka, direct buses to Patuakhali (10–11 hours), then local '
        'buses or jeeps to Kuakata (about 2 hours). Speedboats and launches '
        'also run from Barisal town. $_bdDivisionsNote',
    bestTime: 'October to March',
    highlights: ['Sunrise & sunset points', 'Sea beach road', 'Rakhine village'],
    tips: [
      'Stay at least one night so you catch both sunrise and sunset.',
      'Walk north for quieter, cleaner stretches of sand.',
      'Fresh crab and seafood shacks line the beach road at dusk.',
    ],
    photo: 'assets/images/spots/kuakata.jpg',
  ),

  // ─── RANGPUR ──────────────────────────────────────────────────────────
  TouristSpot(
    id: 'tajhat-palace',
    name: 'Tajhat Palace',
    division: 'Rangpur',
    district: 'Rangpur',
    tagline: 'A colonnaded zamindar palace turned museum',
    description:
        'Tajhat Palace was built in 1905 by the Zamindar of Tajhat and now '
        'houses a museum of Mughal and Hindu sculpture, coins and '
        'manuscripts. Its wide staircases and pillared verandas photograph '
        'beautifully.',
    howToReach:
        'From Rangpur city centre, rickshaws and CNGs reach the palace in '
        'about 15 minutes. Direct night buses run from Dhaka to Rangpur '
        '(7–8 hours); trains also serve the city. $_bdDivisionsNote',
    bestTime: 'October to March',
    highlights: ['Colonial architecture', 'Regional museum', 'Open gardens'],
    tips: [
      'Check museum opening hours before you go; closed some weekdays.',
      'Pair with the nearby Carnegie Centre and Rangpur town hall.',
      'Evening light on the façade is ideal for photography.',
    ],
    photo: 'assets/images/spots/tajhat.jpg',
  ),
  TouristSpot(
    id: 'kantanagar-temple',
    name: 'Kantanagar Temple',
    division: 'Rangpur',
    district: 'Dinajpur',
    tagline: 'Infinite terracotta stories in brick',
    description:
        'Kantanagar Temple (1752 AD) is a stunning terracotta-decorated '
        'Shiva temple whose walls depict the epics, boats, flora and even a '
        'British soldier on horseback in exquisite brickwork.',
    howToReach:
        'Trains from Dhaka reach Dinajpur; from Dinajpur town, rickshaws and '
        'auto-rickshaws take about 45 minutes to Kantanagar. Buses from '
        'Rangpur also run. $_bdDivisionsNote',
    bestTime: 'October to March',
    highlights: ['Terracotta panels', 'Nine spires', 'Shiva festival nights'],
    tips: [
      'Go with binoculars — the fine panels reward a close look.',
      'Sunset colours the brick in warm orange; stay for it.',
      'Visit nearby Dinajpur Rajbari and the Durga Sagar tank.',
    ],
    photo: 'assets/images/spots/kantanagar.jpg',
  ),

  // ─── MYMENSINGH ───────────────────────────────────────────────────────
  TouristSpot(
    id: 'mymensingh-rajbari',
    name: 'Mymensingh Rajbari',
    division: 'Mymensingh',
    district: 'Mymensingh',
    tagline: 'The riverside palace of Bhawal',
    description:
        'Mymensingh Rajbari is a grand old palace beside the Brahmaputra, '
        'with high arches, a royal courtyard and Shiva temple. The river '
        'ghat opposite is one of the finest sunset spots in the region.',
    howToReach:
        'Trains from Dhaka reach Mymensingh in about 3–4 hours; frequent '
        'buses run too. From the town centre, rickshaws reach the palace and '
        'river ghat in minutes. $_bdDivisionsNote',
    bestTime: 'October to March',
    highlights: ['Palace courtyards', 'Brahmaputra ghat', 'Royal temple'],
    tips: [
      'Walk down to the ghat at sunset for boats and golden light.',
      'Ask permission before photographing temple rituals.',
      'Try local sweets — Mymensingh is famous for them.',
    ],
    photo: 'assets/images/spots/mymensingh_rajbari.jpg',
  ),
];

/// Divisions in display order (every division has at least one spot).
const List<String> spotDivisions = [
  'Dhaka',
  'Chittagong',
  'Sylhet',
  'Rajshahi',
  'Khulna',
  'Barisal',
  'Rangpur',
  'Mymensingh',
];

List<TouristSpot> spotsForDivision(String? division) {
  if (division == null || division == 'All') return touristSpots;
  return touristSpots.where((s) => s.division == division).toList();
}

TouristSpot? spotById(String id) {
  for (final spot in touristSpots) {
    if (spot.id == id) return spot;
  }
  return null;
}
