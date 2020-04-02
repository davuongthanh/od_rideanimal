--=============================================================
--= https://github.com/davuongthanh                           =
--=	https://www.youtube.com/channel/UC4f6N3gtOGqn2znOo7lxzQA  =
--= https://www.facebook.com/hida1995/                        =
--=============================================================
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('od_rideanimal:getAnimal', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	MySQL.Async.fetchAll('SELECT animal FROM users WHERE identifier = @identifier', 
	{
		['@identifier'] = identifier
	}, function(result)
        local listAnimal = {}
        for i=1, #result, 1 do
            table.insert(listAnimal, {
                animal = result[i].animal
            })
        end
		cb(listAnimal)
    end)
end)

ESX.RegisterServerCallback('od_rideanimal:buyAnimal', function(source, cb, name, price)
    local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
    if xPlayer.getMoney() >= price then
        MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", 
		{
			['@identifier']	= identifier
		} , function(result)
			local list_animal = {}
			local check = false
			for i=1, #result, 1 do
				table.insert(list_animal, {
					animal = result[i].animal
				})
			end

			local row = {}
			for k, v in pairs(list_animal) do
				if v.animal ~= '[]' then
					local v_animal = {}
					v_animal = json.decode(v.animal)
					if string.find(v.animal, name) then
						check = false
					else
						check = true
						for i=1, #v_animal, 1 do
							table.insert(row, {
								animal = v_animal[i].animal
							})
						end
					end
				else
					check = true
				end
			end
			if check == true then
				table.insert(row, {
					animal = name
				})

				MySQL.Async.execute('UPDATE users SET animal = @animal WHERE identifier = @identifier', {
					['@identifier']	= identifier,
					['@animal'] = json.encode(row)
				}, function(rowsChanged)
					xPlayer.removeMoney(price)
					cb(true)
				end)
			else
				xPlayer.showNotification('~r~bạn đã có động vật này rồi~s~')
			end
		end)
	else
		
        cb(false)
    end
end)

RegisterNetEvent('od_rideanimal:diedAnimal')
AddEventHandler('od_rideanimal:diedAnimal', function(name)
    local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	if name ~= nil then
		if name == -832573324 then 
			name = 'boar'
		elseif name == -664053099 then
			name = 'deer'
		elseif name == -50684386 then
			name = 'cow'
		elseif name == 307287994 then
			name = 'mtlion'
		end
		MySQL.Async.fetchAll("SELECT animal FROM users WHERE identifier = @identifier",
		{
			['@identifier'] = identifier
		}
		, function(result)
			local list_animal = {}
			for i=1, #result, 1 do
				table.insert(list_animal, {
					animal = result[i].animal
				})
			end

			local row = {}
			for k, v in pairs(list_animal) do
				if v.animal ~= '[]' then
					local v_animal = {}
					v_animal = json.decode(v.animal)
					for i=1, #v_animal, 1 do
						table.insert(row, {
							animal = v_animal[i].animal
						})
					end
				end
			end

			for k,v in pairs(row) do
				if(v['animal'] == name) then
					table.remove(row,k)
				end
			end

			MySQL.Async.execute('UPDATE users SET animal = @animal WHERE identifier = @identifier', {
				['@identifier']	= identifier,
				['@animal'] = json.encode(row)
			}, function(rowsChanged)
				xPlayer.showNotification('Thú của bạn đã ~r~chết~s~')
			end)
		end)
	end	
end)