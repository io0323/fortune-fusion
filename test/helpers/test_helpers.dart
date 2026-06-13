import 'package:fortune_fusion/features/profile/domain/entities/profile.dart';

Profile makeTestProfile({
  int id = 1,
  String nickname = 'テスト太郎',
  String gender = '男性',
  DateTime? birthDate,
  DateTime? birthTime,
  String birthPlace = '東京都',
  double birthLat = 35.6762,
  double birthLng = 139.6503,
}) {
  return Profile(
    id: id,
    nickname: nickname,
    gender: gender,
    birthDate: birthDate ?? DateTime(1990, 4, 15),
    birthTime: birthTime,
    birthPlace: birthPlace,
    birthLat: birthLat,
    birthLng: birthLng,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}
