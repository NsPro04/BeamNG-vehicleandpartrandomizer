local P, nop, im = {}, nop, ui_imgui

local im_Checkbox = require "scripts/VehicleAndPartRandomizer/utils/ui/im_Checkbox"
local im_Button   = require "scripts/VehicleAndPartRandomizer/utils/ui/im_Button"

local randomConfigurations = require "scripts/VehicleAndPartRandomizer/utils/randomConfigurations"

local checkboxes = {
	official = im.BoolPtr(true),
	mod      = im.BoolPtr(true),
	without_repeating = im.BoolPtr(false),

	each_vehicle = im.BoolPtr(false)
}

local function randomizeVehicle()
	for _, veh in ipairs(checkboxes.each_vehicle[0] and getAllVehicles() or {getPlayerVehicle(0)}) do
		local randomConfig = randomConfigurations:get(checkboxes.without_repeating[0], checkboxes.official[0], checkboxes.mod[0])
		if not randomConfig then return end

		core_vehicles.replaceVehicle(randomConfig.model_key, {
			config = randomConfig.key,
			keepOtherVehRotation = true
		}, veh)
	end
end

local function onUpdate(SCALE, dt)
	im_Button("Randomize Vehicle", randomizeVehicle)

	im_Checkbox("Allow Official Vehicles", checkboxes.official)
	nop(checkboxes.without_repeating[0] and (im.SameLine() or im.Text("("..(randomConfigurations:getSizes().available.official).."/"..(randomConfigurations:getSizes().available.official + randomConfigurations:getSizes().used.official)..")")))
	im_Checkbox("Allow Mod Vehicles",      checkboxes.mod)
	nop(checkboxes.without_repeating[0] and (im.SameLine() or im.Text("("..(randomConfigurations:getSizes().available.mod)     .."/"..(randomConfigurations:getSizes().available.mod      + randomConfigurations:getSizes().used.mod)..")")))
	im_Checkbox("Without Repeating",       checkboxes.without_repeating)

	im.Separator()

	im_Checkbox("Apply to Each Spawned Vehicle", checkboxes.each_vehicle)
end

P.onUpdate = onUpdate
return P