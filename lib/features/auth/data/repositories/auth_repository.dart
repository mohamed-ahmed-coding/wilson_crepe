import 'package:wilson_crepe/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signIn({required String email, required String password});

  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    String? name,
  });

  Future<UserEntity> signInWithGoogle();

  Future<void> signOut();

  Future<void> deleteAccount();

  UserEntity? getCurrentUser();
}
