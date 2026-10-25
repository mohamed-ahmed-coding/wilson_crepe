import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    String? name,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<void> deleteAccount();

  UserModel? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl(this.supabase);

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw Exception('We could not log you in. Please try again.');
      }

      return UserModel(id: user.id, email: user.email);
    } on AuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    String? name,
  }) async {
    if (password != confirmPassword) {
      throw Exception('Passwords do not match.');
    }

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phoneNumber},
      );

      final user = response.user;

      if (user == null) {
        throw Exception('We could not create your account. Please try again.');
      }

      if (user.identities != null && user.identities!.isEmpty) {
        throw Exception('This email is already used. Please log in instead.');
      }

      return UserModel(
        id: user.id,
        email: user.email,
        fullName: user.userMetadata?['name'] as String?,
        phoneNumber: user.phone ?? user.userMetadata?['phone'] as String?,
      );
    } on AuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(
        serverClientId: '668051207779-tt3qflv72huqnsg7bqht8ssogn62n361.apps.googleusercontent.com',
      );

      final googleUser = await googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Google sign-in failed. Please try again.');
      }

      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      final user = response.user ?? supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Google sign-in failed. Please try again.');
      }

      return UserModel(
        id: user.id,
        email: user.email,
        fullName: user.userMetadata?['name'] as String?,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
      );
    } on GoogleSignInException catch (e) {
      throw Exception(_googleErrorMessage(e));
    } on AuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final response = await supabase.functions.invoke(
        'delete-account',
        method: HttpMethod.post,
      );

      if (response.status < 200 || response.status >= 300) {
        throw Exception('Account deletion failed.');
      }

      await supabase.auth.signOut(scope: SignOutScope.local);
    } on AuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    }
  }

  @override
  UserModel? getCurrentUser() {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    return UserModel(id: user.id, email: user.email);
  }

  String _authErrorMessage(AuthException error) {
    final code = error.code?.toLowerCase();
    final message = error.message.toLowerCase();

    switch (code) {
      case 'invalid_credentials':
        return 'Wrong email or password. Please check your details.';
      case 'email_exists':
      case 'user_already_exists':
        return 'This email is already used. Please log in instead.';
      case 'email_not_confirmed':
        return 'Please confirm your email address before logging in.';
      case 'weak_password':
        return 'Your password is too weak. Please use at least 6 characters.';
      case 'signup_disabled':
        return 'Sign up is currently disabled. Please try again later.';
      case 'over_email_send_rate_limit':
        return 'Too many email attempts. Please wait a moment and try again.';
    }

    if (message.contains('invalid login credentials')) {
      return 'Wrong email or password. Please check your details.';
    }
    if (message.contains('user already registered') ||
        message.contains('already registered') ||
        message.contains('already exists')) {
      return 'This email is already used. Please log in instead.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please confirm your email address before logging in.';
    }
    if (message.contains('password')) {
      return error.message;
    }

    return 'Something went wrong with authentication. Please try again.';
  }

  String _googleErrorMessage(GoogleSignInException error) {
    return switch (error.code) {
      GoogleSignInExceptionCode.canceled => 'Google sign-in was cancelled.',
      GoogleSignInExceptionCode.interrupted =>
        'Google sign-in was interrupted. Please try again.',
      GoogleSignInExceptionCode.uiUnavailable =>
        'Google sign-in is not available on this device.',
      GoogleSignInExceptionCode.clientConfigurationError =>
        'Google sign-in is not configured correctly.',
      _ => 'Google sign-in failed. Please try again.',
    };
  }
}
