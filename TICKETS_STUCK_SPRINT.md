# ✅ Vue détaillée : Tickets bloqués par statut dans le sprint

## 🎯 Nouvelle fonctionnalité

L'analyse de flux affiche maintenant **la liste des tickets qui sont restés trop longtemps** dans In Progress, Review ou Test pendant le sprint.

## 📊 Ce que vous voyez maintenant

### Section 1: Tickets bloqués (>3 jours)

```
⚠️ Tickets stuck (>3 days in a status)

LBCMONSPE-47  Implement user authentication          Done
  🔴 In Progress: 5.2d  🔴 Review: 4.1d  🟢 Test: 0.8d

LBCMONSPE-52  Fix critical bug in login               In Progress
  🔴 In Progress: 8.5d

LBCMONSPE-55  Add dark mode support                   Review
  🟢 In Progress: 2.1d  🔴 Review: 4.8d
```

### Section 2: Moyennes globales

```
Average time per status:

In Progress    ████████ 3.2 days (15 tickets)
Review         ████ 1.5 days (12 tickets)
Test           ██ 0.8 days (8 tickets)
```

## 🔍 Détails affichés par ticket

Pour chaque ticket qui a **dépassé 3 jours** dans un statut :

### 1. En-tête du ticket
- **Clé** : LBCMONSPE-47 (en rouge si bloqué)
- **Résumé** : Titre du ticket (limité à 1 ligne)
- **Statut actuel** : Done, In Progress, etc.

### 2. Temps par phase (avec indicateurs)
- 🔴 **Rouge** : > 3 jours (problème!)
- 🟢 **Vert** : ≤ 3 jours (OK)

**Exemples** :
```
🔴 In Progress: 5.2d  → PROBLÈME (trop long)
🟢 Review: 1.5d       → OK (rapide)
🔴 Test: 4.1d         → PROBLÈME (trop long)
```

## 🎯 Cas d'usage

### Identifier les goulots par ticket

**Exemple 1: Ticket bloqué en Dev**
```
LBCMONSPE-47  Refactor authentication
  🔴 In Progress: 8.5d  ← PROBLÈME!
  🟢 Review: 1.2d
```
→ Ce ticket a pris trop de temps en développement

**Exemple 2: Ticket bloqué en Review**
```
LBCMONSPE-52  Add payment integration
  🟢 In Progress: 2.1d
  🔴 Review: 6.3d       ← PROBLÈME!
```
→ Ce ticket attend en review depuis trop longtemps

**Exemple 3: Ticket bloqué en Test**
```
LBCMONSPE-55  Performance optimization
  🟢 In Progress: 1.5d
  🟢 Review: 0.8d
  🔴 Test: 5.2d         ← PROBLÈME!
```
→ Ce ticket est bloqué en tests

## 💡 Actions selon les insights

### Si beaucoup de tickets rouges en "In Progress"
```
Problème: Les tickets prennent trop de temps à développer

Actions possibles:
- Découper les tickets plus petit
- Pair programming sur les complexes
- Revoir la complexité estimée
- Vérifier si manque de clarté dans les specs
```

### Si beaucoup de tickets rouges en "Review"
```
Problème: Les reviews ne sont pas faites rapidement

Actions possibles:
- Désigner un reviewer du jour
- Reviews 2x par jour (matin + fin d'après-midi)
- Limiter la taille des PRs
- Auto-merge si 2+ approvals et CI green
```

### Si beaucoup de tickets rouges en "Test"
```
Problème: Les tests prennent trop de temps

Actions possibles:
- Tests automatisés insuffisants?
- QA surchargé?
- Problèmes de qualité récurrents?
- Environnement de test instable?
```

## 📋 Où voir ça?

1. **Lancez l'app**
2. **Sélectionnez un sprint**
3. **Cliquez sur "Sprint Review"**
4. **Cliquez sur "Generate Summary"**
5. **Scrollez** → Section "Status Flow Analysis"
6. ✅ **En haut** : Liste des tickets bloqués
7. ✅ **En bas** : Moyennes globales

## 🎨 Interface

### Tickets bloqués (zone rouge)
```
┌─────────────────────────────────────────┐
│ ⚠️ Tickets stuck (>3 days)             │
│                                         │
│ [LBCMONSPE-47] Ticket title            │
│   🔴 In Progress: 5.2d                 │
│   🔴 Review: 4.1d                      │
│                                         │
│ [LBCMONSPE-52] Another ticket          │
│   🔴 In Progress: 8.5d                 │
└─────────────────────────────────────────┘
```

### Moyennes (barres visuelles)
```
┌─────────────────────────────────────────┐
│ Average time per status:                │
│                                         │
│ In Progress  ████████ 3.2 days         │
│ Review       ████ 1.5 days             │
│ Test         ██ 0.8 days               │
└─────────────────────────────────────────┘
```

## 🔍 Méthode de calcul

### Détection des phases de travail

**In Progress** détecté si le statut contient :
- "in progress"
- "en cours"
- "wip"

**Review** détecté si le statut contient :
- "review"
- "to review"
- "à réviser"
- "révision"
- "code review"

**Test** détecté si le statut contient :
- "test"
- "testing"
- "in test"
- "en test"
- "qa"

### Seuil de blocage

Un ticket est **"stuck" (bloqué)** si :
```
timeInProgress > 3 jours
OU timeInReview > 3 jours
OU timeInTest > 3 jours
```

## 📊 Exemple réel avec vos données

D'après vos sprints, vous pourriez voir :

```
⚠️ Tickets stuck (>3 days in a status)

LBCMONSPE-47  Feature X                    Done
  🔴 In Progress: 11.5d

LBCMONSPE-52  Feature Y                    Done
  🔴 In Progress: 8.3d

────────────────────────────────────────

Average time per status:

In Progress    ████████ 9.9 days
```

**Insight** : Les tickets passent presque 10 jours en moyenne en développement → Besoin de les découper?

## ✅ Résultat final

**Avant** : Seulement des moyennes globales
```
In Progress: 3.2 days avg  (mais quels tickets?)
```

**Après** : Liste détaillée + moyennes
```
⚠️ Tickets stuck:
- LBCMONSPE-47: In Progress 5.2d, Review 4.1d
- LBCMONSPE-52: In Progress 8.5d

Average:
- In Progress: 3.2 days
```

## 🚀 Build Status

✅ **BUILD SUCCEEDED** - Prêt à tester!

## 🎯 Prochaines étapes

1. **Testez** avec votre sprint actuel
2. **Identifiez** les tickets problématiques
3. **Analysez** pourquoi ils sont bloqués
4. **Agissez** pour débloquer le workflow
5. **Comparez** avec le prochain sprint

Vous avez maintenant une **vue actionnable** de ce qui s'est passé dans votre sprint! 📊🎯
