return function(Require)
	local UI = Require("Utils.UI")
	local ComponentBase = Require("Components.ComponentBase")
	local Divider = {}
	Divider.__index = Divider

	function Divider.new(section, options)
		if type(options) == "string" then
			options = { Title = options }
		end
		options = options or {}
		local root = UI.Create("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = section:_NextOrder(),
			Size = UDim2.new(1, 0, 0, options.Title and 24 or 12),
			Parent = section.Content,
		})
		local line = UI.Create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 1),
			BorderSizePixel = 0,
			Parent = root,
		})
		section.Library.ThemeManager:Bind(line, { BackgroundColor3 = "Border" })
		local label
		if options.Title then
			label = UI.Text(options.Title, 11, Enum.Font.GothamMedium)
			label.AnchorPoint = Vector2.new(0.5, 0.5)
			label.AutomaticSize = Enum.AutomaticSize.X
			label.BackgroundTransparency = 0
			label.Position = UDim2.fromScale(0.5, 0.5)
			label.Size = UDim2.fromOffset(0, 18)
			label.Parent = root
			UI.Padding(0, 8, 0, 8).Parent = label
			section.Library.ThemeManager:Bind(label, {
				BackgroundColor3 = "Background",
				TextColor3 = "MutedText",
			})
		end
		local base = ComponentBase.new(section, options, root)
		base.TitleLabel = label
		base.Value = options.Title or ""
		local self = setmetatable({
			_base = base,
			Root = root,
			Changed = base.Changed,
		}, Divider)
		for _, method in ipairs({ "GetValue", "SetVisible", "Hide", "Show", "Destroy" }) do
			self[method] = function(_, ...)
				return base[method](base, ...)
			end
		end
		return self
	end

	function Divider:SetTitle(title)
		return self:SetValue(title)
	end

	function Divider:SetDescription(description)
		self.Description = tostring(description or "")
		return self
	end

	function Divider:SetValue(value, silent)
		value = tostring(value or "")
		self._base:_Commit(value, silent)
		if self._base.TitleLabel then
			self._base.TitleLabel.Text = value
		end
		return self
	end

	return Divider
end
