# 🔐 Configuration Jira - Guide détaillé

## Problème: "L'application n'est pas connectée"

Si l'application ne se connecte pas à Jira, suivez ce guide étape par étape.

---

## Option 1: Mot de passe (Simple)

### Pour Jira Server

1. Ouvrez **JiraViewer**
2. Allez dans **Settings** (Cmd+,)
3. Remplissez:

```
URL Jira:          https://jira.ets.mpi-internal.com
Nom d'utilisateur: votre.nom
Mot de passe:      VotreMotDePasseJira
Clé du projet:     LBCMONSPE
```

4. **Fermez** les Settings
5. L'app va automatiquement se connecter

### ⚠️ Si ça ne fonctionne pas

**Vérifiez:**
- ✅ L'URL est correcte (avec `https://`)
- ✅ Vous utilisez le bon nom d'utilisateur (celui pour vous connecter à Jira)
- ✅ Le mot de passe est correct
- ✅ Vous êtes sur le réseau de l'entreprise (ou VPN)

---

## Option 2: Token API (Recommandé pour Jira Cloud)

### Si votre Jira est sur le Cloud (*.atlassian.net)

1. **Créer un API Token:**
   - Allez sur https://id.atlassian.com/manage-profile/security/api-tokens
   - Cliquez sur **"Create API token"**
   - Donnez-lui un nom (ex: "JiraViewer")
   - Copiez le token (vous ne le reverrez plus!)

2. **Dans JiraViewer:**
```
URL Jira:          https://votredomaine.atlassian.net
Nom d'utilisateur: votre.email@entreprise.com
Mot de passe:      [Collez le token API ici]
Clé du projet:     LBCMONSPE
```

---

## Option 3: Token personnel Jira Server

### Pour Jira Server avec authentification par token

1. **Créer un token dans Jira:**
   - Connectez-vous à Jira
   - Allez dans votre **Profil** (en haut à droite)
   - Cliquez sur **"Personal Access Tokens"** ou **"API Tokens"**
   - Créez un nouveau token
   - Copiez-le

2. **Dans JiraViewer:**
```
URL Jira:          https://jira.ets.mpi-internal.com
Nom d'utilisateur: votre.nom
Mot de passe:      [Collez le token ici]
Clé du projet:     LBCMONSPE
```

---

## Vérifier que ça marche

### Test de connexion

1. Fermez les Settings
2. Attendez quelques secondes
3. La colonne **"Sprints"** devrait se remplir
4. Si vous voyez vos sprints → **C'est bon!** ✅

### En cas d'erreur

**Message: "Could not find board"**
- ➡️ Vérifiez la clé du projet (LBCMONSPE)
- ➡️ Assurez-vous d'avoir accès à ce projet dans Jira

**Message: "Failed to fetch sprints"**
- ➡️ Vérifiez vos credentials
- ➡️ Testez de vous connecter à Jira dans le navigateur

**Message: "Bad credentials" ou "401 Unauthorized"**
- ➡️ Mot de passe incorrect
- ➡️ Essayez avec un token API

---

## Trouver la clé de votre projet

La clé du projet se trouve dans l'URL Jira:

```
https://jira.ets.mpi-internal.com/projects/LBCMONSPE/summary
                                            ^^^^^^^^^^
                                          C'est ici!
```

Ou:
```
https://jira.ets.mpi-internal.com/browse/LBCMONSPE-123
                                          ^^^^^^^^^
                                        C'est ici!
```

---

## Configuration Claude AI (Optionnel)

Pour les résumés intelligents:

1. Créez un compte sur https://console.anthropic.com/
2. Allez dans **API Keys** > **Create Key**
3. Copiez la clé (commence par `sk-ant-...`)
4. Dans JiraViewer Settings, collez-la dans **"Clé API Claude"**

**Sans cette clé:**
- ✅ L'app fonctionne normalement
- ❌ Les résumés IA ne seront pas disponibles

---

## Sécurité des credentials

### Où sont stockés les mots de passe?

- Stockés dans **UserDefaults** sur votre Mac
- **Jamais** envoyés à des tiers (sauf Jira et Claude)
- Restent sur votre ordinateur

### Recommandations

- ✅ Utilisez un token API plutôt qu'un mot de passe
- ✅ Créez un token avec les permissions minimales
- ✅ Ne partagez jamais vos credentials
- ❌ N'utilisez pas votre mot de passe principal

---

## Tester votre configuration

### Test rapide dans le Terminal

Pour vérifier si vos credentials fonctionnent:

```bash
# Remplacez USERNAME et PASSWORD
curl -u "USERNAME:PASSWORD" \
  "https://jira.ets.mpi-internal.com/rest/api/2/myself"
```

Si ça retourne vos infos → Les credentials sont bons! ✅

---

## Support

**Problème persistant?**

1. Vérifiez que vous êtes sur le réseau de l'entreprise
2. Testez dans le navigateur: https://jira.ets.mpi-internal.com
3. Contactez votre admin Jira pour vérifier vos permissions
4. Ouvrez une issue: https://github.com/Gioovannii/Jira-viewer/issues

---

## Exemple de configuration complète

```
╔════════════════════════════════════════════════╗
║              SETTINGS - JiraViewer             ║
╠════════════════════════════════════════════════╣
║                                                ║
║  Configuration Jira                            ║
║  ─────────────────────────────────────────     ║
║  URL Jira:                                     ║
║  https://jira.ets.mpi-internal.com            ║
║                                                ║
║  Nom d'utilisateur:                            ║
║  jean.dupont                                   ║
║                                                ║
║  Token API / Mot de passe:                     ║
║  ••••••••••••••••                             ║
║                                                ║
║  Clé du projet:                                ║
║  LBCMONSPE                                     ║
║                                                ║
║  ─────────────────────────────────────────     ║
║                                                ║
║  Configuration Claude AI (Optionnel)           ║
║  ─────────────────────────────────────────     ║
║  Clé API Claude:                               ║
║  sk-ant-api03-...                              ║
║                                                ║
╚════════════════════════════════════════════════╝
```

**Fermez les Settings et c'est parti!** 🚀
