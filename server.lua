local VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
    print = VORPutils.Print:initialize(print) --Initial setup 
end)
local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

local VorpInv = exports.vorp_inventory:vorp_inventoryApi()


-------- THREADS


-------- EVENTS

RegisterServerEvent("rainbow-degradation:CheckWeapon")
AddEventHandler("rainbow-degradation:CheckWeapon", function(weaponHashKey)
	local _source = source

	if Config.ShameyDebug then print("rainbow-degradation:CheckWeapon", _source, weaponHashKey) end
	-- if Config.ShameyDebug then print("rainbow-degradation:CheckWeapon - 21pr", GetGameTimer()) end

	local usedWeaponObject = getWeaponObjectFromHashKey(_source, weaponHashKey)

	if not usedWeaponObject then
		print("ERROR: Could not get user's weapon object from weapon use. (CheckWeapon)", _source, weaponHashKey)
		return
	end


	local current_degradation_promise = promise.new()
	TriggerEvent("rainbow-core:GetWeaponDegradation", usedWeaponObject.id, function(result)
		current_degradation_promise:resolve(result)
	end)
	local currentDegradation = Citizen.Await(current_degradation_promise)
	if Config.ShameyDebug then print("35 - currentDegradation", currentDegradation) end
	if not currentDegradation then
		currentDegradation = 0.0
	else
		currentDegradation = currentDegradation["degradation"]
	end

	if Config.ShameyDebug then print("42 - currentDegradation", currentDegradation) end

	if currentDegradation >= getBreakThresholdFromHashKey(weaponHashKey) then
		TriggerEvent("rainbow-core:BreakWeapon", _source, usedWeaponObject)
	else
		-- Alert the degradation
		-- alertDegradation(_source, weaponHashKey, currentDegradation)
	end

end)

RegisterServerEvent("rainbow-degradation:WeaponUsed")
AddEventHandler("rainbow-degradation:WeaponUsed", function(weaponHashKey, isHogTie)
    local _source = source

	if Config.ShameyDebug then print("rainbow-degradation:WeaponUsed", _source, weaponHashKey, isHogTie) end

	local usedWeaponObject = getWeaponObjectFromHashKey(_source, weaponHashKey)

	if not usedWeaponObject then
		print("ERROR: Could not get user's weapon object from weapon use. (WeaponUsed)", _source, weaponHashKey)
		return
	end

	local incrementAmount = 0.00020 -- default
	local breakThreshold = getBreakThresholdFromHashKey(weaponHashKey)
	if weaponHashKey == `weapon_lasso_reinforced` then
		if isHogTie then
			incrementAmount = Config.Lassoes.Reinforced.Hogtie.IncrementAmount
		else
			incrementAmount = Config.Lassoes.Reinforced.Use.IncrementAmount
		end
	elseif weaponHashKey == `weapon_lasso` then
		if isHogTie then
			incrementAmount = Config.Lassoes.Plain.Hogtie.IncrementAmount
		else
			incrementAmount = Config.Lassoes.Plain.Use.IncrementAmount
		end
	elseif weaponHashKey == `weapon_fishingrod` then
		incrementAmount = Config.FishingRods.Plain.Use.IncrementAmount
	elseif weaponHashKey == `weapon_bow` then
		incrementAmount = Config.Bows.Plain.Use.IncrementAmount
	elseif weaponHashKey == `weapon_bow_improved` then
		incrementAmount = Config.Bows.Improved.Use.IncrementAmount
	elseif weaponHashKey == `weapon_melee_torch` or weaponHashKey == `weapon_melee_torch_crowd` then
		incrementAmount = Config.Torches.Plain.Use.IncrementAmount
	end

	TriggerEvent("rainbow-core:DegradeWeapon", _source, usedWeaponObject, incrementAmount, breakThreshold)

	if Config.ShameyDebug then print("usedWeaponObject", usedWeaponObject) end
end)

-- Handle after when Rainbow-Core degrades a weapon
RegisterServerEvent("rainbow-core:WeaponDegraded")
AddEventHandler("rainbow-core:WeaponDegraded", function(_source, weaponId, currentDegradation)

	if Config.ShameyDebug then print("rainbow-core:WeaponDegraded - _source, weaponId, currentDegradation", _source, weaponId, currentDegradation) end

	-- Update the client/UI metadata of the weapon
	local metadata = {
		description = generateWeaponDurabilityDescription(currentDegradation)
	}
	TriggerClientEvent("vorpCoreClient:SetWeaponMetadata", _source, weaponId, metadata)
end)

RegisterServerEvent("rainbow-degradation:LogOnDiscord")
AddEventHandler("rainbow-degradation:LogOnDiscord", function(mission, deliveryTarget, completed, reasonString)
    local _source = source
	
	-- TODO
end)


-------- FUNCTIONS

function alertDegradation(_source, weaponHashKey, currentDegradation)
	local weaponName = VorpInv.GetWeaponLabelByHashKey(weaponHashKey)
	TriggerClientEvent("rainbow-core:AlertDegradation", _source, weaponName, currentDegradation)
end

function getWeaponObjectFromHash(_source, weaponHash)

	if Config.ShameyDebug then print("getWeaponObjectFromHash", _source, weaponHash) end

	return getWeaponObjectFromHashKey(_source, GetHashKey(weaponHash))
end

function getWeaponObjectFromHashKey(_source, weaponHashKey)

	if Config.ShameyDebug then print("getWeaponObjectFromHashKey", _source, weaponHashKey) end

	local userWeapons = VorpInv.getUserWeapons(_source)

	if Config.ShameyDebug then print("getWeaponObjectFromHashKey - userWeapons", userWeapons) end

	local usedWeaponObject
	for _, v in pairs(userWeapons) do
		-- print('foo', v.name, GetHashKey(v.name), weaponHashKey)
		if GetHashKey(v.name) == weaponHashKey then
			usedWeaponObject = v
		end
	end

	return usedWeaponObject
end

function getBreakThresholdFromHash(weaponHash)
	return getBreakThresholdFromHashKey(GetHashKey(weaponHash))
end

function getBreakThresholdFromHashKey(weaponHashKey)
	local breakThreshold
	if weaponHashKey == `weapon_lasso_reinforced` then
		breakThreshold = Config.Lassoes.Reinforced.BreakThreshold
	elseif weaponHashKey == `weapon_lasso` then
		breakThreshold = Config.Lassoes.Plain.BreakThreshold
	elseif weaponHashKey == `weapon_fishingrod` then
		breakThreshold = Config.FishingRods.Plain.BreakThreshold
	elseif weaponHashKey == `weapon_bow` then
		breakThreshold = Config.Bows.Plain.BreakThreshold
	elseif weaponHashKey == `weapon_bow_improved` then
		breakThreshold = Config.Bows.Improved.BreakThreshold
	elseif weaponHashKey == `weapon_melee_torch` then
		breakThreshold = Config.Torches.Plain.BreakThreshold
	else
		breakThreshold = 0.99
	end
	return breakThreshold
end


--------

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end

end)