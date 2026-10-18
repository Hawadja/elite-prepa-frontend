# Elite-Prepa — Frontend

Frontend mobile de la plateforme **Elite-Prepa**, développé avec Flutter.

## 📌 Présentation

Elite-Prepa est une plateforme destinée à accompagner les étudiants dans leur préparation aux examens et concours.

Le frontend est développé avec **Flutter** et organisé selon une architecture **modulaire basée sur MVVM**, afin de permettre à plusieurs développeurs de travailler simultanément sur les différents modules de l'application.

> La communication avec le backend sera intégrée ultérieurement.

---

## 🛠️ Technologies

* Flutter
* Dart
* Material Design
* Architecture MVVM
* Git / GitHub

---

## 📁 Architecture du projet

```text
lib/
│
├── main.dart
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── routes/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── modules/
│   ├── evaluations/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── services/
│   │   ├── viewmodels/
│   │   ├── views/
│   │   └── widgets/
│   │
│   ├── ressources_pedagogiques/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── services/
│   │   ├── viewmodels/
│   │   ├── views/
│   │   └── widgets/
│   │
│   ├── suivi_performance/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── services/
│   │   ├── viewmodels/
│   │   ├── views/
│   │   └── widgets/
│   │
│   └── utilisateurs/
│       ├── models/
│       ├── repositories/
│       ├── services/
│       ├── viewmodels/
│       ├── views/
│       └── widgets/
│
└── shared/
    ├── models/
    ├── services/
    └── widgets/
```

## 🧩 Organisation

### `core/`

Contient les éléments techniques communs à toute l'application :

* navigation globale
* gestion des erreurs
* constantes
* thème
* utilitaires
* infrastructure réseau
* widgets techniques communs

### `modules/`

Contient les fonctionnalités métier de l'application.

Chaque module possède sa propre structure MVVM et doit rester indépendant autant que possible des autres modules.

### `shared/`

Contient uniquement les éléments réellement réutilisables par plusieurs modules.

---

## 🏗️ Architecture MVVM

Le principe général est :

```text
View
  ↓
ViewModel
  ↓
Repository
  ↓
Service
  ↓
Backend
```

Pour la phase actuelle, le backend n'est pas encore connecté.

Les développeurs peuvent donc travailler sur :

* les modèles
* les interfaces
* les ViewModels
* les écrans
* les widgets propres au module

La couche réseau et l'intégration backend seront réalisées ultérieurement.

---

## 🌿 Git — Organisation du travail

La branche `main` contient la version stable du projet.

La branche `develop` est utilisée pour le développement de l'équipe.

Chaque développeur doit créer une branche dédiée à son travail.

Exemples :

```text
feature/evaluations
feature/ressources-pedagogiques
feature/suivi-performance
feature/utilisateurs
```

### Règles importantes

* ❌ Ne pas travailler directement sur `main`
* ❌ Ne pas travailler directement sur `develop`
* ✅ Créer une branche `feature/...`
* ✅ Faire des commits régulièrement
* ✅ Tester le projet avant de pousser
* ✅ Faire une Pull Request vers `develop`
* ✅ Ne pas modifier le travail d'un autre module sans coordination

---

## 🚀 Installation

Cloner le projet :

```bash
git clone https://github.com/Hawadja/elite-prepa-frontend.git
```

Entrer dans le projet :

```bash
cd elite-prepa-frontend
```

Se placer sur `develop` :

```bash
git checkout develop
```

Installer les dépendances :

```bash
flutter pub get
```

Vérifier le projet :

```bash
flutter analyze
```

Lancer l'application :

```bash
flutter run
```

---

## 🔄 Workflow recommandé

Avant de commencer :

```bash
git checkout develop
git pull origin develop
```

Créer sa branche :

```bash
git checkout -b feature/nom-du-module
```

Après les modifications :

```bash
git add .
git commit -m "feat: description de la fonctionnalité"
git push -u origin feature/nom-du-module
```

Puis créer une **Pull Request vers `develop`**.

---

## 📝 Convention de commits

Utiliser des messages de commit simples et explicites.

Exemples :

```text
feat: ajout de l'écran des ressources
fix: correction de l'affichage du profil
refactor: amélioration du viewmodel
ui: création de la page d'accueil
docs: mise à jour du README
test: ajout des tests du module
```

---

## 👥 Équipe

Le projet est développé en équipe de quatre personnes.

La répartition définitive des modules sera indiquée ici après validation de l'équipe.

| Membre    | Module    |
| --------- | --------- |
| À définir | À définir |
| À définir | À définir |
| À définir | À définir |
| À définir | À définir |

---

## 🔗 Repository

GitHub :

https://github.com/Hawadja/elite-prepa-frontend

