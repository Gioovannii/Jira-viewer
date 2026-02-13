# Jira Viewer

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Native-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

Application macOS native pour visualiser vos tickets Jira et générer des Sprint Reviews automatiques.

## 🎯 Aperçu

Une application SwiftUI moderne qui se connecte à votre instance Jira pour:
- 📊 Visualiser vos tickets par sprint
- 📈 Générer des Sprint Reviews avec statistiques détaillées
- 🤖 Résumés automatiques structurés (traitement local, aucune API externe)
- ⚡️ Interface native rapide et fluide
- 🔐 Authentification sécurisée avec Personal Access Token
- 🔒 100% privé - vos données ne quittent jamais votre Mac

## ✨ Fonctionnalités

### Vue par Sprint
- Navigation entre sprints (actifs, futurs, terminés)
- Tri intelligent: sprints actifs en premier, puis par date
- Dates formatées en français (dd/MM/yyyy)

### Sprint Review avec IA
- **Statistiques complètes du sprint**:
  - Nombre total de tickets
  - Tickets Done avec pourcentage de complétion
  - Tickets en cours et à faire
  - Répartition par type de ticket
  - Barre de progression visuelle

- **Résumé automatique structuré**:
  - Vue d'ensemble des objectifs atteints
  - Points positifs du sprint
  - Points d'attention et blocages
  - Recommandations pour le prochain sprint
  - Traitement 100% local et privé

### Liste de tickets
- Affichage clair avec priorité, status, et assignation
- Détails complets de chaque ticket
- Lien direct vers Jira

## 🚀 Installation

### Prérequis

- macOS 13.0 (Ventura) ou supérieur
- Accès à votre instance Jira
- Personal Access Token Jira

### Configuration

1. **Cloner et compiler**:
```bash
git clone https://github.com/Gioovannii/Jira-viewer.git
cd Jira-viewer
open JiraViewer.xcodeproj
# Build et Run avec Cmd+R
```

2. **Créer un Personal Access Token Jira**:
   - Connectez-vous à Jira
   - Allez dans Profile > Personal Access Tokens
   - Créez un nouveau token
   - Copiez le token (vous ne pourrez plus le voir après!)

3. **Configurer l'application**:
   - Lancez l'app
   - Allez dans Settings (Cmd+,)
   - Collez votre Personal Access Token
   - C'est tout ! Les résumés sont générés localement sans configuration supplémentaire

## 📖 Utilisation

### Sprint Review
1. Sélectionnez un sprint dans la liste de gauche
2. Cliquez sur le bouton "Sprint Review" (icône graphique) dans la barre d'outils
3. Consultez les statistiques du sprint
4. Cliquez sur "Générer le Résumé" pour obtenir un résumé structuré automatique

### Navigation des tickets
1. Les sprints apparaissent dans la barre latérale gauche
2. Cliquez sur un sprint pour voir ses tickets
3. Cliquez sur un ticket pour voir les détails
4. Utilisez "Ouvrir dans Jira" pour accéder au ticket complet

## 🏗 Architecture

```
JiraViewer/
├── JiraViewerApp.swift          # Point d'entrée
├── Models/
│   └── JiraModels.swift         # Modèles de données
├── Services/
│   └── JiraManager.swift        # API Jira et Claude
└── Views/
    ├── ContentView.swift        # Vue principale avec Sprint Review
    └── SettingsView.swift       # Configuration
```

## 🔌 API utilisées

- **Jira REST API v2**: Tickets et recherche
- **Jira Agile API v1.0**: Boards et sprints

## 🔒 Sécurité et Confidentialité

- ✅ Authentification via Personal Access Token
- ✅ Bearer token pour toutes les requêtes API
- ✅ Credentials stockés dans UserDefaults (envisager Keychain pour production)
- ✅ Communication HTTPS uniquement avec votre instance Jira
- ✅ **100% privé**: Les résumés sont générés localement, aucune donnée n'est envoyée à des services tiers
- ✅ Conforme aux politiques de sécurité d'entreprise
- ✅ Support du sandbox macOS

## 🤝 Contribution

Les contributions sont les bienvenues!

## 📝 License

MIT License - voir [LICENSE](LICENSE)

## 💬 Support

- 🐛 Bugs: [Issues GitHub](https://github.com/Gioovannii/Jira-viewer/issues)
- 📚 [Jira API Documentation](https://developer.atlassian.com/server/jira/platform/rest-apis/)

---

Développé avec ❤️ en SwiftUI
