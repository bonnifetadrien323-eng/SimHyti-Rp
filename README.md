# SimHyti-Rp

Ressource FiveM ESX qui ajoute un guide en jeu (type guidebook) pour votre serveur SimHyti-Rp.

## Installation

1. Copier le dossier dans vos `resources`.
2. Ajouter `ensure SimHyti-Rp` dans votre `server.cfg`.
3. Vérifier que `es_extended` est bien installé.

## Utilisation

* Commande en jeu : `/guidebook`
* Le menu affiche des catégories puis des articles.

## Configuration

Modifier `config.lua` pour adapter le contenu du guide :

* `Config.Command` : nom de la commande.
* `Config.Locale` : langue (`fr` ou `en`).
* `Config.Guidebook` : catégories et articles affichés.
* `Config.Debug` : logs client.
