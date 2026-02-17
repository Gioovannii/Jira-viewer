# 🚀 Quick Debug Guide - Badges de blocage

## ⚡ TL;DR

**Problème:** Les badges ⚠️ ne s'affichent plus sur les tickets.

**Solution:** Logs de debug ajoutés - Lancez l'app et regardez la console.

## ✅ Build Status

```
** BUILD SUCCEEDED **
```

Tout compile. Prêt à tester.

## 🎯 Test en 3 étapes

### 1. Lancer l'app
```bash
open JiraViewer.xcodeproj
# Appuyez sur ⌘R
```

### 2. Charger un sprint

Sélectionnez un sprint dans la liste.

### 3. Lire les logs

Console Xcode (en bas):

```
📅 [DAYS] LBCMONSPE-XX: 5.2d in In Progress
🚫 [BLOCK] LBCMONSPE-XX → BLOCKED
```

## 🔍 Diagnostic rapide

| Vous voyez | Ça veut dire | Action |
|------------|--------------|--------|
| `✅ NOT BLOCKED (completed)` | Tickets Done exclus | ✅ Normal |
| `✅ only X.Xd → NOT BLOCKED` | Tous < 3 jours | ✅ Normal ou baisser seuil |
| `⚠️ No updated date` | Dates manquantes | ⚠️ Ajouter fallback |
| `🚫 BLOCKED` mais pas de badge | Bug affichage | 🐛 Envoyez-moi les logs |

## 📊 Logs attendus (exemple normal)

```
📊 [DEBUG] Fetched: 15 issues

📅 [DAYS] LBCMONSPE-41: 0.8d in Done
✅ [BLOCK] LBCMONSPE-41 → NOT BLOCKED (completed)

📅 [DAYS] LBCMONSPE-46: 5.2d in In Progress
🚫 [BLOCK] LBCMONSPE-46 → BLOCKED

📅 [DAYS] LBCMONSPE-55: 1.2d in To Do
✅ [BLOCK] LBCMONSPE-55 → NOT BLOCKED

🚫 [DEBUG] Blocked issues detected: 1
```

**Résultat:** Badge ⚠️ sur LBCMONSPE-46 uniquement.

## ⚙️ Configuration rapide

### Réduire le seuil à 2 jours

**Fichier:** `Domain/Entities/Issue.swift:155`

```swift
if days >= 2.0 {  // Au lieu de 3.0
```

### Inclure les tickets Done

**Fichier:** `Domain/Entities/Issue.swift:146-151`

```swift
// Commentez ces lignes:
// if isCompleted {
//     return false
// }
```

### Fallback sur "created"

**Fichier:** `Domain/Entities/Issue.swift:127`

```swift
guard let updated = updated ?? created else {
```

## 📄 Docs complètes

- **STATUS_BADGES_BLOCAGE.md** - Vue d'ensemble complète
- **COMMENT_TESTER_BADGES.md** - Guide de test détaillé
- **DEBUG_BADGES_DISPARUS.md** - Explication des logs

## ❓ Besoin d'aide?

Envoyez-moi:
1. Les logs `[BLOCK]` et `[DAYS]` de la console
2. Quel scénario correspond (voir tableau ci-dessus)

---

**⚡ Lancez l'app, lisez les logs, identifiez le scénario!**
