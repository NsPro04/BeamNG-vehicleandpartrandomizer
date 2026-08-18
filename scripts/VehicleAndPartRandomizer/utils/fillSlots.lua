local pairs, table, math, next = pairs, table, math, next

local function fillSlots(currentPart, availableParts, ioCtx, jbeamIO)
	local children = {}

	local partData = availableParts[currentPart.chosenPartName]

	for slotName, slotData in pairs(partData.slotInfoUi) do
		local suitablePartNames = jbeamIO.getCompatiblePartNamesForSlot(ioCtx, slotData)

		while (#suitablePartNames ~= 0) do
			local randomPart = table.remove(suitablePartNames, math.random(#suitablePartNames))

			if not availableParts[randomPart].isAuxiliary or (#suitablePartNames == 0 and slotData.coreSlot) then
				children[slotName] = fillSlots({chosenPartName = randomPart}, availableParts, ioCtx, jbeamIO)
				break
			end
		end
	end

	if next(children) then
		currentPart.children = children
	end

	return currentPart
end

return fillSlots