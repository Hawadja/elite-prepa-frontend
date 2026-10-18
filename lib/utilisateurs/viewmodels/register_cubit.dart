import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_model.dart';
import '../repository/auth_repository.dart';

// States
abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  final UserModel user;

  const RegisterSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class RegisterError extends RegisterState {
  final String message;

  const RegisterError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;

  RegisterCubit(this._authRepository) : super(const RegisterInitial());

  /// Lance l'inscription d'un nouvel utilisateur (avec email et mot de passe, nom et prenom optionnels)
  Future<void> register({
    String nom = '',
    String prenom = '',
    required String email,
    required String motDePasse,
    String roleId = '',
  }) async {
    emit(const RegisterLoading());
    try {
      final user = UserModel(
        id: '',
        nom: nom,
        prenom: prenom,
        email: email,
        roleId: roleId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdUser = await _authRepository.register(user, motDePasse);
      emit(RegisterSuccess(createdUser));
    } catch (e) {
      emit(RegisterError(e.toString()));
    }
  }

  /// Permet également d'appeler l'inscription avec un objet UserModel directement
  Future<void> registerWithModel(UserModel user, String motDePasse) async {
    emit(const RegisterLoading());
    try {
      final createdUser = await _authRepository.register(user, motDePasse);
      emit(RegisterSuccess(createdUser));
    } catch (e) {
      emit(RegisterError(e.toString()));
    }
  }
}
