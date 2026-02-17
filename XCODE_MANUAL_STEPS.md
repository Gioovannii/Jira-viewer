# 🔧 Étapes Manuelles dans Xcode

## Problème Actuel

- ❌ Erreur: "No such module 'Swinject'"
- ❌ Les fichiers Tests causent des erreurs (XCTest non disponible dans le target principal)

---

## ✅ Solution : Étapes à Suivre dans Xcode

### 1️⃣ Retirer les Fichiers Tests

Les fichiers Tests ne peuvent pas être dans le target principal car ils utilisent XCTest.

**Dans Xcode** :
1. Project Navigator → Trouvez le dossier `Tests/` (probablement en rouge)
2. **Sélectionnez** le dossier `Tests/`
3. Appuyez sur **Delete** (touche Suppr)
4. Choisissez **"Remove References"** (pas "Move to Trash")

---

### 2️⃣ Vérifier que Swinject est Lié au Target

**Dans Xcode** :
1. Cliquez sur le projet **"JiraViewer"** (icône bleue en haut du Project Navigator)
2. Sélectionnez le target **"JiraViewer"** dans la liste
3. Allez dans l'onglet **"General"**
4. Scrollez jusqu'à **"Frameworks, Libraries, and Embedded Content"**
5. Vérifiez que **"Swinject"** est dans la liste
6. Si **absent** :
   - Cliquez sur le bouton **"+"**
   - Dans la popup, sélectionnez **"Swinject"**
   - Cliquez sur **"Add"**

---

### 3️⃣ Nettoyer et Recompiler

**Dans Xcode** :
1. **Product** → **Clean Build Folder** (Cmd+Shift+K)
2. Attendez que le nettoyage se termine
3. **Product** → **Build** (Cmd+B)

---

### 4️⃣ Si ça ne Fonctionne Toujours Pas

**Fermer et Rouvrir Xcode** :
1. **Xcode** → **Quit Xcode** (Cmd+Q)
2. Rouvrir `JiraViewer.xcodeproj`
3. Attendez que Xcode indexe le projet (barre de progression en haut)
4. **Product** → **Clean Build Folder** (Cmd+Shift+K)
5. **Product** → **Build** (Cmd+B)

---

## 📦 Alternative : Réinstaller Swinject

Si Swinject n'apparaît toujours pas :

1. **File** → **Packages** → **Reset Package Caches**
2. Attendez quelques secondes
3. **File** → **Packages** → **Resolve Package Versions**
4. Attendez que Xcode télécharge Swinject
5. **Product** → **Clean Build Folder** (Cmd+Shift+K)
6. **Product** → **Build** (Cmd+B)

---

## ✅ Résultat Attendu

Après ces étapes, la compilation devrait réussir et vous devriez voir :

```
Build Succeeded ✅
```

---

## 🧪 Note sur les Tests

Les tests unitaires ont été créés mais ne peuvent pas être compilés sans un target de tests dédié.

**Pour ajouter les tests plus tard** :

1. Créer un nouveau target : **File** → **New** → **Target** → **Unit Testing Bundle**
2. Nom : `JiraViewerTests`
3. Ajouter les fichiers du dossier `Tests_BACKUP/` à ce target
4. Les tests pourront alors être exécutés

Les fichiers de tests sont sauvegardés dans `Tests_BACKUP/` et peuvent être réintégrés plus tard.

---

## 📊 Structure Finale du Projet

Après nettoyage, votre projet devrait avoir :

```
JiraViewer/
├── JiraViewerApp.swift
├── Domain/           ✅
├── Data/             ✅
├── Infrastructure/   ✅
├── Presentation/     ✅
└── Package Dependencies
    └── Swinject      ✅
```

---

## 🚀 Prochaine Étape

Une fois la compilation réussie, vous pourrez :
1. **Lancer l'application** (Cmd+R)
2. Configurer votre token Jira dans les Settings
3. Utiliser l'application avec la nouvelle Clean Architecture !

---

*Les tests peuvent être réintégrés plus tard en créant un target de tests dédié.*
