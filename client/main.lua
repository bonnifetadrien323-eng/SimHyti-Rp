local ESX = exports['es_extended']:getSharedObject()

SetNuiFocus(false, false)
SetNuiFocusKeepInput(false)

local function Translate(key)
    if not Locales then
        return key
    end

    local locale = Locales[Config.Locale] or Locales['en'] or {}
    return locale[key] or key
end

local function DebugLog(message)
    if Config.Debug then
        print(('[SimHyti] %s'):format(message))
    end
end

local function OpenGuidebook(payload)
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        action = 'open',
        data = payload,
        strings = {
            title = Translate('menu_title'),
            categories = Translate('menu_categories'),
            pages = Translate('menu_entries'),
            admin = Translate('admin_panel')
        }
    })
end

local function CloseGuidebook()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterCommand(Config.Command, function()
    ESX.TriggerServerCallback('simhyti:openGuidebook', function(response)
        if not response then
            return
        end

        if not response.allowed then
            ESX.ShowNotification(Translate('need_item'))
            return
        end

        OpenGuidebook(response)
    end)
end, false)

RegisterCommand('guidebookclose', function()
    CloseGuidebook()
end, false)

RegisterNUICallback('close', function(_, cb)
    CloseGuidebook()
    cb(true)
end)

RegisterNUICallback('ready', function(_, cb)
    CloseGuidebook()
    cb(true)
end)

RegisterNUICallback('setWaypoint', function(data, cb)
    if data and data.x and data.y then
        SetNewWaypoint(data.x, data.y)
    end
    cb(true)
end)

RegisterNUICallback('refresh', function(_, cb)
    ESX.TriggerServerCallback('simhyti:getGuidebook', function(payload)
        cb(payload)
    end)
end)

RegisterNUICallback('admin:saveCategory', function(data, cb)
    ESX.TriggerServerCallback('simhyti:adminSaveCategory', function(payload)
        cb(payload)
    end, data)
end)

RegisterNUICallback('admin:savePage', function(data, cb)
    ESX.TriggerServerCallback('simhyti:adminSavePage', function(payload)
        cb(payload)
    end, data)
end)

RegisterNUICallback('admin:savePoint', function(data, cb)
    ESX.TriggerServerCallback('simhyti:adminSavePoint', function(payload)
        cb(payload)
    end, data)
end)

RegisterNUICallback('admin:deleteItem', function(data, cb)
    ESX.TriggerServerCallback('simhyti:adminDeleteItem', function(payload)
        cb(payload)
    end, data)
end)

CreateThread(function()
    DebugLog(('Command /%s ready.'):format(Config.Command))
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    CloseGuidebook()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    CreateThread(function()
        Wait(500)
        CloseGuidebook()
    end)
end)
