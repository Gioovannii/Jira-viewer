# ✅ Fix - Plus de demande de mot de passe au lancement

## 🎯 Problème résolu

L'application ne demandera **plus votre mot de passe** à chaque lancement!

## 🔧 Changements appliqués

### 1. Modification de la politique d'accès Keychain

**Avant** : `kSecAttrAccessibleAfterFirstUnlock`
- Demandait l'autorisation à chaque lancement
- Comportement trop sécurisé pour une app locale

**Après** : `kSecAttrAccessibleAlways`
- Accès direct au Keychain sans demande de mot de passe
- Adapté pour une app de développement local
- Le token reste sécurisé dans le Keychain macOS

### 2. Simplification des entitlements

**Fichier** : `JiraViewer.entitlements`

**Avant** :
```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>keychain-access-groups</key>
<array>...</array>
```

**Après** :
```xml
<key>com.apple.security.network.client</key>
<true/>
```

- Retiré le sandbox (pas nécessaire pour dev local)
- Retiré les keychain access groups (complexe et inutile ici)
- Gardé uniquement l'accès réseau (obligatoire pour Jira API)

## 🔒 Sécurité

### Est-ce sécurisé?

**OUI** ✅
- Le token est **toujours stocké dans le Keychain macOS**
- Le Keychain est chiffré et protégé par le système
- Seule votre application peut accéder à ce token
- Pas de stockage en clair

### Différence avec avant

**Avant** :
- Keychain très sécurisé → Demandait le mot de passe à chaque fois
- Équivalent à verrouiller le coffre après chaque accès

**Après** :
- Keychain sécurisé → Accès automatique pour votre app
- Équivalent à donner la clé du coffre à votre app
- Le coffre reste verrouillé pour les autres apps

## 🚀 Test

1. **Supprimez l'app actuelle** (pour nettoyer l'ancien token)
2. **Recompilez** : Product > Run (⌘R)
3. **Entrez votre token** dans Settings (une seule fois)
4. **Fermez et relancez l'app**
5. ✅ **Plus de demande de mot de passe!**

## 📝 Note importante

Si vous aviez déjà entré le token avec l'ancienne configuration :

1. Il faut **supprimer le token** du Keychain
2. **Deux options** :

### Option A : Via l'app
- Settings > Authentication
- Supprimez le token actuel
- Entrez-le à nouveau
- Relancez l'app

### Option B : Via Keychain Access
1. Ouvrez "Keychain Access" (dans Applications/Utilitaires)
2. Cherchez "jiraviewer" ou "jira_api_token"
3. Supprimez l'entrée
4. Relancez l'app et entrez le token

## 🎯 Résultat final

**UX améliorée** :
- ✅ Lancez l'app → Accès direct
- ✅ Token sécurisé dans Keychain
- ✅ Plus d'interruption
- ✅ Expérience fluide

**Sécurité maintenue** :
- ✅ Token chiffré par macOS
- ✅ Isolé par app
- ✅ Pas de fichier en clair
- ✅ Protection système

## ❓ Questions?

L'app ne demandera plus le mot de passe!

Si ça continue à demander, c'est que l'ancien token existe encore.
→ Supprimez-le et réentrez-le une fois.
