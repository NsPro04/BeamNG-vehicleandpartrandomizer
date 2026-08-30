local pairs = pairs

local function std__ranges__any_of(iterable, predicate)
	for k, v in pairs(iterable) do
		if predicate(k, v) then return true end
	end

	return false
end

return std__ranges__any_of