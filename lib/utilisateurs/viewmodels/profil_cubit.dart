import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/app_exception.dart';
import '../../core/storage/token_storage.dart';
import '../../core/utils/jwt_utils.dart';
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

class ProfilNotFound extends ProfilState {
  const ProfilNotFound();
}

// Cubit
class ProfilCubit extends Cubit<ProfilState> {
  final ProfilRepository _profilRepository;
  final TokenStorage _tokenStorage;

  ProfilCubit(this._profilRepository, [TokenStorage? tokenStorage])
      : _tokenStorage = tokenStorage ?? TokenStorage(),
        super(const ProfilInitial());

  Future<String> _resolveUserId(String userId) async {
    if (userId.isNotEmpty) return userId;
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      return extractUserIdFromToken(token) ?? '';
    }
    return '';
  }

  /// Récupère le profil d'un utilisateur
  Future<void> fetchProfil(String userId) async {
    emit(const ProfilLoading());
    try {
      final effectiveUserId = await _resolveUserId(userId);
      if (effectiveUserId.isEmpty) {
        emit(const ProfilError('Utilisateur non authentifié. Veuillez vous reconnecter.'));
        return;
      }
      final profil = await _profilRepository.getProfil(effectiveUserId);
      emit(ProfilLoaded(profil));
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        emit(const ProfilNotFound());
      } else {
        emit(ProfilError(e.message));
      }
    } catch (e) {
      emit(ProfilError(e.toString()));
    }
  }

  /// Crée le profil d'un utilisateur
  Future<void> createProfil(
    String userId,
    String nom,
    String prenom, {
    String? telephone,
    String? ville,
    DateTime? dateNaissance,
    String? lieuDeNaissance,
    String? photoUrl,
  }) async {
    emit(const ProfilLoading());
    try {
      final effectiveUserId = await _resolveUserId(userId);
      if (effectiveUserId.isEmpty) {
        emit(const ProfilError('Utilisateur non authentifié.'));
        return;
      }
      final profil = await _profilRepository.createProfil(
        effectiveUserId,
        nom,
        prenom,
        telephone: telephone,
        ville: ville,
        dateNaissance: dateNaissance,
        lieuDeNaissance: lieuDeNaissance,
        photoUrl: photoUrl,
      );
      emit(ProfilLoaded(profil));
    } on ApiException catch (e) {
      emit(ProfilError(e.message));
    } catch (e) {
      emit(ProfilError(e.toString()));
    }
  }

  /// Met à jour le profil d'un utilisateur
  Future<void> updateProfil(String userId, ProfilModel profil) async {
    emit(const ProfilLoading());
    try {
      final effectiveUserId =
          await _resolveUserId(userId.isNotEmpty ? userId : profil.userId);
      if (effectiveUserId.isEmpty) {
        emit(const ProfilError('Utilisateur non authentifié.'));
        return;
      }
      final updatedProfil =
          await _profilRepository.updateProfil(effectiveUserId, profil);
      emit(ProfilLoaded(updatedProfil));
    } catch (e) {
      emit(ProfilError(e.toString()));
    }
  }
}
