import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    phoneNumber,
    avatarUrl,
    address,
    createdAt,
    updatedAt,
  ];
}
