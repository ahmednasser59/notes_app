import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    emit(AuthLoading());
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        emit(AuthFailure("Biometrics not supported on this device."));
        return false;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to unlock private notes',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        emit(AuthSuccess());
        return true;
      } else {
        emit(AuthFailure("Authentication failed."));
        return false;
      }
    } on PlatformException catch (e) {
      emit(AuthFailure(e.message ?? "An error occurred during authentication."));
      return false;
    }
  }
}
