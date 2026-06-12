return function(Require)
	local UI = Require("Utils.UI")
	local Signal = Require("Utils.Signals")
	local CleanupManager = Require("Managers.CleanupManager")
	local Dialog = {}
	Dialog.__index = Dialog

	function Dialog.new(library, options)
		options = options or {}
		local overlay = UI.Create("CanvasGroup", {
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.38,
			BorderSizePixel = 0,
			GroupTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Parent = library.ModalLayer,
		})
		local panel = UI.Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = options.Size or UDim2.fromOffset(390, 210),
			Parent = overlay,
		}, {
			UI.Corner(12),
			UI.Stroke(),
		})
		library.ThemeManager:Bind(panel, { BackgroundColor3 = "Surface" })
		library.ThemeManager:Bind(panel:FindFirstChildOfClass("UIStroke"), { Color = "Border" })

		local title = UI.Text(options.Title or "Confirm", 18, Enum.Font.GothamBold)
		title.Position = UDim2.fromOffset(20, 17)
		title.Size = UDim2.new(1, -40, 0, 28)
		title.Parent = panel
		library.ThemeManager:Bind(title, { TextColor3 = "Text" })

		local content = UI.Text(options.Content or "", 13, Enum.Font.Gotham)
		content.Position = UDim2.fromOffset(20, 54)
		content.Size = UDim2.new(1, -40, 1, -118)
		content.TextYAlignment = Enum.TextYAlignment.Top
		content.Parent = panel
		library.ThemeManager:Bind(content, { TextColor3 = "MutedText" })

		local buttonHolder = UI.Create("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 20, 1, -18),
			Size = UDim2.new(1, -40, 0, 38),
			Parent = panel,
		}, {
			UI.Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})

		local self = setmetatable({
			Library = library,
			Root = overlay,
			Panel = panel,
			TitleLabel = title,
			ContentLabel = content,
			Value = nil,
			Visible = true,
			Changed = Signal.new(),
			Cleanup = CleanupManager.new(),
			Closed = false,
		}, Dialog)

		for index, buttonOptions in ipairs(options.Buttons or {
			{ Title = "Cancel", Value = false },
			{ Title = "Confirm", Value = true, Primary = true },
		}) do
			local button = UI.Create("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamSemibold,
				LayoutOrder = index,
				Size = UDim2.fromOffset(104, 38),
				Text = buttonOptions.Title or "Button",
				TextSize = 13,
				Parent = buttonHolder,
			}, {
				UI.Corner(7),
				UI.Stroke(),
			})
			library.ThemeManager:Bind(button, {
				BackgroundColor3 = buttonOptions.Primary and "Accent" or "SurfaceAlt",
				TextColor3 = "Text",
			})
			library.ThemeManager:Bind(button:FindFirstChildOfClass("UIStroke"), { Color = "Border" })
			self.Cleanup:Add(button.MouseButton1Click:Connect(function()
				self:SetValue(buttonOptions.Value ~= nil and buttonOptions.Value or buttonOptions.Title)
				if buttonOptions.Callback then
					task.spawn(buttonOptions.Callback, self.Value, self)
				end
				if options.Callback then
					task.spawn(options.Callback, self.Value, self)
				end
				self:Destroy()
			end))
		end

		library.AnimationManager:Play(overlay, { GroupTransparency = 0 }, 0.2)
		library.AnimationManager:Play(panel, { Size = panel.Size }, 0.22, Enum.EasingStyle.Back)
		return self
	end

	function Dialog:SetValue(value)
		local previous = self.Value
		self.Value = value
		self.Changed:Fire(value, previous)
		return self
	end

	function Dialog:GetValue()
		return self.Value
	end

	function Dialog:SetTitle(title)
		self.TitleLabel.Text = tostring(title or "")
		return self
	end

	function Dialog:SetDescription(description)
		self.ContentLabel.Text = tostring(description or "")
		return self
	end

	function Dialog:Show()
		self.Visible = true
		self.Root.Visible = true
		self.Library.AnimationManager:Play(self.Root, { GroupTransparency = 0 }, 0.18)
		return self
	end

	function Dialog:Hide()
		self.Visible = false
		self.Root.Visible = false
		return self
	end

	function Dialog:SetVisible(visible)
		return visible and self:Show() or self:Hide()
	end

	function Dialog:Destroy()
		if self.Closed then
			return
		end
		self.Closed = true
		self.Cleanup:Destroy()
		self.Changed:Destroy()
		if self.Root then
			self.Root:Destroy()
			self.Root = nil
		end
	end

	return Dialog
end
