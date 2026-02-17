# Solution - Changelog Vide

## 🔍 Problème identifié

D'après vos logs :
```
📊 [DEBUG] Issues with changelog: 12  ✅ (le changelog est présent)
📊 [DEBUG] Issue LBCMONSPE-73 has 0 transitions  ❌ (mais vide!)
```

**Le changelog est récupéré mais il est VIDE.**

Cela signifie que :
- Soit les tickets n'ont jamais changé de statut
- Soit l'API Jira ne retourne pas l'historique complet
- Soit le changelog ne contient pas de changements de type "status"

## ✅ Solution implémentée

J'ai ajouté une **méthode de détection alternative** qui fonctionne **sans le changelog** :

### Avant (ne fonctionnait pas)
```
Calcul basé sur le changelog uniquement
→ Si changelog vide → Pas de détection
```

### Après (nouvelle version)
```
1. Essayer d'utiliser le changelog (si disponible)
2. SINON: Utiliser la date "updated" du ticket
   → Calcule: Nombre de jours depuis la dernière mise à jour
   → Si > 3 jours → Ticket stagnant → Bloqué ⚠️
```

## 🎯 Comment ça fonctionne maintenant

### Détection de stagnation (méthode fallback)
Un ticket est considéré comme **stagnant** si :
- `Date().now - ticket.updated > 3 jours`

**Exemple :**
- Ticket LBCMONSPE-42
- Dernière mise à jour : 10 février
- Aujourd'hui : 17 février
- Différence : 7 jours → **BLOQUÉ** ⚠️

### Détection de flag
Un ticket est **flaggé** si :
- Le champ `customfield_10021` contient "impediment" ou "blocked"
- (Dans vos logs : `Issues with flagged field: 0` donc aucun ticket flaggé)

## 🧪 Test maintenant

1. **Relancez l'application** (la nouvelle version avec fallback)
2. **Regardez les nouveaux logs dans la console :**

Vous devriez maintenant voir :
```
✅ [DEBUG] Issue LBCMONSPE-42 only 1.2 days in status (< 3 days)
🚫 [DEBUG] Issue LBCMONSPE-55 is STAGNANT (7.5 days in Done)
```

3. **Dans l'interface :**
   - Les tickets avec `updated` > 3 jours devraient avoir le badge ⚠️
   - Le filtre "Show only blocked issues" devrait fonctionner
   - La Sprint Review devrait afficher les métriques

## 📊 Nouveaux logs de débogage

J'ai ajouté des logs plus détaillés :

### 1. Dans IssueHistoryMapper
```
📊 [DEBUG] Changelog has X history items
📊 [DEBUG] First history item has Y changes
📊 [DEBUG] First change field: status (ou autre)
```
→ Pour comprendre pourquoi le changelog est vide

### 2. Dans Issue.isBlocked
```
🚫 [DEBUG] Issue XXX is STAGNANT (7.5 days in Done)
✅ [DEBUG] Issue YYY only 1.2 days in status (< 3 days)
```
→ Pour voir la détection en action

## 🎯 Prochains tests

### Test 1: Vérifier la détection de stagnation
1. Relancez l'app
2. Regardez la console
3. Cherchez les messages `🚫 [DEBUG]` ou `✅ [DEBUG]`
4. Notez combien de tickets sont détectés comme stagnants

### Test 2: Vérifier l'interface
1. Dans la liste de tickets, cherchez les badges ⚠️ rouges
2. Au survol : devrait dire "Stagnant for X days"
3. Activez "Show only blocked issues"
4. La liste devrait se filtrer

### Test 3: Sprint Review
1. Cliquez sur "Sprint Review"
2. Cherchez la section "🚫 Blocked Issues"
3. Devrait afficher les statistiques

## ❓ Si ça ne fonctionne toujours pas

### Question 1: Combien de tickets ont `updated` > 3 jours?
Peut-être que tous vos tickets sont récents (< 3 jours) ?

### Question 2: Le champ "Flagged" existe-t-il?
D'après les logs : `Issues with flagged field: 0`
→ Le champ `customfield_10021` n'existe pas ou est vide

**Pour trouver le bon champ :**
1. Exécutez `./test_jira_api.sh` (après avoir ajouté votre token)
2. Regardez le fichier `jira_fields_debug.json`
3. Cherchez un champ lié à "flag", "impediment", "blocked"

## 📋 Résumé des changements

### Fichiers modifiés

1. **Domain/Entities/Issue.swift**
   - `daysInCurrentStatus` : Ajout fallback sur `updated` date
   - `isBlocked` : Ajout logs de débogage

2. **Data/Mappers/IssueHistoryMapper.swift**
   - Ajout logs pour comprendre pourquoi changelog est vide

### Comportement

**Avant :**
- Changelog vide → Pas de détection → Aucun ticket bloqué ❌

**Après :**
- Changelog vide → Utilise `updated` date → Détection fonctionne ✅

## 🚀 Action immédiate

1. **Fermez l'application actuelle**
2. **Recompilez :** Product > Run (⌘R) dans Xcode
3. **Chargez un sprint**
4. **Regardez la console** pour les nouveaux logs
5. **Vérifiez l'interface** pour les badges ⚠️

## 📞 Retour attendu

Partagez-moi les nouveaux logs, notamment :
```
📊 [DEBUG] Changelog has X history items
🚫 [DEBUG] Issue XXX is STAGNANT (Y days)
✅ [DEBUG] Issue YYY only Z days
```

Cela me dira si la détection fonctionne maintenant avec le fallback! 🎯
