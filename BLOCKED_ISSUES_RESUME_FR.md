# Résumé - Implémentation des Tickets Bloqués

## 🎯 Qu'est-ce qu'un "Blocked Issue" (Ticket Bloqué)?

Un ticket est considéré comme **bloqué** dans deux cas:

1. **Flaggé dans Jira**: Le ticket a le flag "Impediment" ou "Blocked" activé
2. **Stagnant**: Le ticket est dans le même statut depuis **3 jours ou plus**

## ✅ Ce qui a été implémenté

### 1. Détection automatique des tickets bloqués
- Badge ⚠️ rouge sur les tickets bloqués dans la liste
- Information au survol: "Flagged as blocked" ou "Stagnant for X days"

### 2. Timeline des changements de statut
- Historique complet des transitions de statut
- Temps passé dans chaque statut
- Dates et auteurs des changements

### 3. Filtre de tickets bloqués
- Toggle "Show only blocked issues" dans la liste
- Permet de ne voir que les tickets problématiques

### 4. Métriques dans la Sprint Review
- Section "Blocked Issues" avec:
  - Nombre total de tickets bloqués
  - Tickets flaggés vs stagnants
  - Durée moyenne de blocage
  - Détection du statut "goulot d'étranglement"

### 5. Configuration du champ "Flagged"
- Settings > Advanced > Flagged Field ID
- Personnalisable selon votre instance Jira
- Par défaut: `customfield_10021`

## 🔍 Pourquoi ça ne fonctionne pas encore?

Il y a probablement **deux problèmes**:

### Problème 1: Le changelog n'est pas récupéré

**Symptôme:** Aucun historique de statut ne s'affiche, aucune détection de stagnation

**Cause possible:**
- Le token API n'a pas les permissions nécessaires
- Le serveur Jira ne supporte pas `expand=changelog`
- Configuration réseau/firewall

**Comment vérifier:**
1. Lancez l'application dans Xcode
2. Regardez la console pour: `📊 [DEBUG] Issues with changelog: X`
3. Si X = 0, le changelog n'est pas récupéré

### Problème 2: Le champ "Flagged" n'est pas le bon

**Symptôme:** Les tickets flaggés dans Jira ne sont pas détectés

**Cause probable:**
- Votre instance Jira utilise un autre ID que `customfield_10021`
- Le champ "Flagged" n'existe pas dans votre configuration

**Comment vérifier:**
1. Lancez l'application dans Xcode
2. Regardez la console pour: `📊 [DEBUG] Issues with flagged field: X`
3. Si X = 0, le champ n'existe pas

## 🛠️ Comment déboguer

### Étape 1: Lancer l'application avec les logs

1. Ouvrez le projet dans Xcode
2. Product > Run (ou ⌘R)
3. Chargez un sprint
4. Regardez la console (View > Debug Area > Show Debug Area)
5. Notez les messages qui commencent par `📊 [DEBUG]` ou `🚫 [DEBUG]`

### Étape 2: Tester l'API Jira directement

J'ai créé un script de test: `test_jira_api.sh`

**Comment l'utiliser:**

1. Ouvrez le fichier `test_jira_api.sh`
2. Remplacez `JIRA_TOKEN=""` par votre token API
3. Exécutez: `./test_jira_api.sh`
4. Le script va:
   - Appeler l'API Jira
   - Vérifier si le changelog est retourné
   - Lister tous les custom fields disponibles
   - Sauvegarder les résultats dans des fichiers JSON

**Résultats attendus:**
```
✅ A un changelog: true
✅ A un champ flagged: true
```

### Étape 3: Corriger la configuration

**Si le changelog n'est pas récupéré:**
- Vérifier les permissions du Personal Access Token dans Jira
- Le token doit avoir accès en lecture aux tickets et à leur historique

**Si le champ flagged n'existe pas:**
1. Regardez le fichier `jira_fields_debug.json` généré
2. Cherchez un champ qui contient "flag", "impediment" ou "block"
3. Notez son ID (ex: `customfield_12345`)
4. Dans l'application: Settings > Advanced > Flagged Field ID
5. Mettez le bon ID

## 📋 Tests à faire

### Test 1: Historique de statut
1. Cliquez sur un ticket dans la liste
2. Dans la vue détail, vous devriez voir "Status History"
3. Une timeline des changements de statut devrait s'afficher

**Si ça n'apparaît pas:** Le changelog n'est pas récupéré (voir Problème 1)

### Test 2: Badge de blocage
1. Trouvez un ticket dans le même statut depuis 3+ jours
2. Un badge ⚠️ rouge devrait apparaître
3. Au survol: "Stagnant for X days"

**Si ça n'apparaît pas:** Le changelog n'est pas récupéré (voir Problème 1)

### Test 3: Filtre
1. Activez "Show only blocked issues"
2. La liste se filtre pour ne montrer que les tickets bloqués
3. Le compteur dans le titre change

### Test 4: Sprint Review
1. Cliquez sur "Sprint Review"
2. Vous devriez voir une section "🚫 Blocked Issues"
3. Avec statistiques et métriques

## 🚀 Solutions rapides

### Solution A: Version simplifiée (sans changelog)

Si le changelog ne peut pas être récupéré, on peut simplifier:
- Détecter les tickets bloqués uniquement par le champ "Flagged"
- Calculer la stagnation avec les dates `created`/`updated` au lieu du changelog

Voulez-vous que j'implémente cette version?

### Solution B: Debugging approfondi

Je peux ajouter plus de logs pour comprendre exactement:
- Ce que l'API Jira retourne
- Où le mapping échoue
- Quels champs sont présents/absents

## 📞 Prochaines étapes

1. **Lancez l'application** et regardez les logs dans la console Xcode
2. **Exécutez le script** `test_jira_api.sh` pour tester l'API
3. **Partagez les résultats** des logs et du script
4. Je pourrai alors vous aider à:
   - Identifier le problème exact
   - Trouver le bon custom field ID
   - Adapter la configuration

## 📄 Fichiers importants

- `DEBUG_BLOCKED_ISSUES.md` - Guide de débogage complet
- `test_jira_api.sh` - Script de test de l'API
- `BLOCKED_ISSUES_IMPLEMENTATION.md` - Documentation technique complète
- `ADD_FILES_TO_XCODE.md` - Liste des fichiers ajoutés

## ❓ Questions?

Si rien ne fonctionne, envoyez-moi:
1. Les logs de la console Xcode (messages avec 📊 ou 🚫)
2. Le résultat de `./test_jira_api.sh`
3. Le contenu de `jira_response_debug.json` (sans données sensibles)

Cela m'aidera à identifier le problème exact!
