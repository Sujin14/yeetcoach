import 'package:flutter/foundation.dart';

@immutable
class Certification {
  final String title;
  final String issuer;
  final int year;

  const Certification({
    required this.title,
    required this.issuer,
    required this.year,
  });

  Certification copyWith({String? title, String? issuer, int? year}) =>
      Certification(
        title: title ?? this.title,
        issuer: issuer ?? this.issuer,
        year: year ?? this.year,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Certification &&
          title == other.title &&
          issuer == other.issuer &&
          year == other.year;

  @override
  int get hashCode => Object.hash(title, issuer, year);
}

@immutable
class CoachProfile {
  final String uid;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String bio;
  final List<String> specializations;
  final List<Certification> certifications;
  final bool isVerified;
  final bool isActive;
  final double averageRating;
  final int totalClients;

  /// Years of coaching experience; null until the coach sets it.
  final int? experienceYears;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  CoachProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.bio,
    required List<String> specializations,
    required List<Certification> certifications,
    required this.isVerified,
    required this.isActive,
    required this.averageRating,
    required this.totalClients,
    this.experienceYears,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  })  : specializations = List.unmodifiable(specializations),
        certifications = List.unmodifiable(certifications);

  CoachProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImageUrl,
    String? bio,
    List<String>? specializations,
    List<Certification>? certifications,
    bool? isVerified,
    bool? isActive,
    double? averageRating,
    int? totalClients,
    int? experienceYears,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      CoachProfile(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        email: email ?? this.email,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        bio: bio ?? this.bio,
        specializations: specializations ?? this.specializations,
        certifications: certifications ?? this.certifications,
        isVerified: isVerified ?? this.isVerified,
        isActive: isActive ?? this.isActive,
        averageRating: averageRating ?? this.averageRating,
        totalClients: totalClients ?? this.totalClients,
        experienceYears: experienceYears ?? this.experienceYears,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoachProfile &&
          uid == other.uid &&
          name == other.name &&
          email == other.email &&
          profileImageUrl == other.profileImageUrl &&
          bio == other.bio &&
          listEquals(specializations, other.specializations) &&
          listEquals(certifications, other.certifications) &&
          isVerified == other.isVerified &&
          isActive == other.isActive &&
          averageRating == other.averageRating &&
          totalClients == other.totalClients &&
          experienceYears == other.experienceYears &&
          phoneNumber == other.phoneNumber &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
        uid, name, email, profileImageUrl, bio,
        Object.hashAll(specializations),
        Object.hashAll(certifications),
        isVerified, isActive, averageRating, totalClients,
        experienceYears, phoneNumber,
        createdAt, updatedAt,
      );
}
