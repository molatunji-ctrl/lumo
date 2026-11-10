import 'package:cloud_firestore/cloud_firestore.dart';

double? _readFirestoreNumber(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class Product {
  final String id;
  final String name;
  final String description;
  final double? price;
  final String? formattedPrice;
  final String imageUrl;
  final double rating;
  final String shopName;
  final String shopLocation;
  final String category;
  final bool isFavourite;
  final bool isSellerListed;
  final String? sellerUid;
  final bool isPublished;
  final double? shopLatitude;
  final double? shopLongitude;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    this.price,
    this.formattedPrice,
    required this.imageUrl,
    this.rating = 4.8,
    required this.shopName,
    this.shopLocation = 'Location not provided',
    required this.category,
    this.isFavourite = false,
    this.isSellerListed = true,
    this.sellerUid,
    this.isPublished = true,
    this.shopLatitude,
    this.shopLongitude,
  });

  String get displayPrice =>
      formattedPrice ??
      (price != null ? '₦${price!.toStringAsFixed(0)}' : 'Price not provided');

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: _readFirestoreNumber(json['price']),
      formattedPrice: json['formattedPrice'] as String?,
      imageUrl: json['imageUrl'] as String,
      rating: _readFirestoreNumber(json['rating']) ?? 4.8,
      shopName: json['shopName'] as String,
      shopLocation: json['shopLocation'] as String? ?? 'Location not provided',
      category: json['category'] as String,
      isFavourite: json['isFavourite'] as bool? ?? false,
      isSellerListed: json['isSellerListed'] as bool? ?? true,
      sellerUid: json['sellerUid'] as String?,
      isPublished: json['isPublished'] as bool? ?? true,
      shopLatitude: _readFirestoreNumber(json['shopLatitude']),
      shopLongitude: _readFirestoreNumber(json['shopLongitude']),
    );
  }

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic>? data = doc.data();
    if (data == null) {
      throw FormatException('Product ${doc.id} has no document data.');
    }
    return Product.fromJson(<String, dynamic>{...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'formattedPrice': formattedPrice,
      'imageUrl': imageUrl,
      'rating': rating,
      'shopName': shopName,
      'shopLocation': shopLocation,
      'category': category,
      'isFavourite': isFavourite,
      'isSellerListed': isSellerListed,
      'sellerUid': sellerUid,
      'isPublished': isPublished,
      'shopLatitude': shopLatitude,
      'shopLongitude': shopLongitude,
    };
  }

  static const List<Product> mockProducts = [
    Product(
      id: 'p1',
      name: 'Oraimo SpaceBuds',
      description: 'Wireless noise cancelling earbuds with crystal clear sound and long battery life.',
      price: 42500,
      formattedPrice: '₦42,500',
      imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?q=80&w=800&auto=format&fit=crop',
      shopName: 'Gadget Hub Ikeja',
      shopLocation: 'Ikeja',
      category: 'Audio & headphones',
      isFavourite: false,
      isSellerListed: true,
    ),
    Product(
      id: 'p2',
      name: 'Nike Air Max 270',
      description:
          'Breathable lightweight running sneakers with premium cushion sole.',
      price: 85000,
      formattedPrice: '₦85,000',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=800&auto=format&fit=crop',
      shopName: 'Mainland Kicks',
      shopLocation: 'Yaba',
      category: "Men's sneakers",
      isFavourite: true,
      isSellerListed: true,
    ),
    Product(
      id: 'p3',
      name: 'Ankara Tote',
      description: 'Handcrafted African pattern tote bag stitched with durable canvas interior.',
      price: 18000,
      formattedPrice: '₦18,000',
      imageUrl: 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?q=80&w=800&auto=format&fit=crop',
      shopName: 'Zuri Collective',
      shopLocation: 'Ikeja',
      category: 'Handmade accessories',
      isFavourite: false,
      isSellerListed: true,
    ),
    Product(
      id: 'p4',
      name: 'Everyday leather tote',
      description: 'A structured carryall for the workday and everything else. This fictional listing demonstrates how shoppers discover products at local shops.',
      formattedPrice: 'Price not provided',
      imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=800&auto=format&fit=crop',
      shopName: 'Kora Collective',
      shopLocation: 'Ikeja',
      category: 'Bags & accessories',
      isFavourite: false,
      isSellerListed: false,
    ),
    Product(
      id: 'p5',
      name: 'Classic white sneakers',
      description:
          'Versatile low-top leather sneakers built for everyday comfort.',
      formattedPrice: 'Price not provided',
      imageUrl: 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?q=80&w=800&auto=format&fit=crop',
      shopName: 'Kora Collective',
      shopLocation: 'Yaba',
      category: 'Footwear',
      isFavourite: false,
      isSellerListed: false,
    ),
    Product(
      id: 'p6',
      name: 'Over-ear wireless headphones',
      description: 'Studio-quality wireless over-ear headphones with active noise cancellation.',
      formattedPrice: 'Price not provided',
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=800&auto=format&fit=crop',
      shopName: 'Gadget Hub Ikeja',
      shopLocation: 'Ikeja',
      category: 'Electronics',
      isFavourite: false,
      isSellerListed: false,
    ),
    Product(
      id: 'p7',
      name: 'Silver everyday watch',
      description:
          'Minimalist stainless steel analog timepiece with water resistance.',
      formattedPrice: 'Price not provided',
      imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=800&auto=format&fit=crop',
      shopName: 'Lagos Timepieces',
      shopLocation: 'Lagos Island',
      category: 'Accessories',
      isFavourite: false,
      isSellerListed: false,
    ),
  ];
}
