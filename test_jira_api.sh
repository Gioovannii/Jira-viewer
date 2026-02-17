#!/bin/bash

# Script de test pour vérifier ce que l'API Jira retourne
# Usage: ./test_jira_api.sh

echo "🔍 Test de l'API Jira - Blocked Issues Debug"
echo "==========================================="
echo ""

# Configuration (à remplir)
JIRA_BASE_URL="https://jira.ets.mpi-internal.com"
PROJECT_KEY="LBCMONSPE"
# Remplacez par votre token:
JIRA_TOKEN=""

if [ -z "$JIRA_TOKEN" ]; then
    echo "❌ Erreur: Veuillez définir votre JIRA_TOKEN dans ce script"
    echo "Ouvrez le fichier et remplacez JIRA_TOKEN=\"\" par votre token"
    exit 1
fi

echo "📊 Configuration:"
echo "  - URL: $JIRA_BASE_URL"
echo "  - Projet: $PROJECT_KEY"
echo ""

# Test 1: Récupérer un ticket avec changelog
echo "Test 1: Récupération d'un ticket avec changelog"
echo "----------------------------------------------"
JQL="project=$PROJECT_KEY ORDER BY updated DESC"
API_ENDPOINT="$JIRA_BASE_URL/rest/api/2/search"

echo "📡 Appel API: $API_ENDPOINT"
echo "📝 JQL: $JQL"
echo ""

RESPONSE=$(curl -s -X GET \
  "$API_ENDPOINT?jql=$JQL&maxResults=1&expand=changelog&fields=summary,status,updated,customfield_10020,customfield_10021" \
  -H "Authorization: Bearer $JIRA_TOKEN" \
  -H "Content-Type: application/json")

# Vérifier si la requête a réussi
if echo "$RESPONSE" | grep -q "errorMessages"; then
    echo "❌ Erreur API:"
    echo "$RESPONSE" | jq '.'
    exit 1
fi

echo "✅ Réponse reçue!"
echo ""

# Extraire les informations importantes
TOTAL=$(echo "$RESPONSE" | jq -r '.total')
echo "📊 Nombre total de tickets: $TOTAL"
echo ""

if [ "$TOTAL" -gt 0 ]; then
    ISSUE_KEY=$(echo "$RESPONSE" | jq -r '.issues[0].key')
    ISSUE_SUMMARY=$(echo "$RESPONSE" | jq -r '.issues[0].fields.summary')
    HAS_CHANGELOG=$(echo "$RESPONSE" | jq -r '.issues[0].changelog != null')
    CHANGELOG_HISTORIES=$(echo "$RESPONSE" | jq -r '.issues[0].changelog.histories | length')
    HAS_FLAGGED=$(echo "$RESPONSE" | jq -r '.issues[0].fields.customfield_10021 != null')

    echo "📋 Premier ticket:"
    echo "  - Clé: $ISSUE_KEY"
    echo "  - Résumé: $ISSUE_SUMMARY"
    echo "  - A un changelog: $HAS_CHANGELOG"
    if [ "$HAS_CHANGELOG" = "true" ]; then
        echo "  - Nombre d'historiques: $CHANGELOG_HISTORIES"
    fi
    echo "  - A un champ flagged (customfield_10021): $HAS_FLAGGED"
    echo ""

    # Afficher le changelog complet si présent
    if [ "$HAS_CHANGELOG" = "true" ] && [ "$CHANGELOG_HISTORIES" -gt 0 ]; then
        echo "📜 Historique du changelog (premiers éléments):"
        echo "$RESPONSE" | jq -r '.issues[0].changelog.histories[0:3][] | "  - \(.created): \(.items[0].field) changed from \(.items[0].fromString // "null") to \(.items[0].toString // "null")"'
        echo ""
    fi

    # Afficher le champ flagged si présent
    if [ "$HAS_FLAGGED" = "true" ]; then
        echo "🚩 Valeur du champ flagged:"
        echo "$RESPONSE" | jq -r '.issues[0].fields.customfield_10021'
        echo ""
    fi

    # Sauvegarder la réponse complète
    echo "$RESPONSE" | jq '.' > jira_response_debug.json
    echo "💾 Réponse complète sauvegardée dans: jira_response_debug.json"
    echo ""
fi

# Test 2: Lister tous les custom fields disponibles
echo ""
echo "Test 2: Liste des custom fields disponibles"
echo "-------------------------------------------"
echo "📡 Récupération des métadonnées de champs..."

FIELDS_RESPONSE=$(curl -s -X GET \
  "$JIRA_BASE_URL/rest/api/2/field" \
  -H "Authorization: Bearer $JIRA_TOKEN" \
  -H "Content-Type: application/json")

echo "🔍 Custom fields qui contiennent 'flag' ou 'impediment':"
echo "$FIELDS_RESPONSE" | jq -r '.[] | select(.custom == true and (.name | test("flag|impediment|block"; "i"))) | "  - \(.id): \(.name)"'
echo ""

echo "💾 Liste complète des champs sauvegardée dans: jira_fields_debug.json"
echo "$FIELDS_RESPONSE" | jq '.' > jira_fields_debug.json

echo ""
echo "✅ Tests terminés!"
echo ""
echo "📋 Résumé:"
echo "  1. Si 'A un changelog: true' -> Le changelog est bien récupéré ✅"
echo "  2. Si 'A un changelog: false' -> Le changelog n'est PAS récupéré ❌"
echo "  3. Si 'A un champ flagged: true' -> Le champ existe ✅"
echo "  4. Si 'A un champ flagged: false' -> Le champ customfield_10021 n'existe pas ❌"
echo ""
echo "📁 Fichiers générés:"
echo "  - jira_response_debug.json (réponse complète)"
echo "  - jira_fields_debug.json (liste de tous les champs)"
echo ""
echo "💡 Prochaines étapes:"
echo "  - Si changelog = false: Vérifier les permissions du token"
echo "  - Si flagged = false: Regarder jira_fields_debug.json pour trouver le bon ID"
