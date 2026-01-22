local ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('simhyti:getGuidebook', function(_, cb)
    cb(Config.Guidebook)
end)
