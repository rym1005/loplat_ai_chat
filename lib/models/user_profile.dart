class UserProfile {
  final int age;
  final String gender;

  UserProfile({
    required this.age,
    required this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      age: json['age'] as int,
      gender: json['gender'] as String,
    );
  }
} 