local core_vehicle_manager, unpack, pcall, type, pairs, math, isnaninf, clamp, next = core_vehicle_manager, unpack, pcall, type, pairs, math, isnaninf, clamp, next

local jbeamLoader = require "jbeam/loader"

local function getRandomVariables(vehicle, config)
	local vehicleID = vehicle:getID()
	local currentVehicleBundle = core_vehicle_manager.getVehicleData(vehicleID)

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

	for name, data in pairs(vehicleBundle.vdata.variables) do
		if data.type ~= "range" then goto CONTINUE end

		local min = math.min(data.max, data.min)
		local max = math.max(data.max, data.min)
		local minDis = math.min(data.maxDis, data.minDis)
		local maxDis = math.max(data.maxDis, data.minDis)
		local dist1 = max - min
		local dist2 = maxDis - minDis
		local stepDis = math.abs(data.stepDis)
		local step = dist2 == 0 and 0 or stepDis * dist1 / dist2
		local stepCount = (step == 0 or dist1 == 0) and 0 or math.ceil(dist1 / math.min(step, dist1))
		if not isnaninf(dist1 + dist2 + stepDis + step + stepCount) then
			variables[name] = clamp(math.random(0, stepCount) * step + min, min, max)
		end

		::CONTINUE::
	end

	return next(variables) ~= nil and variables or nil
end

return getRandomVariables