import '../../domain/entities/profile.dart';

class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.nickname,
    required this.gender,
    required this.birthDate,
    this.birthTime,
    required this.birthPlace,
    required this.birthLat,
    required this.birthLng,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String nickname;
  final String gender;
  final DateTime birthDate;
  final DateTime? birthTime;
  final String birthPlace;
  final double birthLat;
  final double birthLng;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile toEntity() => Profile(
        id: id,
        nickname: nickname,
        gender: gender,
        birthDate: birthDate,
        birthTime: birthTime,
        birthPlace: birthPlace,
        birthLat: birthLat,
        birthLng: birthLng,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
