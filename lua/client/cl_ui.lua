bMenuOpen = false 

local ESX = exports[SimpleBanking.ExtendedScriptName]:getSharedObject()
local isLoggedIn = false
local PlayerJob = {}

RegisterNetEvent('esx:playerLoaded', function()
    SendNUIMessage({type = "refresh_accounts"})
end)

RegisterNetEvent('esx:onPlayerDeath', function()
    SendNUIMessage({type = "refresh_accounts"})
end)

RegisterNetEvent('esx:setJob', function(JobInfo)
    PlayerJob = ESX.GetPlayerData().job
	PlayerJob = JobInfo
    SendNUIMessage({type = "refresh_accounts"})
end)


function ToggleUI()
    ESX.TriggerServerCallback('qb-banking:server:GetCharInfo', function(charinfo)
    
        bMenuOpen = not bMenuOpen

        if (not bMenuOpen) then
            SetNuiFocus(false, false)
        else
            ESX.TriggerServerCallback("qb-banking:server:GetBankData", function(data, transactions)
                local PlayerBanks = json.encode(data)


                SetNuiFocus(true, true)
                SendNUIMessage({type = 'OpenUI', accounts = PlayerBanks, transactions = json.encode(transactions), name = charinfo.firstname.. " ".. charinfo.lastname})
            end)
        end
    end)
end

RegisterNUICallback("CloseATM", function()
    ToggleUI()
    ClearPedTasks(PlayerPedId())
end)

RegisterNUICallback("DepositCash", function(data, cb)
    if (not data or not data.account or not data.amount) then
        return
    end

    if (tonumber(data.amount) <= 0) then
        return
    end

    TriggerServerEvent("qb-banking:server:Deposit", data.account, data.amount, (data.note ~= nil and data.note or ""))
end)

RegisterNUICallback("WithdrawCash", function(data, cb)
    if (not data or not data.account or not data.amount) then
        return
    end

    if(tonumber(data.amount) <= 0) then
        return
    end

    TriggerServerEvent("qb-banking:server:Withdraw", data.account, data.amount, (data.note ~= nil and data.note or ""))
end)

RegisterNUICallback("TransferCash", function(data, cb)
    if (not data or not data.account or not data.amount or not data.target) then
        return
    end

    if(tonumber(data.amount) <= 0) then
        return
    end

    if(tonumber(data.target) <= 0) then
        return
    end

    TriggerServerEvent("qb-banking:server:Transfer", data.target, data.account, data.amount, (data.note ~= nil and data.note or ""))
end)



--// Net Events \\--
RegisterNetEvent("qb-banking:client:Notify")
AddEventHandler("qb-banking:client:Notify", function(type, msg)
    if (bMenuOpen) then
        SendNUIMessage({type = 'notification', msg_type = type, message = msg})
    end
end)

RegisterNetEvent("qb-banking:client:UpdateTransactions")
AddEventHandler("qb-banking:client:UpdateTransactions", function(transactions)
    if (bMenuOpen) then

        SendNUIMessage({type = 'update_transactions', transactions = json.encode(transactions)})

        ESX.TriggerServerCallback("qb-banking:server:GetBankData", function(data, transactions)
            local PlayerBanks = json.encode(data)
            SendNUIMessage({type = "refresh_balances", accounts = PlayerBanks})
        end)
    end
end)
