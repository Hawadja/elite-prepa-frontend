import '../models/sujet.dart';
import '../repositories/sujet_repository.dart';

class SujetViewModel {
  final SujetRepository _repository;

  SujetViewModel({SujetRepository? repository})
    : _repository = repository ?? SujetRepository();

  Future<SujetsPage> loadSujets({
    String? matiere,
    String? concours,
    String? anneeAcademique,
    String? search,
    int page = 1,
    int limit = 10,
  }) {
    return _repository.getSujetsPage(
      matiere: matiere,
      concours: concours,
      anneeAcademique: anneeAcademique,
      search: search,
      page: page,
      limit: limit,
    );
  }

  Future<Sujet> loadSujetById(String id) {
    return _repository.getSujetById(id);
  }
}
