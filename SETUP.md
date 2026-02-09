# Configuration rapide

## 1. Pousser sur GitHub/GitLab

### Créer un nouveau repository sur GitHub
```bash
# Sur GitHub.com, créez un nouveau repository (ne pas initialiser avec README)
# Puis exécutez:

git remote add origin https://github.com/votre-username/jira-viewer.git
git branch -M main
git push -u origin main
```

### Ou sur GitLab
```bash
git remote add origin https://gitlab.com/votre-username/jira-viewer.git
git branch -M main
git push -u origin main
```

### Ou sur votre serveur Git interne
```bash
git remote add origin https://git.mpi-internal.com/votre-username/jira-viewer.git
git branch -M main
git push -u origin main
```

## 2. Configuration de l'application

### Première utilisation

1. Ouvrez le projet:
```bash
open JiraViewer.xcodeproj
```

2. Lancez l'app (Cmd+R)

3. Allez dans Settings (Cmd+,) et configurez:

**Configuration Jira:**
- URL Jira: `https://jira.ets.mpi-internal.com`
- Nom d'utilisateur: Votre username Jira
- Token/Mot de passe: Votre mot de passe
- Clé du projet: `LBCMONSPE` (ou votre projet)

**Configuration Claude AI:**
- Clé API Claude: Obtenez-la sur https://console.anthropic.com/
  - Créez un compte
  - Allez dans "API Keys"
  - Créez une nouvelle clé
  - Copiez-la dans les settings

4. Redémarrez l'app pour que les changements prennent effet

### Trouver votre clé de projet Jira

Dans votre URL Jira, cherchez:
- `https://jira.ets.mpi-internal.com/projects/LBCMONSPE/...`

La clé est `LBCMONSPE` dans cet exemple.

### Trouver le custom field pour les sprints

Si les sprints ne s'affichent pas:

1. Ouvrez un ticket dans votre navigateur
2. Inspectez le JSON (F12 > Network > Cherchez une requête API)
3. Trouvez le champ sprint (ex: `customfield_10020`)
4. Modifiez dans `JiraModels.swift`:

```swift
enum CodingKeys: String, CodingKey {
    // ...
    case sprint = "customfield_XXXXX"  // Remplacez XXXXX
}
```

## 3. Build et distribution

### Build de développement
```bash
xcodebuild -project JiraViewer.xcodeproj \
  -scheme JiraViewer \
  -configuration Debug \
  build
```

### Build de release
```bash
xcodebuild -project JiraViewer.xcodeproj \
  -scheme JiraViewer \
  -configuration Release \
  -derivedDataPath ./build \
  build
```

L'app sera dans: `./build/Build/Products/Release/JiraViewer.app`

### Créer un .dmg pour distribution

```bash
# Installer create-dmg si nécessaire
brew install create-dmg

# Créer le DMG
create-dmg \
  --volname "Jira Viewer" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --app-drop-link 425 120 \
  "JiraViewer-1.0.dmg" \
  "./build/Build/Products/Release/JiraViewer.app"
```

## 4. Développement

### Ajouter des fichiers
```bash
# Ajoutez vos fichiers Swift dans Models/, Services/, ou Views/
# Puis régénérez le projet:
xcodegen generate
```

### Commits
```bash
git add .
git commit -m "Description de vos changements"
git push
```

### Branches
```bash
# Créer une branche feature
git checkout -b feature/nouvelle-fonctionnalite

# Travailler...
git add .
git commit -m "Add: Nouvelle fonctionnalité"

# Pousser
git push origin feature/nouvelle-fonctionnalite
```

## 5. Dépannage

### Erreur "Could not find board"
→ Vérifiez que votre clé de projet est correcte dans Settings

### Erreur d'authentification Jira
→ Pour Jira Server: utilisez votre mot de passe
→ Pour Jira Cloud: créez un API token depuis votre profil Atlassian

### Les sprints ne s'affichent pas
→ Vérifiez le custom field ID (voir section ci-dessus)

### Erreur Claude API
→ Vérifiez que votre clé API est valide
→ Vérifiez que vous avez des crédits sur votre compte Anthropic

### Erreur de compilation Xcode
```bash
# Nettoyez et régénérez
xcodegen generate
xcodebuild clean
xcodebuild build
```

## 6. Déploiement en équipe

### Variables d'environnement (recommandé)

Au lieu de stocker les credentials dans UserDefaults, créez un fichier `APIKeys.swift` (déjà dans .gitignore):

```swift
// APIKeys.swift
struct APIKeys {
    static let jiraBaseURL = "https://jira.ets.mpi-internal.com"
    static let projectKey = "LBCMONSPE"
    // Ne committez JAMAIS les credentials réels!
}
```

### CI/CD

Exemple de workflow GitHub Actions (`.github/workflows/build.yml`):

```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install XcodeGen
        run: brew install xcodegen
      - name: Generate Xcode project
        run: xcodegen generate
      - name: Build
        run: xcodebuild -project JiraViewer.xcodeproj -scheme JiraViewer -configuration Release build
```

## Support

Pour toute question, ouvrez une issue sur le repository Git.
