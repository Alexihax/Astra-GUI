return function(Require)
	local UI = Require("Utils.UI")
	local ComponentBase = Require("Components.ComponentBase")
	local ComponentUI = Require("Components.ComponentUI")
	local Button = {}
	Button.__index = Button

	function Button.new(section, options)
		options = options or {}
		local root, title, description = ComponentUI.Card(section, options, options.Description and 58 or 46)
		title.Size = UDim2.new(1, -66, 1, options.Description and -18 or 0)
		local arrow = UI.Text(">", 17, Enum.Font.GothamBold)
		arrow.AnchorPoint = Vector2.new(1, 0.5)
		arrow.Position = UDim2.new(1, -14, 0.5, 0)
		arrow.Size = UDim2.fromOffset(20, 24)
		arrow.TextXAlignment = Enum.TextXAlignment.Center
		arrow.Parent = root
		section.Library.ThemeManager:Bind(arrow, { TextColor3 = "AccentAlt" })

		local hitbox = UI.Button("")
		hitbox.Size = UDim2.fromScale(1, 1)
		hitbox.Parent = root

		local base = ComponentUI.AttachBase(ComponentBase.new(section, options, root), title, description)
		base:_Commit(options.Default or 0, true)
		local self = ComponentUI.CopyBaseMethods(setmetatable({}, Button), base)
		self.Hitbox = hitbox

		base.Cleanup:Add(hitbox.MouseEnter:Connect(function()
			section.Library.AnimationManager:Play(root, {
				BackgroundColor3 = section.Library.ThemeManager.Current.SurfaceHover,
			}, 0.14)
		end))
		base.Cleanup:Add(hitbox.MouseLeave:Connect(function()
			section.Library.AnimationManager:Play(root, {
				BackgroundColor3 = section.Library.ThemeManager.Current.SurfaceAlt,
			}, 0.14)
		end))
		base.Cleanup:Add(hitbox.MouseButton1Click:Connect(function()
			self:Press()
		end))
		return self
	end

	function Button:Press()
		local nextValue = (tonumber(self._base.Value) or 0) + 1
		self._base:_Commit(nextValue, false)
		self._base.Library.AnimationManager:Play(self.Root, {
			BackgroundColor3 = self._base.Library.ThemeManager.Current.Accent,
		}, 0.08)
		task.delay(0.09, function()
			if self.Root and self.Root.Parent then
				self._base.Library.AnimationManager:Play(self.Root, {
					BackgroundColor3 = self._base.Library.ThemeManager.Current.SurfaceAlt,
				}, 0.16)
			end
		end)
		return self
	end

	function Button:SetValue(value, silent)
		if value == true or value == "Press" then
			if silent then
				self._base:_Commit((tonumber(self._base.Value) or 0) + 1, true)
			else
				self:Press()
			end
		else
			self._base:_Commit(value, silent)
		end
		return self
	end

	return Button
end
