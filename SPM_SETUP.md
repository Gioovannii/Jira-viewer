# Configuration des dépendances SPM

## Étapes pour ajouter Swinject et KeychainAccess

### Via Xcode UI (Recommandé)

1. Ouvrir `JiraViewer.xcodeproj` dans Xcode
2. File → Add Package Dependencies...
3. Ajouter les packages suivants :

#### Swinject (Dependency Injection)
- URL: `https://github.com/Swinject/Swinject.git`
- Version: 2.8.0 ou supérieure
- Produit: Swinject

#### KeychainAccess (Stockage sécurisé)
- URL: `https://github.com/kishikawakatsumi/KeychainAccess.git`
- Version: 4.2.2 ou supérieure
- Produit: KeychainAccess

4. Sélectionner le target `JiraViewer`
5. Cliquer "Add Package"

### Vérification

Les packages doivent apparaître dans :
- Project Navigator → JiraViewer → Package Dependencies
- Project Settings → JiraViewer (target) → Frameworks, Libraries, and Embedded Content

### Import dans le code

```swift
import Swinject
import KeychainAccess
```

## Alternative : Ajouter manuellement au project.pbxproj

Si besoin, les références peuvent être ajoutées manuellement au fichier `JiraViewer.xcodeproj/project.pbxproj`.
