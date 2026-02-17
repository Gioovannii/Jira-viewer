# 🧪 Comment tester les badges de blocage

## ✅ Build Status
**BUILD SUCCEEDED** - L'app compile correctement avec les logs de debug.

## 🎯 Ce qui a été fait

J'ai vérifié que tout le code est en place:

1. **Issue.swift (lignes 115-166)** ✅
   - `daysInCurrentStatus` calcule les jours avec logs détaillés
   - `isBlocked` détecte le blocage avec logs détaillés

2. **IssueRow.swift (lignes 47-51)** ✅
   - Badge ⚠️ rouge affiché si `issue.isBlocked == true`
   - Tooltip explicatif (flagged ou stagnant X jours)

3. **IssueListViewModel.swift (lignes 36-41)** ✅
   - Filtre "Show only blocked issues" fonctionnel

## 🔍 Étapes de test

### 1. Lancez l'app depuis Xcode

```bash
# Ouvrez Xcode
open JiraViewer.xcodeproj

# Lancez l'app avec ⌘R
# La console Xcode s'affichera en bas
```

### 2. Chargez un sprint ou board

- Sélectionnez un sprint dans la liste
- Les tickets vont se charger

### 3. Regardez la console Xcode

Vous devriez voir pour **chaque ticket**:

```
📅 [DAYS] LBCMONSPE-47: 11.5d in Done (from updated date)
✅ [BLOCK] LBCMONSPE-47 is Done but stagnant (11.5d) → NOT BLOCKED (completed)

📅 [DAYS] LBCMONSPE-52: 5.2d in In Progress (from updated date)
🚫 [BLOCK] LBCMONSPE-52 is STAGNANT (5.2d in In Progress) → BLOCKED

📅 [DAYS] LBCMONSPE-55: 1.2d in To Do (from updated date)
✅ [BLOCK] LBCMONSPE-55 only 1.2d in To Do → NOT BLOCKED
```

### 4. Vérifiez l'affichage dans la liste

Comparez les logs avec l'interface:

| Ticket | Log | Badge attendu |
|--------|-----|---------------|
| LBCMONSPE-47 | `✅ NOT BLOCKED (completed)` | ❌ Pas de badge (Done) |
| LBCMONSPE-52 | `🚫 BLOCKED` | ✅ Badge ⚠️ rouge |
| LBCMONSPE-55 | `✅ NOT BLOCKED` | ❌ Pas de badge (< 3j) |

## 🔎 Diagnostic selon les logs

### Scénario A: Tous les tickets sont "Done"

**Console:**
```
✅ [BLOCK] LBCMONSPE-41 is Done but stagnant → NOT BLOCKED (completed)
✅ [BLOCK] LBCMONSPE-47 is Done but stagnant → NOT BLOCKED (completed)
✅ [BLOCK] LBCMONSPE-52 is Done but stagnant → NOT BLOCKED (completed)
```

**Diagnostic:** ✅ Normal - Les tickets Done ne sont plus marqués comme bloqués

**Solution:** Chargez un sprint en cours avec des tickets "In Progress"

---

### Scénario B: Aucun ticket > 3 jours

**Console:**
```
✅ [BLOCK] LBCMONSPE-41 only 1.2d in In Progress → NOT BLOCKED
✅ [BLOCK] LBCMONSPE-47 only 2.5d in To Do → NOT BLOCKED
✅ [BLOCK] LBCMONSPE-52 only 0.8d in Review → NOT BLOCKED
```

**Diagnostic:** ✅ Normal - Aucun ticket n'est stagnant (tous < 3 jours)

**Solution:** Le seuil est à 3 jours. Options:
1. Attendez que des tickets stagnent
2. Baissez le seuil à 2 jours (voir section Configuration)

---

### Scénario C: Pas de date "updated"

**Console:**
```
⚠️ [DAYS] LBCMONSPE-41: No updated date, can't calculate days
⚠️ [BLOCK] LBCMONSPE-41 has no daysInCurrentStatus → NOT BLOCKED

⚠️ [DAYS] LBCMONSPE-47: No updated date, can't calculate days
⚠️ [BLOCK] LBCMONSPE-47 has no daysInCurrentStatus → NOT BLOCKED
```

**Diagnostic:** ⚠️ Problème - Les tickets n'ont pas de date "updated"

**Solution:** Ajouter un fallback sur "created" (voir section Configuration)

---

### Scénario D: Logs BLOCKED mais pas de badge

**Console:**
```
🚫 [BLOCK] LBCMONSPE-52 is STAGNANT (5.2d in In Progress) → BLOCKED
```

**Interface:** Mais aucun badge ⚠️ sur LBCMONSPE-52

**Diagnostic:** 🐛 Bug d'affichage - `isBlocked` retourne true mais badge ne s'affiche pas

**Solution:** Problème dans IssueRow.swift, je vais investiguer

---

## ⚙️ Configuration (si nécessaire)

### Option 1: Réduire le seuil à 2 jours

**Fichier:** `Domain/Entities/Issue.swift` ligne 155

**Avant:**
```swift
if days >= 3.0 {
```

**Après:**
```swift
if days >= 2.0 {  // Seuil réduit à 2 jours
```

---

### Option 2: Inclure les tickets "Done"

**Fichier:** `Domain/Entities/Issue.swift` lignes 146-151

**Avant:**
```swift
if isCompleted {
    if let days = daysInCurrentStatus, days >= 3.0 {
        print("✅ [BLOCK] \(key) is Done but stagnant (\(String(format: "%.1f", days))d) → NOT BLOCKED (completed)")
    }
    return false
}
```

**Après:**
```swift
// Commentez ces lignes pour inclure les tickets Done
// if isCompleted {
//     if let days = daysInCurrentStatus, days >= 3.0 {
//         print("✅ [BLOCK] \(key) is Done but stagnant (\(String(format: "%.1f", days))d) → NOT BLOCKED (completed)")
//     }
//     return false
// }
```

---

### Option 3: Fallback sur "created"

**Fichier:** `Domain/Entities/Issue.swift` ligne 127

**Avant:**
```swift
guard let updated = updated else {
    print("⚠️ [DAYS] \(key): No updated date, can't calculate days")
    return nil
}
```

**Après:**
```swift
guard let updated = updated ?? created else {  // Fallback sur created
    print("⚠️ [DAYS] \(key): No updated or created date, can't calculate days")
    return nil
}
```

---

## 📋 Checklist de test

Cochez au fur et à mesure:

- [ ] App lancée depuis Xcode (⌘R)
- [ ] Console visible en bas de Xcode
- [ ] Sprint/Board chargé
- [ ] Logs `[DAYS]` visibles dans la console
- [ ] Logs `[BLOCK]` visibles dans la console
- [ ] Comparé les logs avec l'affichage des badges
- [ ] Identifié le scénario (A, B, C ou D)

## 🚀 Prochaines étapes

**Si Scénario A ou B:** ✅ Tout fonctionne normalement
- Pas de tickets bloqués détectés (normal selon les données)

**Si Scénario C:** ⚠️ Données manquantes
- Appliquez "Option 3: Fallback sur created"
- Rebuild (⌘B) et relancez (⌘R)

**Si Scénario D:** 🐛 Bug d'affichage
- **Copiez-moi les logs complets** de la console
- Je vais investiguer pourquoi le badge ne s'affiche pas

---

## 📊 Exemple de bons logs

Si tout fonctionne correctement avec un ticket bloqué:

```
📊 [DEBUG] ===== FETCHING ISSUES =====
📊 [DEBUG] JQL: sprint = 123
📊 [DEBUG] Expand: changelog

📅 [DAYS] LBCMONSPE-41: 0.8d in Done (from updated date)
✅ [BLOCK] LBCMONSPE-41 is Done but stagnant → NOT BLOCKED (completed)

📅 [DAYS] LBCMONSPE-46: 5.2d in In Progress (from updated date)
🚫 [BLOCK] LBCMONSPE-46 is STAGNANT (5.2d in In Progress) → BLOCKED

📅 [DAYS] LBCMONSPE-55: 1.2d in To Do (from updated date)
✅ [BLOCK] LBCMONSPE-55 only 1.2d in To Do → NOT BLOCKED

📊 [DEBUG] ===== SUMMARY =====
📊 [DEBUG] Fetched: 25 issues
🚫 [DEBUG] Blocked issues detected: 1
```

Et dans l'interface:
- LBCMONSPE-41: Pas de badge (Done)
- LBCMONSPE-46: **Badge ⚠️ rouge** ← Visible!
- LBCMONSPE-55: Pas de badge (< 3 jours)

---

## ❓ Besoin d'aide?

**Lancez l'app, regardez les logs, et envoyez-moi:**

1. **Le scénario** (A, B, C ou D)
2. **Quelques lignes de logs** `[BLOCK]` et `[DAYS]`
3. **Une capture d'écran** de la liste des tickets

Je pourrai alors diagnostiquer exactement ce qui se passe! 🔍
