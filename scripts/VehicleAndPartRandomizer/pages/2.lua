local P, nop, im = {}, nop, ui_imgui

local jbeamIO     = require "jbeam/io"
local jbeamLoader = require "jbeam/loader"

local im_Checkbox = require "scripts/VehicleAndPartRandomizer/utils/ui/im_Checkbox"
local im_Button   = require "scripts/VehicleAndPartRandomizer/utils/ui/im_Button"

local getRandomPaint      = require "scripts/VehicleAndPartRandomizer/utils/getRandomPaint"
local getRandomParts      = require "scripts/VehicleAndPartRandomizer/utils/getRandomParts"
local fillSlots           = require "scripts/VehicleAndPartRandomizer/utils/fillSlots"
local getRandomVariables  = require "scripts/VehicleAndPartRandomizer/utils/getRandomVariables"
local sanitizePartsTree   = require "scripts/VehicleAndPartRandomizer/utils/sanitizePartsTree"

local checkboxes = {
	paints  = im.BoolPtr(true),
	parts   = im.BoolPtr(true),
	tunings = im.BoolPtr(false),

	each_vehicle = im.BoolPtr(false)
}

local function randomize()
	for _, veh in ipairs(checkboxes.each_vehicle[0] and getAllVehicles() or {getPlayerVehicle(0)}) do
		local config = {}

		if checkboxes.parts[0] then
			local randomParts = getRandomParts(veh, jbeamIO, fillSlots)
			if not randomParts then goto CONTINUE end

			config.mainPartName = randomParts.chosenPartName
			config.partsTree = randomParts
		end

		if checkboxes.tunings[0] then
			local randomVariables = getRandomVariables(veh, config.mainPartName ~= nil and config or nil, jbeamLoader)
			if randomVariables then config.vars = randomVariables end
		end

		if checkboxes.paints[0] then
			config.paints = {getRandomPaint(), getRandomPaint(), getRandomPaint()}
		end

		if next(config) == nil then goto CONTINUE end

		if next(config) == "paints" and next(config, "paints") == nil then
			core_vehicle_partmgmt.setConfigPaints(config.paints, false)
			goto CONTINUE
		end

		if config.mainPartName == nil then
			local currentVehicleBundle = core_vehicle_manager.getVehicleData(veh:getID())
			config.mainPartName = currentVehicleBundle.config.mainPartName
			config.partsTree = sanitizePartsTree(currentVehicleBundle.config.partsTree)
		end

		--[[if config.paints == nil then
			local currentVehicleBundle = core_vehicle_manager.getVehicleData(veh:getID())
			config.paints = currentVehicleBundle.config.paints
		end]]

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
end

P.onUpdate = onUpdate
return P