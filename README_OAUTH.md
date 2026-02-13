# JiraViewer avec OAuth SSO - Installation Complète

## ✅ Ce qui a été fait

L'authentification OAuth avec Okta SSO a été **complètement implémentée** dans votre application JiraViewer!

### Fichiers ajoutés:

1. **Services/OAuthManager.swift** - Gestion OAuth complète avec PKCE
2. **Services/KeychainManager.swift** - Stockage sécurisé dans le Keychain
3. **Models/OAuthModels.swift** - Modèles de données OAuth
4. **Views/OAuthWebView.swift** - Interface de connexion WebView
5. **OAUTH_SETUP.md** - Documentation technique détaillée

### Fichiers modifiés:

- **Info.plist** - URL scheme `jiraviewer://` ajouté
- **JiraViewerApp.swift** - Intégration OAuth et gestion des callbacks
- **JiraManager.swift** - Support OAuth + Basic Auth
- **SettingsView.swift** - Interface utilisateur pour OAuth
- **ContentView.swift** - Vérification d'authentification

### Fonctionnalités OAuth implémentées:

✅ Flux OAuth 2.0 avec PKCE (sécurité renforcée)
✅ WebView pour connexion Okta
✅ Stockage sécurisé des tokens dans le Keychain macOS
✅ Rafraîchissement automatique des tokens
✅ Gestion des erreurs et timeouts
✅ Support de la déconnexion
✅ Coexistence avec l'authentification basique

## 🚀 Comment utiliser l'application

### Étape 1: Lancer l'application

L'application est déjà compilée et prête à l'emploi!

### Étape 2: Configurer les préférences

1. Ouvrez les Préférences (Cmd+,)
2. L'URL Jira et la clé de projet sont déjà pré-remplies:
   - URL: `https://jira.ets.mpi-internal.com`
   - Projet: `LBCMONSPE`

### Étape 3: Choisir la méthode d'authentification

Vous avez deux options:

#### Option A: Authentification Basique (Fonctionne maintenant)

1. Dans Préférences, sélectionnez "Authentification Basique"
2. Entrez votre nom d'utilisateur Jira
3. Entrez votre mot de passe
4. Fermez les Préférences
5. L'app chargera automatiquement vos sprints et tickets!

#### Option B: Okta SSO (OAuth) - Configuration requise

Pour utiliser OAuth avec Okta SSO, vous devez d'abord configurer Okta:

1. **Demandez à votre administrateur IT** de créer une application OAuth dans Okta
2. **Configuration Okta requise:**
   - Type: Native Application
   - Grant Type: Authorization Code with PKCE
   - Redirect URI: `jiraviewer://oauth-callback`
   - Scopes: openid, profile, email, offline_access

3. **Obtenez de votre admin:**
   - Client ID
   - Okta Domain (ex: `company.okta.com`)

4. **Mettez à jour `Models/OAuthModels.swift`:**
   ```swift
   static let okta = OAuthConfig(
       clientId: "VOTRE_CLIENT_ID",
       authorizationEndpoint: "https://VOTRE_DOMAINE.okta.com/oauth2/default/v1/authorize",
       tokenEndpoint: "https://VOTRE_DOMAINE.okta.com/oauth2/default/v1/token",
       redirectURI: "jiraviewer://oauth-callback",
       scopes: ["openid", "profile", "email", "offline_access"]
   )
   ```

5. **Recompilez l'app:**
   ```bash
   cd /Users/jonathan.gaffe/Documents/JiraViewer
   xcodebuild -scheme JiraViewer build
   ```

6. **Utilisez OAuth:**
   - Ouvrez Préférences (Cmd+,)
   - Sélectionnez "Okta SSO (OAuth)"
   - Cliquez "Se connecter avec Okta SSO"
   - Une fenêtre s'ouvrira avec la page de connexion Okta
   - Connectez-vous avec vos identifiants
   - L'app recevra automatiquement le token

## 📝 Utilisation Quotidienne

### Avec Authentification Basique:
1. Lancez l'app
2. L'app se connecte automatiquement avec vos identifiants sauvegardés
3. Les sprints s'affichent dans la colonne de gauche
4. Sélectionnez un sprint pour voir les tickets
5. Cliquez sur un ticket pour voir les détails

### Avec OAuth:
1. Lancez l'app
2. Si le token est valide, connexion automatique
3. Si le token est expiré, il sera rafraîchi automatiquement
4. Si pas de token, vous serez invité à vous connecter

## 🔧 Architecture Technique

### Sécurité:
- **PKCE** - Protection contre les attaques d'interception de code
- **State Parameter** - Protection CSRF
- **Keychain Storage** - Tokens chiffrés et sécurisés
- **Bearer Token** - Authentification OAuth standard
- **Auto-refresh** - Rafraîchissement transparent des tokens

### Flux OAuth:
```
1. User clique "Se connecter avec Okta SSO"
2. App génère code_verifier + code_challenge (PKCE)
3. App ouvre WebView avec URL d'autorisation Okta
4. User se connecte via Okta SSO
5. Okta redirige vers jiraviewer://oauth-callback?code=...
6. App intercepte le callback
7. App échange le code contre un access_token + refresh_token
8. Tokens stockés dans le Keychain
9. Tous les appels API utilisent le Bearer token
10. Token rafraîchi automatiquement quand il expire
```

## 🆘 Dépannage

### L'app ne se lance pas
```bash
cd /Users/jonathan.gaffe/Documents/JiraViewer
xcodebuild -scheme JiraViewer clean build
open /Users/jonathan.gaffe/Library/Developer/Xcode/DerivedData/JiraViewer-*/Build/Products/Debug/JiraViewer.app
```

### "Nom d'utilisateur manquant" avec Basic Auth
- Ouvrez Préférences (Cmd+,)
- Vérifiez que "Authentification Basique" est sélectionné
- Entrez votre nom d'utilisateur et mot de passe
- Fermez les Préférences

### OAuth ne fonctionne pas
1. Vérifiez que OAuthConfig est correctement configuré dans `Models/OAuthModels.swift`
2. Vérifiez que l'app OAuth est créée dans Okta
3. Vérifiez que le Redirect URI est exactement `jiraviewer://oauth-callback`
4. Regardez les logs d'erreur dans les Préférences

### Token expiré
- L'app rafraîchit automatiquement les tokens
- Si ça échoue, déconnectez-vous et reconnectez-vous dans les Préférences

## 📚 Documentation Additionnelle

- **OAUTH_SETUP.md** - Guide technique détaillé pour la configuration OAuth
- **CONFIGURATION_JIRA.md** - Configuration générale de Jira
- **GUIDE_UTILISATEUR.md** - Guide d'utilisation de l'application
- **INSTALLATION_RAPIDE.md** - Installation pour utilisateurs non techniques

## 🎉 Prêt à l'emploi!

Votre application JiraViewer est maintenant prête avec:
- ✅ Authentification Basique (fonctionne immédiatement)
- ✅ OAuth SSO avec Okta (nécessite configuration Okta)
- ✅ Stockage sécurisé des identifiants
- ✅ Interface moderne et intuitive
- ✅ Intégration Claude AI pour les résumés

**Lancez l'app et connectez-vous avec la méthode Basique pour commencer tout de suite!**

Pour activer OAuth, suivez les instructions de configuration Okta dans **OAUTH_SETUP.md**.
