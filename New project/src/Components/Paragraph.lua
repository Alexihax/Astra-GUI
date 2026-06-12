return function(Require)
	local UI = Require("Utils.UI")
	local ComponentBase = Require("Components.ComponentBase")
	local ComponentUI = Require("Components.ComponentUI")
	local Paragraph = {}
	Paragraph.__index = Paragraph

	function Paragraph.new(section, options)
		options = options or {}
		options.Description = options.Description or options.Content or ""
		local root, title, description = ComponentUI.Card(section, options, options.Height or 76)
		title.Size = UDim2.new(1, -26, 0, 24)
		if description then
			description.Position = UDim2.fromOffset(13, 29)
			description.Size = UDim2.new(1, -26, 1, -36)
			description.TextYAlignment = Enum.TextYAlignment.Top
		end
		local base = ComponentUI.AttachBase(ComponentBase.new(section, options, root), title, description)
		local self = ComponentUI.CopyBaseMethods(setmetatable({}, Paragraph), base)
		self:SetValue(options.Content or options.Description or "", true)
		return self
	end

	function Paragraph:SetValue(value, silent)
		value = tostring(value or "")
		self._base:_Commit(value, silent)
		self._base:SetDescription(value)
		return self
	end

	return Paragraph
end
