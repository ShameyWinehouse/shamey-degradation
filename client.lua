local VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
    print = VORPutils.Print:initialize(print) --Initial setup 
end)
local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

local currentWeapon

local lastLassoCheck
local lastFishingRodCheck

local playerPedId


-------- THREADS
-- Performance
Citizen.CreateThread(function ()
    while true do
        playerPedId = PlayerPedId()
        Citizen.Wait(1000)
    end
end)


-- Show lasso's degradation when aiming (i.e. "inspecting")
Citizen.CreateThread(function ()
    lastLassoCheck = GetGameTimer()
    while true do

        local sleep = 500

        -- If the interval for checking the lasso's status has expired
        if playerPedId and (lastLassoCheck + Config.Lassoes.CheckInterval) <= GetGameTimer() then

            sleep = 100

            local isAimingLasso = isAiming(playerPedId) and isCurrentWeaponALasso(playerPedId) 
            if isAimingLasso then
                local hasWeapon, weaponHashKey = GetCurrentPedWeapon(playerPedId, true, 0, false)
                TriggerServerEvent("rainbow-degradation:CheckWeapon", weaponHashKey)
                lastLassoCheck = GetGameTimer()
            end

        end

        Citizen.Wait(sleep)

    end
end)

-- Hogtie events
Citizen.CreateThread(function ()
    while true do

        Citizen.Wait(0)

        -- Check for hogtie events

        local size 

        size = GetNumberOfEvents(0)
        if playerPedId and size > 0 then
            for i = 0, size - 1 do
                local eventAtIndex = GetEventAtIndex(0, i)
				if eventAtIndex ~= `EVENT_PED_CREATED` and eventAtIndex ~= `EVENT_PED_DESTROYED` and eventAtIndex ~= `EVENT_CHALLENGE_GOAL_UPDATE` then
					-- print("eventAtIndex0", eventAtIndex)

                    -- Hogtie event
					if eventAtIndex == GetHashKey("EVENT_ENTITY_HOGTIED") then
						local eventHogtied = events.getEventData("EVENT_ENTITY_HOGTIED")
						if Config.ShameyDebug then print('EVENT: eventHogtied', eventHogtied) end
						if eventHogtied["hogtier ped id"] == playerPedId then
							-- The player has hogtied someone with their lasso
							local hasWeapon, weaponHash = GetCurrentPedWeapon(playerPedId, true, 0, false)
							if Config.ShameyDebug then print('lasso hogtied by player, weaponhash:', weaponHash) end
							-- TriggerServerEvent("rainbow-degradation:DegradeLasso", weaponHash)
							TriggerServerEvent("rainbow-degradation:WeaponUsed", weaponHash, true)
						end
					end

                    -- Melee weapons
                    -- 402722103 = EVENT_ENTITY_DAMAGED
                    if eventAtIndex == GetHashKey("EVENT_ENTITY_DAMAGED") then
                        -- Check if the weapon was melee
                        local hasWeapon, weaponHash = GetCurrentPedWeapon(playerPedId, true, 0, false)
                        if hasWeapon then
                            local isWeaponMeleeWeapon = IsSupportedMeleeWeapon(weaponHash)
                            if isWeaponMeleeWeapon then
                                -- if Config.ShameyDebug then print("IsWeaponMeleeWeapon(weaponHash)", IsWeaponMeleeWeapon(weaponHash)) end
                                if Config.ShameyDebug then print("ped 'shot' melee weapon") end
                                TriggerServerEvent("rainbow-degradation:WeaponUsed", weaponHash, false)
                            end
                        end
                    end

				end
            end
        end

        -- Check for lassoing (non-hogtie) events
        size = GetNumberOfEvents(1)
        if playerPedId and size > 0 then
            for i = 0, size - 1 do
                local eventAtIndex = GetEventAtIndex(1, i)
                -- print("eventAtIndex1", eventAtIndex)
                
                -- Lasso used event
                if eventAtIndex == GetHashKey("EVENT_NETWORK_LASSO_ATTACH") then
					local lassoAttach = events.getEventData("EVENT_NETWORK_LASSO_ATTACH")
					if Config.ShameyDebug then print('EVENT: EVENT_NETWORK_LASSO_ATTACH', lassoAttach) end
					if Config.ShameyDebug then print(lassoAttach) end

                    if lassoAttach["PerpitratorEntityId"]  == playerPedId then
                        if Config.ShameyDebug then print("player was the lassoER") end
                        TriggerServerEvent("rainbow-degradation:WeaponUsed", lassoAttach["WeaponUsed"], false)
                    end

                end

            end
        end

    end
end)

-- Shooting bows
Citizen.CreateThread(function ()
    while true do

        local sleep = 250
        
        if playerPedId then
            
            local hasWeapon, weaponHash = GetCurrentPedWeapon(playerPedId, true, 0, false)
            if hasWeapon then
                local isWeaponBow = IsWeaponBow(weaponHash) -- return value is "any"
                if isWeaponBow and isWeaponBow ~= 0 then
                    sleep = 0
                    if IsPedShooting(playerPedId) then
                        if Config.ShameyDebug then print("ped shooting bow") end
                        TriggerServerEvent("rainbow-degradation:WeaponUsed", weaponHash, false)
                    end
                end
            end
        end

        Citizen.Wait(sleep)

    end
end)


-------- EVENTS

RegisterNetEvent("rainbow-core:WeaponEquipped")
AddEventHandler("rainbow-core:WeaponEquipped", function(weaponHash, weaponId)

    if Config.ShameyDebug then print("rainbow-core:WeaponEquipped", weaponHash) end

    currentWeapon = weaponHash

    weaponHashKey = GetHashKey(weaponHash)

    -- Lasso
	if isWeaponALasso(weaponHashKey) then -- IsWeaponLasso
        TriggerServerEvent("rainbow-degradation:CheckWeapon", weaponHashKey)
    -- Fishing Rod
    elseif weaponHashKey == `weapon_fishingrod` then
        TriggerServerEvent("rainbow-degradation:CheckWeapon", weaponHashKey)
    -- Bows
    elseif weaponHashKey == `weapon_bow` or weaponHashKey == `weapon_bow_improved`  then
        if Config.ShameyDebug then print("bows") end
        TriggerServerEvent("rainbow-degradation:CheckWeapon", weaponHashKey)
    -- Torches
    elseif weaponHashKey == `weapon_melee_torch` or weaponHashKey == `weapon_melee_torch_crowd` then
        if Config.ShameyDebug then print("torches") end
        -- Torches *uniquely* get degraded upon EQUIPPING ("using").
        TriggerServerEvent("rainbow-degradation:CheckWeapon", weaponHashKey)
        TriggerServerEvent("rainbow-degradation:WeaponUsed", weaponHashKey, false)
    end

end)

RegisterNetEvent("rainbow-core:AlertDegradation")
AddEventHandler("rainbow-core:AlertDegradation", function(weaponName, currentDegradation)
    lastLassoCheck = GetGameTimer()
    if Config.ShameyDebug then print("rainbow-core:AlertDegradation - 225pr", GetGameTimer()) end
    TriggerEvent("vorp:TipRight", string.format("%s Degradation: %.1f%%", weaponName, currentDegradation * 100), 6 * 1000)
end)


-------- FUNCTIONS

function isAiming(ped)
    return Citizen.InvokeNative(0x698F456FB909E077) or Citizen.InvokeNative(0x936F967D4BE1CE9D, ped) -- IsAimCamActive, IsPlayerFreeAiming
end

function isCurrentWeaponALasso(ped)
	local currentWeaponHashKey = getCurrentWeaponHashKey(ped)
	local currentWeaponTypeGroup = Citizen.InvokeNative(0xEDCA14CA5199FF25, currentWeaponHashKey) -- GetWeapontypeGroup
	if currentWeaponTypeGroup == `group_lasso` then
		-- or currentWeaponHashKey == `weapon_fishingrod` then
		return true
	else
		return false
	end
end

function getCurrentWeaponHashKey(ped)
    return Citizen.InvokeNative(0x8425C5F057012DAB, ped) -- GetPedCurrentHeldWeapon
end

function isWeaponALasso(weaponHashKey)
	local group = GetWeapontypeGroup(tonumber(weaponHashKey))
	return group == `group_lasso`
end

function GetObjectIndexOfPedWeapon(ped, weaponHash)
	for attachPoint=0, 29 do
		local _, _weaponHash = GetCurrentPedWeapon(ped, true, attachPoint, false)

		if _weaponHash == weaponHash then
			return GetObjectIndexFromEntityIndex(GetCurrentPedWeaponEntityIndex(ped, attachPoint))
		end
	end

	return nil
end

function IsSupportedMeleeWeapon(weaponHash)
    -- if Config.ShameyDebug then print("IsSupportedMeleeWeapon(weaponHash)", weaponHash) end
    if InArray(Config.MeleeWeapons.List, weaponHash) then
        return true
    end
    return false
end

function InArray(array, item)
    for k, v in pairs(array) do
        if v == item then return true end
    end
    return false
end


--------

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end

end)
