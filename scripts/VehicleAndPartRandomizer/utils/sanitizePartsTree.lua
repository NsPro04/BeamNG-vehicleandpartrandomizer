local pairs, next = pairs, next

local function sanitizePartsTree(partsTree)
	local sanitized = {chosenPartName = partsTree.chosenPartName}

	local children = {}

	for slotName, slotData in pairs(partsTree.children or {}) do
		children[slotName] = sanitizePartsTree(slotData)
	end

	if next(children) then
		sanitized.children = children
	end

	return sanitized
end

return sanitizePartsTree