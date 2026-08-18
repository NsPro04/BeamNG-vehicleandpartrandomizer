local P, nop, im, ipairs, core_vehicles = {}, nop, ui_imgui, ipairs, core_vehicles

local im_Button   = require "scripts/VehicleAndPartRandomizer/utils/ui/im_Button"
local im_Checkbox = require "scripts/VehicleAndPartRandomizer/utils/ui/im_Checkbox"

local randomConfigurations = require "scripts/VehicleAndPartRandomizer/utils/randomConfigurations"
local vehicles             = require "scripts/VehicleAndPartRandomizer/utils/vehicles"

local checkboxes = {
	official = im.BoolPtr(true),
	mod      = im.BoolPtr(true),
	without_repeating = im.BoolPtr(false),

	each_vehicle = im.BoolPtr(false),
	sub_models = im.BoolPtr(true)
}

local function randomizeVehicle()
	for _, veh in ipairs(checkboxes.each_vehicle[0] and vehicles:getAll() or {vehicles:getPlayer()}) do
		local randomConfig = randomConfigurations:get(checkboxes.without_repeating[0], checkboxes.sub_models[0], checkboxes.official[0], checkboxes.mod[0])
		if not randomConfig then return end

		core_vehicles.replaceVehicle(randomConfig.model_key, {
			config = randomConfig.key,
			keepOtherVehRotation = true
		}, veh)
	end
end

local function onUpdate(SCALE, dt)
	local RC_initialized = randomConfigurations:isInitialized()
	local available_tbl = RC_initialized and randomConfigurations:getAvailableCount()[checkboxes.sub_models[0]]
	local used_tbl      = RC_initialized and randomConfigurations:getUsedCount()[checkboxes.sub_models[0]]

	if RC_initialized then
		local text_color = im.GetStyleColorVec4(im.Col_Text)

		repeat
			if not checkboxes.without_repeating[0] or #vehicles:getAll() == 0 then break end

			local available = available_tbl:sum(checkboxes.official[0], checkboxes.mod[0])
			local used      =      used_tbl:sum(checkboxes.official[0], checkboxes.mod[0])

			if available == 0 and used == 0 then break end

			if available == 0 then
				text_color = im.ImVec4(1, 0, 0, 1)
			elseif not checkboxes.each_vehicle[0] then
				break
			elseif available < #vehicles:getAll() then
				text_color = im.ImVec4(1, 0.5, 0, 1)
			end
		until true

		im.PushStyleColor2(im.Col_Text, text_color)
			im_Button("Randomize Vehicle", randomizeVehicle)
		im.PopStyleColor()
	else
		im_Button("Initialize", function() randomConfigurations:init() end)
	end

	im_Checkbox("Allow Official Vehicles", checkboxes.official)
	if checkboxes.official[0] and RC_initialized then
		im.SameLine()
		im.PushStyleVar2(im.StyleVar_ItemSpacing, im.ImVec2(0, 0))
		im.Text("(")
			if checkboxes.without_repeating[0] then
				im.SameLine()

				if available_tbl.official == 0 and used_tbl.official ~= 0 then
					im.TextColored(im.ImVec4(1, 0, 0, 1), ("%d"):format(available_tbl.official))
				else
					im.Text(("%d"):format(available_tbl.official))
				end

				im.SameLine()
				im.Text("/")
			end

			im.SameLine()
			im.Text(("%d"):format(available_tbl.official + used_tbl.official))
			im.SameLine()
		im.PopStyleVar()
		im.Text(")")
	end

	im_Checkbox("Allow Mod Vehicles", checkboxes.mod)
	if checkboxes.mod[0] and RC_initialized then
		im.SameLine()
		im.PushStyleVar2(im.StyleVar_ItemSpacing, im.ImVec2(0, 0))
		im.Text("(")
			if checkboxes.without_repeating[0] then
				im.SameLine()

				if available_tbl.mod == 0 and used_tbl.mod ~= 0 then
					im.TextColored(im.ImVec4(1, 0, 0, 1), ("%d"):format(available_tbl.mod))
				else
					im.Text(("%d"):format(available_tbl.mod))
				end

				im.SameLine()
				im.Text("/")
			end

			im.SameLine()
			im.Text(("%d"):format(available_tbl.mod + used_tbl.mod))
			im.SameLine()
		im.PopStyleVar()
		im.Text(")")
	end

	im_Checkbox("Without Repeating", checkboxes.without_repeating)

	im.Separator()

	im_Checkbox("Apply to Each Spawned Vehicle", checkboxes.each_vehicle)
	nop(checkboxes.each_vehicle[0] and (im.SameLine() or
		im.Text(("(%d)"):format(#vehicles:getAll()))
	))

	do
		local _sub_models = checkboxes.sub_models[0]

		im_Checkbox("Split Sub-Models", checkboxes.sub_models)
		if _sub_models and RC_initialized then
			im.SameLine()
			im.Text(("(+%d)"):format(
				(                                  available_tbl:sum(checkboxes.official[0], checkboxes.mod[0]) +                                   used_tbl:sum(checkboxes.official[0], checkboxes.mod[0])) -
				(randomConfigurations:getAvailableCount()[false]:sum(checkboxes.official[0], checkboxes.mod[0]) + randomConfigurations:getUsedCount()[false]:sum(checkboxes.official[0], checkboxes.mod[0]))
			))
		end
	end
end

P.onUpdate = onUpdate
return P