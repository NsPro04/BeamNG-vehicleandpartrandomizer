local M, nop, im = {}, nop, ui_imgui

local windowOpen = im.BoolPtr(false)

local windowSize = {
	width =  ((((GFXDevice or {}).getDesktopMode or nop)() or {}).width  or 2560)/16*2,
	height = ((((GFXDevice or {}).getDesktopMode or nop)() or {}).height or 1440)/9*1.2
}

local pages = {
	require("scripts/VehicleAndPartRandomizer/pages/1"),
	require("scripts/VehicleAndPartRandomizer/pages/2")
}

local currentPage = {
	value = 1,
	min = 1,
	max = #pages,

	inc = function(self) return self:set(self:get() + 1) end,
	dec = function(self) return self:set(self:get() - 1) end,
	get = function(self) return self.value end,
	set = function(self, new_value)
		self.value = clamp(new_value, self.min, self.max)
		return self:get()
	end
}

local function onUpdate(dt)
	if not windowOpen[0] then return end

	im.SetNextWindowSize(im.ImVec2(windowSize.width, windowSize.height), im.Cond_FirstUseEver)
	im.Begin("Vehicle And Part Randomizer by _N_S_ v2", windowOpen)
		local SCALE = im.GetWindowWidth() / 320
		im.SetWindowFontScale(SCALE)

		do
			local pos = im.GetCursorPosX()
			local buttonSize = im.GetFrameHeight()
			local windowWidth = im.GetWindowWidth()

			im.ArrowButton("Previous page", im.Dir_Left)
			nop(im.IsItemHovered() and im.SetMouseCursor(im.MouseCursor_Hand))
			nop(im.IsItemClicked() and currentPage:dec())
			im.SameLine()

			local availWidth = im.GetContentRegionAvailWidth()
			local text = currentPage:get() .. "/" .. (#pages)
			local textSize = im.CalcTextSize(text).x
			local indent = (windowWidth - pos * 2 - buttonSize * 2 - textSize) / 2

			im.SetCursorPosX(pos + buttonSize + indent)
			im.Text(text)
			im.SameLine()

			im.SetCursorPosX(windowWidth - pos - buttonSize)
			im.ArrowButton("Next page", im.Dir_Right)
			nop(im.IsItemHovered() and im.SetMouseCursor(im.MouseCursor_Hand))
			nop(im.IsItemClicked() and currentPage:inc())
		end

		pages[currentPage:get()].onUpdate(SCALE, dt)
	im.End()
end

local function toggleUI()
	windowOpen[0] = not windowOpen[0]
end

M.onUpdate = onUpdate
M.toggleUI = toggleUI
return M