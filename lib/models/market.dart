class Market {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final int shopCount;
  final String description;
  final double rating;

  const Market({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.shopCount,
    required this.description,
    required this.rating,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      imageUrl: json['imageUrl'] as String,
      shopCount: json['shopCount'] as int,
      description: json['description'] as String,
      rating: (json['rating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'imageUrl': imageUrl,
      'shopCount': shopCount,
      'description': description,
      'rating': rating,
    };
  }

  static const List<Market> mockMarkets = [
    Market(
      id: 'm1',
      name: 'Central City Market',
      location: 'Downtown Square',
      imageUrl: 'https://images.unsplash.com/photo-1533900298318-6b8da08a523e',
      shopCount: 42,
      description: 'The largest vibrant open-air market with local produce, coffee, and crafts.',
      rating: 4.8,
    ),
    Market(
      id: 'm2',
      name: 'Eastside Artisan Hub',
      location: 'East River District',
      imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5',
      shopCount: 28,
      description: 'A creative community marketplace featuring artisan food, bakeries, and handmade goods.',
      rating: 4.7,
    ),
    Market(
      id: 'm3',
      name: 'Harbor View Bazaar',
      location: 'Port Waterfront',
      imageUrl: 'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf',
      shopCount: 35,
      description: 'Fresh seafood, coastal crafts, and waterfront dining stalls.',
      rating: 4.9,
    ),
  ];
}
