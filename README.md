# SimHyti-Rp Guidebook

Ressource FiveM ESX qui ajoute un guide en jeu avec interface NUI moderne, points GPS cliquables et panneau admin pour éditer le contenu.

## Installation

1. Copier le dossier dans vos `resources`.
2. Ajouter `ensure SimHyti-Rp` dans votre `server.cfg`.
3. Installer les dépendances :
   - `es_extended`
   - `oxmysql`
   - `ox_inventory`
4. Importer le SQL (ou laisser la ressource créer les tables automatiquement) :
   - `sql/guidebook.sql`

## Utilisation

* Commande en jeu : `/guidebook`
* Le guide s’ouvre uniquement si le joueur possède l’item configuré.
* Les points GPS sont cliquables pour créer un waypoint.

## Configuration

Modifier `config.lua` selon vos besoins :

* `Config.Command` : commande d’ouverture.
* `Config.RequireItemToOpen` / `Config.RequiredItem` : item obligatoire via ox_inventory.
* `Config.AdminAce` : permission ACE pour ouvrir le panneau admin.
* `Config.LogoUrl` : logo du serveur affiché dans l’UI.

## Permissions

Ajoutez l’ACE dans votre `server.cfg` :

```
add_ace group.admin guidebook.admin allow
```

## Panel admin

Utilisez le bouton **Admin** dans le guidebook (si vous avez la permission) pour créer/modifier :

* Catégories
* Pages (texte ou raccourcis)
* Points GPS
