# Notes de version

## Version 1.0.0 (Février 2026)

### 🎉 Première version

Application macOS native pour visualiser vos tickets Jira avec intelligence artificielle.

### ✨ Fonctionnalités principales

- **Navigation par sprint**
  - Vue claire de tous vos sprints (actifs, futurs, terminés)
  - Indicateurs visuels de l'état des sprints
  - Affichage des dates et objectifs de sprint

- **Liste de tickets intuitive**
  - Affichage de tous les tickets par sprint
  - Codes couleur pour les priorités
  - Informations essentielles visibles d'un coup d'œil
  - Support de 100+ tickets par sprint

- **Détails complets des tickets**
  - Vue détaillée avec toutes les informations Jira
  - Bouton direct pour ouvrir dans Jira
  - Interface claire et lisible

- **Résumés IA avec Claude**
  - Génération de résumés intelligents en français
  - Résumés concis en 2-3 phrases
  - Mise en évidence des points clés
  - Basé sur Claude 3.5 Sonnet

- **Configuration flexible**
  - Support Jira Server et Cloud
  - Configuration facile via Settings
  - Stockage sécurisé des credentials
  - Multi-projets

### 🔧 Technique

- Interface native SwiftUI
- Architecture async/await moderne
- Support macOS 13.0+
- API Jira REST v2 et Agile v1.0
- Intégration API Claude
- Mode sandbox macOS activé

### 📦 Installation

Téléchargez le fichier `.dmg` et suivez le [Guide Utilisateur](GUIDE_UTILISATEUR.md)

### ⚙️ Configuration requise

- macOS 13.0 (Ventura) ou supérieur
- Connexion internet
- Compte Jira (Server ou Cloud)
- Clé API Claude (optionnel, pour les résumés IA)

### 🐛 Problèmes connus

- Le custom field pour les sprints peut varier selon les instances Jira
- Les très grandes descriptions (>10 000 caractères) peuvent prendre du temps à charger
- Limite de 100 tickets par sprint (limitation de l'API Jira)

### 🚀 Prochaines améliorations prévues

- Cache local des tickets
- Génération de résumés par batch (tout un sprint)
- Export des résumés en markdown
- Notifications pour les nouveaux tickets
- Filtres personnalisés avancés
- Support du dark mode
- Recherche globale dans les tickets

### 📝 Notes

Cette première version se concentre sur l'essentiel:
- Interface claire et rapide
- Fonctionnalités de base solides
- Stabilité et fiabilité

Vos retours sont les bienvenus pour orienter les prochaines versions!

---

## Comment mettre à jour

1. Téléchargez la nouvelle version depuis [Releases](https://github.com/Gioovannii/Jira-viewer/releases)
2. Remplacez l'ancienne version dans Applications
3. Relancez l'application

Vos paramètres seront conservés automatiquement.
