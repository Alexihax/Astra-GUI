return function()
	local UI = {}

	function UI.Create(className, properties, children)
		local instance = Instance.new(className)
		for property, value in pairs(properties or {}) do
			instance[property] = value
		end
		for _, child in ipairs(children or {}) do
			child.Parent = instance
		end
		return instance
	end

	function UI.Corner(radius)
		return UI.Create("UICorner", {
			CornerRadius = UDim.new(0, radius or 8),
		})
	end

	function UI.Stroke(color, transparency, thickness)
		return UI.Create("UIStroke", {
			Color = color or Color3.new(1, 1, 1),
			Transparency = transparency or 0,
			Thickness = thickness or 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		})
	end

	function UI.Padding(top, right, bottom, left)
		return UI.Create("UIPadding", {
			PaddingTop = UDim.new(0, top or 0),
			PaddingRight = UDim.new(0, right or top or 0),
			PaddingBottom = UDim.new(0, bottom or top or 0),
			PaddingLeft = UDim.new(0, left or right or top or 0),
		})
	end

	function UI.List(spacing, horizontal)
		return UI.Create("UIListLayout", {
			Padding = UDim.new(0, spacing or 0),
			FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	end

	function UI.Text(text, size, font)
		return UI.Create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = font or Enum.Font.Gotham,
			Text = text or "",
			TextSize = size or 14,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
		})
	end

	function UI.Button(text)
		return UI.Create("TextButton", {
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Text = text or "",
			TextSize = 14,
		})
	end

	function UI.SetCanvasFromLayout(scroller, layout, padding)
		local function update()
			scroller.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + (padding or 0))
		end
		local connection = layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
		update()
		return connection
	end

	function UI.ClampToViewport(frame, viewport, margin)
		margin = margin or 8
		local size = frame.AbsoluteSize
		local position = frame.AbsolutePosition
		local x = math.clamp(position.X, margin, math.max(margin, viewport.X - size.X - margin))
		local y = math.clamp(position.Y, margin, math.max(margin, viewport.Y - size.Y - margin))
		frame.Position = UDim2.fromOffset(x, y)
	end

	function UI.SafeCallback(callback, ...)
		if type(callback) ~= "function" then
			return true
		end
		local arguments = table.pack(...)
		return xpcall(function()
			callback(table.unpack(arguments, 1, arguments.n))
		end, warn)
	end

	return UI
end
