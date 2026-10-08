import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/token_storage.dart';
import '../models/user_model.dart';
import '../repository/auth_repository.dart';

// States
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final UserModel user;

  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class LoginError extends LoginState {
  final String message;

  const LoginError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;

  LoginCubit(
    this._authRepository, {
    TokenStorage? tokenStorage,
  })  : _tokenStorage = tokenStorage ?? TokenStorage(),
        super(const LoginInitial());

  /// Effectue la connexion, sauvegarde les tokens et émet l'état correspondant
  Future<void> login(String email, String motDePasse) async {
    emit(const LoginLoading());
    try {
      final authResponse = await _authRepository.login(email, motDePasse);
      await _tokenStorage.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      emit(LoginSuccess(authResponse.user));
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}
