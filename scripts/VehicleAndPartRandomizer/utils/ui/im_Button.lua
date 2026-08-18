local im = ui_imgui

local function im_Button(string_label, func)
	if im.Button(string_label, im.ImVec2(im.GetContentRegionAvailWidth(), 0)) then
		func()
	end
	if im.IsItemHovered() then
		im.SetMouseCursor(im.MouseCursor_Hand)
	end
end

return im_Button