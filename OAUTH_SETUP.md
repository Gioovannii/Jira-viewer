# Configuration OAuth avec Okta SSO

Ce guide explique comment configurer l'authentification OAuth avec Okta SSO pour JiraViewer.

## Étape 1: Ajouter les fichiers au projet Xcode

Les fichiers suivants ont été créés mais doivent être ajoutés manuellement au projet Xcode:

1. Ouvrez `JiraViewer.xcodeproj` dans Xcode
2. Ajoutez les fichiers suivants à leurs dossiers respectifs:

**Dans Services/**
- `Services/OAuthManager.swift` - Gestion du flux OAuth
- `Services/KeychainManager.swift` - Stockage sécurisé des tokens

**Dans Models/**
- `Models/OAuthModels.swift` - Modèles de données OAuth

**Dans Views/**
- `Views/OAuthWebView.swift` - Interface WebView pour la connexion

### Comment ajouter les fichiers:

1. Dans Xcode, faites un clic droit sur le dossier `Services`
2. Choisissez "Add Files to JiraViewer..."
3. Sélectionnez `OAuthManager.swift` et `KeychainManager.swift`
4. Cochez "Copy items if needed" et "Add to targets: JiraViewer"
5. Cliquez "Add"

Répétez pour les autres dossiers.

## Étape 2: Configuration Okta

Vous devez créer une application OAuth dans Okta (demandez à votre administrateur IT):

### Configuration requise:

1. **Type d'application**: Native Application
2. **Grant Type**: Authorization Code with PKCE
3. **Redirect URI**: `jiraviewer://oauth-callback`
4. **Scopes nécessaires**:
   - `openid`
   - `profile`
   - `email`
   - `offline_access`

### Informations à obtenir:

- **Client ID**: L'identifiant de votre application Okta
- **Okta Domain**: Votre domaine Okta (ex: `company.okta.com`)
- **Authorization Server**: Généralement `/oauth2/default`

## Étape 3: Mettre à jour OAuthConfig

Éditez le fichier `Models/OAuthModels.swift` et mettez à jour la configuration:

```swift
static let okta = OAuthConfig(
    clientId: "VOTRE_CLIENT_ID_ICI",  // À remplacer
    authorizationEndpoint: "https://VOTRE_DOMAINE_OKTA/oauth2/default/v1/authorize",  // À remplacer
    tokenEndpoint: "https://VOTRE_DOMAINE_OKTA/oauth2/default/v1/token",  // À remplacer
    redirectURI: "jiraviewer://oauth-callback",
    scopes: ["openid", "profile", "email", "offline_access"]
)
```

## Étape 4: Utilisation

1. Lancez l'application
2. Ouvrez les Préférences (Cmd+,)
3. Sélectionnez "Okta SSO (OAuth)" comme méthode d'authentification
4. Cliquez sur "Se connecter avec Okta SSO"
5. Une fenêtre s'ouvrira avec la page de connexion Okta
6. Connectez-vous avec vos identifiants Okta
7. L'application recevra automatiquement le token

## Architecture OAuth

### Flux d'authentification:

1. **Génération PKCE**: Code verifier et code challenge
2. **Authorization Request**: L'utilisateur est redirigé vers Okta
3. **User Login**: L'utilisateur se connecte via Okta SSO
4. **Callback**: Okta redirige vers `jiraviewer://oauth-callback?code=...`
5. **Token Exchange**: Le code est échangé contre un access token
6. **Token Storage**: Les tokens sont stockés dans le Keychain macOS
7. **API Calls**: Les appels API utilisent le Bearer token

### Sécurité:

- **PKCE (Proof Key for Code Exchange)**: Protection contre les attaques d'interception
- **State Parameter**: Protection CSRF
- **Keychain Storage**: Stockage sécurisé et chiffré des tokens
- **Automatic Refresh**: Rafraîchissement automatique quand le token expire
- **Bearer Token**: Utilisé pour toutes les requêtes API Jira

## Dépannage

### L'app ne se lance pas après ajout des fichiers

1. Vérifiez que tous les fichiers sont bien ajoutés à la target "JiraViewer"
2. Clean Build Folder (Cmd+Shift+K)
3. Rebuild (Cmd+B)

### La fenêtre OAuth ne s'ouvre pas

1. Vérifiez que le Client ID et les endpoints sont corrects
2. Vérifiez les logs dans la console

### Le callback ne fonctionne pas

1. Vérifiez que le URL scheme est enregistré dans Info.plist
2. Vérifiez que le Redirect URI dans Okta match `jiraviewer://oauth-callback`

### Token expired

Le token est automatiquement rafraîchi. Si ça échoue:
1. Déconnectez-vous dans les Settings
2. Reconnectez-vous

## Retour à l'authentification basique

Si OAuth ne fonctionne pas, vous pouvez toujours utiliser l'authentification basique:

1. Ouvrez les Préférences
2. Sélectionnez "Authentification Basique"
3. Entrez votre username et password/token

## Support

Pour plus d'informations sur Okta OAuth:
- https://developer.okta.com/docs/guides/implement-grant-type/authcodepkce/main/
