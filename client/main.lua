local ESX = exports['es_extended']:getSharedObject()

local function Translate(key)
    local locale = Locales[Config.Locale] or Locales['en'] or {}
    return locale[key] or key
end

local function OpenEntryMenu(category)
    local elements = {}

    for _, entry in ipairs(category.entries or {}) do
        elements[#elements + 1] = {
            label = entry.label,
            value = entry
        }
    end

    if #elements == 0 then
        elements[1] = {
            label = Translate('no_entries'),
            value = nil
        }
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'guidebook_entries', {
        title = ('%s - %s'):format(Translate('menu_entries'), category.label),
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        local entry = data.current.value

        if entry then
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'guidebook_entry', {
                title = entry.label,
                align = 'top-left',
                elements = {
                    { label = entry.content, value = nil },
                    { label = Translate('back'), value = 'back' }
                }
            }, function(entryData, entryMenu)
                if entryData.current.value == 'back' then
                    entryMenu.close()
                end
            end, function(_, entryMenu)
                entryMenu.close()
            end)
        end
    end, function(_, menu)
        menu.close()
    end)
end

local function OpenGuidebook(categories)
    local elements = {}

    for _, category in ipairs(categories) do
        elements[#elements + 1] = {
            label = category.label,
            value = category
        }
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'guidebook_categories', {
        title = Translate('menu_title'),
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        menu.close()
        OpenEntryMenu(data.current.value)
    end, function(_, menu)
        menu.close()
    end)
end

RegisterCommand(Config.Command, function()
    ESX.TriggerServerCallback('simhyti:getGuidebook', function(categories)
        OpenGuidebook(categories)
    end)
end, false)

if Config.Debug then
    CreateThread(function()
        print(('[SimHyti] Command /%s ready.'):format(Config.Command))
    end)
end
