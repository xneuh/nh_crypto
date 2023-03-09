local Ped = { }

CreateThread(function()
    while(1) do 
       Wait(2500)
       Ped = {
            ["Id"] = PlayerPedId(),
            ["Data"] = ESX.GetPlayerData()
       } 
    end
end)

RegisterCommand("koparka", function()
    TriggerServerEvent("nh_crypto:OpenCrypto")
end)
RegisterNetEvent("nh_crypto:OpenCryptoCL", function(par)
    OpenCrypto(par)
end)

RegisterNetEvent("nh_crypto:OpenBuyMenu", function()
    OpenBuyMenu()
end)

RegisterNetEvent("nh_crypto:OpenPortfel", function(par)
    OpenPortfelMenu(par)
end)

OpenCrypto = function(par)
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'crypto_menu', {
		title = "Koparka Kryptowalut",
		align = 'center',
		elements = {
            {label = "OnlyCoin #RATE [" .. par["HASHRATE"] .. "]"},
            {label = "Ulepsz Koparke", value = "upgrade"},
            {label = "Sprzedaj OnlyCoin", value = "sell"},
            {label  = "Portfel Kryptowalut", value = "portfel"}
        }
	}, function(data, menu)
        if(data.current.value ~= nil) then
            if(data.current.value == "upgrade") then
                TriggerServerEvent("nh_crypto:UpgradeCrypto")
            elseif(data.current.value == "sell") then
                TriggerServerEvent("nh_crypto:SellCrypto")
            elseif(data.current.value == "portfel") then
                TriggerServerEvent("nh_crypto:OpenPortfel")
            end
        end
        menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

OpenPortfelMenu = function(par)
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'buy_menu', {
		title = "Portfel Kryptowalut ID [" .. par["id"] .. "]",
		align = 'center',
		elements = {
            {label = "ONLY-COIN [" .. par["only_coin"] .. "]"},
            {label = "Przelej Kryptowalute", value = "pay"}
        }
	}, function(data, menu)
        if(data.current.value == "pay") then
            DialogCryptoID()
        end
        menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

DialogCryptoID = function()
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'crypto_id',
        {
            align    = 'center',
            title    = 'ID Portfela',
            elements = {}
        },
        function(data1, menu1)
            DialogCryptoCount(data1.value)
            menu1.close()
        end,
        function(data1, menu1)
            menu.close()
        end
    )
end

DialogCryptoCount = function(cryptoID)
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'crypto_count',
        {
            align    = 'center',
            title    = 'Ilość ONLY-COIN',
            elements = {}
        },
        function(data1, menu1)
            TriggerServerEvent("nh_crypto:Przelew", cryptoID, data1.value)
            menu1.close()
        end,
        function(data1, menu1)
            menu.close()
        end
    )
end



OpenBuyMenu = function()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'buy_menu', {
		title = "Zakup Koparke Kryptowalut [$" .. Settings.BuyPrice .. "]",
		align = 'center',
		elements = {
            {label = "Tak", value = "yes"},
            {label = "Nie", value = "no"}
        }
	}, function(data, menu)
        if(data.current.value == "yes") then 
            TriggerServerEvent("nh_crypto:BuyCrypto")
        end
        menu.close()
	end, function(data, menu)
		menu.close()
	end)
end