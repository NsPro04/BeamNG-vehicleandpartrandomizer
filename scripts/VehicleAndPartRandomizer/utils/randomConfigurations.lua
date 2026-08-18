local core_vehicles, pairs, ipairs, type, tableContainsCaseInsensitive, math = core_vehicles, pairs, ipairs, type, tableContainsCaseInsensitive, math

local function std__ranges__any_of(iterable, predicate)
	for k, v in pairs(iterable) do
		if predicate(k, v) then return true end
	end
	return false
end

local function std__ranges__none_of(iterable, predicate)
	for k, v in pairs(iterable) do
		if predicate(k, v) then return false end
	end

	return true
end

local function std__reduce(iterable, init, binary_op)
	local result = init

	for k, v in pairs(iterable) do
		result = binary_op(result, v)
	end

	return result
end

local function _sum_by_source(self, official, mod)
	return
		(official and self.official or 0) +
		(mod      and self.mod      or 0)
end

local configurations = nil

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

	for _, config in ipairs(configs) do
		if  type(config) == "table" and
			type(config.model_key) == "string" and
			type(config.key) == "string" and
			type(config.aggregates) == "table" and
			type(config.aggregates.Type) == "table" and
			type(config.aggregates.Source) == "table" and
			(not config.useSubCluster or type(config.vehicleSelectorSubCluster) == "string") and
			std__ranges__none_of(config.aggregates.Type, function(k, v)
				return tableContainsCaseInsensitive(VEHICLE_TYPE_BLACKLIST, k)
			end) then

			local source = config.aggregates.Source["Mod"] and "mod" or "official"
			local vehicleSelectorSubCluster = not config.useSubCluster and "nil" or config.vehicleSelectorSubCluster
			local models = configurations.available[source]

			for i=1, #models + 1 do
				local model = models[i]

				if model then
					if model.model_key == config.model_key then
						local subClusters = model.subClusters

						for j=1, #subClusters + 1 do
							local subCluster = subClusters[j]

							if subCluster then
								if subCluster.vehicleSelectorSubCluster == vehicleSelectorSubCluster then
									local configs = subCluster.configs

									configs[#configs + 1] = config
									break
								end
							else
								subClusters[j] = {
									vehicleSelectorSubCluster = vehicleSelectorSubCluster,
									configs = {config}
								}
							end
						end

						break
					end
				else
					models[i] = {
						model_key = config.model_key,
						subClusters = {{
							vehicleSelectorSubCluster = vehicleSelectorSubCluster,
							configs = {config}
						}}
					}
				end
			end
		end
	end
end

return {
	get = function(self, without_repeating, sub_models, official, mod)
		self.getAvailableCount.data = nil
		self.getUsedCount.data = nil

		local subClusters_tmp = {}

		for source, enable in pairs({official = official, mod = mod}) do
			local available_models = configurations.available[source]
			local used_models      = configurations.used[source]

			if not enable then goto CONTINUE end

			if #used_models ~= 0 and (not without_repeating or not sub_models) then
				for i=#used_models, 1, -1 do
					local used_model = used_models[i]
					local used_subClusters = used_model.subClusters

					for j=1, #available_models + 1 do
						local available_model = available_models[j]

						if available_model then
							if available_model.model_key == used_model.model_key then
								local available_subClusters = available_model.subClusters

								for k=#used_subClusters, 1, -1 do
									local used_subCluster = used_subClusters[k]
									used_subClusters[k] = nil

									available_subClusters[#available_subClusters + 1] = used_subCluster
								end

								break
							end
						elseif not without_repeating then
							available_models[j] = used_model

							used_model = nil
						end
					end

					if used_model == nil or #used_subClusters == 0 then
						for j=i, #used_models do
							used_models[j] = used_models[j + 1]
						end
					end
				end
			end

			for i=1, #available_models do
				local available_model = available_models[i]
				local available_subClusters = available_model.subClusters

				if sub_models then
					for j=1, #available_subClusters do
						subClusters_tmp[#subClusters_tmp + 1] = available_subClusters[j]
					end
				else
					subClusters_tmp[#subClusters_tmp + 1] = available_subClusters[math.random(#available_subClusters)]
				end
			end

			::CONTINUE::
		end

		local randomSubCluster = subClusters_tmp[math.random(#subClusters_tmp)] or {configs = {}}
		local randomConfig  = randomSubCluster.configs[math.random(#randomSubCluster.configs)]

		if without_repeating then
			for source, enable in pairs({official = official, mod = mod}) do
				local available_models = configurations.available[source]
				local used_models      = configurations.used[source]

				if not enable then goto CONTINUE end

				for i=#available_models, 1, -1 do
					local available_model = available_models[i]
					local available_subClusters = available_model.subClusters

					for j=#available_subClusters, 1, -1 do
						local available_subCluster = available_subClusters[j]

						if available_subCluster == randomSubCluster then
							if sub_models then
								for k=j, #available_subClusters do
									available_subClusters[k] = available_subClusters[k + 1]
								end

								for k=1, #used_models + 1 do
									local used_model = used_models[k]

									if used_model then
										if used_model.model_key == available_model.model_key then
											used_model.subClusters[#used_model.subClusters + 1] = available_subCluster

											break
										end
									else
										used_models[#used_models + 1] = {
											model_key = available_model.model_key,
											subClusters = {available_subCluster}
										}
									end
								end
							else
								used_models[#used_models + 1] = available_model

								available_model = nil
							end

							if available_model == nil or #available_subClusters == 0 then
								for k=i, #available_models do
									available_models[k] = available_models[k + 1]
								end
							end

							goto BREAK
						end
					end
				end

				::CONTINUE::
			end

			::BREAK::
		end

		return randomConfig
	end,

	getAvailableCount = setmetatable({
		data = nil and {
			[--[[sub_models]] true and false] = {
				official = 0,
				mod = 0
			}
		} or nil
	}, {
		__call = function(self, _)
			if not self.data then
				self.data = {
					[true] = {
						official = std__reduce(configurations.available.official, 0, function(acc, available_model)
							return acc + #available_model.subClusters
						end),
						mod = std__reduce(configurations.available.mod, 0, function(acc, available_model)
							return acc + #available_model.subClusters
						end),
						sum = _sum_by_source
					},
					[false] = {
						official = #configurations.available.official,
						mod = #configurations.available.mod,
						sum = _sum_by_source
					}
				}
			end

			return self.data
		end
	}),

	getUsedCount = setmetatable({
		data = nil and {
			[--[[sub_models]] true and false] = {
				official = 0,
				mod = 0
			}
		} or nil
	}, {
		__call = function(self, _)
			if not self.data then
				self.data = {
					[true] = {
						official = std__reduce(configurations.used.official, 0, function(acc, used_model)
							return acc + #used_model.subClusters
						end),
						mod = std__reduce(configurations.used.mod, 0, function(acc, used_model)
							return acc + #used_model.subClusters
						end),
						sum = _sum_by_source
					},
					[false] = {
						official = std__reduce(configurations.used.official, 0, function(acc, used_model)
							return acc + (std__ranges__none_of(configurations.available.official, function(_, available_model)
								return available_model.model_key == used_model.model_key
							end) and 1 or 0)
						end),
						mod = std__reduce(configurations.used.mod, 0, function(acc, used_model)
							return acc + (std__ranges__none_of(configurations.available.mod, function(_, available_model)
								return available_model.model_key == used_model.model_key
							end) and 1 or 0)
						end),
						sum = _sum_by_source
					}
				}
			end

			return self.data
		end
	}),

	isInitialized = function(self) return not not configurations end,
	init = function(self) init() end
}