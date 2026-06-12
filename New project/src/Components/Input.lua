return function(Require)
	local UI = Require("Utils.UI")
	local ComponentBase = Require("Components.ComponentBase")
	local ComponentUI = Require("Components.ComponentUI")
	local Input = {}
	Input.__index = Input

	function Input.new(section, options)
		options = options or {}
		local root, title, description = ComponentUI.Card(section, options, options.Description and 72 or 62)
		title.Size = UDim2.new(1, -26, 0, 22)
		local box = UI.Create("TextBox", {
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			ClearTextOnFocus = false,
			Font = Enum.Font.Gotham,
			PlaceholderText = options.Placeholder or "Enter text...",
			Position = UDim2.new(0, 12, 1, -35),
			Size = UDim2.new(1, -24, 0, 27),
			Text = "",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = root,
		}, {
			UI.Corner(6),
			UI.Stroke(),
			UI.Padding(0, 9, 0, 9),
		})
		section.Library.ThemeManager:Bind(box, {
			BackgroundColor3 = "Surface",
			PlaceholderColor3 = "MutedText",
			TextColor3 = "Text",
		})
		section.Library.ThemeManager:Bind(box:FindFirstChildOfClass("UIStroke"), { Color = "Border" })

		local base = ComponentUI.AttachBase(ComponentBase.new(section, options, root), title, description)
		local self = ComponentUI.CopyBaseMethods(setmetatable({}, Input), base)
		self.Box = box
		base.Cleanup:Add(box.FocusLost:Connect(function(enterPressed)
			if options.Numeric then
				local number = tonumber(box.Text)
				if number == nil then
					box.Text = tostring(base.Value or "")
					return
				end
				self:SetValue(number)
			elseif options.FinishedOnly == false or enterPressed or options.FinishedOnly == nil then
				self:SetValue(box.Text)
			end
		end))
		if options.FinishedOnly == false then
			base.Cleanup:Add(box:GetPropertyChangedSignal("Text"):Connect(function()
				self:SetValue(box.Text)
			end))
		end
		self:SetValue(options.Default or "", true)
		return self
	end

	function Input:SetValue(value, silent)
		if self.Options and self.Options.Numeric then
			value = tonumber(value) or 0
		else
			value = tostring(value or "")
		end
		self._base:_Commit(value, silent)
		if self.Box.Text ~= tostring(value) then
			self.Box.Text = tostring(value)
		end
		return self
	end

	return Input
end
