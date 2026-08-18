return {
	getPlayer = function(self) return self._getPlayerVehicle(0) end,
	getAll    = function(self) return self._getAllVehicles() end,

	_getPlayerVehicle = getPlayerVehicle,
	_getAllVehicles = getAllVehicles
}