local pairs, table, math, next = pairs, table, math, next

local MAX_PART_NESTING = 5

local function fillSlots(currentPart, availableParts, ioCtx, slotMap, branch, empty_slot_chance, jbeamIO)
	local children = {}

	local partData = availableParts[currentPart.chosenPartName]

	for slotName, slotData in pairs(partData.slotInfoUi) do
		local suitablePartNames = jbeamIO.getCompatiblePartNamesForSlot(ioCtx, slotData, slotMap)

		while (#suitablePartNames ~= 0) do
			local randomPart = table.remove(suitablePartNames, math.random(#suitablePartNames))

			if not availableParts[randomPart].isAuxiliary or (#suitablePartNames == 0 and slotData.coreSlot) then
				if not slotData.coreSlot then
					-- Right?
					if (branch[randomPart] and branch[randomPart] >= MAX_PART_NESTING) or (math.random(1, 100) <= empty_slot_chance) then
						children[slotName] = {chosenPartName = ""}
						break
					end
				end

				branch[randomPart] = (branch[randomPart] or 0) + 1
				children[slotName] = fillSlots({chosenPartName = randomPart}, availableParts, ioCtx, slotMap, branch, empty_slot_chance, jbeamIO)
				branch[randomPart] = branch[randomPart] - 1

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