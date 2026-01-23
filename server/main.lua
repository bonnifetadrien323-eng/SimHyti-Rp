local ESX = exports['es_extended']:getSharedObject()

local function isAdmin(source)
    return IsPlayerAceAllowed(source, Config.AdminAce)
end

local function fetchGuidebook(cb)
    local categories = MySQL.query.await(
        ('SELECT id, label, sort_order FROM %s ORDER BY sort_order ASC, id ASC'):format(Config.Database.categoryTable)
    )

    local pages = MySQL.query.await(
        ('SELECT id, category_id, title, content, page_type, sort_order, enabled FROM %s ORDER BY sort_order ASC, id ASC')
            :format(Config.Database.pageTable)
    )

    local points = MySQL.query.await(
        ('SELECT id, page_id, label, x, y, z FROM %s ORDER BY id ASC'):format(Config.Database.pointTable)
    )

    cb({
        categories = categories or {},
        pages = pages or {},
        points = points or {}
    })
end

local function ensureSchema()
    local categorySql = [[
        CREATE TABLE IF NOT EXISTS %s (
            id INT AUTO_INCREMENT PRIMARY KEY,
            label VARCHAR(120) NOT NULL,
            sort_order INT NOT NULL DEFAULT 0
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]]

    local pageSql = [[
        CREATE TABLE IF NOT EXISTS %s (
            id INT AUTO_INCREMENT PRIMARY KEY,
            category_id INT NOT NULL,
            title VARCHAR(160) NOT NULL,
            content LONGTEXT,
            page_type VARCHAR(40) NOT NULL DEFAULT 'text',
            sort_order INT NOT NULL DEFAULT 0,
            enabled TINYINT(1) NOT NULL DEFAULT 1,
            FOREIGN KEY (category_id) REFERENCES %s(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]]

    local pointSql = [[
        CREATE TABLE IF NOT EXISTS %s (
            id INT AUTO_INCREMENT PRIMARY KEY,
            page_id INT NOT NULL,
            label VARCHAR(160) NOT NULL,
            x DOUBLE NOT NULL,
            y DOUBLE NOT NULL,
            z DOUBLE NOT NULL,
            FOREIGN KEY (page_id) REFERENCES %s(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]]

    MySQL.query.await(categorySql:format(Config.Database.categoryTable))
    MySQL.query.await(pageSql:format(Config.Database.pageTable, Config.Database.categoryTable))
    MySQL.query.await(pointSql:format(Config.Database.pointTable, Config.Database.pageTable))

    local existing = MySQL.scalar.await(
        ('SELECT COUNT(1) FROM %s'):format(Config.Database.categoryTable)
    )

    if existing == 0 then
        local categoryId = MySQL.insert.await(
            ('INSERT INTO %s (label, sort_order) VALUES (?, ?)'):format(Config.Database.categoryTable),
            { 'Bienvenue', 1 }
        )

        MySQL.insert.await(
            ('INSERT INTO %s (category_id, title, content, page_type, sort_order, enabled) VALUES (?, ?, ?, ?, ?, ?)')
                :format(Config.Database.pageTable),
            {
                categoryId,
                'Notre ville',
                'Bienvenue sur SimHyti-Rp. Respectez les autres joueurs et amusez-vous !',
                'text',
                1,
                1
            }
        )

        MySQL.insert.await(
            ('INSERT INTO %s (category_id, title, content, page_type, sort_order, enabled) VALUES (?, ?, ?, ?, ?, ?)')
                :format(Config.Database.pageTable),
            {
                categoryId,
                'Commandes utiles',
                json.encode({
                    { label = '/guidebook', key = 'F1', description = 'Ouvrir la tablette guide' },
                    { label = '/report', key = 'F2', description = 'Contacter le staff' },
                    { label = 'Inventaire', key = 'TAB', description = 'Ouvrir l\'inventaire' }
                }),
                'shortcuts',
                2,
                1
            }
        )
    end
end

local function hasRequiredItem(source)
    if not Config.RequireItemToOpen then
        return true
    end

    local count = exports.ox_inventory:Search(source, 'count', Config.RequiredItem)
    return count and count > 0
end

MySQL.ready(function()
    ensureSchema()
end)

ESX.RegisterServerCallback('simhyti:openGuidebook', function(source, cb)
    local allowed = hasRequiredItem(source)

    fetchGuidebook(function(payload)
        cb({
            allowed = allowed,
            isAdmin = isAdmin(source),
            logoUrl = Config.LogoUrl,
            categories = payload.categories,
            pages = payload.pages,
            points = payload.points
        })
    end)
end)

ESX.RegisterServerCallback('simhyti:getGuidebook', function(source, cb)
    fetchGuidebook(function(payload)
        payload.isAdmin = isAdmin(source)
        payload.logoUrl = Config.LogoUrl
        cb(payload)
    end)
end)

ESX.RegisterServerCallback('simhyti:adminSaveCategory', function(source, cb, data)
    if not isAdmin(source) then
        cb({ success = false, message = 'unauthorized' })
        return
    end

    if data.id then
        MySQL.update.await(
            ('UPDATE %s SET label = ?, sort_order = ? WHERE id = ?'):format(Config.Database.categoryTable),
            { data.label, data.sort_order or 0, data.id }
        )
        cb({ success = true, id = data.id })
        return
    end

    local id = MySQL.insert.await(
        ('INSERT INTO %s (label, sort_order) VALUES (?, ?)'):format(Config.Database.categoryTable),
        { data.label, data.sort_order or 0 }
    )
    cb({ success = true, id = id })
end)

ESX.RegisterServerCallback('simhyti:adminSavePage', function(source, cb, data)
    if not isAdmin(source) then
        cb({ success = false, message = 'unauthorized' })
        return
    end

    local content = data.content
    if data.page_type == 'shortcuts' and type(data.content) == 'table' then
        content = json.encode(data.content)
    end

    if data.id then
        MySQL.update.await(
            ('UPDATE %s SET title = ?, content = ?, page_type = ?, sort_order = ?, enabled = ?, category_id = ? WHERE id = ?')
                :format(Config.Database.pageTable),
            {
                data.title,
                content,
                data.page_type or 'text',
                data.sort_order or 0,
                data.enabled and 1 or 0,
                data.category_id,
                data.id
            }
        )
        cb({ success = true, id = data.id })
        return
    end

    local id = MySQL.insert.await(
        ('INSERT INTO %s (category_id, title, content, page_type, sort_order, enabled) VALUES (?, ?, ?, ?, ?, ?)')
            :format(Config.Database.pageTable),
        {
            data.category_id,
            data.title,
            content,
            data.page_type or 'text',
            data.sort_order or 0,
            data.enabled and 1 or 0
        }
    )

    cb({ success = true, id = id })
end)

ESX.RegisterServerCallback('simhyti:adminSavePoint', function(source, cb, data)
    if not isAdmin(source) then
        cb({ success = false, message = 'unauthorized' })
        return
    end

    if data.id then
        MySQL.update.await(
            ('UPDATE %s SET label = ?, x = ?, y = ?, z = ? WHERE id = ?'):format(Config.Database.pointTable),
            { data.label, data.x, data.y, data.z, data.id }
        )
        cb({ success = true, id = data.id })
        return
    end

    local id = MySQL.insert.await(
        ('INSERT INTO %s (page_id, label, x, y, z) VALUES (?, ?, ?, ?, ?)'):format(Config.Database.pointTable),
        { data.page_id, data.label, data.x, data.y, data.z }
    )

    cb({ success = true, id = id })
end)

ESX.RegisterServerCallback('simhyti:adminDeleteItem', function(source, cb, data)
    if not isAdmin(source) then
        cb({ success = false, message = 'unauthorized' })
        return
    end

    if data.type == 'category' then
        MySQL.update.await(
            ('DELETE FROM %s WHERE id = ?'):format(Config.Database.categoryTable),
            { data.id }
        )
        cb({ success = true })
        return
    end

    if data.type == 'page' then
        MySQL.update.await(
            ('DELETE FROM %s WHERE id = ?'):format(Config.Database.pageTable),
            { data.id }
        )
        cb({ success = true })
        return
    end

    if data.type == 'point' then
        MySQL.update.await(
            ('DELETE FROM %s WHERE id = ?'):format(Config.Database.pointTable),
            { data.id }
        )
        cb({ success = true })
        return
    end

    cb({ success = false, message = 'invalid_type' })
end)
