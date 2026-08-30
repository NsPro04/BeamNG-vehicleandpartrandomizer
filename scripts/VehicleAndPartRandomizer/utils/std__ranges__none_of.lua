local pairs = pairs

local function std__ranges__none_of(iterable, predicate)
	for k, v in pairs(iterable) do
		if predicate(k, v) then return false end
	end

	return true
end

return std__ranges__none_of