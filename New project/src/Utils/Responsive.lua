return function()
	local UserInputService = game:GetService("UserInputService")
	local Responsive = {}

	function Responsive.IsMobile()
		return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	end

	function Responsive.GetMode()
		return Responsive.IsMobile() and "Mobile" or "PC"
	end

	function Responsive.Attach(screenGui, callback)
		local camera = workspace.CurrentCamera
		local scale = Instance.new("UIScale")
		scale.Name = "ResponsiveScale"
		scale.Parent = screenGui

		local function update()
			camera = workspace.CurrentCamera or camera
			local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
			local base = math.min(viewport.X / 1280, viewport.Y / 720)
			scale.Scale = math.clamp(base, Responsive.IsMobile() and 0.72 or 0.82, 1.15)
			if screenGui:IsA("GuiObject") then
				screenGui.AnchorPoint = Vector2.new(0.5, 0.5)
				screenGui.Position = UDim2.fromScale(0.5, 0.5)
				screenGui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)
			end
			if callback then
				callback(Responsive.GetMode(), viewport, scale.Scale)
			end
		end

		local connection
		if camera then
			connection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
		end
		update()
		return scale, connection
	end

	return Responsive
end
