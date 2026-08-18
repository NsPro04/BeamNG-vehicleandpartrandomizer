local core_vehicle_manager, type = core_vehicle_manager, type

local function getRandomParts(vehicle, jbeamIO, fillSlots)
	local vehicleID = vehicle:getID()

	local vdata = core_vehicle_manager.getVehicleData(vehicleID)
	if type(vdata) ~= "table" then return end

	local ioCtx = vdata.ioCtx
	if type(ioCtx) ~= "table" then return end

	local availableParts = jbeamIO.getAvailableParts(ioCtx)
	if type(availableParts) ~= "table" then return end

	local mainPartName = jbeamIO.getMainPartName(ioCtx)
	if type(mainPartName) ~= "string" then return end

	local mainPart = fillSlots({chosenPartName = mainPartName}, availableParts, ioCtx, jbeamIO)

	return mainPart
end

return getRandomParts