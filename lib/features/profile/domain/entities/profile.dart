class Profile {
  const Profile({
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

  Profile copyWith({
    int? id,
    String? nickname,
    String? gender,
    DateTime? birthDate,
    DateTime? birthTime,
    String? birthPlace,
    double? birthLat,
    double? birthLng,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthPlace: birthPlace ?? this.birthPlace,
      birthLat: birthLat ?? this.birthLat,
      birthLng: birthLng ?? this.birthLng,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
