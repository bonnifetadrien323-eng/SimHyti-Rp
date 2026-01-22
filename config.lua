Config = {}

Config.Locale = 'fr'
Config.Command = 'guidebook'
Config.Debug = true

Config.Guidebook = {
    {
        id = 'rules',
        label = 'Règlement',
        entries = {
            {
                id = 'respect',
                label = 'Respect',
                content = 'Restez respectueux envers tous les joueurs et le staff.'
            },
            {
                id = 'metagaming',
                label = 'Metagaming',
                content = 'Le metagaming est interdit. Utilisez uniquement les informations en jeu.'
            }
        }
    },
    {
        id = 'jobs',
        label = 'Métiers',
        entries = {
            {
                id = 'police',
                label = 'LSPD',
                content = 'Rejoignez la police via un dossier RP sur le Discord.'
            },
            {
                id = 'ems',
                label = 'EMS',
                content = 'Les EMS doivent suivre les procédures médicales et rester neutres.'
            }
        }
    }
}
