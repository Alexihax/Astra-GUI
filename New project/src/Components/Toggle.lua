return function(Require)
	local UI = Require("Utils.UI")
	local ComponentBase = Require("Components.ComponentBase")
	local ComponentUI = Require("Components.ComponentUI")
	local Toggle = {}
	Toggle.__index = Toggle

	function Toggle.new(section, options)
		options = options or {}
		local root, title, description = ComponentUI.Card(section, options, options.Description and 58 or 46)
		title.Size = UDim2.new(1, -74, title.Size.Y.Scale, title.Size.Y.Offset)

		local track = UI.Create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -13, 0.5, 0),
			Size = UDim2.fromOffset(42, 23),
			BorderSizePixel = 0,
			Parent = root,
		}, {
			UI.Corner(12),
			UI.Stroke(),
		})
		local knob = UI.Create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 4, 0.5, 0),
			Size = UDim2.fromOffset(15, 15),
			BorderSizePixel = 0,
			Parent = track,
		}, {
			UI.Corner(8),
		})
		section.Library.ThemeManager:Bind(knob, { BackgroundColor3 = "Text" })
		section.Library.ThemeManager:Bind(track:FindFirstChildOfClass("UIStroke"), { Color = "Border" })

		local hitbox = UI.Button("")
		hitbox.Size = UDim2.fromScale(1, 1)
		hitbox.Parent = root

		local base = ComponentUI.AttachBase(ComponentBase.new(section, options, root), title, description)
		local self = ComponentUI.CopyBaseMethods(setmetatable({}, Toggle), base)
		self.Track = track
		self.Knob = knob
		base.Cleanup:Add(hitbox.MouseButton1Click:Connect(function()
			self:SetValue(not base.Value)
		end))
		base.Cleanup:Add(section.Library.ThemeManager.Changed:Connect(function()
			self:_ApplyVisualState(true)
		end))
		self:SetValue(options.Default == true, true)
		return self
	end

	function Toggle:_ApplyVisualState(instant)
		local theme = self._base.Library.ThemeManager.Current
		local value = self._base.Value == true
		if instant then
			self.Track.BackgroundColor3 = value and theme.Accent or theme.SurfaceHover
			self.Knob.Position = value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 4, 0.5, 0)
		else
			self._base.Library.AnimationManager:Play(self.Track, {
				BackgroundColor3 = value and theme.Accent or theme.SurfaceHover,
			}, 0.17)
			self._base.Library.AnimationManager:Play(self.Knob, {
				Position = value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
			}, 0.17)
		end
	end

	function Toggle:SetValue(value, silent)
		value = value == true
		self._base:_Commit(value, silent)
		self:_ApplyVisualState(false)
		return self
	end

	return Toggle
end
