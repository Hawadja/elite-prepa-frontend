import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/profil_model.dart';
import '../repository/profil_repository.dart';

// States
abstract class ProfilState extends Equatable {
  const ProfilState();

  @override
  List<Object?> get props => [];
}

class ProfilInitial extends ProfilState {
  const ProfilInitial();
}

class ProfilLoading extends ProfilState {
  const ProfilLoading();
}

class ProfilLoaded extends ProfilState {
  final ProfilModel profil;

  const ProfilLoaded(this.profil);

  @override
  List<Object?> get props => [profil];
}

class ProfilError extends ProfilState {
  final String message;

  const ProfilError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class ProfilCubit extends Cubit<ProfilState> {
  final ProfilRepository _profilRepository;

  ProfilCubit(this._profilRepository) : super(const ProfilInitial());

  /// Récupère le profil d'un utilisateur
  Future<void> fetchProfil(String userId) async {
    emit(const ProfilLoading());
    try {
      final profil = await _profilRepository.getProfil(userId);
      emit(ProfilLoaded(profil));
    } catch (e) {
      emit(ProfilError(e.toString()));
    }
  }

  /// Met à jour le profil d'un utilisateur
  Future<void> updateProfil(String userId, ProfilModel profil) async {
    emit(const ProfilLoading());
    try {
      final updatedProfil =
          await _profilRepository.updateProfil(userId, profil);
      emit(ProfilLoaded(updatedProfil));
    } catch (e) {
      emit(ProfilError(e.toString()));
    }
  }
}
