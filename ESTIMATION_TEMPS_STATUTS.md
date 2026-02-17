# 📐 Estimation du temps par statut (sans changelog)

## 🔍 Problème identifié

Vous voyez **"In Progress: 0.6 days"** alors qu'un ticket a été bloqué **8 jours**.

### Pourquoi ?

**Le changelog est vide** (0 transitions de statut) :
- Jira ne renvoie pas l'historique des changements de statut
- On ne peut pas savoir combien de temps le ticket a passé dans chaque statut
- Le fallback utilisait `updated` date (dernière modification) = **0.6 jours**

**Mais le ticket a été créé il y a 8 jours!**

## ✅ Solution appliquée

J'ai ajouté une **logique d'estimation** pour les tickets **terminés** (Done) sans historique :

### Pour les tickets Done/Cancelled

**Estimation basée sur le cycle time** :

```
Cycle Time = resolved_date - created_date = 8 jours

Estimation des phases :
├─ In Progress : 60% du cycle = 8 × 0.6 = 4.8 jours
├─ Review      : 20% du cycle = 8 × 0.2 = 1.6 jours
└─ Test        : 20% du cycle = 8 × 0.2 = 1.6 jours
```

### Pour les tickets en cours

**Utilise la date de mise à jour** :

```
Si ticket actuellement en "In Progress" :
  → Temps = Date actuelle - updated_date
```

## 📊 Avant vs Après

### Avant (bug)
```
Ticket LBCMONSPE-47 (Done après 8 jours) :
  In Progress: 0.6 days  ← FAUX! (juste la dernière mise à jour)
```

### Après (estimation)
```
Ticket LBCMONSPE-47 (Done après 8 jours) :
  📐 In Progress: 4.8 days (estimé: 60% du cycle time)
  📐 Review: 1.6 days (estimé: 20% du cycle time)
  📐 Test: 1.6 days (estimé: 20% du cycle time)
```

## 🎯 Ratios d'estimation

J'ai utilisé des ratios typiques d'un workflow agile :

| Phase | % du cycle | Justification |
|-------|-----------|---------------|
| **In Progress** | 60% | La majorité du temps (dev + corrections) |
| **Review** | 20% | Reviews de code + discussions |
| **Test** | 20% | Tests QA + corrections |

**Ces ratios sont configurables** si votre workflow est différent!

## 🔧 Personnalisation des ratios

Si vos phases sont différentes, je peux ajuster :

### Exemple 1 : Dev rapide, tests longs
```swift
In Progress: 40%  (dev rapide)
Review: 20%
Test: 40%         (tests approfondis)
```

### Exemple 2 : Reviews longues
```swift
In Progress: 50%
Review: 35%       (reviews détaillées)
Test: 15%
```

### Exemple 3 : Workflow simple
```swift
In Progress: 80%  (presque tout le temps)
Review: 20%
Test: 0%          (pas de phase de test)
```

## 📊 Logs de débogage

Dans la console, vous verrez maintenant :

```
📊 [DEBUG] Extracting time for LBCMONSPE-47
📊 [DEBUG] Current status: Done
📊 [DEBUG] No history or no transitions available
📊 [DEBUG] Ticket is COMPLETED
📊 [DEBUG] 📐 Estimated In Progress time (60% of cycle): 4.8 days
📊 [DEBUG] 📐 Estimated Review time (20% of cycle): 1.6 days
```

## ⚠️ Limites de l'estimation

### Ce que l'estimation fait BIEN
✅ Donne une **vue d'ensemble** du temps passé
✅ Mieux que "0.6 days" qui est clairement faux
✅ Permet de comparer les tickets entre eux
✅ Identifie les tickets qui ont pris longtemps

### Ce que l'estimation fait MAL
❌ **Pas précis** si le workflow réel est différent
❌ **Pas exact** (estimation vs réalité)
❌ Ne détecte pas si un ticket est resté 7j en Review et 1j en Dev

## 💡 Solution idéale (future)

Pour avoir des données **exactes**, il faudrait :

### Option 1 : Activer le changelog dans Jira
- Configuration Jira pour inclure les transitions de statut
- Permissions du token API pour lire l'historique

### Option 2 : Tracking manuel
- Ajouter des dates custom dans Jira :
  - `Start Dev Date`
  - `Start Review Date`
  - `Start Test Date`
- Calculer les durées exactes

### Option 3 : Webhooks Jira
- Capturer les transitions en temps réel
- Stocker dans une base de données locale
- Afficher les vraies durées

## 🎯 Utilité actuelle

Avec l'estimation, vous pouvez :

✅ **Identifier les tickets longs** :
```
Ticket A : In Progress estimé 8 jours  ← PROBLÈME!
Ticket B : In Progress estimé 2 jours  ← OK
```

✅ **Comparer les tickets** :
```
Tickets terminés :
- LBCMONSPE-47 : 4.8 jours (estimé)
- LBCMONSPE-52 : 2.1 jours (estimé)
→ LBCMONSPE-47 a pris 2x plus de temps
```

✅ **Vue d'ensemble du sprint** :
```
Moyenne In Progress estimée : 3.5 jours
→ Indique si le sprint était complexe ou non
```

## 🚀 Test maintenant

1. **Relancez l'app**
2. **Générez le Sprint Summary**
3. **Regardez les logs** dans la console :
   - Messages avec 📐 = Estimation
   - Messages avec ✅ = Donnée réelle du changelog
   - Messages avec ⚠️ = Fallback sur updated date

4. **Vérifiez** les tickets "Done" :
   - Doivent maintenant afficher des temps réalistes
   - Basés sur 60% / 20% / 20% du cycle time

## ✅ Build Status

**BUILD SUCCEEDED** - Prêt à tester!

---

**Les tickets Done avec 8 jours de cycle devraient maintenant afficher ~4.8 jours en In Progress au lieu de 0.6 jours!** 📐✅
