RegisterServerEvent("nh_crypto:OpenCrypto", function()
    local src = source 
    local data = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll("SELECT hascrypto FROM users WHERE identifier = @identifier", {
        ["@identifier"] = data.identifier
    }, function(res)
        if(res[1].hascrypto == 1) then 
            MySQL.Async.fetchAll("SELECT only_coin, hashrate FROM users WHERE identifier = @identifier", {
                ["@identifier"] = data.identifier
            }, function(res)
                local par = {
                    ["ONLYCOIN"] = res[1].only_coin,
                    ["HASHRATE"] = res[1].hashrate
                }
                TriggerClientEvent("nh_crypto:OpenCryptoCL", src, par)
            end)
        else
            TriggerClientEvent("nh_crypto:OpenBuyMenu", src)
        end
    end)
end)

RegisterServerEvent("nh_crypto:BuyCrypto", function()
    local src = source
    local data = ESX.GetPlayerFromId(src)

    if(data.getMoney() >= Settings.BuyPrice) then 
        MySQL.Async.execute("UPDATE users SET hascrypto = 1 WHERE identifier = @identifier", {
            ["@identifier"] = data.identifier
        }, function()
            data.removeMoney(Settings.BuyPrice)
            data.showNotification("~b~Pomyslnie Zakupiono Koparke Kryptowalut")
        end)
    else
        data.showNotification("~b~Nie Posiadasz Wystarczajacej ilości Gotówki ~r~[$" .. Settings.BuyPrice .. "$]")
    end
end)

RegisterServerEvent("nh_crypto:SellCrypto", function()
    local src = source 
    local data = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll("SELECT only_coin FROM users WHERE identifier = @identifier", {
        ["@identifier"] = data.identifier
    }, function(res)
        if(tonumber(res[1].only_coin) >= 0) then
            MySQL.Async.execute("UPDATE users SET only_coin = 0 WHERE identifier = @identifier", {
                ["@identifier"] = data.identifier
            }, function()
                data.showNotification("~b~Pomyślnie Sprzedano ~r~[" .. res[1].only_coin .. " ONLY-COIN]~b~ za cene ~r~[" .. Settings.CryptoPrice .. " / 1 ONLY-COIN]")
                data.addMoney(Settings.CryptoPrice * res[1].only_coin)
            end)
        else
            data.showNotification("~b~Nie posiadasz Wystarczającej Ilości ONLY-COIN")
        end
    end)
end)

RegisterServerEvent("nh_crypto:UpgradeCrypto", function()
    local src = source 
    local data = ESX.GetPlayerFromId(src)

    if(data.getInventoryItem("kartagraficzna").count >= 1) then 
        MySQL.Async.execute("UPDATE users SET hashrate = hashrate + 1 WHERE identifier = @identifier", {
            ["@identifier"] = data.identifier
        }, function()
            data.removeInventoryItem("kartagraficzna", 1)
            data.showNotification("~b~Pomyślnie Ulepszono Koparke Kryptowalut")
        end)
    else
        data.showNotification("~b~Nie posiadasz ~r~[1x Karta Graficzna]")
    end
end)

RegisterServerEvent("nh_crypto:Przelew", function(cryptoID, cryptoCount)
    local src = source 
    local data = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll("SELECT only_coin FROM users WHERE identifier = @identifier", {
        ["@identifier"] = data.identifier
    }, function(res)
        if(res[1].only_coin >= cryptoCount) then
            MySQL.Async.execute("UPDATE users SET only_coin = only_coin + @cryptoCount WHERE cryptoID = @cryptoID", {
                ["@cryptoID"] = cryptoID,
                ["@cryptoCount"] = cryptoCount    
            }, function()
                MySQL.Async.execute("UPDATE users SET only_coin = only_coin - @cryptoCount WHERE identifier = @identifier", {
                    ["@identifier"] = data.identifier,
                    ["@cryptoCount"] = cryptoCount
                }, function()
                    data.showNotification("~b~Pomyślnie Przelano ~r~[" .. cryptoCount .. " ONLY-COIN]~b~ Na Portfel ~r~[" .. cryptoID .. "]")
                end)
            end)
        else
            data.showNotification("~b~Nie posiadasz Wystarczającej Ilości ONLY-COIN'a ~r~[" .. res[1].only_coin .. "/" .. cryptoCount .. "]")
        end
    end)
end)

RegisterServerEvent("nh_crypto:OpenPortfel", function()
    local src = source 
    local data = ESX.GetPlayerFromId(src)
    MySQL.Async.fetchAll("SELECT cryptoID FROM users WHERE identifier = @identifier", {
        ["@identifier"] = data.identifier
    }, function(res)
        if(res[1].cryptoID == "Brak") then
            local newCryptoID = math.random(10000,900000) 
            MySQL.Async.execute("UPDATE users SET cryptoID = @cryptoID WHERE identifier = @identifier", {
                ["@identifier"] = data.identifier,
                ["@cryptoID"] = newCryptoID
            }, function()
                data.showNotification("~b~Pomyślnie Utworzono Portfel o ID ~r~[" .. newCryptoID .. "]")
            end)
        else
            MySQL.Async.fetchAll("SELECT cryptoID, only_coin FROM users WHERE identifier = @identifier", {
                ["@identifier"] = data.identifier
            }, function(res)
                par = {
                    ["id"] = res[1].cryptoID,
                    ["only_coin"] = res[1].only_coin
                }
                TriggerClientEvent("nh_crypto:OpenPortfel", src, par)
            end)
        end
    end)
end)

CreateThread(function()
    while(1) do 
       Wait(60000)
       MySQL.Async.execute("UPDATE users SET only_coin = only_coin + @hashrate * hashrate WHERE hascrypto = 1", {
            ["@hashrate"] = Settings.HashRate 
       }) 
    end
end)