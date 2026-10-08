import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/token_storage.dart';
import '../models/user_model.dart';
import '../repository/auth_repository.dart';

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class Authenticated extends AuthState {
  final UserModel? user;

  const Authenticated([this.user]);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Listenable global pour déclencher la réévaluation de go_router lors d'un changement d'auth
class AuthNotifier extends ChangeNotifier {
  static final AuthNotifier instance = AuthNotifier._();
  AuthNotifier._();

  void notifyAuthChanged() {
    notifyListeners();
  }
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;
  final AuthNotifier _authNotifier = AuthNotifier.instance;

  AuthCubit({
    AuthRepository? authRepository,
    TokenStorage? tokenStorage,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _tokenStorage = tokenStorage ?? TokenStorage(),
        super(const AuthInitial());

  /// Vérifie le statut d'authentification (jeton présent ou non)
  Future<void> checkAuthStatus() async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      emit(const Authenticated());
    } else {
      emit(const Unauthenticated());
    }
    _authNotifier.notifyAuthChanged();
  }

  /// Déconnexion utilisateur : efface les tokens et déclenche le refreshListenable
  Future<void> logout() async {
    await _authRepository.logout();
    emit(const Unauthenticated());
    _authNotifier.notifyAuthChanged();
  }

  /// Marque l'utilisateur comme authentifié
  void setAuthenticated([UserModel? user]) {
    emit(Authenticated(user));
    _authNotifier.notifyAuthChanged();
  }
}
