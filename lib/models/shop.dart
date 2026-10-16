class Shop {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String address;
  final String distance;
  final double rating;
  final bool isOpen;
  final String marketName;
  final String category;

  const Shop({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.address,
    required this.distance,
    required this.rating,
    required this.isOpen,
    required this.marketName,
    required this.category,
  });

  static const List<Shop> mockShops = [
    Shop(
      id: 's1',
      name: 'Kora Collective',
      description: 'A fictional independent shop bringing together bags, footwear and everyday accessories.',
      imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=800&auto=format&fit=crop',
      address: 'Ikeja, Lagos · Street address not supplied',
      distance: 'Within 2 km',
      rating: 4.8,
      isOpen: true,
      marketName: 'Ikeja Area',
      category: 'Fashion & accessories',
    ),
    Shop(
      id: 's2',
      name: 'Tobi Carry Studio',
      description: 'Bags & everyday essentials crafted with artisanal care.',
      imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?q=80&w=800&auto=format&fit=crop',
      address: 'Yaba, Lagos',
      distance: '3.5 km away',
      rating: 4.9,
      isOpen: true,
      marketName: 'Yaba Hub',
      category: 'Bags & everyday essentials',
    ),
    Shop(
      id: 's3',
      name: 'Computer Village',
      description: 'Explore local electronics shops. Confirm individual shop information before a visit.',
      imageUrl: 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=800&auto=format&fit=crop',
      address: 'Shopping area · Ikeja, Lagos',
      distance: '1.2 km away',
      rating: 4.7,
      isOpen: true,
      marketName: 'Computer Village District',
      category: 'Shopping area',
    ),
  ];
}
