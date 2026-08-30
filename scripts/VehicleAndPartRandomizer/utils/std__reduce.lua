local pairs = pairs

local function std__reduce(iterable, init, binary_op)
	local result = init

	for k, v in pairs(iterable) do
		result = binary_op(result, v)
	end

	return result
end

return std__reduce