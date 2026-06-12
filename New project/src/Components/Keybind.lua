return function(Require)
	local UI = Require("Utils.UI")
	local ComponentBase = Require("Components.ComponentBase")
	local ComponentUI = Require("Components.ComponentUI")
	local UserInputService = game:GetService("UserInputService")
	local Keybind = {}
	Keybind.__index = Keybind

	local function normalize(value)
		if typeof(value) == "EnumItem" then
			return value
		end
		if type(value) == "string" then
			return Enum.KeyCode[value] or Enum.UserInputType[value]
		end
		return Enum.KeyCode.Unknown
	end

	function Keybind.new(section, options)
		options = options or {}
		local root, title, description = ComponentUI.Card(section, options, options.Description and 58 or 46)
		title.Size = UDim2.new(1, -120, title.Size.Y.Scale, title.Size.Y.Offset)
		local capture = UI.Create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			AutoButtonColor = false,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(88, 28),
			Text = "",
			TextSize = 12,
			Parent = root,
		}, {
			UI.Corner(6),
			UI.Stroke(),
		})
		section.Library.ThemeManager:Bind(capture, {
			BackgroundColor3 = "Surface",
			TextColor3 = "AccentAlt",
		})
		section.Library.ThemeManager:Bind(capture:FindFirstChildOfClass("UIStroke"), { Color = "Border" })

		local base = ComponentUI.AttachBase(ComponentBase.new(section, options, root), title, description)
		local self = ComponentUI.CopyBaseMethods(setmetatable({}, Keybind), base)
		self.Capture = capture
		self.Listening = false
		self.Active = false

		base.Cleanup:Add(capture.MouseButton1Click:Connect(function()
			self.Listening = true
			capture.Text = "Press a key"
		end))
		base.Cleanup:Add(UserInputService.InputBegan:Connect(function(input, processed)
			if self.Listening then
				local key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
				self.Listening = false
				self:SetValue(key)
				return
			end
			if processed and not options.IgnoreProcessed then
				return
			end
			local matches = input.KeyCode == base.Value or input.UserInputType == base.Value
			if matches then
				if options.Mode == "Toggle" then
					self.Active = not self.Active
					if options.OnToggle then
						task.spawn(options.OnToggle, self.Active)
					end
				end
				if options.OnPressed then
					task.spawn(options.OnPressed, self.Active, input)
				elseif options.Callback then
					task.spawn(options.Callback, base.Value, self.Active, input)
				end
			end
		end))
		self:SetValue(options.Default or Enum.KeyCode.RightShift, true)
		return self
	end

	function Keybind:SetValue(value, silent)
		value = normalize(value)
		self._base:_Commit(value, silent)
		self.Capture.Text = value.Name
		return self
	end

	return Keybind
end
