local P, nop, im, ipairs, core_vehicle_manager, next, type, tableMerge, serialize, clamp = {}, nop, ui_imgui, ipairs, core_vehicle_manager, next, type, tableMerge, serialize, clamp

local im_Button   = require "scripts/VehicleAndPartRandomizer/utils/ui/im_Button"
local im_Checkbox = require "scripts/VehicleAndPartRandomizer/utils/ui/im_Checkbox"

local vehicles           = require "scripts/VehicleAndPartRandomizer/utils/vehicles"
local getRandomParts     = require "scripts/VehicleAndPartRandomizer/utils/getRandomParts"
local getRandomVariables = require "scripts/VehicleAndPartRandomizer/utils/getRandomVariables"
local sanitizePartsTree  = require "scripts/VehicleAndPartRandomizer/utils/sanitizePartsTree"
local getRandomPaint     = require "scripts/VehicleAndPartRandomizer/utils/getRandomPaint"

local checkboxes = {
	paints  = im.BoolPtr(true),
	parts   = im.BoolPtr(true),
	tunings = im.BoolPtr(false),

	each_vehicle = im.BoolPtr(false)
}

local inputs = {
	empty_slot_chance = im.IntPtr(0)
}

local function randomize()
	for _, veh in ipairs(checkboxes.each_vehicle[0] and vehicles:getAll() or {vehicles:getPlayer()}) do
		local config = {}

		if checkboxes.parts[0] then
			local randomParts = getRandomParts(veh, inputs.empty_slot_chance[0])
			if not randomParts then goto CONTINUE end

			config.mainPartName = randomParts.chosenPartName
			config.partsTree = randomParts
		end

		if checkboxes.tunings[0] then
			local randomVariables = getRandomVariables(veh, config.mainPartName ~= nil and config or nil)
			if randomVariables then
				config.vars = randomVariables

				if config.mainPartName == nil then
					local vehID = veh:getID()
					local vehConfig = core_vehicle_manager.getVehicleData(vehID).config

					config.mainPartName = vehConfig.mainPartName
					config.partsTree = sanitizePartsTree(vehConfig.partsTree)
				end
			end
		end

		if checkboxes.paints[0] then
			config.paints = {getRandomPaint(), getRandomPaint(), getRandomPaint()}
		end

		if next(config) == nil then goto CONTINUE end

		if next(config) == "paints" and next(config, "paints") == nil then
			local vehID = veh:getID()
			local vehConfig = core_vehicle_manager.getVehicleData(vehID).config

			if type(vehConfig.paints) ~= "table" then vehConfig.paints = {} end

			tableMerge(vehConfig.paints, config.paints)

			for i=1, #config.paints do
				core_vehicle_manager.liveUpdateVehicleColors(vehID, veh, i, config.paints[i])
			end

			veh:setField('partConfig', '', serialize(vehConfig))
			goto CONTINUE
		end

		if veh ~= vehicles:getPlayer() then
			-- lua/ge/extensions/core/vehicle/manager.lua:173 (spawnCCallback) BeamNG.drive 0.39.4.0
			--[[
				if vehicleObj.autoEnterVehicle ~= "false" then -- and not reloading
					-- TODO: FIXME: do not call enterVehicle if the player is already in the vehicle or we reload: "and not reloading"
					local player = vehicleObj.autoEnterVehiclePlayer ~= "" and tonumber(vehicleObj.autoEnterVehiclePlayer) or 0
					be:enterVehicle(player, vehicleObj) -- will trigger onVehicleSwitched
				end
			]]
			veh:setDynDataFieldbyName("autoEnterVehicle", 0, "false")
		end

		veh:respawn(serialize(config))

		::CONTINUE::
	end
end

local function onUpdate(SCALE, dt)
	im_Button("Randomize!", randomize)

	im_Checkbox("Paints",  checkboxes.paints)
	im_Checkbox("Parts",   checkboxes.parts)
	im_Checkbox("Tunings", checkboxes.tunings)

	im.Separator()

	im_Checkbox("Apply to Each Spawned Vehicle", checkboxes.each_vehicle)
	nop(checkboxes.each_vehicle[0] and (im.SameLine() or
		im.Text(("(%d)"):format(#vehicles:getAll()))
	))

	im.SetNextItemWidth(im.GetContentRegionAvailWidth() / 3)
	im.InputInt("Empty Slot Chance (%)", inputs.empty_slot_chance, 1, 1)
	inputs.empty_slot_chance[0] = clamp(inputs.empty_slot_chance[0], 0, 100)
end

P.onUpdate = onUpdate
return P