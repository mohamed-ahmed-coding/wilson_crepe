import 'package:wilson_crepe/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wilson_crepe/features/auth/data/repositories/auth_repository.dart';

import '../../domain/entities/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.signIn(email: email, password: password);
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    String? name,
  }) async {
    return await remoteDataSource.signUp(
      email: email,
      password: password,
      name: name,
      confirmPassword: confirmPassword,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    return await remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    return await remoteDataSource.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    await remoteDataSource.deleteAccount();
  }

  @override
  UserEntity? getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }
}
