return function(Require)
	local UI = Require("Utils.UI")
	local ComponentBase = Require("Components.ComponentBase")
	local ComponentUI = Require("Components.ComponentUI")
	local Dropdown = {}
	Dropdown.__index = Dropdown

	local function contains(list, value)
		return table.find(list, value) ~= nil
	end

	function Dropdown.new(section, options)
		options = options or {}
		options.Values = options.Values or options.Options or {}
		local root, title, description = ComponentUI.Card(section, options, options.Description and 62 or 50)
		root.ClipsDescendants = true
		title.Size = UDim2.new(0.42, -13, title.Size.Y.Scale, title.Size.Y.Offset)

		local selection = UI.Create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			AutoButtonColor = false,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Position = UDim2.new(1, -10, 0, options.Description and 25 or 25),
			Size = UDim2.new(0.54, 0, 0, 30),
			Text = "Select",
			TextSize = 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = root,
		}, {
			UI.Corner(7),
			UI.Stroke(),
		})
		section.Library.ThemeManager:Bind(selection, {
			BackgroundColor3 = "Surface",
			TextColor3 = "MutedText",
		})
		section.Library.ThemeManager:Bind(selection:FindFirstChildOfClass("UIStroke"), { Color = "Border" })

		local list = UI.Create("Frame", {
			Position = UDim2.new(0, 10, 0, options.Description and 62 or 50),
			Size = UDim2.new(1, -20, 0, 0),
			BackgroundTransparency = 1,
			Parent = root,
		}, { UI.List(4) })

		local base = ComponentUI.AttachBase(ComponentBase.new(section, options, root), title, description)
		local self = ComponentUI.CopyBaseMethods(setmetatable({}, Dropdown), base)
		self.Selection = selection
		self.List = list
		self.Values = table.clone(options.Values)
		self.Multi = options.Multi == true
		self.Open = false
		self.OptionButtons = {}

		base.Cleanup:Add(selection.MouseButton1Click:Connect(function()
			self:SetOpen(not self.Open)
		end))
		self:_Rebuild()
		self:SetValue(options.Default or (self.Multi and {} or nil), true)
		return self
	end

	function Dropdown:_DisplayValue()
		local value = self._base.Value
		if self.Multi then
			if #value == 0 then
				return "Select"
			end
			return table.concat(value, ", ")
		end
		return value == nil and "Select" or tostring(value)
	end

	function Dropdown:_Rebuild()
		for _, button in ipairs(self.OptionButtons) do
			button:Destroy()
		end
		table.clear(self.OptionButtons)
		for _, option in ipairs(self.Values) do
			local button = UI.Create("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Font = Enum.Font.Gotham,
				Size = UDim2.new(1, 0, 0, 30),
				Text = tostring(option),
				TextSize = 12,
				Parent = self.List,
			}, { UI.Corner(6) })
			self._base.Library.ThemeManager:Bind(button, {
				BackgroundColor3 = "Surface",
				TextColor3 = "Text",
			})
			self._base.Cleanup:Add(button.MouseButton1Click:Connect(function()
				if self.Multi then
					local values = table.clone(self._base.Value or {})
					local index = table.find(values, option)
					if index then
						table.remove(values, index)
					else
						table.insert(values, option)
					end
					self:SetValue(values)
				else
					self:SetValue(option)
					self:SetOpen(false)
				end
			end))
			table.insert(self.OptionButtons, button)
		end
		if self.Open then
			self:SetOpen(true)
		end
	end

	function Dropdown:SetValues(values, preserveValue)
		self.Values = table.clone(values or {})
		self:_Rebuild()
		if not preserveValue then
			self:SetValue(self.Multi and {} or nil, true)
		end
		return self
	end

	function Dropdown:SetOpen(open)
		self.Open = open == true
		local baseHeight = self.Options.Description and 62 or 50
		local listHeight = math.min(#self.Values, self.Options.MaxVisible or 6) * 34
		self._base.Library.AnimationManager:Play(self.Root, {
			Size = UDim2.new(1, 0, 0, baseHeight + (self.Open and listHeight + 8 or 0)),
		}, 0.2)
		return self
	end

	function Dropdown:SetValue(value, silent)
		if self.Multi then
			local normalized = {}
			for _, option in ipairs(type(value) == "table" and value or {}) do
				if contains(self.Values, option) and not contains(normalized, option) then
					table.insert(normalized, option)
				end
			end
			value = normalized
		elseif value ~= nil and not contains(self.Values, value) then
			value = nil
		end
		self._base:_Commit(value, silent)
		self.Selection.Text = self:_DisplayValue()
		for index, option in ipairs(self.Values) do
			local button = self.OptionButtons[index]
			local selected = self.Multi and contains(value, option) or value == option
			if button then
				button.BackgroundColor3 = selected
					and self._base.Library.ThemeManager.Current.Accent
					or self._base.Library.ThemeManager.Current.Surface
			end
		end
		return self
	end

	return Dropdown
end
