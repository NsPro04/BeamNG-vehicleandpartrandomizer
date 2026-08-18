local core_vehicle_manager, type = core_vehicle_manager, type

local fillSlots = require "scripts/VehicleAndPartRandomizer/utils/fillSlots"

local jbeamIO = require "jbeam/io"

local function getRandomParts(vehicle, empty_slot_chance)
	local vehicleID = vehicle:getID()

	local vdata = core_vehicle_manager.getVehicleData(vehicleID)

	local ioCtx = vdata.ioCtx
	if type(ioCtx) ~= "table" then return end

	local slotMap = jbeamIO.getAvailableSlotNameMap(ioCtx)
	if type(slotMap) ~= "table" then return end

	local mainPartName = (slotMap['main'] or {})[1]
	if type(mainPartName) ~= "string" then return end

	local availableParts = jbeamIO.getAvailableParts(ioCtx)
	if type(availableParts) ~= "table" then return end

	local mainPart = fillSlots({chosenPartName = mainPartName}, availableParts, ioCtx, slotMap, {[mainPartName] = 1}, empty_slot_chance, jbeamIO)

	return mainPart
end

return getRandomParts