local ESX = exports[SimpleBanking.ExtendedScriptName]:getSharedObject()
RegisterServerEvent('qb-banking:server:Deposit')
AddEventHandler('qb-banking:server:Deposit', function(account, amount, note, fSteamID)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer or xPlayer == -1 then
        return
    end

    if not amount or tonumber(amount) <= 0 then
        TriggerClientEvent("qb-banking:client:Notify", src, "error", "Špatný počet!") 
        return
    end

    local amount = tonumber(amount)
    if amount > xPlayer.getMoney() then
        TriggerClientEvent("qb-banking:client:Notify", src, "error", "Toto si nemůžeš dovolit!") 
        return
    end

    if account == "personal"  then
        local amt = math.floor(amount)

        xPlayer.removeMoney(amt)
        Wait(500)
        xPlayer.addAccountMoney('bank', amt)
        RefreshTransactions(src)
        AddTransaction(src, "personal", amount, "deposit", "N/A", (note ~= "" and note or "Vloženo $"..format_int(amount).." peněz."))
        return
    end

    if account == "business"  then
        local job = xPlayer.job
        local job_grade = job.grade_name

        if (not SimpleBanking.Config["business_ranks"][string.lower(job_grade)] and not SimpleBanking.Config["business_ranks_overrides"][string.lower(job.name)]) then
            return
        end

        local low = string.lower(job.name)
        local grade = string.lower(job_grade)

        if (SimpleBanking.Config["business_ranks_overrides"][low] and not SimpleBanking.Config["business_ranks_overrides"][low][grade]) then
            return
        end


    local result = MySQL.Sync.fetchAll('SELECT * FROM addon_account_data WHERE account_name= @account_name', {
        ['@account_name'] = 'society_'..job.name
    })
    local data = result[1]

    if data then
        local deposit = math.floor(amount)
        xPlayer.removeMoney(deposit)
        TriggerEvent('qb-banking:society:server:DepositMoney', src, deposit, data.name)
        AddTransaction(src, "business", amount, "deposit", job.label, (note ~= "" and note or "Vloženo $"..format_int(amount).." peněz do ".. job.label .."'firemního účtu."))        end
    end
end)
