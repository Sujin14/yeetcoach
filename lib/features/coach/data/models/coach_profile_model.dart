import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/coach_profile.dart';

class CertificationModel extends Certification {
  const CertificationModel({
    required super.title,
    required super.issuer,
    required super.year,
  });

  factory CertificationModel.fromMap(Map<String, dynamic> map) =>
      CertificationModel(
        title: (map['title'] as String?) ?? '',
        issuer: (map['issuer'] as String?) ?? '',
        year: (map['year'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'issuer': issuer,
        'year': year,
      };
}

class CoachProfileModel extends CoachProfile {
  CoachProfileModel({
    required super.uid,
    required super.name,
    required super.email,
    super.profileImageUrl,
    required super.bio,
    required super.specializations,
    required super.certifications,
    required super.isVerified,
    required super.isActive,
    required super.averageRating,
    required super.totalClients,
    super.experienceYears,
    super.phoneNumber,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CoachProfileModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CoachProfileModel(
      uid: doc.id,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      profileImageUrl: data['profileImageUrl'] as String?,
      bio: (data['bio'] as String?) ?? '',
      specializations: List<String>.from(
          (data['specializations'] as List<dynamic>?) ?? []),
      certifications: ((data['certifications'] as List<dynamic>?) ?? [])
          .map((e) =>
              CertificationModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      isVerified: (data['isVerified'] as bool?) ?? false,
      isActive: (data['isActive'] as bool?) ?? true,
      averageRating: ((data['averageRating'] as num?) ?? 0).toDouble(),
      totalClients: (data['totalClients'] as num?)?.toInt() ?? 0,
      experienceYears: (data['experience'] as num?)?.toInt(),
      phoneNumber: data['phoneNumber'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'profileImageUrl': profileImageUrl,
        'bio': bio,
        'specializations': specializations,
        'certifications': certifications
            .map((c) => CertificationModel(
                  title: c.title,
                  issuer: c.issuer,
                  year: c.year,
                ).toMap())
            .toList(),
        'isVerified': isVerified,
        'isActive': isActive,
        'averageRating': averageRating,
        'totalClients': totalClients,
        'experience': experienceYears,
        'phoneNumber': phoneNumber,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
