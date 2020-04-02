--=============================================================
--= https://github.com/davuongthanh                           =
--=	https://www.youtube.com/channel/UC4f6N3gtOGqn2znOo7lxzQA  =
--= https://www.facebook.com/hida1995/                        =
--=============================================================
ESX = nil
local show = true
local ped, model = {}, {}
local cuoi = true
local pedid = nil
local come = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	Citizen.Wait(5000)
	DoRequestModel(GetHashKey('a_c_boar'))
	DoRequestModel(GetHashKey('a_c_cow'))
	DoRequestModel(GetHashKey('a_c_deer'))
	DoRequestModel(GetHashKey('a_c_mtlion'))
end)

function DoRequestModel(model)
	RequestModel(model)
	while not HasModelLoaded(model) do
		Citizen.Wait(1)
	end
end

function DoRequestAnimSet(anim)
	RequestAnimDict(anim)
	while not HasAnimDictLoaded(anim) do
		Citizen.Wait(1)
	end
end

Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.AnimalShop.Pos.x, Config.Zones.AnimalShop.Pos.y, Config.Zones.AnimalShop.Pos.z)

	SetBlipSprite (blip, Config.Zones.AnimalShop.Sprite)
	SetBlipDisplay(blip, Config.Zones.AnimalShop.Display)
	SetBlipScale  (blip, 1.0)
	SetBlipColour (blip, Config.Zones.AnimalShop.Color)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("<FONT FACE='UVNBaiSau_R'>Cửa hàng động vật</FONT>")
	EndTextCommandSetBlipName(blip)
end)

RegisterNUICallback('NUIFocusOff', function()
	SetNuiFocus(false, false)
	show = true
end)

function attached()
	local GroupHandle = GetPlayerGroup(PlayerId())
	SetGroupSeparationRange(GroupHandle, 2.5)
	SetPedNeverLeavesGroup(ped, false)
	FreezeEntityPosition(ped, true)
end

function detached()
	local GroupHandle = GetPlayerGroup(PlayerId())
	SetGroupSeparationRange(GroupHandle, 999999.9)
	SetPedNeverLeavesGroup(ped, true)
	SetPedAsGroupMember(ped, GroupHandle)
	FreezeEntityPosition(ped, false)
end

function openchien()
	local playerPed = PlayerPedId()
	local LastPosition = GetEntityCoords(playerPed)
	local GroupHandle = GetPlayerGroup(PlayerId())

	DoRequestAnimSet('rcmnigel1c')

	TaskPlayAnim(playerPed, 'rcmnigel1c', 'hailing_whistle_waive_a' ,8.0, -8, -1, 120, 0, false, false, false)

	Citizen.SetTimeout(5000, function()
		ped = CreatePed(28, model, LastPosition.x +1, LastPosition.y +1, LastPosition.z -1, 1, 1)
		pedid = ped
		SetPedAsGroupLeader(playerPed, GroupHandle)
		SetPedAsGroupMember(ped, GroupHandle)
		SetPedNeverLeavesGroup(ped, true)
		SetPedCanBeTargetted(ped, false)
		SetEntityAsMissionEntity(ped, true,true)

		status = math.random(40, 90)
		Citizen.Wait(5)
		attached()
		Citizen.Wait(5)
		detached()
	end)
end

function OpenMenuAnimal()
	ESX.TriggerServerCallback('od_rideanimal:getAnimal', function(listAnimal) 
		local elements = {}
		for k, v in pairs(listAnimal) do
			if v.animal then
				local v_animal = {}
				v_animal = json.decode(v.animal)
				if v.animal ~= '[]' then
					for i=1, #v_animal, 1 do
						for j=1, #Config.AnimalShop, 1 do
							if v_animal[i].animal == Config.AnimalShop[j].name then
								label = Config.AnimalShop[j].label
							end
						end
						table.insert(elements, {
							label = label,
							value = v_animal[i].animal
						})
					end
				end
			end
		end
		ESX.UI.Menu.CloseAll()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'animal', {
			title    = 'Quản lý Động Vật Nuôi',
			align    = 'center',
			elements = elements
		}, function(data, menu)
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'animal_confirm', {
				title    = 'Quản lý Động Vật Nuôi',
				align    = 'center',
				elements = {
					{label = 'Gọi thú ra', value = 'comein'},
					{label = 'Gọi thú về nhà', value = 'comeout'}
			}}, function (data2, menu2)
				if data2.current.value == 'comein' and come == 0 then
					if data.current.value == 'boar' then
						model = GetHashKey('a_c_boar')
						openchien()
						come = 1
						ESX.UI.Menu.CloseAll()
					elseif data.current.value == 'cow' and come == 0 then
						model = GetHashKey('a_c_cow')
						openchien()
						come = 1
						ESX.UI.Menu.CloseAll()
					elseif data.current.value == 'deer' and come == 0 then
						model = GetHashKey('a_c_deer')
						openchien()
						come = 1
						ESX.UI.Menu.CloseAll()	
					elseif data.current.value == 'mtlion' and come == 0 then
						model = GetHashKey('a_c_mtlion')
						openchien()
						come = 1
						ESX.UI.Menu.CloseAll()
					else
						ESX.ShowNotification('Thú của bạn đang ở ~y~ngoài~s~')
						ESX.UI.Menu.CloseAll()
					end	
				else
					if  pedid ~= nil then
						if DoesEntityExist(pedid) then
							local GroupHandle = GetPlayerGroup(PlayerId())
							local coords      = GetEntityCoords(PlayerPedId())

							ESX.ShowNotification('Thú của bạn đang về ~y~nhà~s~')

							SetGroupSeparationRange(GroupHandle, 1.9)
							SetPedNeverLeavesGroup(ped, false)
							TaskGoToCoordAnyMeans(ped, coords.x + 40, coords.y, coords.z, 5.0, 0, 0, 786603, 0xbf800000)

							Citizen.Wait(5000)
							come = 0
							pedid = nil
							DeleteEntity(ped)
						end
					end
					menu2.close()
				end	
			end, function(data2, menu2)
				menu2.close()	
			end)
		end, function(data, menu)
			menu.close()
		end)

	end)
end

function OpenAnimalShop()
	if show == true then
		for i=1, #Config.AnimalShop, 1 do
			SendNUIMessage({
				name = Config.AnimalShop[i].name,
				label = Config.AnimalShop[i].label,
				price = Config.AnimalShop[i].price,
				display = true,
			})
		end
		SetNuiFocus(true, true)
		show = false
	end
end

RegisterNUICallback('animal_buy', function(data)
	if data.name ~= nil then
		ESX.TriggerServerCallback('od_rideanimal:buyAnimal', function(success)
			if success then
				ESX.ShowNotification('bạn đã mua ~y~'..data.label..'~s~ giá ~r~-'..ESX.Math.GroupDigits(data.price)..'$~s~')
			else
				ESX.ShowNotification('~r~bạn không đủ tiền~s~')
			end
		end, data.name, tonumber(data.price))	
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coord = GetEntityCoords(PlayerPedId())
		
		local distance = GetDistanceBetweenCoords(coord, Config.Zones.AnimalShop.Pos.x, Config.Zones.AnimalShop.Pos.y, Config.Zones.AnimalShop.Pos.z, true)

		if distance < Config.DrawDistance then
			DrawMarker(Config.MarkerType, Config.Zones.AnimalShop.Pos.x, Config.Zones.AnimalShop.Pos.y, Config.Zones.AnimalShop.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
			Draw3DText(Config.Zones.AnimalShop.Pos.x, Config.Zones.AnimalShop.Pos.y, Config.Zones.AnimalShop.Pos.z  -1.000, "[~g~E~s~] để vào cửa hàng", 0.08, 0.08)
		end
		if distance < 2 then
			if IsControlJustReleased(0, 38) then
				OpenAnimalShop()
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)
		if IsControlJustReleased(0, 167) then
			OpenMenuAnimal()
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId())
		local health = GetEntityHealth(pedid)
		if cuoi == true then
			if  pedid ~= nil then
				if health == 0 then
					TriggerServerEvent('od_rideanimal:diedAnimal', GetEntityModel(pedid))
					come = 0
					pedid = nil
					Citizen.Wait(5000)
					DeleteEntity(ped)
				else
					if DoesEntityExist(pedid) then
						local AnimalPosition = GetEntityCoords(pedid, false)
						local distance  = GetDistanceBetweenCoords(coords, AnimalPosition, true)
						if distance < 2 then
							DrawText3D(AnimalPosition.x, AnimalPosition.y, AnimalPosition.z, "[~g~E~s~] để cưỡi")
						end	

					end
				end
			end
		end
	end
end)

function Draw3DText(x,y,z,textInput,scaleX,scaleY)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)    
	local scale = (1/dist)*20
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov   
	SetTextScale(scaleX*scale, scaleY*scale)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(250, 250, 250, 255)		-- You can change the text color here
	SetTextDropshadow(1, 1, 1, 1, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString("<FONT FACE='UVNBaiSau_R'>" .. textInput .. "</FONT>")
	SetDrawOrigin(x,y,z+2, 0)
	DrawText(0.0, 0.0)
	 --ClearDrawOrigin()
end

function DrawText3D(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local factor = #text / 370
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString("<FONT FACE='UVNBaiSau_R'>" .. text .. "</FONT>")
	DrawText(_x,_y)
	DrawRect(_x,_y + 0.0175, 0.0125 + factor, 0.03, 0, 0, 0, 80)
end




--===========================================================================================================================
-- 'Event Functions' You can use to trigger events/actions on your server/gamemode
--===========================================================================================================================
function OnPlayerBoardAnimal()
	-- You could use these calls to for example save stats of players on how many times they
	-- have ridden animals or so. 
	-- NOTE: I WILL NOT make such scripts or help with them, since those heavily depend on what
	-- YOU need or want, and also on your type of data(base) storage. 
end

function OnPlayerLeaveAnimal()
	-- You could use these calls to for example save stats of players on how many times they
	-- have ridden animals or so. 
	-- NOTE: I WILL NOT make such scripts or help with them, since those heavily depend on what
	-- YOU need or want, and also on your type of data(base) storage. 

	-- The reason I have a OnPlayerBOARDAnimal AND a OnPlayerLeaveAnimal is because we also
	-- keep track of riding time(s), and we do checks for when a farmer for example has 'exit' his
	-- cow to put it in the barn(s)
end

function OnPlayerRequestToRideAnimal()
	-- Check for 'own conditions' on our server if the player is allowed at that time to
	-- even ride/board animals. You could also use that function for example to 'exclude' wanted
	-- players from riding/boarding animals.
	
	-- We for example use it to check if the player has obtained a special perk which makes him/her able
	-- to ride these animals.
	return true
end

--===========================================================================================================================
-- ONE simple setting to allow other players to ride on other players IF they are animals
-- NOTE: you CAN NOT control the other player though!
--===========================================================================================================================
local AllowRidingAnimalPlayers = false
IhaveReplacedMyDeerWithModNumber1 = true

--===========================================================================================================================
-- (Global) Script Declarations
--===========================================================================================================================
local HelperMessageID = 0
AnimalControlStatus =  0.05
XNL_IsRidingAnimal = false		-- This one is used so the script knows if it need to run the entire code in
								-- it's main thread or not (and thus performance increasing on idle (not riding))

local Animal = {
	Handle = nil,
	Invincible = false,
	Ragdoll = false,
	Marker = false,
	InControl = false,
	IsFleeing = false,
	Speed = {
		Walk = 2.0,
		Run = 3.0,
	},
}

--===========================================================================================================================
-- Enitiy Enumerator Section
--===========================================================================================================================
local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	end
}

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end
	
		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
	
		local next = true
		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next
	
		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function GetNearbyPeds(X, Y, Z, Radius)
	local NearbyPeds = {}
	for Ped in EnumeratePeds() do
		if DoesEntityExist(Ped) then
			local PedPosition = GetEntityCoords(Ped, false)
			if Vdist(X, Y, Z, PedPosition.x, PedPosition.y, PedPosition.z) <= Radius then
				table.insert(NearbyPeds, Ped)
			end
		end
	end
	return NearbyPeds
end

--===========================================================================================================================
-- Animal Related Fuctions
--===========================================================================================================================
function Animal.Attach()
	local Ped = PlayerPedId()

	FreezeEntityPosition(Animal.Handle, true)
	FreezeEntityPosition(Ped, true)

	local AnimalPosition = GetEntityCoords(Animal.Handle, false)
	SetEntityCoords(Ped, AnimalPosition.x, AnimalPosition.y, AnimalPosition.z)
	

	AnimalName = "Deer"
	AnimalType = 1
	XAminalOffSet = 0.0 -- Default DEER offset
	AnimalOffSet  = 0.2  -- Default DEER offset
	--if GetEntityModel(Animal.Handle) == GetHashKey('a_c_cow') then AnimalOffSet = 0.2 end

	
	
	if GetEntityModel(Animal.Handle) == GetHashKey('a_c_boar') then 
		AnimalName = "Boar"
		AnimalOffSet = 0.3
		AnimalType = 3
		XAminalOffSet = -0.0
	end
	
	if GetEntityModel(Animal.Handle) == GetHashKey('a_c_cow') then 
		AnimalName = "Cow"
		AnimalType = 2
		AnimalOffSet  = 0.1
		XAminalOffSet = 0.1
	end
	
	if GetEntityModel(Animal.Handle) == GetHashKey('a_c_deer') then 
		AnimalName = "Deer"
		AnimalType = 1
		AnimalOffSet  = 0.12
		XAminalOffSet = -0.2
	end

	if GetEntityModel(Animal.Handle) == GetHashKey('a_c_mtlion') then 
		AnimalName = "Mtilion"
		AnimalType = 1
		AnimalOffSet  = 0.12
		XAminalOffSet = -0.2
	end

	if NetworkGetPlayerIndexFromPed(Animal.Handle) == -1 then
		Animal.InControl = true
		cuoi = false
		if (HelperMessageID > 2 or HelperMessageID < 2) then --  and Animal.InControl 
			HelperMessageID = 2
			AnimalControlStatus = 0.05
		end
	end
	
	SetCurrentPedWeapon(Ped, "weapon_unarmed", true)	-- Sets the player to unarmed (no weapons), 
														-- it could "freak out" Peds or Feds, and 'space the weapon' through the animal
	AttachEntityToEntity(Ped, Animal.Handle, GetPedBoneIndex(Animal.Handle, 24816), XAminalOffSet, 0.0, AnimalOffSet, 0.0, 0.0, -90.0, false, false, false, true, 2, true)

	if AnimalType == 1  then
		RequestAnimDict("amb@prop_human_seat_chair@male@generic@base")
		while not HasAnimDictLoaded("amb@prop_human_seat_chair@male@generic@base") do
			Citizen.Wait(250)
		end
		TaskPlayAnim(Ped, "amb@prop_human_seat_chair@male@generic@base", "base", 8.0, 1, -1, 1, 1.0, 0, 0, 0)
	elseif AnimalType == 2 or AnimalType == 3 then
		RequestAnimDict("amb@prop_human_seat_chair@male@elbows_on_knees@idle_a")
		while not HasAnimDictLoaded("amb@prop_human_seat_chair@male@elbows_on_knees@idle_a") do
			Citizen.Wait(250)
		end

		TaskPlayAnim(Ped, "amb@prop_human_seat_chair@male@elbows_on_knees@idle_a", "idle_a", 8.0, 1, -1, 1, 1.0, 0, 0, 0)
	end
	--TaskPlayAnim(Ped, "rcmjosh2", "josh_sitting_loop", 8.0, 1, -1, 2, 1.0, 0, 0, 0)

	
	FreezeEntityPosition(Animal.Handle, false)
	FreezeEntityPosition(Ped, false)
	OnPlayerBoardAnimal() -- Used to do some 'extra stuff' on our server when a player has boarded an animal
						  -- you can also use it to for example save stats like: Ridden Animals: [number of times]
	XNL_IsRidingAnimal = true
end

function Animal.Ride()
	local Ped = PlayerPedId()
	local PedPosition = GetEntityCoords(Ped, false)
	if IsPedSittingInAnyVehicle(Ped) or IsPedGettingIntoAVehicle(Ped) then
		return
	end

	local AttachedEntity = GetEntityAttachedTo(Ped)
	
	if (IsEntityAttached(Ped)) and (GetEntityModel(AttachedEntity) == GetHashKey("a_c_boar") 
		or (GetEntityModel(AttachedEntity) == GetHashKey("a_c_cow")
		or GetEntityModel(AttachedEntity) == GetHashKey("a_c_deer") 
	    or GetEntityModel(AttachedEntity) == GetHashKey("a_c_mtlion"))) then
		local SideCoordinates = GetCoordsInfrontOfEntityWithDistance(AttachedEntity, 1.0, 90.0)
		local SideHeading = GetEntityHeading(AttachedEntity)

		SideCoordinates.z = GetGroundZ(SideCoordinates.x, SideCoordinates.y, SideCoordinates.z)

		Animal.Handle = nil
		Animal.InControl = false
		DetachEntity(Ped, true, false)
		ClearPedSecondaryTask(Ped)
		ClearPedTasksImmediately(Ped)

		AminD2 = "amb@prop_human_seat_chair@male@elbows_on_knees@react_aggressive"
		RequestAnimDict(AminD2)
		while not HasAnimDictLoaded(AminD2) do
			Citizen.Wait(0)
		end
		TaskPlayAnim(Ped, AminD2, "exit_left", 8.0, 1, -1, 0, 1.0, 0, 0, 0)
		Wait(100)
		SetEntityCoords(Ped, SideCoordinates.x, SideCoordinates.y, SideCoordinates.z)
		SetEntityHeading(Ped, SideHeading)
		ClearPedSecondaryTask(Ped)
		ClearPedTasksImmediately(Ped)
		RemoveAnimDict(AminD2)
		OnPlayerLeaveAnimal() -- Used on our server to do 'stuff' when the player got of the animal
		if HelperMessageID > 0 then
			HelperMessageID = 0
			ClearAllHelpMessages()				
		end

	else
		for _, Ped in pairs(GetNearbyPeds(PedPosition.x, PedPosition.y, PedPosition.z, 2.0)) do
			if not IsPedFalling(Ped) and not IsPedFatallyInjured(Ped) and not IsPedDeadOrDying(Ped) 
			   and not IsPedDeadOrDying(Ped) and not IsPedGettingUp(Ped) and not IsPedRagdoll(Ped) then
				if (GetEntityModel(Ped) == GetHashKey("a_c_boar") 
					or GetEntityModel(Ped) == GetHashKey("a_c_cow")
					or GetEntityModel(Ped) == GetHashKey("a_c_deer")
					or GetEntityModel(Ped) == GetHashKey("a_c_mtlion")) then
					
					if NetworkGetPlayerIndexFromPed(Ped) > -1 and not AllowRidingAnimalPlayers then
						return
					end
					
					
					-- Here we do a simple scan to see if there are other Peds in the radius of the animal
					-- (although for 'all safety' I've made this scan a bit bigger)
					-- If it turns out if there is a player nearby it will then compare if that Entity (The other player)
					-- if attached to the 'just detected entity (the animal)'. If this is the case we will NOT allow the
					-- player to "also" board the animal
					for _, Ped2 in pairs(GetNearbyPeds(PedPosition.x, PedPosition.y, PedPosition.z, 4.0)) do
						if IsEntityAttachedToEntity(Ped2, Ped) then
							return
						end
					end

					-- Check for 'own conditions' on our server if the player is allowed at that time to
					-- even ride/board animals. You could also use that function for example to 'exclude' wanted
					-- players from riding/boarding animals
					if OnPlayerRequestToRideAnimal() then
						Animal.Handle = Ped
						Animal.Attach()
					end
					break
				end
			end
		end
	end
end

function DropPlayerFromAnimal()
	local Ped = PlayerPedId()
	Animal.Handle = nil
	DetachEntity(Ped, true, false)
	ClearPedTasksImmediately(Ped)
	ClearPedSecondaryTask(Ped)
	Animal.InControl = false
	cuoi = true
	AminD2 = "amb@prop_human_seat_chair@male@elbows_on_knees@react_aggressive"
	RequestAnimDict(AminD2)
	while not HasAnimDictLoaded(AminD2) do
		Citizen.Wait(0)
	end
	TaskPlayAnim(Ped, AminD2, "exit_left", 8.0, 1, -1, 0, 1.0, 0, 0, 0)
	Wait(100)
	ClearPedSecondaryTask(Ped)
	ClearPedTasksImmediately(Ped)
	Wait(100)
	SetPedToRagdoll(Ped, 1500, 1500, 0, 0, 0, 0)
	AnimalControlStatus = 0
	OnPlayerLeaveAnimal() -- Used on our server to do 'stuff' when the player got of the animal
	XNL_IsRidingAnimal = false
end

--===========================================================================================================================
-- Main 'Helper' functions
--===========================================================================================================================
function GetCoordsInfrontOfEntityWithDistance(Entity, Distance, Heading)
	local Coordinates = GetEntityCoords(Entity, false)
	local Head = (GetEntityHeading(Entity) + (Heading or 0.0)) * math.pi / 180.0
	return {x = Coordinates.x + Distance * math.sin(-1.0 * Head), y = Coordinates.y + Distance * math.cos(-1.0 * Head), z = Coordinates.z}
end

function GetGroundZ(X, Y, Z)
	if tonumber(X) and tonumber(Y) and tonumber(Z) then
		local _, GroundZ = GetGroundZFor_3dCoord(X + 0.0, Y + 0.0, Z + 0.0, Citizen.ReturnResultAnyway())
		return GroundZ
	else
		return 0.0
	end
end

--===========================================================================================================================
-- Controling Threads
--===========================================================================================================================
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(50)
		if AnimalControlStatus > 0 then
			AnimalControlStatus = AnimalControlStatus - 0.001
		end
	end

end)

local group = "user"
RegisterNetEvent('46e4402d-2e6d-4fc1-a97e-70874c8aed85')
AddEventHandler('46e4402d-2e6d-4fc1-a97e-70874c8aed85', function(g)
	group = g
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
			if IsControlJustPressed(1, 51) then
				Animal.Ride()
			end

			if XNL_IsRidingAnimal then
				local Ped = PlayerPedId()
				local AttachedEntity = GetEntityAttachedTo(Ped)
				if (not IsPedSittingInAnyVehicle(Ped) or not IsPedGettingIntoAVehicle(Ped)) and IsEntityAttached(Ped) and AttachedEntity == Animal.Handle then
					if DoesEntityExist(Animal.Handle) then
						AnimalChecksOkay = true 		-- We set the 'animal state' default to true
						
						-- Here we check if the animal is 'okay' (not dead, tripped, run over etc etc),
						-- if the animal is 'not okay' we'll make the player fall off/ragdoll.
						-- same goes for when the player is 'not okay' anymore 
						if IsPedFalling(AttachedEntity) or IsPedFatallyInjured(AttachedEntity) or IsPedDeadOrDying(AttachedEntity) 
						   or IsPedDeadOrDying(AttachedEntity) or IsPedDeadOrDying(Ped) or IsPedGettingUp(AttachedEntity) or IsPedRagdoll(AttachedEntity) then
							Animal.IsFleeing = false
							Animal.InControl = false
							AnimalChecksOkay = false
							DropPlayerFromAnimal()
						end
					
						-- If the animal checks out all okay, we'll resume riding it
						if AnimalChecksOkay then
							local LeftAxisXNormal, LeftAxisYNormal = GetControlNormal(2, 218), GetControlNormal(2, 219)
							local Speed, Range = Animal.Speed.Walk, 4.0
			
							-- Make the animal 'run', however this is 'kinda buggy' and not totally satisfactory,
							-- so you could disable the following four lines of code to 'disable animal running'
							if IsControlPressed(0, 21) then
								Speed = Animal.Speed.Run
								Range = 8.0
							end
			
							if Animal.InControl then
								Animal.IsFleeing = false
								local GoToOffset = GetOffsetFromEntityInWorldCoords(Animal.Handle, LeftAxisXNormal * Range, LeftAxisYNormal * -1.0 * Range, 0.0)
				
								TaskLookAtCoord(Animal.Handle, GoToOffset.x, GoToOffset.y, GoToOffset.z, 0, 0, 2)
								TaskGoStraightToCoord(Animal.Handle, GoToOffset.x, GoToOffset.y, GoToOffset.z, Speed, 20000, 40000.0, 0.5)
				
								if Animal.Marker then
									DrawMarker(6, GoToOffset.x, GoToOffset.y, GoToOffset.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 255, 255, 255, 0, 0, 2, 0, 0, 0, 0)
								end
							else
								if NetworkGetPlayerIndexFromPed(Animal.Handle) == -1 then
									-- Tapping (Default) the [W] key to gain control of the animal
									if IsControlJustPressed(1, 71) then
										if AnimalControlStatus < 0.1 then
											AnimalControlStatus = AnimalControlStatus + 0.005
											if AnimalControlStatus > 0.1 then 
												AnimalControlStatus = 0.1 
												if HelperMessageID > 4 or HelperMessageID < 4 then
													ESX.ShowHelpNotification("Bạn đã giành được quyền kiểm soát động vật")
													HelperMessageID = 4
													AnimalControlStatus = 0
													Animal.InControl = true
												end
											end
										end
									end
								
									if AnimalControlStatus <= 0.001 and not Animal.InControl then
										if HelperMessageID > 3 or HelperMessageID < 3 then
											ESX.ShowHelpNotification("Bạn đã mất nắm và rơi ra")
											HelperMessageID = 3
										end
										DropPlayerFromAnimal()
									end
									
									if not Animal.IsFleeing then
										Animal.IsFleeing = true
										TaskSmartFleePed(Animal.Handle, Ped, 9000.0, -1, false, false)
									end
								end
							end
						end
					end
				end
				-- PKS.in.TH
				if not IsEntityAttached(Ped) or AttachedEntity == -1 then
					DropPlayerFromAnimal()
					
				end
			end
	end
end)