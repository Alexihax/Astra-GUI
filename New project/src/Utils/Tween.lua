return function()
	local TweenService = game:GetService("TweenService")
	local active = setmetatable({}, { __mode = "k" })
	local Tween = {}

	function Tween.Play(instance, properties, duration, style, direction)
		local previous = active[instance]
		if previous then
			previous:Cancel()
		end
		local tween = TweenService:Create(
			instance,
			TweenInfo.new(
				duration or 0.2,
				style or Enum.EasingStyle.Quint,
				direction or Enum.EasingDirection.Out
			),
			properties
		)
		active[instance] = tween
		tween.Completed:Once(function()
			if active[instance] == tween then
				active[instance] = nil
			end
		end)
		tween:Play()
		return tween
	end

	function Tween.Cancel(instance)
		local tween = active[instance]
		if tween then
			tween:Cancel()
			active[instance] = nil
		end
	end

	function Tween.Hover(button, normalColor, hoverColor)
		local enter = button.MouseEnter:Connect(function()
			Tween.Play(button, { BackgroundColor3 = hoverColor }, 0.14)
		end)
		local leave = button.MouseLeave:Connect(function()
			Tween.Play(button, { BackgroundColor3 = normalColor }, 0.14)
		end)
		return { enter, leave }
	end

	return Tween
end
