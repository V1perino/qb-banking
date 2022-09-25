local ESX = exports[SimpleBanking.ExtendedScriptName]:getSharedObject()

ESX.RegisterServerCallback("qb-banking:server:GetBankData", function(source, cb)
    local src = source
    if not src then return end

    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local PlayerMoney = xPlayer.getAccount('bank').money or 0 
    local Identifier = xPlayer.identifier

    local TransactionHistory = {}
    local TransactionRan = false
    local tbl = {}
    tbl[1] = {
        type = "personal",
        amount = PlayerMoney
    }

    local job = xPlayer.job
    
    if (job.name and job.grade_name) then
        if(SimpleBanking.Config["business_ranks"][string.lower(job.grade_name)] or SimpleBanking.Config["business_ranks_overrides"][string.lower(job.name)] and SimpleBanking.Config["business_ranks_overrides"][string.lower(job.name)][string.lower(job.grade_name)]) then
            local result = MySQL.Sync.fetchAll('SELECT * FROM addon_account_data WHERE account_name= @account_name', {
                ['@account_name'] = 'society_'..job.name
            })
            local data = result[1]

            if data ~= nil then
                tbl[#tbl + 1] = {
                    type = "business",
                    name = job.label,
                    amount = format_int(data.money) or 0
                }
            end
        end
    end
    local result = MySQL.Sync.fetchAll("SELECT * FROM transaction_history WHERE identifier =  @identifier AND DATE(date) > (NOW() - INTERVAL "..SimpleBanking.Config["Days_Transaction_History"].." DAY)", {
        ['@identifier'] = Identifier
    })

    if result ~= nil then
        TransactionRan = true
        TransactionHistory = result
    end


    repeat
        Wait(0)
    until 
        TransactionRan
    cb(tbl, TransactionHistory)
end)


ESX.RegisterServerCallback("qb-banking:server:GetCharInfo", function(source, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
        ['@identifier'] = xPlayer.identifier
    })
    if result[1] ~= nil then
        local identity = result[1]
        local brbr = {
            firstname = identity['firstname'],
            lastname = identity['lastname'],
        }
    cb(brbr)
    end
end)