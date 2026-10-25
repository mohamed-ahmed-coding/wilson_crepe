import 'package:wilson_crepe/features/auth/data/repositories/auth_repository.dart';

import '../entities/user_entity.dart';

class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  Future<UserEntity> call({required String email, required String password}) {
    return repository.signIn(email: email, password: password);
  }
}

class SignUp {
  final AuthRepository repository;

  SignUp(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    String? name,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      name: name,
      confirmPassword: confirmPassword,
      phoneNumber: phoneNumber,
    );
  }
}

class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<UserEntity> call() {
    return repository.signInWithGoogle();
  }
}

class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}

class DeleteAccountUseCase {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<void> call() {
    return repository.deleteAccount();
  }
}

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  UserEntity? call() {
    return repository.getCurrentUser();
  }
}
