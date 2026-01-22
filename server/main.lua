local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('simhyti:requestReward', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return
    end

    xPlayer.addInventoryItem(Config.RewardItem, Config.RewardAmount)
    TriggerClientEvent('simhyti:notify', source, Config.Notification)

    if Config.Debug then
        print(('[SimHyti] Gave %sx %s to %s'):format(Config.RewardAmount, Config.RewardItem, xPlayer.getName()))
    end
end)
