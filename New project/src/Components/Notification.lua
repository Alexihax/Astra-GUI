return function(Require)
	local UI = Require("Utils.UI")
	local Signal = Require("Utils.Signals")
	local CleanupManager = Require("Managers.CleanupManager")
	local Notification = {}
	Notification.__index = Notification

	function Notification.new(library, options)
		options = options or {}
		local typeName = options.Type or "Info"
		local colorToken = typeName == "Success" and "Success"
			or typeName == "Error" and "Error"
			or typeName == "Warning" and "Warning"
			or "Accent"

		local root = UI.Create("CanvasGroup", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			GroupTransparency = 1,
			Size = UDim2.fromOffset(330, 86),
			Parent = library.NotificationContainer,
		}, {
			UI.Corner(10),
			UI.Stroke(),
		})
		library.ThemeManager:Bind(root, { BackgroundColor3 = "Surface" })
		library.ThemeManager:Bind(root:FindFirstChildOfClass("UIStroke"), { Color = "Border" })

		local accent = UI.Create("Frame", {
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(4, 86),
			Parent = root,
		}, { UI.Corner(4) })
		library.ThemeManager:Bind(accent, { BackgroundColor3 = colorToken })

		local title = UI.Text(options.Title or typeName, 14, Enum.Font.GothamSemibold)
		title.Position = UDim2.fromOffset(17, 10)
		title.Size = UDim2.new(1, -52, 0, 22)
		title.Parent = root
		library.ThemeManager:Bind(title, { TextColor3 = "Text" })

		local content = UI.Text(options.Content or options.Text or "", 12, Enum.Font.Gotham)
		content.Position = UDim2.fromOffset(17, 34)
		content.Size = UDim2.new(1, -34, 0, 39)
		content.TextYAlignment = Enum.TextYAlignment.Top
		content.Parent = root
		library.ThemeManager:Bind(content, { TextColor3 = "MutedText" })

		local self = setmetatable({
			Library = library,
			Root = root,
			TitleLabel = title,
			ContentLabel = content,
			Value = options.Content or options.Text or "",
			Visible = true,
			Changed = Signal.new(),
			Cleanup = CleanupManager.new(),
			Closed = false,
		}, Notification)

		local close = UI.Button("X")
		close.AnchorPoint = Vector2.new(1, 0)
		close.Position = UDim2.new(1, -8, 0, 8)
		close.Size = UDim2.fromOffset(24, 24)
		close.TextSize = 12
		close.Parent = root
		library.ThemeManager:Bind(close, { TextColor3 = "MutedText" })
		self.Cleanup:Add(close.MouseButton1Click:Connect(function()
			self:Destroy()
		end))
		return self
	end

	function Notification:Show()
		self.Visible = true
		self.Root.Visible = true
		self.Library.AnimationManager:Play(self.Root, { GroupTransparency = 0 }, 0.22)
		return self
	end

	function Notification:Hide()
		self.Visible = false
		self.Library.AnimationManager:Play(self.Root, { GroupTransparency = 1 }, 0.18)
		task.delay(0.2, function()
			if self.Root and self.Root.Parent and not self.Visible then
				self.Root.Visible = false
			end
		end)
		return self
	end

	function Notification:SetVisible(visible)
		return visible and self:Show() or self:Hide()
	end

	function Notification:SetValue(value)
		local previous = self.Value
		self.Value = tostring(value or "")
		self.ContentLabel.Text = self.Value
		self.Changed:Fire(self.Value, previous)
		return self
	end

	function Notification:GetValue()
		return self.Value
	end

	function Notification:SetTitle(title)
		self.TitleLabel.Text = tostring(title or "")
		return self
	end

	function Notification:SetDescription(description)
		return self:SetValue(description)
	end

	function Notification:Destroy()
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
		self.Library:_AdvanceNotifications()
	end

	return Notification
end
