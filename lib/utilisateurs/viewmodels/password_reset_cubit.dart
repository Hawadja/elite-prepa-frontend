import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/auth_repository.dart';

// States
abstract class PasswordResetState extends Equatable {
  const PasswordResetState();

  @override
  List<Object?> get props => [];
}

class PasswordResetInitial extends PasswordResetState {
  const PasswordResetInitial();
}

class PasswordResetLoading extends PasswordResetState {
  const PasswordResetLoading();
}

class PasswordResetSuccess extends PasswordResetState {
  const PasswordResetSuccess();
}

class PasswordResetError extends PasswordResetState {
  final String message;

  const PasswordResetError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class PasswordResetCubit extends Cubit<PasswordResetState> {
  final AuthRepository _authRepository;

  PasswordResetCubit(this._authRepository)
      : super(const PasswordResetInitial());

  /// Demande l'envoi d'un email de réinitialisation de mot de passe
  Future<void> forgotPassword(String email) async {
    emit(const PasswordResetLoading());
    try {
      await _authRepository.forgotPassword(email);
      emit(const PasswordResetSuccess());
    } catch (e) {
      emit(PasswordResetError(e.toString()));
    }
  }

  /// Réinitialise le mot de passe avec le token et le nouveau mot de passe
  Future<void> resetPassword(String token, String nouveauMotDePasse) async {
    emit(const PasswordResetLoading());
    try {
      await _authRepository.resetPassword(token, nouveauMotDePasse);
      emit(const PasswordResetSuccess());
    } catch (e) {
      emit(PasswordResetError(e.toString()));
    }
  }
}
