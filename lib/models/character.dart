class Character {
  final String name;
  final String gender;
  final int kindnessLevel; // 1-5
  final String? presetId; // 프리셋 ID (null이면 직접 설정)

  Character({
    required this.name,
    required this.gender,
    required this.kindnessLevel,
    this.presetId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'kindnessLevel': kindnessLevel,
      'presetId': presetId,
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'] as String,
      gender: json['gender'] as String,
      kindnessLevel: json['kindnessLevel'] as int,
      presetId: json['presetId'] as String?,
    );
  }
}
