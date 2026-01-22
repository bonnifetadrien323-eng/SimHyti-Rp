local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('simhyti:notify', function(message)
    ESX.ShowNotification(message)
end)

RegisterCommand(Config.Command, function()
    TriggerServerEvent('simhyti:requestReward')
end, false)

if Config.Debug then
    CreateThread(function()
        print(('[SimHyti] Command /%s ready.'):format(Config.Command))
    end)
end
