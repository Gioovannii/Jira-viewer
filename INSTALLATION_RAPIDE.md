# 📦 Installation en 3 étapes

## Pour les PO, EM, et utilisateurs non-techniques

### Étape 1: Télécharger 📥

1. Cliquez sur ce lien: **[Télécharger Jira Viewer](https://github.com/Gioovannii/Jira-viewer/releases/latest)**
2. Téléchargez le fichier **`JiraViewer-v1.0.0.dmg`**
3. Attendez que le téléchargement se termine

### Étape 2: Installer 💻

1. **Double-cliquez** sur le fichier `.dmg` téléchargé
2. Une fenêtre s'ouvre avec l'icône JiraViewer
3. **Glissez** l'icône dans le dossier **Applications**
4. Attendez la copie (quelques secondes)
5. **Éjectez** le disque JiraViewer (clic droit > Éjecter)

### Étape 3: Configurer ⚙️

1. Ouvrez **JiraViewer** depuis Applications
2. Si un message de sécurité apparaît:
   - Allez dans **Préférences Système** > **Confidentialité et sécurité**
   - Cliquez sur **"Ouvrir quand même"**

3. Une fois l'app ouverte, allez dans **Settings** (menu ou `Cmd+,`)

4. Remplissez les 4 champs:

   ```
   URL Jira:          https://jira.ets.mpi-internal.com
   Nom d'utilisateur: [votre username Jira]
   Mot de passe:      [votre mot de passe Jira]
   Clé du projet:     LBCMONSPE
   ```

   **⚠️ Problème de connexion?** Voir le guide détaillé: [CONFIGURATION_JIRA.md](CONFIGURATION_JIRA.md)

5. **Optionnel** - Pour les résumés IA:
   - Créez un compte sur https://console.anthropic.com
   - Créez une clé API
   - Collez-la dans **Clé API Claude**

6. **Fermez** les Settings et profitez! 🎉

   **Important:** L'app se connecte automatiquement quand vous fermez les Settings. Attendez quelques secondes que les sprints apparaissent.

---

## 🆘 Besoin d'aide?

- **Guide complet**: [GUIDE_UTILISATEUR.md](GUIDE_UTILISATEUR.md)
- **Questions**: Ouvrez une issue sur GitHub
- **Bug**: Signalez-le à votre équipe technique

---

## ✨ Utilisation rapide

### Voir vos sprints
- Colonne de gauche = Liste des sprints
- 🟢 Vert = Sprint actif
- 🔵 Bleu = Sprint futur
- ⚫ Gris = Sprint terminé

### Voir les tickets
- Cliquez sur un sprint
- Les tickets s'affichent au milieu
- 🔴 Rouge = Haute priorité
- 🟠 Orange = Moyenne priorité
- 🔵 Bleu = Basse priorité

### Voir les détails
- Cliquez sur un ticket
- Les détails s'affichent à droite
- **Bouton "Générer"** = Créer un résumé IA
- **Bouton "Ouvrir dans Jira"** = Voir dans le navigateur

---

**C'est tout!** Vous êtes prêt à utiliser Jira Viewer 🚀
