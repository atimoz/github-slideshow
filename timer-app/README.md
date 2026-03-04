# Work Timer 🏃‍♂️

Une application moderne de chronomètre pour mesurer ton temps de travail avec un leaderboard hebdomadaire et mensuel.

## Fonctionnalités ✨

### Chronomètre
- ⏱️ Démarrage, pause et réinitialisation fluides
- ⚡ Affichage en temps réel (heures:minutes:secondes)
- 💾 Sauvegarde les sessions dans le stockage local

### Leaderboard
- 📅 **Cette semaine** - Top 7 derniers jours
- 📆 **Ce mois** - Top 30 derniers jours
- 🥇🥈🥉 Badges colorés pour les 3 premiers
- 📊 Affiche le temps exact de chaque session

### Statistiques
- 📈 Total du temps travaillé cette semaine
- 📈 Total du temps travaillé ce mois
- 🎯 Nombre total de sessions enregistrées

## Design 🎨

- **Style Apple** : minimaliste, épuré et moderne
- **Dégradés** : couleurs doces et harmonieuses
- **Animations** : transitions fluides et élégantes
- **Responsive** : adapté à tous les appareils (mobile, tablette, desktop)
- **Sombre en dégradé** : fond avec gradient subtil
- **Typography** : Utilise la pile système d'Apple

## Comment utiliser 📱

1. **Ouvrir l'application** : Ouvre `index.html` dans un navigateur
2. **Entrer ton nom** : La première fois, l'app demande ton nom
3. **Démarrer le chronomètre** : Clique sur "▶ Démarrer"
4. **Mettre en pause** : Clique sur "⏸ Pause"
5. **Enregistrer la session** : Clique sur "✓ Enregistrer la session" (minimum 1 minute)
6. **Consulter le leaderboard** : Bascule entre "Cette semaine" et "Ce mois"

## Stockage des données 💾

Toutes les données sont sauvegardées dans le **localStorage** de ton navigateur:
- Sessions de travail
- Ton nom
- Aucun serveur - 100% local et privé

## Supprimer une session 🗑️

Fais un **clic droit** sur une session du leaderboard pour la supprimer.

## Gestion du nom 🆔

Pour changer ton nom, ouvre la console et exécute:
```javascript
localStorage.setItem('timerUserName', 'Ton nouveau nom');
location.reload();
```

## Caractéristiques techniquement

- **Vanille JavaScript** - Pas de dépendances externes
- **CSS moderne** - Variables CSS, Grid, Flexbox, Gradients
- **Accessibilité** - Support des préférences système (prefers-reduced-motion)
- **Performance** - Application légère et rapide
- **Offline-first** - Fonctionne sans connexion internet

## Structure

```
timer-app/
├── index.html       # Structure HTML
├── styles.css       # Styles modernes & responsifs
├── script.js        # Logique JavaScript
└── README.md        # Cette documentation
```

## Conseils d'utilisation 💡

- ⏰ Enregistre tes sessions régulièrement pour suivre ta productivité
- 📊 Consulte le leaderboard pour voir ta progression
- 🎯 Définis-toi des objectifs de temps hebdomadaires
- 📱 Utilise l'app sur tous tes appareils (données synchronisées localement)

---

**Créé avec ❤️ pour optimiser ta productivité**
