local notified = false
local lastNotified = 0

local banks = {
	{name='<font face="Fire Sans">Banka', id=108, x=150.266, y=-1040.203, z=29.374},
	{name='<font face="Fire Sans">Banka', id=108, x=-1212.980, y=-330.841, z=37.787},
	{name='<font face="Fire Sans">Banka', id=108, x=-2962.582, y=482.627, z=15.703},
	{name='<font face="Fire Sans">Banka', id=108, x=-112.202, y=6469.295, z=31.626},
	{name='<font face="Fire Sans">Banka', id=108, x=314.187, y=-278.621, z=54.170},
	{name='<font face="Fire Sans">Banka', id=108, x=-351.534, y=-49.529, z=49.042}, 
	{name='<font face="Fire Sans">Banka', id=106, x=241.610, y=225.120, z=106.286},
	{name='<font face="Fire Sans">Banka', id=108, x=1175.064, y=2706.643, z=38.094}
}	

--[[ Show Things ]]--
CreateThread(function()
	for k,v in ipairs(banks) do
	  local blip = AddBlipForCoord(v.x, v.y, v.z)
	  SetBlipSprite(blip, v.id)
	  SetBlipDisplay(blip, 4)
	  SetBlipScale  (blip, 0.5)
	  SetBlipColour (blip, 0)
	  SetBlipAsShortRange(blip, true)
	  BeginTextCommandSetBlipName("STRING")
	  AddTextComponentString(tostring(v.name))
	  EndTextCommandSetBlipName(blip)
	end
end)

RegisterNetEvent('qb-banking:client:bank:openUI')
AddEventHandler('qb-banking:client:bank:openUI', function() -- this one bank from target models
	if not bMenuOpen then
		if lib.progressBar({
			duration = 2000,
			label = 'Otevírám banku',
			useWhileDead = false,
			canCancel = true,
			disable = {
				car = false,
			},
			anim = {
				dict = 'mp_common',
				clip = 'givetake1_a' 
			},
		}) then print('Dělejte věci po dokončení') else print('Dělejte věci po zrušení')
		end
		ToggleUI()
	end
end)

RegisterNetEvent('qb-banking:client:atm:openUI')
AddEventHandler('qb-banking:client:atm:openUI', function() -- this opens ATM
	if not bMenuOpen then
		if lib.progressBar({
			duration = 2000,
			label = 'Otevírám banku',
			useWhileDead = false,
			canCancel = true,
			disable = {
				car = false,
			},
			anim = {
				dict = 'mp_common',
				clip = 'givetake1_a' 
			},
		}) then print('Dělejte věci po dokončení') else print('Dělejte věci po zrušení')
		end
		ToggleUI()
	end
end)

CreateThread(function()
	local ATMS = { `prop_atm_01`, `prop_atm_02`, `prop_atm_03`, `prop_fleeca_atm` }
	exports[SimpleBanking.Target]:AddTargetModel(ATMS, { options = { { event = "qb-banking:client:atm:openUI", icon = "fas fa-credit-card", label = "ATM" }, }, distance = 1.5 })
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end
