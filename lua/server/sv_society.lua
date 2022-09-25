local ESX = exports[SimpleBanking.ExtendedScriptName]:getSharedObject()
function GetSociety(name)
    local result = MySQL.Sync.fetchAll('SELECT * FROM addon_account_data WHERE account_name= @account_name', {
        ['@account_name'] = 'society_'..name
    })
    local data = result[1]

    return data
end


RegisterNetEvent('qb-banking:society:server:WithdrawMoney')
AddEventHandler('qb-banking:society:server:WithdrawMoney', function(pSource, a, n)
    local src = pSource
    if not src then return end

    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    if not a then return end
    if not n then return end

    local s = GetSociety(n)
    local sMoney = tonumber(s.money)
    local amount = tonumber(a)
    local withdraw = sMoney - amount

    local setter = MySQL.Async.execute("UPDATE addon_account_data SET money = @withdraw WHERE account_name = @account_name", {
        ['@withdraw'] = withdraw, 
        ['@account_name'] = 'society_'..n
    })
end)

RegisterServerEvent('qb-banking:society:server:DepositMoney')
AddEventHandler('qb-banking:society:server:DepositMoney', function(pSource, a, n)
    local src = pSource
    if not src then return end

    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    if not a then return end
    if not n then return end

    local s = GetSociety(n)
    local sMoney = tonumber(s.money)
    local amount = tonumber(a)
    local deposit = sMoney + amount

    
    local setter = MySQL.Async.execute("UPDATE addon_account_data SET money =  @deposit WHERE account_name = account_name", {
        ['@deposit'] = deposit, 
        ['@account_name'] = 'society_'..n
    })
end)