return function(Require)
	local UI = Require("Utils.UI")
	local Blur = Require("Utils.Blur")
	local Responsive = Require("Utils.Responsive")
	local ExecutorDetection = Require("Utils.ExecutorDetection")
	local CleanupManager = Require("Managers.CleanupManager")
	local EventManager = Require("Managers.EventManager")
	local AnimationManager = Require("Managers.AnimationManager")
	local StateManager = Require("Managers.StateManager")
	local FlagManager = Require("Managers.FlagManager")
	local ThemeManager = Require("Managers.ThemeManager")
	local ConfigManager = Require("Managers.ConfigManager")
	local Window = Require("Window")
	local Notification = Require("Components.Notification")
	local Dialog = Require("Components.Dialog")

	local Players = game:GetService("Players")
	local CoreGui = game:GetService("CoreGui")
	local RunService = game:GetService("RunService")
	local TextService = game:GetService("TextService")
	local UserInputService = game:GetService("UserInputService")

	local Library = {}
	Library.__index = Library
	Library.Version = "1.0.0"

	local function resolveParent(options)
		if options.Parent then
			return options.Parent
		end
		if type(gethui) == "function" then
			local ok, result = pcall(gethui)
			if ok and result then
				return result
			end
		end
		local player = Players.LocalPlayer
		if player then
			local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 5)
			if playerGui then
				return playerGui
			end
		end
		return CoreGui
	end

	function Library.new(options)
		options = options or {}
		local capabilities = ExecutorDetection.Detect()
		local cleanup = CleanupManager.new()
		local themeManager = ThemeManager.new()
		local flagManager = FlagManager.new()
		local eventManager = EventManager.new()
		local animationManager = AnimationManager.new(options.ReducedMotion)
		local stateManager = StateManager.new({
			Visible = true,
			Mode = Responsive.GetMode(),
		})
		local configManager = ConfigManager.new(flagManager, themeManager, capabilities)

		local screenGui = UI.Create("ScreenGui", {
			DisplayOrder = options.DisplayOrder or 999,
			IgnoreGuiInset = true,
			Name = options.Name or ("ModernUI_" .. tostring(math.random(100000, 999999))),
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		local parent = resolveParent(options)
		if capabilities.ProtectGui then
			local environment = getgenv and getgenv() or _G
			local protect = type(protectgui) == "function" and protectgui
				or environment.syn and environment.syn.protect_gui
			if protect then
				pcall(protect, screenGui)
			end
		end
		screenGui.Parent = parent

		local root = UI.Create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Parent = screenGui,
		})
		local windowLayer = UI.Create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
			Parent = root,
		})
		local notificationLayer = UI.Create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1000,
			Parent = root,
		})
		local notificationContainer = UI.Create("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -18, 0, 18),
			Size = UDim2.fromOffset(340, 600),
			Parent = notificationLayer,
		}, {
			UI.Create("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = UDim.new(0, 9),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
		local modalLayer = UI.Create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2000,
			Parent = root,
		})
		local overlayLayer = UI.Create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 3000,
			Parent = root,
		})

		local self = setmetatable({
			Options = options,
			ScreenGui = screenGui,
			Root = root,
			WindowLayer = windowLayer,
			NotificationLayer = notificationLayer,
			NotificationContainer = notificationContainer,
			ModalLayer = modalLayer,
			OverlayLayer = overlayLayer,
			Capabilities = capabilities,
			Mode = Responsive.GetMode(),
			Cleanup = cleanup,
			EventManager = eventManager,
			AnimationManager = animationManager,
			StateManager = stateManager,
			FlagManager = flagManager,
			ThemeManager = themeManager,
			ConfigManager = configManager,
			Flags = flagManager,
			Windows = {},
			Locales = { en = {} },
			Locale = options.Locale or "en",
			NotificationQueue = {},
			ActiveNotifications = {},
			MaxNotifications = options.MaxNotifications or 4,
			BlurUsers = 0,
			Destroyed = false,
			_zIndex = 20,
		}, Library)

		self.Blur = Blur.new(screenGui.Name .. "_Blur")
		cleanup:Add(self.Blur)
		cleanup:Add(screenGui)
		cleanup:Add(eventManager)
		cleanup:Add(stateManager)
		cleanup:Add(flagManager)
		cleanup:Add(configManager)
		cleanup:Add(themeManager)

		local scale, responsiveConnection = Responsive.Attach(root, function(mode, viewport, currentScale)
			self.Mode = mode
			self.StateManager:Set("Mode", mode)
			self.EventManager:Emit("ResponsiveChanged", mode, viewport, currentScale)
			self:_UpdateMobileButton()
		end)
		self.Scale = scale
		if responsiveConnection then
			cleanup:Add(responsiveConnection)
		end

		self:_CreateTooltip()
		self:_CreateMobileButton()
		if options.Theme then
			self:SetTheme(options.Theme)
		end
		if options.ConfigFolder then
			configManager:SetFolder(options.ConfigFolder)
		end
		if options.AutoSave then
			configManager:SetAutoSave(true, options.AutoSaveName or "autosave", options.AutoSaveDelay)
		end
		return self
	end

	function Library:_CreateTooltip()
		local tooltip = UI.Create("CanvasGroup", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 0),
			Visible = false,
			ZIndex = 3100,
			Parent = self.OverlayLayer,
		}, {
			UI.Corner(6),
			UI.Stroke(),
			UI.Padding(7, 9, 7, 9),
		})
		self.ThemeManager:Bind(tooltip, { BackgroundColor3 = "Surface" })
		self.ThemeManager:Bind(tooltip:FindFirstChildOfClass("UIStroke"), { Color = "Border" })
		local label = UI.Text("", 11, Enum.Font.Gotham)
		label.AutomaticSize = Enum.AutomaticSize.XY
		label.Size = UDim2.fromOffset(0, 0)
		label.ZIndex = 3101
		label.Parent = tooltip
		self.ThemeManager:Bind(label, { TextColor3 = "Text" })
		self.Tooltip = tooltip
		self.TooltipLabel = label
		self.Cleanup:Add(UserInputService.InputChanged:Connect(function(input)
			if tooltip.Visible and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				tooltip.Position = UDim2.fromOffset(input.Position.X + 14, input.Position.Y + 14)
			end
		end))
	end

	function Library:_ShowTooltip(text, anchor)
		self.TooltipLabel.Text = text
		local bounds = TextService:GetTextSize(text, 11, Enum.Font.Gotham, Vector2.new(280, 500))
		self.TooltipLabel.Size = UDim2.fromOffset(math.min(bounds.X, 280), bounds.Y)
		local mouse = UserInputService:GetMouseLocation()
		self.Tooltip.Position = UDim2.fromOffset(mouse.X + 14, mouse.Y + 14)
		self.Tooltip.Visible = true
		self.Tooltip.GroupTransparency = 1
		self.AnimationManager:Play(self.Tooltip, { GroupTransparency = 0 }, 0.12)
	end

	function Library:_HideTooltip()
		if self.Tooltip then
			self.Tooltip.Visible = false
		end
	end

	function Library:_CreateMobileButton()
		local button = UI.Create("TextButton", {
			AnchorPoint = Vector2.new(1, 1),
			AutoButtonColor = false,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(1, -18, 1, -18),
			Size = UDim2.fromOffset(48, 48),
			Text = "UI",
			TextSize = 13,
			Visible = false,
			ZIndex = 3050,
			Parent = self.OverlayLayer,
		}, {
			UI.Corner(14),
			UI.Stroke(),
		})
		self.ThemeManager:Bind(button, {
			BackgroundColor3 = "Accent",
			TextColor3 = "Text",
		})
		self.ThemeManager:Bind(button:FindFirstChildOfClass("UIStroke"), { Color = "AccentAlt" })
		self.MobileButton = button
		self.Cleanup:Add(button.MouseButton1Click:Connect(function()
			local anyVisible = false
			for _, window in ipairs(self.Windows) do
				anyVisible = anyVisible or window.Visible
			end
			for _, window in ipairs(self.Windows) do
				window:SetVisible(not anyVisible)
			end
		end))
		self:_UpdateMobileButton()
	end

	function Library:_UpdateMobileButton()
		if self.MobileButton then
			self.MobileButton.Visible = self.Mode == "Mobile" or self.Options.AlwaysShowMobileButton == true
		end
	end

	function Library:_AcquireBlur()
		self.BlurUsers = self.BlurUsers + 1
		self.AnimationManager:Play(self.Blur.Effect, {
			Size = self.Options.BlurSize or 14,
		}, 0.2)
	end

	function Library:_ReleaseBlur()
		self.BlurUsers = math.max(0, self.BlurUsers - 1)
		if self.BlurUsers == 0 then
			self.AnimationManager:Play(self.Blur.Effect, { Size = 0 }, 0.2)
		end
	end

	function Library:_FocusWindow(window)
		self._zIndex = self._zIndex + 2
		window.Shadow.ZIndex = self._zIndex
		window.Frame.ZIndex = self._zIndex + 1
	end

	function Library:_RemoveWindow(window)
		local index = table.find(self.Windows, window)
		if index then
			table.remove(self.Windows, index)
		end
	end

	function Library:CreateWindow(options)
		assert(not self.Destroyed, "Cannot create a window on a destroyed library")
		local window = Window.new(self, options)
		table.insert(self.Windows, window)
		self:_FocusWindow(window)
		self.EventManager:Emit("WindowCreated", window)
		return window
	end

	function Library:Notify(options)
		local notification = Notification.new(self, options)
		notification.Root.Visible = false
		table.insert(self.NotificationQueue, {
			Object = notification,
			Duration = math.max(0.25, tonumber(options and options.Duration) or 5),
		})
		self:_AdvanceNotifications()
		return notification
	end

	function Library:_AdvanceNotifications()
		if self.Destroyed then
			return
		end
		local active = {}
		for _, item in ipairs(self.ActiveNotifications) do
			if not item.Object.Closed then
				table.insert(active, item)
			end
		end
		self.ActiveNotifications = active

		while #self.ActiveNotifications < self.MaxNotifications and #self.NotificationQueue > 0 do
			local item = table.remove(self.NotificationQueue, 1)
			if not item.Object.Closed then
				table.insert(self.ActiveNotifications, item)
				item.Object:Show()
				task.delay(item.Duration, function()
					if not item.Object.Closed then
						item.Object:Destroy()
					end
				end)
			end
		end
	end

	function Library:Dialog(options)
		local dialog = Dialog.new(self, options)
		self.Cleanup:Add(dialog)
		return dialog
	end

	function Library:CreateWatermark(options)
		if type(options) == "string" then
			options = { Text = options }
		end
		options = options or {}
		local root = UI.Create("Frame", {
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = options.Position or UDim2.fromOffset(15, 15),
			Size = UDim2.fromOffset(0, 30),
			Parent = self.OverlayLayer,
		}, {
			UI.Corner(7),
			UI.Stroke(),
			UI.Padding(0, 10, 0, 10),
		})
		self.ThemeManager:Bind(root, { BackgroundColor3 = "Surface" })
		self.ThemeManager:Bind(root:FindFirstChildOfClass("UIStroke"), { Color = "Border" })
		local label = UI.Text(options.Text or "ModernUI", 11, Enum.Font.GothamSemibold)
		label.AutomaticSize = Enum.AutomaticSize.X
		label.Size = UDim2.fromOffset(0, 30)
		label.Parent = root
		self.ThemeManager:Bind(label, { TextColor3 = "Text" })

		local watermark = {
			Root = root,
			Label = label,
			BaseText = options.Text or "ModernUI",
			ShowFPS = options.ShowFPS == true,
			Visible = true,
		}
		function watermark:SetText(text)
			self.BaseText = tostring(text or "")
			self.Label.Text = self.BaseText
			return self
		end
		function watermark:SetVisible(visible)
			self.Visible = visible == true
			self.Root.Visible = self.Visible
			return self
		end
		function watermark:Hide()
			return self:SetVisible(false)
		end
		function watermark:Show()
			return self:SetVisible(true)
		end
		function watermark:Destroy()
			if self.Destroyed then
				return
			end
			self.Destroyed = true
			if self.Connection then
				self.Connection:Disconnect()
			end
			if self.Root then
				self.Root:Destroy()
				self.Root = nil
			end
		end

		if watermark.ShowFPS then
			local frames = 0
			local elapsed = 0
			watermark.Connection = RunService.RenderStepped:Connect(function(delta)
				frames = frames + 1
				elapsed = elapsed + delta
				if elapsed >= 0.5 then
					local fps = math.floor(frames / elapsed + 0.5)
					label.Text = watermark.BaseText .. "  |  " .. fps .. " FPS"
					frames = 0
					elapsed = 0
				end
			end)
		end
		self.Cleanup:Add(watermark)
		return watermark
	end

	function Library:RegisterLocale(locale, translations)
		assert(type(locale) == "string", "Locale must be a string")
		assert(type(translations) == "table", "Translations must be a table")
		self.Locales[locale] = table.clone(translations)
		return self
	end

	function Library:SetLocale(locale)
		assert(self.Locales[locale], "Unknown locale: " .. tostring(locale))
		self.Locale = locale
		self.EventManager:Emit("LocaleChanged", locale)
		return self
	end

	function Library:Translate(key, fallback, replacements)
		local text = self.Locales[self.Locale] and self.Locales[self.Locale][key]
			or self.Locales.en[key]
			or fallback
			or key
		for name, value in pairs(replacements or {}) do
			text = string.gsub(text, "{" .. name .. "}", tostring(value))
		end
		return text
	end

	function Library:RegisterTheme(name, theme)
		return self.ThemeManager:Register(name, theme)
	end

	function Library:SetTheme(theme)
		self.ThemeManager:Set(theme)
		self.EventManager:Emit("ThemeChanged", self.ThemeManager.Current, self.ThemeManager.CurrentName)
		return self
	end

	function Library:GetTheme()
		return self.ThemeManager.Current
	end

	function Library:SaveConfig(name)
		return self.ConfigManager:SaveConfig(name)
	end

	function Library:LoadConfig(name, options)
		return self.ConfigManager:LoadConfig(name, options)
	end

	function Library:DeleteConfig(name)
		return self.ConfigManager:DeleteConfig(name)
	end

	function Library:ExportConfig()
		return self.ConfigManager:ExportConfig()
	end

	function Library:ImportConfig(json, options)
		return self.ConfigManager:ImportConfig(json, options)
	end

	function Library:SetVisible(visible)
		visible = visible == true
		self.Root.Visible = visible
		self.StateManager:Set("Visible", visible)
		self.AnimationManager:Play(self.Blur.Effect, {
			Size = visible and self.BlurUsers > 0 and (self.Options.BlurSize or 14) or 0,
		}, 0.18)
		return self
	end

	function Library:Hide()
		return self:SetVisible(false)
	end

	function Library:Show()
		return self:SetVisible(true)
	end

	function Library:Toggle()
		return self:SetVisible(not self.Root.Visible)
	end

	function Library:Destroy()
		if self.Destroyed then
			return
		end
		self.Destroyed = true
		for index = #self.Windows, 1, -1 do
			self.Windows[index]:Destroy()
		end
		for _, item in ipairs(self.ActiveNotifications) do
			if not item.Object.Closed then
				item.Object:Destroy()
			end
		end
		for _, item in ipairs(self.NotificationQueue) do
			if not item.Object.Closed then
				item.Object:Destroy()
			end
		end
		self.Cleanup:Destroy()
	end

	return Library
end
