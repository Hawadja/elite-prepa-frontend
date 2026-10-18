import '../models/matiere.dart';
import '../repositories/matiere_repository.dart';

class MatiereViewModel {
  final MatiereRepository _repository;

  MatiereViewModel({
    MatiereRepository? repository,
  }) : _repository = repository ?? MatiereRepository();

  Future<List<Matiere>> loadMatieres() {
    return _repository.getMatieres();
  }
}