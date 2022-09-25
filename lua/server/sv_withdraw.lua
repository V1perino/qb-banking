local ESX = exports[SimpleBanking.ExtendedScriptName]:getSharedObject()
RegisterServerEvent('qb-banking:server:Withdraw')
AddEventHandler('qb-banking:server:Withdraw', function(account, amount, note, fSteamID)
    local src = source
    if not src then return end
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer or xPlayer == -1 then
        return
    end

    if not amount or tonumber(amount) <= 0 then
        TriggerClientEvent("qb-banking:client:Notify", src, "error", "Špatný počet!") 
        return
    end

    amount = tonumber(amount)

    if account == "personal" then
        if amount > xPlayer.getAccount('bank').money then
            TriggerClientEvent("qb-banking:client:Notify", src, "error", "Tvá banka nemá tolik peněz!") 
            return
        end
        local withdraw = math.floor(amount)

        xPlayer.addMoney(withdraw)
        xPlayer.removeAccountMoney('bank', withdraw)

        AddTransaction(src, "personal", -amount, "withdraw", "N/A", (note ~= "" and note or "Vybráno $"..format_int(amount).."."))
        RefreshTransactions(src)
    end

    if(account == "business") then
        local job = xPlayer.job

        if not SimpleBanking.Config["business_ranks"][string.lower(job.grade_name)] and not SimpleBanking.Config["business_ranks_overrides"][string.lower(job.name)] then
            return
        end

        local low = string.lower(job.name)
        local grade = string.lower(job.grade_name)

        if (SimpleBanking.Config["business_ranks_overrides"][low] and not SimpleBanking.Config["business_ranks_overrides"][low][grade]) then

            return
        end

        local result = MySQL.Sync.fetchAll('SELECT * FROM addon_account_data WHERE account_name= @account_name', {
            ['@account_name'] = 'society_'..job.name
        })
        local data = result[1]

        if data then
            local sM = tonumber(data.money)
            if sM >= amount then
                TriggerEvent('qb-banking:society:server:WithdrawMoney',src, amount, data.name)

                AddTransaction(src, "business", -amount, "deposit", job.label, (note ~= "" and note or "Vloženo $"..format_int(amount).." od ".. job.label .." účtu"))
                xPlayer.addMoney(amount)
            else
                TriggerClientEvent("qb-banking:client:Notify", src, "error", "Nemáš tolik peněz, máš jen: $"..sM) 
            end
        end
    end
end)