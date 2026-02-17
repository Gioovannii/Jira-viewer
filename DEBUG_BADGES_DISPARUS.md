# 🔍 Debug : Badges de blocage disparus

## 🎯 Problème

Les badges ⚠️ n'apparaissent plus dans la liste des tickets sur le board.

## 🔧 Logs de débogage ajoutés

J'ai ajouté des logs détaillés pour comprendre ce qui se passe.

### Logs de calcul des jours

Dans la console, vous verrez maintenant :

```
📅 [DAYS] LBCMONSPE-47: 11.5d in Done (from updated date)
📅 [DAYS] LBCMONSPE-52: 2.1d in In Progress (from updated date)
⚠️ [DAYS] LBCMONSPE-55: No updated date, can't calculate days
```

### Logs de détection de blocage

Pour chaque ticket, vous verrez :

```
🚫 [BLOCK] LBCMONSPE-52 is STAGNANT (5.2d in In Progress) → BLOCKED
✅ [BLOCK] LBCMONSPE-47 is Done but stagnant (11.5d) → NOT BLOCKED (completed)
✅ [BLOCK] LBCMONSPE-55 only 1.2d in To Do → NOT BLOCKED
⚠️ [BLOCK] LBCMONSPE-60 has no daysInCurrentStatus → NOT BLOCKED
```

## 📋 Ce qu'il faut vérifier

### 1. Lancez l'app et chargez un sprint/board

### 2. Regardez la console pour les logs

Cherchez les messages avec `[BLOCK]` et `[DAYS]` :

**Questions clés** :
- Voyez-vous des messages `🚫 [BLOCK] ... → BLOCKED` ?
- Ou seulement des `✅ [BLOCK] ... → NOT BLOCKED` ?
- Y a-t-il des `⚠️ [DAYS] ... No updated date` ?

### 3. Copiez-moi quelques exemples

Par exemple :
```
📅 [DAYS] LBCMONSPE-XX: 5.2d in In Progress
🚫 [BLOCK] LBCMONSPE-XX → BLOCKED

📅 [DAYS] LBCMONSPE-YY: 1.2d in To Do
✅ [BLOCK] LBCMONSPE-YY → NOT BLOCKED
```

## 🔍 Causes possibles

### Cause 1 : Tous les tickets sont "Done"
Si tous les tickets du board sont en statut "Done" :
```
✅ [BLOCK] ... is Done but stagnant → NOT BLOCKED (completed)
```
→ Normal, les tickets Done ne sont plus marqués comme bloqués

**Solution** : Voir les tickets en cours (In Progress, To Do, etc.)

### Cause 2 : Aucun ticket > 3 jours
Si tous les tickets ont été mis à jour récemment :
```
✅ [BLOCK] ... only 1.2d → NOT BLOCKED
✅ [BLOCK] ... only 2.5d → NOT BLOCKED
```
→ Normal, aucun ticket n'est stagnant

**Solution** : Le seuil est à 3 jours, peut-être le baisser à 2 jours?

### Cause 3 : Pas de date "updated"
Si les tickets n'ont pas de date de mise à jour :
```
⚠️ [DAYS] ... No updated date
⚠️ [BLOCK] ... has no daysInCurrentStatus → NOT BLOCKED
```
→ Bug, il faudrait utiliser la date "created" comme fallback

**Solution** : Je peux ajouter un fallback sur "created"

### Cause 4 : Les logs montrent BLOCKED mais pas de badge

Si vous voyez dans les logs :
```
🚫 [BLOCK] LBCMONSPE-XX → BLOCKED
```
Mais aucun badge dans l'interface → Problème d'affichage

**Solution** : Vérifier le code de IssueRow.swift

## 🎛️ Options de configuration

### Option 1 : Réduire le seuil de stagnation

Actuellement : **3 jours**

Si vous voulez **2 jours** :

**Fichier** : `Domain/Entities/Issue.swift` ligne 145
```swift
if let days = daysInCurrentStatus, days >= 2.0 {  // Changer 3.0 → 2.0
```

### Option 2 : Inclure les tickets "Done" stagnants

Si vous voulez voir les badges même sur les tickets Done :

**Fichier** : `Domain/Entities/Issue.swift` ligne 140-142
```swift
// Commenter ces lignes :
// if isCompleted {
//     return false
// }
```

### Option 3 : Utiliser "created" comme fallback

Si les tickets n'ont pas de date "updated" :

**Fichier** : `Domain/Entities/Issue.swift` ligne 126
```swift
guard let updated = updated ?? created else { return nil }
```

## 🚀 Prochaines étapes

1. **Relancez l'app**
2. **Chargez un board/sprint**
3. **Regardez la console** Xcode
4. **Copiez-moi les logs** `[BLOCK]` et `[DAYS]`
5. **Je pourrai diagnostiquer** exactement pourquoi les badges ne s'affichent plus

## 📊 Exemple de bons logs

Si tout fonctionne correctement, vous devriez voir :

```
// Chargement des tickets
📅 [DAYS] LBCMONSPE-41: 11.5d in Done (from updated date)
✅ [BLOCK] LBCMONSPE-41 is Done but stagnant → NOT BLOCKED (completed)

📅 [DAYS] LBCMONSPE-46: 5.2d in In Progress (from updated date)
🚫 [BLOCK] LBCMONSPE-46 is STAGNANT (5.2d in In Progress) → BLOCKED

📅 [DAYS] LBCMONSPE-55: 0.6d in To Do (from updated date)
✅ [BLOCK] LBCMONSPE-55 only 0.6d in To Do → NOT BLOCKED
```

Et dans l'interface :
- LBCMONSPE-41 : Pas de badge (Done)
- LBCMONSPE-46 : Badge ⚠️ rouge (Stagnant)
- LBCMONSPE-55 : Pas de badge (< 3 jours)

## ✅ Build Status

**BUILD SUCCEEDED** - Prêt à tester avec logs!

---

**Relancez l'app et envoyez-moi les logs pour qu'on trouve pourquoi les badges ont disparu!** 🔍
