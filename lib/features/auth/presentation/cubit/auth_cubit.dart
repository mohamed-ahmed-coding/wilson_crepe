import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wilson_crepe/core/notifications/notifications_service.dart';
import 'package:wilson_crepe/features/auth/domain/usecases/auth_use_case.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignIn signIn;
  final SignUp signUp;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final DeleteAccountUseCase deleteAccountUseCase;
  final NotificationsService notificationsService;

  AuthCubit({
    required this.signIn,
    required this.signUp,
    required this.signInWithGoogle,
    required this.signOut,
    required this.getCurrentUser,
    required this.deleteAccountUseCase,
    required this.notificationsService,
  }) : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    if (isClosed) return;

    emit(AuthLoading());

    try {
      final user = await signIn(email: email, password: password);

      await notificationsService.initialize();

      if (isClosed) return;
      emit(AuthAuthenticated(user));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_errorMessage(e)));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String phoneNumber,
    required String confirmPassword,
    String? name,
  }) async {
    if (isClosed) return;

    emit(AuthLoading());

    try {
      final user = await signUp(
        email: email,
        password: password,
        name: name,
        confirmPassword: confirmPassword,
        phoneNumber: phoneNumber,
      );

      await notificationsService.initialize();

      if (isClosed) return;
      emit(AuthAuthenticated(user));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_errorMessage(e)));
    }
  }

  Future<void> googleLogin() async {
    if (isClosed) return;

    emit(AuthLoading());

    try {
      final user = await signInWithGoogle();

      await notificationsService.initialize();

      if (isClosed) return;
      emit(AuthAuthenticated(user));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_errorMessage(e)));
    }
  }

  Future<void> logout() async {
    if (isClosed) return;

    emit(AuthLoading());

    try {
      await signOut();
      await notificationsService.dispose();

      if (isClosed) return;
      emit(AuthUnauthenticated());
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_errorMessage(e)));
    }
  }

  Future<void> deleteAccount() async {
    if (isClosed) return;

    emit(AuthLoading());

    try {
      await deleteAccountUseCase();

      await notificationsService.dispose();

      if (isClosed) return;
      emit(const AuthUnauthenticated());
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_errorMessage(e)));
    }
  }

  String _errorMessage(Object error) {
    final message = error.toString().toLowerCase();

    const networkKeywords = [
      'handshakeexception',
      'certificate_verify_failed',
      'unable to get local issuer certificate',
      'socketexception',
      'clientexception',
      'network',
      'connection reset',
      'connection refused',
      'failed host lookup',
      'timed out',
      'timeoutexception',
    ];

    if (networkKeywords.any(message.contains)) {
      return 'error.network_error'.tr();
    }

    if (message.contains('user already registered') ||
        message.contains('already registered') ||
        message.contains('email_exists') ||
        message.contains('duplicate key') ||
        message.contains('user_already_exists')) {
      return 'error.email_exists'.tr();
    }

    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials') ||
        message.contains('wrong email or password') ||
        message.contains('user not found')) {
      return 'error.wrong_email_or_password'.tr();
    }

    if (message.contains('email not confirmed')) {
      return 'error.email_not_confirmed'.tr();
    }

    if (message.contains('password does not match')) {
      return 'error.error_passwords_match'.tr();
    }

    if (message.contains('weak password') ||
        message.contains('password should be at least')) {
      return 'error.weak_password'.tr();
    }

    if (message.contains('signup disabled')) {
      return 'error.signup_disabled'.tr();
    }

    if (message.contains('over email send rate limit') ||
        message.contains('email rate limit exceeded')) {
      return 'error.over_email_send_rate_limit'.tr();
    }

    if (message.contains('cancelled') || message.contains('canceled')) {
      return 'error.google_signin_was_cancelled'.tr();
    }

    if (message.contains('google') ||
        message.contains('google_sign_in') ||
        message.contains('sign_in_failed')) {
      return 'error.google_signin_was_cancelled'.tr();
    }

    if (message.contains('jwt expired') ||
        message.contains('session expired') ||
        message.contains('refresh token') ||
        message.contains('not authenticated')) {
      return 'error.session_expired'.tr();
    }

    if (message.contains('permission denied') ||
        message.contains('unauthorized') ||
        message.contains('forbidden')) {
      return 'error.permission_denied'.tr();
    }

    return 'error.general_error'.tr();
  }
}
