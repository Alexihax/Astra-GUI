return function(Require)
	local UI = Require("Utils.UI")
	local ComponentBase = Require("Components.ComponentBase")
	local ComponentUI = Require("Components.ComponentUI")
	local UserInputService = game:GetService("UserInputService")
	local ColorPicker = {}
	ColorPicker.__index = ColorPicker

	local function fromHex(hex)
		hex = string.gsub(tostring(hex or ""), "#", "")
		if #hex ~= 6 then
			return nil
		end
		local r = tonumber(string.sub(hex, 1, 2), 16)
		local g = tonumber(string.sub(hex, 3, 4), 16)
		local b = tonumber(string.sub(hex, 5, 6), 16)
		if not r or not g or not b then
			return nil
		end
		return Color3.fromRGB(r, g, b)
	end

	local function toHex(color)
		return string.format(
			"#%02X%02X%02X",
			math.floor(color.R * 255 + 0.5),
			math.floor(color.G * 255 + 0.5),
			math.floor(color.B * 255 + 0.5)
		)
	end

	function ColorPicker.new(section, options)
		options = options or {}
		local collapsedHeight = options.Description and 58 or 46
		local root, title, description = ComponentUI.Card(section, options, collapsedHeight)
		root.ClipsDescendants = true
		title.Size = UDim2.new(1, -122, title.Size.Y.Scale, title.Size.Y.Offset)

		local preview = UI.Create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			AutoButtonColor = false,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(92, 28),
			Text = "#FFFFFF",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 11,
			Parent = root,
		}, {
			UI.Corner(6),
			UI.Stroke(Color3.new(1, 1, 1), 0.55),
		})

		local controls = UI.Create("Frame", {
			Position = UDim2.fromOffset(12, collapsedHeight + 4),
			Size = UDim2.new(1, -24, 0, 96),
			BackgroundTransparency = 1,
			Parent = root,
		})

		local base = ComponentUI.AttachBase(ComponentBase.new(section, options, root), title, description)
		local self = ComponentUI.CopyBaseMethods(setmetatable({}, ColorPicker), base)
		self.Preview = preview
		self.Controls = controls
		self.Open = false
		self.Hue = 0
		self.Saturation = 1
		self.Value = 1
		self.Bars = {}
		self.ApplyAccent = options.ApplyAccent == true

		local function makeBar(name, y, gradient)
			local label = UI.Text(name, 11, Enum.Font.GothamMedium)
			label.Position = UDim2.fromOffset(0, y)
			label.Size = UDim2.fromOffset(18, 22)
			label.Parent = controls
			section.Library.ThemeManager:Bind(label, { TextColor3 = "MutedText" })

			local bar = UI.Create("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(24, y + 7),
				Size = UDim2.new(1, -24, 0, 9),
				Text = "",
				Parent = controls,
			}, {
				UI.Corner(5),
				UI.Create("UIGradient", {
					Color = gradient,
				}),
			})
			local cursor = UI.Create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.fromOffset(13, 13),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				Parent = bar,
			}, {
				UI.Corner(7),
				UI.Stroke(Color3.fromRGB(30, 30, 35), 0, 1),
			})
			self.Bars[name] = { Bar = bar, Cursor = cursor }
			return bar
		end

		local hueGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
			ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
			ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
			ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
			ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
			ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
		})
		local hueBar = makeBar("H", 0, hueGradient)
		local saturationBar = makeBar("S", 31, ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(0, 1, 1)))
		local valueBar = makeBar("V", 62, ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(0, 1, 1)))

		local dragging
		local function updateFromInput(input)
			if not dragging then
				return
			end
			local bar = dragging.Bar
			local alpha = math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
			if dragging.Name == "H" then
				self.Hue = alpha
			elseif dragging.Name == "S" then
				self.Saturation = alpha
			else
				self.Value = alpha
			end
			self:SetValue(Color3.fromHSV(self.Hue, self.Saturation, self.Value))
		end

		for name, data in pairs(self.Bars) do
			base.Cleanup:Add(data.Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					dragging = { Name = name, Bar = data.Bar }
					updateFromInput(input)
				end
			end))
		end
		base.Cleanup:Add(UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				updateFromInput(input)
			end
		end))
		base.Cleanup:Add(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = nil
			end
		end))
		base.Cleanup:Add(preview.MouseButton1Click:Connect(function()
			self:SetOpen(not self.Open)
		end))

		self.HueBar = hueBar
		self.SaturationBar = saturationBar
		self.ValueBar = valueBar
		self:SetValue(options.Default or Color3.fromRGB(71, 137, 255), true)
		return self
	end

	function ColorPicker:SetOpen(open)
		self.Open = open == true
		local collapsedHeight = self.Options.Description and 58 or 46
		self._base.Library.AnimationManager:Play(self.Root, {
			Size = UDim2.new(1, 0, 0, collapsedHeight + (self.Open and 108 or 0)),
		}, 0.2)
		return self
	end

	function ColorPicker:SetValue(value, silent)
		if type(value) == "string" then
			value = fromHex(value)
		end
		if typeof(value) ~= "Color3" then
			return self
		end
		self.Hue, self.Saturation, self.Value = Color3.toHSV(value)
		self._base:_Commit(value, silent)
		if self.ApplyAccent and not silent then
			self._base.Library:SetAccent(value)
		end
		self.Preview.BackgroundColor3 = value
		self.Preview.Text = toHex(value)
		local luminance = value.R * 0.299 + value.G * 0.587 + value.B * 0.114
		self.Preview.TextColor3 = luminance > 0.58 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
		self.Bars.H.Cursor.Position = UDim2.new(self.Hue, 0, 0.5, 0)
		self.Bars.S.Cursor.Position = UDim2.new(self.Saturation, 0, 0.5, 0)
		self.Bars.V.Cursor.Position = UDim2.new(self.Value, 0, 0.5, 0)
		self.SaturationBar.UIGradient.Color = ColorSequence.new(
			Color3.new(1, 1, 1),
			Color3.fromHSV(self.Hue, 1, 1)
		)
		self.ValueBar.UIGradient.Color = ColorSequence.new(
			Color3.new(0, 0, 0),
			Color3.fromHSV(self.Hue, self.Saturation, 1)
		)
		return self
	end

	function ColorPicker:GetHex()
		return toHex(self._base.Value)
	end

	return ColorPicker
end
