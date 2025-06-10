import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final UserType userType;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? profileImageUrl;
  final double? latitude;
  final double? longitude;
  final double rating;
  final int totalRatings;
  final List<String> services;
  final String? description;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.userType,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.profileImageUrl,
    this.latitude,
    this.longitude,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.services = const [],
    this.description,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      // 🔥 CORRECCIÓN: Manejar mejor el userType
      userType: _parseUserType(map['userType']),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? _parseDateTime(map['updatedAt']) : null,
      isActive: map['isActive'] ?? true,
      profileImageUrl: map['profileImageUrl'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
      services: List<String>.from(map['services'] ?? []),
      description: map['description'],
    );
  }

  // 🔹 MÉTODO HELPER PARA PARSEAR USERTYPE CORRECTAMENTE
  static UserType _parseUserType(dynamic value) {
    if (value == null) return UserType.client;

    // Si es un string (como "provider", "admin", "client")
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'provider':
          return UserType.provider;
        case 'admin':
          return UserType.admin;
        case 'client':
        default:
          return UserType.client;
      }
    }

    // Si es un int (como 0, 1, 2)
    if (value is int) {
      if (value >= 0 && value < UserType.values.length) {
        return UserType.values[value];
      }
    }

    // Default fallback
    return UserType.client;
  }

  // 🔹 MÉTODO HELPER PARA PARSEAR DATETIME CORRECTAMENTE
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      // 🔹 GUARDAR COMO STRING PARA MAYOR CLARIDAD
      'userType': userType.name, // "client", "provider", "admin"
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'totalRatings': totalRatings,
      'services': services,
      'description': description,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    UserType? userType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? profileImageUrl,
    double? latitude,
    double? longitude,
    double? rating,
    int? totalRatings,
    List<String>? services,
    String? description,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      services: services ?? this.services,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, userType: ${userType.name})';
  }
}

enum UserType { client, provider, admin }
