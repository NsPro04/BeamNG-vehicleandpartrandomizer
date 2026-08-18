local core_vehicle_manager, type, unpack, pcall, pairs, math, isnaninf, clamp, next = core_vehicle_manager, type, unpack, pcall, pairs, math, isnaninf, clamp, next

local function getRandomVariables(vehicle, config, jbeamLoader)
	local vehicleID = vehicle:getID()

	local currentVehicleBundle = core_vehicle_manager.getVehicleData(vehicleID)
	if type(currentVehicleBundle) ~= "table" then return end

	local ok, vehicleBundle = unpack(config ~= nil and {
		pcall(function()
			return jbeamLoader.loadVehicleStage1(-1, currentVehicleBundle.vehicleDirectory, config)
		end)
	} or {
		true,
		currentVehicleBundle
	})

	if not ok or type(vehicleBundle) ~= "table" or type(vehicleBundle.vdata.variables) ~= "table" then return end

	local variables = {}

	for variablesName, variablesData in pairs(vehicleBundle.vdata.variables) do
		local min = math.min(variablesData.max, variablesData.min)
		local max = math.max(variablesData.max, variablesData.min)
		local minDis = math.min(variablesData.maxDis, variablesData.minDis)
		local maxDis = math.max(variablesData.maxDis, variablesData.minDis)
		local dist1 = max - min
		local dist2 = maxDis - minDis
		local stepDis = math.abs(variablesData.stepDis)
		local step = dist2 == 0 and 0 or stepDis * dist1 / dist2
		local stepCount = (step == 0 or dist1 == 0) and 0 or math.ceil(dist1 / math.min(step, dist1))
		if not isnaninf(dist1 + dist2 + stepDis + step + stepCount) then
			variables[variablesName] = clamp(math.random(0, stepCount) * step + min, min, max)
		end
	end

	return next(variables) ~= nil and variables or nil
end

return getRandomVariables