local ESX = exports[SimpleBanking.ExtendedScriptName]:getSharedObject()
function AddTransaction(source, sAccount, iAmount, sType, sReceiver, sMessage, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local Identifier = xPlayer.identifier

    local iTransactionID = math.random(1000, 100000)

    MySQL.Async.insert("INSERT INTO `transaction_history` (`identifier`, `trans_id`, `account`, `amount`, `trans_type`, `receiver`, `message`) VALUES(@identifier, @iTransactionID, @sAccount, @iAmount, @sType, @sReceiver, @sMessage)", {
        ['@identifier'] = Identifier,
        ['@iTransactionID'] = iTransactionID,
        ['@sAccount'] = sAccount,
        ['@iAmount'] = iAmount,
        ['@sType'] = sType,
        ['@sReceiver'] = sReceiver,
        ['@sMessage'] = sMessage
    }, function()
        RefreshTransactions(src)
    end)
end

function RefreshTransactions(source)
    local src = source
    if not src then return end

    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local result = MySQL.Sync.fetchAll("SELECT * FROM transaction_history WHERE identifier = @identifier AND DATE(date) > (NOW() - INTERVAL "..SimpleBanking.Config["Days_Transaction_History"].." DAY)", {
       ['@identifier'] = xPlayer.identifier
    })

    if result ~= nil then
        TriggerClientEvent("qb-banking:client:UpdateTransactions", src, result)
    end
end