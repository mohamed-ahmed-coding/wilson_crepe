import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    super.fullName,
    super.phoneNumber,
    super.createdAt,
    super.updatedAt,
    super.address,
    super.avatarUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'],
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      address: map['address'],
      avatarUrl: map['avatar_url'],
    );
  }
}
