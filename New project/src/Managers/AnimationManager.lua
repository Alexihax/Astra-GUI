return function(Require)
	local Tween = Require("Utils.Tween")
	local AnimationManager = {}
	AnimationManager.__index = AnimationManager

	function AnimationManager.new(reducedMotion)
		return setmetatable({
			ReducedMotion = reducedMotion == true,
		}, AnimationManager)
	end

	function AnimationManager:SetReducedMotion(enabled)
		self.ReducedMotion = enabled == true
	end

	function AnimationManager:Play(instance, properties, duration, style, direction)
		if self.ReducedMotion then
			for property, value in pairs(properties) do
				instance[property] = value
			end
			return nil
		end
		return Tween.Play(instance, properties, duration, style, direction)
	end

	function AnimationManager:Fade(instance, visible, duration)
		instance.Visible = true
		local goal = visible and 0 or 1
		local tween = self:Play(instance, { GroupTransparency = goal }, duration or 0.18)
		if not visible and tween then
			tween.Completed:Once(function()
				if instance.Parent and instance.GroupTransparency >= 0.99 then
					instance.Visible = false
				end
			end)
		elseif not visible then
			instance.Visible = false
		end
		return tween
	end

	return AnimationManager
end
