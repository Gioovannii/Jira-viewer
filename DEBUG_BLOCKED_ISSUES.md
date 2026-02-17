# Débogage des Tickets Bloqués (Blocked Issues)

## Pourquoi les tickets bloqués ne s'affichent pas?

Il y a plusieurs raisons possibles:

### 1. Le changelog n'est pas récupéré de Jira

**Comment vérifier:**
1. Lancez l'application dans Xcode (Product > Run ou ⌘R)
2. Chargez un sprint
3. Regardez la console Xcode pour ces messages:
   ```
   📊 [DEBUG] Fetched X issues
   📊 [DEBUG] Issues with changelog: Y
   ```

**Si "Issues with changelog: 0":**
- Le serveur Jira ne renvoie pas le changelog
- Vérifiez que votre token API a les permissions nécessaires
- L'API Jira peut ne pas supporter l'expansion du changelog

**Solution:** Vérifier les permissions de votre Personal Access Token dans Jira.

### 2. Le champ "Flagged" n'est pas le bon

**Comment vérifier:**
1. Regardez dans la console:
   ```
   📊 [DEBUG] Issues with flagged field: Z
   ```

**Si "Issues with flagged field: 0":**
- Le champ `customfield_10021` n'existe pas dans votre instance Jira
- Ou ce n'est pas le champ utilisé pour "Flagged"

**Comment trouver le bon champ:**

1. Dans Jira, allez sur un ticket
2. Ouvrez les DevTools du navigateur (F12)
3. Allez dans l'onglet Network
4. Rechargez la page
5. Cherchez une requête à l'API REST (`.../rest/api/2/issue/...`)
6. Regardez la réponse JSON
7. Cherchez le champ "Flagged" ou "Impediment"
8. Notez son ID (ex: `customfield_XXXXX`)

**Solution:** Mettre à jour le champ dans Settings > Advanced > Flagged Field ID

### 3. Aucun ticket n'est réellement bloqué

Un ticket est considéré comme bloqué si:
- **Flaggé**: Le ticket a le flag "Impediment" dans Jira
- **OU Stagnant**: Le ticket est dans le même statut depuis 3+ jours

**Comment vérifier:**
1. Regardez les logs dans la console:
   ```
   📊 [DEBUG] Issue XXX-123 has Y transitions
   🚫 [DEBUG] Issue XXX-456 is FLAGGED
   ```

**Si aucun log ne montre de transitions:**
- Le changelog n'est pas récupéré (voir point 1)

**Si aucun ticket n'est FLAGGED:**
- Aucun ticket n'a le flag "Impediment" dans Jira
- Ou le champ flagged n'est pas correct (voir point 2)

### 4. Test de la détection de stagnation

Pour tester la détection des tickets stagnants (3+ jours dans le même statut):

1. **Avec changelog récupéré:**
   - Si un ticket est dans "In Progress" depuis 4 jours
   - Il devrait automatiquement être détecté comme bloqué
   - Un badge ⚠️ rouge devrait apparaître

2. **Regardez dans la console:**
   ```
   📊 [DEBUG] Issue XXX-123 has 5 transitions
   ```
   - Si vous voyez des transitions, la détection devrait fonctionner

## Tests manuels à faire

### Test 1: Vérifier qu'un ticket montre l'historique

1. Lancez l'application
2. Chargez un sprint
3. Cliquez sur un ticket
4. Dans la vue détail, cherchez la section "Status History"
5. Vous devriez voir la timeline des changements de statut

**Si la section n'apparaît pas:**
- Le changelog n'est pas récupéré de Jira
- Voir les solutions du point 1

### Test 2: Vérifier la détection de stagnation

1. Trouvez un ticket qui est dans le même statut depuis plus de 3 jours
2. Le badge ⚠️ rouge devrait apparaître à côté du ticket dans la liste
3. Au survol, le tooltip devrait dire "Stagnant for X days"

### Test 3: Vérifier le filtre

1. Activez le toggle "Show only blocked issues"
2. La liste devrait se filtrer pour ne montrer que les tickets bloqués
3. Le compteur dans le titre devrait changer

### Test 4: Vérifier les métriques du sprint

1. Cliquez sur "Sprint Review"
2. Cherchez la section "🚫 Blocked Issues"
3. Vous devriez voir:
   - Nombre de tickets bloqués
   - Nombre de tickets flaggés
   - Nombre de tickets stagnants
   - Durée moyenne de blocage
   - Statut goulot d'étranglement (si détecté)

## Logs de débogage ajoutés

Les logs suivants ont été ajoutés pour vous aider:

1. **Dans IssueRepository:**
   ```
   📊 [DEBUG] Fetched X issues
   📊 [DEBUG] Issues with changelog: Y
   📊 [DEBUG] Issues with flagged field: Z
   ```

2. **Dans IssueMapper:**
   ```
   📊 [DEBUG] Issue XXX-123 has Y transitions
   🚫 [DEBUG] Issue XXX-456 is FLAGGED
   ```

Ces logs apparaissent dans la console Xcode quand vous chargez des tickets.

## Configuration recommandée

1. **Vérifier le champ Flagged:**
   - Ouvrir Settings dans l'application
   - Aller dans Advanced
   - Vérifier que "Flagged Field ID" contient le bon ID
   - Par défaut: `customfield_10021`

2. **Vérifier les permissions du token:**
   - Votre Personal Access Token doit avoir accès en lecture aux tickets
   - Il doit pouvoir lire l'historique des tickets

## Si rien ne fonctionne

### Option 1: Simplifier la détection

On peut simplifier la détection pour ne se baser que sur les dates (sans le changelog):

- Un ticket est bloqué si `updated` date de plus de 3 jours
- Pas besoin du changelog

Voulez-vous que j'implémente cette version simplifiée?

### Option 2: Tester avec un endpoint direct

Je peux créer un script de test qui:
1. Appelle directement l'API Jira
2. Récupère un ticket avec `expand=changelog`
3. Affiche la réponse JSON complète
4. Vous permet de voir exactement ce que Jira renvoie

Cela nous aidera à comprendre pourquoi le changelog n'est pas récupéré.

## Prochaines étapes

1. Lancez l'application dans Xcode
2. Chargez un sprint
3. Copiez-collez ici les logs qui apparaissent dans la console
4. Cela m'aidera à identifier le problème exact
