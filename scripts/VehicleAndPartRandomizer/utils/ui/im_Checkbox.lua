local im = ui_imgui

local function im_Checkbox(string_label, bool_v)
	im.Checkbox("##" .. string_label, bool_v)
	if im.IsItemHovered() then
		im.SetMouseCursor(im.MouseCursor_Hand)
	end
	im.SameLine()
	im.Text(string_label)
end

return im_Checkbox