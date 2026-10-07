import '../models/matiere.dart';

class MatiereRepository {
  Future<List<Matiere>> getMatieres() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return const [
      Matiere(
        id: '1',
        nom: 'Mathématiques',
        code: 'MATH',
        description: 'Algèbre, analyse et probabilités.',
      ),
      Matiere(
        id: '2',
        nom: 'Physique',
        code: 'PHYS',
        description: 'Mécanique, électricité et physique générale.',
      ),
      Matiere(
        id: '3',
        nom: 'Chimie',
        code: 'CHIM',
        description: 'Chimie générale et chimie organique.',
      ),
      Matiere(
        id: '4',
        nom: 'Informatique',
        code: 'INFO',
        description: 'Algorithmique, programmation et systèmes.',
      ),
      Matiere(
        id: '5',
        nom: 'Français',
        code: 'FR',
        description: 'Expression française et compréhension.',
      ),
      Matiere(
        id: '6',
        nom: 'Anglais',
        code: 'ANG',
        description: 'Expression et compréhension anglaise.',
      ),
    ];
  }
}