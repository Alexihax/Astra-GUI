return function(Require)
	local UI = Require("Utils.UI")
	local Lighting = game:GetService("Lighting")
	local Blur = {}
	Blur.__index = Blur

	function Blur.new(name)
		local self = setmetatable({}, Blur)
		self.Effect = UI.Create("BlurEffect", {
			Name = name or "AstraUIBlur",
			Size = 0,
			Enabled = true,
			Parent = Lighting,
		})
		return self
	end

	function Blur:Set(amount)
		self.Effect.Size = math.clamp(amount or 0, 0, 56)
	end

	function Blur:ApplyAcrylic(frame, theme)
		frame.BackgroundTransparency = theme.AcrylicTransparency or 0.08
		local gradient = UI.Create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, theme.Surface),
				ColorSequenceKeypoint.new(1, theme.Background),
			}),
			Rotation = 115,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 0.12),
			}),
			Parent = frame,
		})
		return gradient
	end

	function Blur:Destroy()
		if self.Effect then
			self.Effect:Destroy()
			self.Effect = nil
		end
	end

	return Blur
end
