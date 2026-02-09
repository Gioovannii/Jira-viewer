# Guide de contribution

## Structure du projet

```
JiraViewer/
├── JiraViewerApp.swift          # Point d'entrée de l'application
├── Models/
│   └── JiraModels.swift         # Modèles de données (Issue, Sprint, etc.)
├── Services/
│   └── JiraManager.swift        # Logique API Jira et Claude
├── Views/
│   ├── ContentView.swift        # Vue principale (3 colonnes)
│   └── SettingsView.swift       # Panneau de configuration
├── Info.plist                   # Configuration de l'app
├── JiraViewer.entitlements      # Permissions (réseau, sandbox)
├── project.yml                  # Configuration XcodeGen
└── JiraViewer.xcodeproj/        # Projet Xcode (généré)
```

## Prérequis

- macOS 13.0 (Ventura) ou supérieur
- Xcode 15.0 ou supérieur
- XcodeGen (pour régénérer le projet)

## Installation

1. Cloner le repository:
```bash
git clone <votre-repo>
cd JiraViewer
```

2. Générer le projet Xcode (si nécessaire):
```bash
xcodegen generate
```

3. Ouvrir le projet:
```bash
open JiraViewer.xcodeproj
```

## Développement

### Régénérer le projet

Si vous ajoutez de nouveaux fichiers ou modifiez la structure:
```bash
xcodegen generate
```

### Build et Run

Dans Xcode: `Cmd+R`

En ligne de commande:
```bash
xcodebuild -project JiraViewer.xcodeproj -scheme JiraViewer -configuration Debug build
```

### Tests

Pour tester l'API Jira sans lancer l'app complète:
1. Configurez vos credentials dans Settings
2. Vérifiez la console Xcode pour les logs de debug

## Architecture

### JiraManager
- Gère toutes les communications avec l'API Jira
- Support Jira Server (API v2) et Agile API (v1.0)
- Génération de résumés avec l'API Claude
- Observable pour mise à jour automatique de l'UI

### Modèles de données
- `JiraIssue`: Représente un ticket Jira
- `Sprint`: Représente un sprint Agile
- `IssueSummary`: Résumé généré par IA

### Interface utilisateur
- Architecture NavigationSplitView (3 colonnes)
- Colonne 1: Liste des sprints
- Colonne 2: Liste des tickets du sprint sélectionné
- Colonne 3: Détails du ticket avec résumé IA

## Ajouter des fonctionnalités

### Nouveau champ Jira

1. Ajoutez le champ dans `IssueFields` (JiraModels.swift)
2. Ajoutez-le aux `CodingKeys` si nécessaire
3. Mettez à jour la liste des champs dans `fetchIssues` (JiraManager.swift)
4. Affichez-le dans l'UI (IssueDetailView)

### Nouveau filtre

1. Créez une propriété @Published dans JiraManager
2. Ajoutez un picker/toggle dans ContentView
3. Modifiez le JQL dans `fetchIssues` selon le filtre

### Support Jira Cloud

Changez les URLs dans JiraManager:
- REST API v3: `/rest/api/3/`
- Utilisez des tokens API au lieu de mots de passe

## Style de code

- SwiftUI moderne (iOS 16+ features si applicable)
- Async/await pour les appels réseau
- @Published pour la réactivité
- Commentaires MARK: pour organiser le code

## Pull Requests

1. Créez une branche feature:
```bash
git checkout -b feature/ma-fonctionnalite
```

2. Commitez avec des messages clairs:
```bash
git commit -m "Add: Support for custom JQL queries"
```

3. Pushez et créez une PR:
```bash
git push origin feature/ma-fonctionnalite
```

## Problèmes connus

- Les custom fields Jira varient selon les instances → ajustez `customfield_10020` pour votre sprint field
- L'API Claude nécessite une clé payante
- Jira Server peut avoir des limitations de rate-limiting

## Ressources

- [Jira REST API](https://developer.atlassian.com/server/jira/platform/rest-apis/)
- [Jira Agile API](https://developer.atlassian.com/server/jira/platform/jira-agile-rest-api-reference/)
- [Claude API](https://docs.anthropic.com/claude/reference/getting-started-with-the-api)
- [SwiftUI](https://developer.apple.com/documentation/swiftui/)
