# Jira Viewer

Application macOS native pour visualiser vos tickets Jira avec génération de résumés par IA.

## Fonctionnalités

- **Vue par Sprint**: Naviguez facilement entre vos sprints (actifs, futurs, terminés)
- **Liste de tickets**: Affichage clair des tickets avec priorité, status, et assignation
- **Résumés IA**: Génération automatique de résumés concis avec l'API Claude
- **Interface native**: Application SwiftUI moderne et performante
- **Support Jira Server**: Compatible avec votre instance Jira interne

## Configuration

### Prérequis

- macOS 13.0 (Ventura) ou supérieur
- Xcode 15.0 ou supérieur
- Accès à votre instance Jira
- Clé API Claude (optionnel, pour les résumés IA)

### Compilation

1. Ouvrez le projet dans Xcode:
```bash
cd JiraViewer
open -a Xcode .
```

2. Dans Xcode, créez un nouveau projet:
   - File > New > Project
   - Choisissez "macOS" > "App"
   - Nom: JiraViewer
   - Interface: SwiftUI
   - Langage: Swift
   - Ajoutez tous les fichiers .swift créés au projet

3. Configurez le Bundle Identifier:
   - Cliquez sur le projet dans la sidebar
   - Allez dans "Signing & Capabilities"
   - Définissez un Bundle Identifier unique (ex: com.votreentreprise.JiraViewer)

4. Build et Run (Cmd+R)

### Configuration de l'application

1. Lancez l'application
2. Allez dans Settings (Cmd+,)
3. Configurez:
   - **URL Jira**: `https://jira.ets.mpi-internal.com`
   - **Nom d'utilisateur**: Votre username Jira
   - **Token/Mot de passe**: Votre mot de passe Jira
   - **Clé du projet**: `LBCMONSPE`
   - **Clé API Claude**: Votre clé API depuis https://console.anthropic.com/

## Utilisation

1. **Navigation par Sprint**:
   - La barre latérale gauche affiche tous vos sprints
   - Cliquez sur un sprint pour voir ses tickets
   - Les sprints actifs sont mis en évidence

2. **Liste des tickets**:
   - La colonne centrale affiche tous les tickets du sprint sélectionné
   - Codes couleur pour les priorités
   - Filtrage automatique par sprint

3. **Détails et résumé**:
   - Cliquez sur un ticket pour voir les détails
   - Cliquez sur "Générer" pour créer un résumé IA
   - Le résumé est généré en français et met en évidence les points clés

4. **Ouvrir dans Jira**:
   - Bouton "Ouvrir dans Jira" pour accéder au ticket complet dans votre navigateur

## Architecture

```
JiraViewer/
├── JiraViewerApp.swift          # Point d'entrée de l'app
├── Models/
│   └── JiraModels.swift         # Modèles de données Jira
├── Services/
│   └── JiraManager.swift        # Logique API Jira et Claude
└── Views/
    ├── ContentView.swift        # Vue principale
    └── SettingsView.swift       # Configuration
```

## API utilisées

- **Jira REST API v2**: Pour les tickets et sprints
- **Jira Agile API v1.0**: Pour les boards et sprints
- **Claude API**: Pour la génération de résumés IA

## Sécurité

- Les credentials sont stockés dans UserDefaults (pour développement)
- Pour la production, envisagez d'utiliser le Keychain
- L'app utilise HTTPS pour toutes les communications
- Support du sandbox macOS activé

## Améliorations futures

- [ ] Cache des tickets et synchronisation en arrière-plan
- [ ] Génération de résumés par batch pour tout un sprint
- [ ] Export des résumés en markdown
- [ ] Notifications pour les nouveaux tickets
- [ ] Support des filtres personnalisés
- [ ] Dark mode automatique
- [ ] Stockage sécurisé dans le Keychain

## Support

Pour tout problème avec votre instance Jira ou la configuration, contactez votre administrateur Jira.

Pour les problèmes d'API Claude, consultez: https://docs.anthropic.com/
