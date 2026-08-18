local core_vehicles, type, pairs, tableContainsCaseInsensitive, math = core_vehicles, type, pairs, tableContainsCaseInsensitive, math

local configurations = nil
local sizes = nil

local function init()
	configurations = {
		available = {
			official = {},
			mod = {}
		},
		used = {
			official = {},
			mod = {}
		}
	}

	local VEHICLE_TYPE_BLACKLIST = {
		"Debug",
		"Prop",
		"PropParked",
		"PropTraffic",
		"Traffic",
		"Trailer"
	}

	local configs = core_vehicles.getConfigList(true).configs

	for config_index=1, #configs do
		local config = configs[config_index]

		if  type(config) == "table" and
			type(config.model_key) == "string" and
			type(config.key) == "string" and
			type(config.aggregates) == "table" and
			type(config.aggregates.Type) == "table" and
			type(config.aggregates.Source) == "table" and
			(function()
				for configType in pairs(config.aggregates.Type) do
					if tableContainsCaseInsensitive(VEHICLE_TYPE_BLACKLIST, configType) then
						return false
					end
				end
				return true
			end)() then

				local source = config.aggregates.Source["Mod"] and "mod" or "official"
				local configsList = configurations.available[source]

				for i=1, #configsList + 1 do
					if configsList[i] then
						if configsList[i][1].model_key == config.model_key then
							configsList[i][#configsList[i] + 1] = config
							break
						end
					else
						configsList[i] = {config}
					end
				end
		end
	end
end

return {
	get = function(self, without_repeating, official, mod)
		if not configurations then init() end
		sizes = nil

		local configsList_tmp = {}

		for source, enable in pairs({official = official, mod = mod}) do
			if enable then
				if not without_repeating and #configurations.used[source] ~= 0 then
					for i=#configurations.used[source], 1, -1 do
						configurations.available[source][#configurations.available[source] + 1] = configurations.used[source][i]
						configurations.used[source][i] = nil
					end
				end

				for i=1, #configurations.available[source] do
					configsList_tmp[#configsList_tmp + 1] = configurations.available[source][i]
				end
			end
		end

		local randomConfigs = configsList_tmp[math.random(#configsList_tmp)] or {}
		local randomConfig  = randomConfigs[  math.random(#randomConfigs)]

		if without_repeating then
			for source, configsList in pairs(configurations.available) do
				for i=1, #configsList do
					if randomConfigs == configsList[i] then
						configurations.used[source][#configurations.used[source] + 1] = configsList[i]
						for j=i, #configsList do
							configsList[j] = configsList[j+1]
						end
						goto BREAK
					end
				end
			end

			::BREAK::
		end

		return randomConfig
	end,

	getSizes = function(self)
		if not sizes then
			sizes = {
				available = {
					official = #(((configurations or {}).available or {}).official or {}),
					mod      = #(((configurations or {}).available or {}).mod      or {}),
				},
				used = {
					official = #(((configurations or {}).used or {}).official or {}),
					mod      = #(((configurations or {}).used or {}).mod      or {}),
				}
			}
		end

		return sizes
	end
}