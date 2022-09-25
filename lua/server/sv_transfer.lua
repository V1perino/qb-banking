local ESX = exports[SimpleBanking.ExtendedScriptName]:getSharedObject()
RegisterServerEvent('qb-banking:server:Transfer')
AddEventHandler('qb-banking:server:Transfer', function(target, account, amount, note, fSteamID)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    target = target ~= nil and tonumber(target) or nil
    if not target or target <= 0 or target == src then
        return
    end

    target = tonumber(target)
    amount = tonumber(amount)
    local targetPly = ESX.GetPlayerFromId(target)

    if not targetPly or targetPly == -1 then
        return
    end

    if (target == src) then
        return
    end

    if (not amount or amount <= 0) then
        return
    end
    local targetCharInfo = getIdentity(target)
    local PlayerCharInfo = getIdentity(src)
    if (account == "personal") then
        local balance = xPlayer.getAccount('bank').money

        if amount > balance then
            return
        end

        xPlayer.removeAccountMoney('bank', amount)
        targetPly.addAccountMoney('bank', math.floor(amount))

        AddTransaction(src, "personal", -amount, "transfer", targetCharInfo.firstname, "Převedeno $" .. format_int(amount) .. " na " .. targetCharInfo.firstname" účet")
        AddTransaction(targetPly..source, "personal", amount, "transfer", PlayerCharInfo.firstname, "Přijato $" .. format_int(amount) .. " od " ..PlayerCharInfo.firstname)
    end

    if (account == "business") then
        local job = xPlayer.job

        if (not SimpleBanking.Config["business_ranks"][string.lower(job.grade_name)] and not SimpleBanking.Config["business_ranks_overrides"][string.lower(job.name)]) then
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
            local society = data.account_name

            TriggerEvent('qb-banking:society:server:WithdrawMoney', src, amount, society)
            Wait(50)
            targetPly.addMoney(amount)
            AddTransaction(src, "personal", -amount, "transfer", targetCharInfo.firstname, "Převedeno $" .. format_int(amount) .. " na " .. targetCharInfo.firstname .. " od " .. job.label .. " účtu")
        end
    end
end)

function getIdentity(target)
    local identifier = GetPlayerIdentifiers(target)[1]

	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
	if result[1] ~= nil then
		local identity = result[1]

		return {
			firstname = identity['firstname'],
			lastname = identity['lastname'],
		}
	else
		return nil
  end
end