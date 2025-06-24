import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final ServiceCategory category;
  final double pricePerHour;
  final String providerId;
  final String providerName;
  final List<String> imageUrls;
  final double rating;
  final int totalRatings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? latitude;
  final double? longitude;
  final String? address;
  final List<String> tags;
  final int estimatedDuration; // en minutos

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.pricePerHour,
    required this.providerId,
    required this.providerName,
    this.imageUrls = const [],
    this.rating = 0.0,
    this.totalRatings = 0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.latitude,
    this.longitude,
    this.address,
    this.tags = const [],
    this.estimatedDuration = 60,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: ServiceCategory.values[map['category'] ?? 0],
      pricePerHour: (map['pricePerHour'] ?? 0.0).toDouble(),
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      address: map['address'],
      tags: List<String>.from(map['tags'] ?? []),
      estimatedDuration: map['estimatedDuration'] ?? 60,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.index,
      'pricePerHour': pricePerHour,
      'providerId': providerId,
      'providerName': providerName,
      'imageUrls': imageUrls,
      'rating': rating,
      'totalRatings': totalRatings,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'tags': tags,
      'estimatedDuration': estimatedDuration,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    ServiceCategory? category,
    double? pricePerHour,
    String? providerId,
    String? providerName,
    List<String>? imageUrls,
    double? rating,
    int? totalRatings,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? latitude,
    double? longitude,
    String? address,
    List<String>? tags,
    int? estimatedDuration,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      tags: tags ?? this.tags,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    );
  }
}

enum ServiceCategory {
  cleaning,
  plumbing,
  carpentry,
  electricity,
  gardening,
  housework,
  wasteDisposal,
  other
}
