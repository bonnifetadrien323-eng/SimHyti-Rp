# SimHyti-Rp

Petit exemple de ressource FiveM pour ESX (Legacy) afin de démarrer rapidement.

## Installation

1. Copier le dossier dans vos `resources`.
2. Ajouter `ensure SimHyti-Rp` dans votre `server.cfg`.
3. Vérifier que `es_extended` et `oxmysql` sont bien installés.

## Utilisation

* Commande en jeu : `/simhyti`
* Le joueur reçoit un item configuré dans `config.lua`.

## Configuration

Modifier `config.lua` selon vos besoins :

* `Config.Command` : nom de la commande.
* `Config.RewardItem` / `Config.RewardAmount` : item donné.
* `Config.Notification` : message envoyé au joueur.
* `Config.Debug` : logs serveur/client.
