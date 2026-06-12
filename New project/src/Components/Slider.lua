return function(Require)
	local UI = Require("Utils.UI")
	local ComponentBase = Require("Components.ComponentBase")
	local ComponentUI = Require("Components.ComponentUI")
	local UserInputService = game:GetService("UserInputService")
	local Slider = {}
	Slider.__index = Slider

	function Slider.new(section, options)
		options = options or {}
		options.Min = tonumber(options.Min) or 0
		options.Max = tonumber(options.Max) or 100
		options.Step = math.abs(tonumber(options.Step) or 1)
		if options.Max < options.Min then
			options.Min, options.Max = options.Max, options.Min
		end
		local root, title, description = ComponentUI.Card(section, options, options.Description and 78 or 68)
		title.Size = UDim2.new(1, -92, 0, 24)

		local valueLabel = UI.Text("", 13, Enum.Font.GothamMedium)
		valueLabel.AnchorPoint = Vector2.new(1, 0)
		valueLabel.Position = UDim2.new(1, -13, 0, 8)
		valueLabel.Size = UDim2.fromOffset(68, 20)
		valueLabel.TextXAlignment = Enum.TextXAlignment.Right
		valueLabel.Parent = root
		section.Library.ThemeManager:Bind(valueLabel, { TextColor3 = "AccentAlt" })

		local track = UI.Create("Frame", {
			Position = UDim2.new(0, 13, 1, -21),
			Size = UDim2.new(1, -26, 0, 7),
			BorderSizePixel = 0,
			Parent = root,
		}, { UI.Corner(4) })
		section.Library.ThemeManager:Bind(track, { BackgroundColor3 = "SurfaceHover" })
		local fill = UI.Create("Frame", {
			Size = UDim2.fromScale(0, 1),
			BorderSizePixel = 0,
			Parent = track,
		}, { UI.Corner(4) })
		section.Library.ThemeManager:Bind(fill, { BackgroundColor3 = "Accent" })
		local knob = UI.Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(15, 15),
			BorderSizePixel = 0,
			Parent = track,
		}, {
			UI.Corner(8),
			UI.Stroke(),
		})
		section.Library.ThemeManager:Bind(knob, { BackgroundColor3 = "Text" })
		section.Library.ThemeManager:Bind(knob:FindFirstChildOfClass("UIStroke"), { Color = "Accent" })

		local hitbox = UI.Button("")
		hitbox.Position = UDim2.fromOffset(0, -8)
		hitbox.Size = UDim2.new(1, 0, 1, 16)
		hitbox.Parent = track

		local base = ComponentUI.AttachBase(ComponentBase.new(section, options, root), title, description)
		local self = ComponentUI.CopyBaseMethods(setmetatable({}, Slider), base)
		self.Track = track
		self.Fill = fill
		self.Knob = knob
		self.ValueLabel = valueLabel
		self.Min = options.Min
		self.Max = options.Max
		self.Step = options.Step

		local dragging = false
		local function update(input)
			local width = math.max(track.AbsoluteSize.X, 1)
			local alpha = math.clamp((input.Position.X - track.AbsolutePosition.X) / width, 0, 1)
			self:SetValue(self.Min + (self.Max - self.Min) * alpha)
		end
		base.Cleanup:Add(hitbox.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				update(input)
			end
		end))
		base.Cleanup:Add(UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				update(input)
			end
		end))
		base.Cleanup:Add(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end))
		self:SetValue(options.Default or self.Min, true)
		return self
	end

	function Slider:SetValue(value, silent)
		value = math.clamp(tonumber(value) or self.Min, self.Min, self.Max)
		value = math.floor((value / self.Step) + 0.5) * self.Step
		value = math.clamp(value, self.Min, self.Max)
		local decimalPart = string.match(tostring(self.Step), "%.(%d+)")
		local decimals = decimalPart and #decimalPart or 0
		value = tonumber(string.format("%." .. decimals .. "f", value))
		self._base:_Commit(value, silent)
		local alpha = self.Max == self.Min and 0 or (value - self.Min) / (self.Max - self.Min)
		self.ValueLabel.Text = (self.Options and self.Options.Suffix) and tostring(value) .. self.Options.Suffix or tostring(value)
		self._base.Library.AnimationManager:Play(self.Fill, { Size = UDim2.fromScale(alpha, 1) }, 0.08)
		self._base.Library.AnimationManager:Play(self.Knob, { Position = UDim2.new(alpha, 0, 0.5, 0) }, 0.08)
		return self
	end

	return Slider
end
