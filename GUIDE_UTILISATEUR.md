# 📘 Guide Utilisateur - Jira Viewer

## Installation

### Étape 1: Télécharger l'application

1. Allez sur https://github.com/Gioovannii/Jira-viewer/releases
2. Téléchargez le fichier **JiraViewer-vX.X.X.dmg** (le plus récent)
3. Une fois téléchargé, double-cliquez sur le fichier `.dmg`

### Étape 2: Installer l'application

1. Une fenêtre s'ouvre avec l'icône JiraViewer
2. **Glissez-déposez** l'icône JiraViewer dans le dossier Applications
3. Attendez que la copie se termine
4. Éjectez le disque JiraViewer (clic droit > Éjecter)

### Étape 3: Premier lancement

1. Ouvrez le dossier **Applications**
2. Double-cliquez sur **JiraViewer**
3. Si un message de sécurité apparaît:
   - Allez dans **Préférences Système** > **Confidentialité et sécurité**
   - Cliquez sur **Ouvrir quand même**
   - Confirmez en cliquant sur **Ouvrir**

## Configuration

### Configuration Jira

Au premier lancement, allez dans les réglages:
- **Menu** > **Settings** (ou appuyez sur `Cmd+,`)

Remplissez les champs suivants:

1. **URL Jira**: `https://jira.ets.mpi-internal.com`
2. **Nom d'utilisateur**: Votre identifiant Jira (celui que vous utilisez pour vous connecter)
3. **Mot de passe**: Votre mot de passe Jira
4. **Clé du projet**: Le code de votre projet (ex: `LBCMONSPE`)
   - Vous le trouvez dans l'URL Jira, par exemple:
   - `https://jira.ets.mpi-internal.com/projects/LBCMONSPE/...`
   - La clé est `LBCMONSPE`

### Configuration Claude AI (Optionnel)

Pour activer les résumés intelligents par IA:

1. Créez un compte gratuit sur https://console.anthropic.com/
2. Allez dans **API Keys** > **Create Key**
3. Copiez la clé générée
4. Collez-la dans **Settings** > **Clé API Claude**

> **Note**: Les résumés IA sont optionnels. Vous pouvez utiliser l'app sans cette fonctionnalité.

## Utilisation

### Interface

L'application est divisée en 3 colonnes:

```
┌─────────────┬──────────────┬─────────────────┐
│  Sprints    │   Tickets    │    Détails      │
│             │              │                 │
│  Sprint 1   │  TICKET-123  │  Description    │
│  Sprint 2   │  TICKET-456  │  Status         │
│  Sprint 3   │  TICKET-789  │  Assigné à      │
│             │              │  [Résumé IA]    │
└─────────────┴──────────────┴─────────────────┘
```

### Naviguer dans les sprints

1. **Colonne de gauche**: Liste de tous vos sprints
   - 🟢 Sprint actif en vert
   - 🔵 Sprint futur en bleu
   - ⚫ Sprint terminé en gris

2. **Cliquez sur un sprint** pour voir ses tickets

3. **Bouton de rafraîchissement** en haut pour actualiser

### Voir les tickets

1. **Colonne centrale**: Liste des tickets du sprint sélectionné
   - Badge avec le code du ticket (ex: LBCMONSPE-123)
   - Type de ticket (Bug, Story, Task...)
   - Priorité avec code couleur:
     - 🔴 Critique / Haute
     - 🟠 Moyenne
     - 🔵 Basse

2. **Cliquez sur un ticket** pour voir les détails

### Détails du ticket

**Colonne de droite** affiche:
- Code et titre du ticket
- Status actuel
- Type de ticket
- Priorité
- Assignation
- Description complète
- **Bouton "Générer"**: Crée un résumé IA du ticket (si configuré)
- **Bouton "Ouvrir dans Jira"**: Ouvre le ticket dans votre navigateur

### Générer un résumé IA

1. Sélectionnez un ticket dans la liste
2. Dans le panneau de détails, cliquez sur **Générer**
3. Attendez quelques secondes
4. Le résumé s'affiche en français en 2-3 phrases

Le résumé met en évidence:
- L'objectif principal du ticket
- Les points clés à retenir
- Le contexte important

## Raccourcis clavier

- `Cmd + ,` : Ouvrir les Settings
- `Cmd + R` : Rafraîchir les données
- `Cmd + Q` : Quitter l'application

## Astuces

### Filtrer par sprint

Pour voir uniquement les tickets d'un sprint spécifique:
- Cliquez sur le sprint dans la liste de gauche
- Les tickets se filtrent automatiquement

### Trouver un ticket rapidement

1. Utilisez `Cmd + F` pour rechercher
2. Tapez le code du ticket ou des mots-clés
3. Les résultats s'affichent instantanément

### Voir l'historique complet

Cliquez sur **"Ouvrir dans Jira"** pour accéder à:
- L'historique des modifications
- Les commentaires
- Les pièces jointes
- Les sous-tâches

## Questions fréquentes

### L'application ne se connecte pas à Jira

**Vérifiez:**
1. Que votre URL Jira est correcte (avec `https://`)
2. Que votre nom d'utilisateur et mot de passe sont corrects
3. Que vous êtes bien connecté au réseau de l'entreprise (VPN si nécessaire)

### Mes sprints ne s'affichent pas

**Solutions:**
1. Vérifiez que la clé du projet est correcte
2. Assurez-vous d'avoir accès au projet dans Jira
3. Cliquez sur le bouton de rafraîchissement
4. Redémarrez l'application

### Les résumés IA ne fonctionnent pas

**Causes possibles:**
1. La clé API Claude n'est pas configurée
2. La clé API est expirée ou invalide
3. Vous n'avez plus de crédits sur votre compte Anthropic

**Solution:** Allez dans Settings et vérifiez votre clé API

### L'application est lente

**Optimisations:**
1. Fermez les autres applications
2. Sélectionnez un sprint spécifique plutôt que "Tous les tickets"
3. Redémarrez l'application

### Je veux utiliser un autre projet Jira

1. Allez dans **Settings** (`Cmd+,`)
2. Changez la **Clé du projet**
3. Cliquez sur le bouton de rafraîchissement

## Support

### Besoin d'aide?

- 📧 Contactez votre administrateur Jira
- 🐛 Signalez un bug: https://github.com/Gioovannii/Jira-viewer/issues
- 💬 Questions: Ouvrez une discussion sur GitHub

### Mises à jour

L'application ne se met pas à jour automatiquement.

Pour installer une nouvelle version:
1. Téléchargez la nouvelle version depuis [Releases](https://github.com/Gioovannii/Jira-viewer/releases)
2. Remplacez l'ancienne version dans Applications
3. Vos paramètres seront conservés

## Confidentialité et Sécurité

### Où sont stockées mes données?

- **Credentials Jira**: Stockés localement sur votre Mac (UserDefaults)
- **Clé API Claude**: Stockée localement sur votre Mac
- **Aucune donnée** n'est envoyée à des serveurs tiers (sauf Jira et Claude)

### Est-ce sécurisé?

- L'application utilise HTTPS pour toutes les communications
- Vos credentials ne sont jamais partagés
- L'application fonctionne en mode sandbox macOS

### Puis-je l'utiliser hors ligne?

Non, l'application nécessite une connexion internet pour:
- Se connecter à Jira
- Générer des résumés IA

## Désinstallation

Pour supprimer l'application:

1. Ouvrez le dossier **Applications**
2. Glissez **JiraViewer** vers la Corbeille
3. Videz la Corbeille

Pour supprimer complètement les données:
```bash
# Ouvrir le Terminal et exécuter:
defaults delete com.mpi.JiraViewer
```

---

**Version du guide**: 1.0
**Dernière mise à jour**: Février 2026
