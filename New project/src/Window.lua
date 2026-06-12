return function(Require)
	local UI = Require("Utils.UI")
	local Icons = Require("Utils.Icons")
	local CleanupManager = Require("Managers.CleanupManager")
	local Tab = Require("Tab")
	local UserInputService = game:GetService("UserInputService")
	local Window = {}
	Window.__index = Window

	local function isPrimaryInput(input)
		return input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
	end

	function Window.new(library, options)
		options = options or {}
		local size = options.Size or UDim2.fromOffset(700, 470)
		local position = options.Position or UDim2.fromScale(0.5, 0.5)

		local shadow = UI.Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.63,
			BorderSizePixel = 0,
			Position = UDim2.new(position.X.Scale, position.X.Offset + 8, position.Y.Scale, position.Y.Offset + 11),
			Size = UDim2.new(size.X.Scale, size.X.Offset + 20, size.Y.Scale, size.Y.Offset + 24),
			ZIndex = options.ZIndex or 10,
			Parent = library.WindowLayer,
		}, { UI.Corner(18) })
		library.ThemeManager:Bind(shadow, { BackgroundColor3 = "Shadow" })

		local frame = UI.Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = position,
			Size = size,
			ZIndex = (options.ZIndex or 10) + 1,
			Parent = library.WindowLayer,
		}, {
			UI.Corner(options.CornerRadius or 13),
			UI.Stroke(),
		})
		library.ThemeManager:Bind(frame, { BackgroundColor3 = "Background" })
		library.ThemeManager:Bind(frame:FindFirstChildOfClass("UIStroke"), { Color = "Border" })
		if options.Acrylic ~= false then
			local acrylicGradient = library.Blur:ApplyAcrylic(frame, library.ThemeManager.Current)
			library.ThemeManager:Bind(acrylicGradient, {
				Color = function(theme)
					return ColorSequence.new({
						ColorSequenceKeypoint.new(0, theme.Surface),
						ColorSequenceKeypoint.new(1, theme.Background),
					})
				end,
			})
			library:_AcquireBlur()
		end

		local topbar = UI.Create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 56),
			ZIndex = frame.ZIndex + 1,
			Parent = frame,
		})
		local title = UI.Text(options.Title or "Modern UI", 17, Enum.Font.GothamBold)
		title.Position = UDim2.fromOffset(18, 8)
		title.Size = UDim2.new(1, -170, 0, 24)
		title.Parent = topbar
		library.ThemeManager:Bind(title, { TextColor3 = "Text" })
		local subtitle = UI.Text(options.Subtitle or "", 11, Enum.Font.Gotham)
		subtitle.Position = UDim2.fromOffset(18, 31)
		subtitle.Size = UDim2.new(1, -170, 0, 17)
		subtitle.Parent = topbar
		library.ThemeManager:Bind(subtitle, { TextColor3 = "MutedText" })

		local controls = UI.Create("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -10, 0, 10),
			Size = UDim2.fromOffset(112, 34),
			Parent = topbar,
		}, {
			UI.Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})

		local function controlButton(text, order)
			local button = UI.Create("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				LayoutOrder = order,
				Size = UDim2.fromOffset(32, 32),
				Text = text,
				TextSize = 12,
				Parent = controls,
			}, { UI.Corner(7) })
			library.ThemeManager:Bind(button, {
				BackgroundColor3 = "SurfaceAlt",
				TextColor3 = "MutedText",
			})
			return button
		end

		local menuButton = controlButton(Icons.Resolve("Menu").Value, 1)
		local minimizeButton = controlButton(Icons.Resolve("Minimize").Value, 2)
		local closeButton = controlButton(Icons.Resolve("Close").Value, 3)

		local body = UI.Create("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 56),
			Size = UDim2.new(1, 0, 1, -56),
			Parent = frame,
		})

		local sidebar = UI.Create("Frame", {
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 190, 1, 0),
			Parent = body,
		})
		library.ThemeManager:Bind(sidebar, { BackgroundColor3 = "Surface" })

		local search = UI.Create("TextBox", {
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			ClearTextOnFocus = false,
			Font = Enum.Font.Gotham,
			PlaceholderText = options.SearchPlaceholder or "Search controls...",
			Position = UDim2.fromOffset(10, 9),
			Size = UDim2.new(1, -20, 0, 34),
			Text = "",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = sidebar,
		}, {
			UI.Corner(8),
			UI.Stroke(),
			UI.Padding(0, 10, 0, 10),
		})
		library.ThemeManager:Bind(search, {
			BackgroundColor3 = "SurfaceAlt",
			PlaceholderColor3 = "MutedText",
			TextColor3 = "Text",
		})
		library.ThemeManager:Bind(search:FindFirstChildOfClass("UIStroke"), { Color = "Border" })

		local tabList = UI.Create("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.fromOffset(0, 0),
			Position = UDim2.fromOffset(10, 52),
			ScrollBarThickness = 0,
			Size = UDim2.new(1, -20, 1, -62),
			Parent = sidebar,
		}, { UI.List(6) })
		local tabLayout = tabList:FindFirstChildOfClass("UIListLayout")

		local content = UI.Create("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(190, 0),
			Size = UDim2.new(1, -190, 1, 0),
			Parent = body,
		})

		local resizeHandle = UI.Create("TextButton", {
			AnchorPoint = Vector2.new(1, 1),
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.fromOffset(22, 22),
			Text = "",
			ZIndex = frame.ZIndex + 4,
			Parent = frame,
		})
		local resizeMark = UI.Create("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -5, 1, -5),
			Rotation = -45,
			Size = UDim2.fromOffset(11, 2),
			Parent = resizeHandle,
		})
		library.ThemeManager:Bind(resizeMark, { BackgroundColor3 = "MutedText" })

		local self = setmetatable({
			Library = library,
			Options = options,
			Frame = frame,
			Shadow = shadow,
			Topbar = topbar,
			Body = body,
			Sidebar = sidebar,
			SearchBox = search,
			TabList = tabList,
			Content = content,
			TitleLabel = title,
			SubtitleLabel = subtitle,
			Tabs = {},
			ActiveTab = nil,
			Visible = true,
			Minimized = false,
			SidebarCollapsed = false,
			Closed = false,
			NormalSize = size,
			_BlurActive = options.Acrylic ~= false,
			Cleanup = CleanupManager.new(),
		}, Window)

		self.Cleanup:Add(UI.SetCanvasFromLayout(tabList, tabLayout, 12))
		self.Cleanup:Add(menuButton.MouseButton1Click:Connect(function()
			self:SetSidebarCollapsed(not self.SidebarCollapsed)
		end))
		self.Cleanup:Add(minimizeButton.MouseButton1Click:Connect(function()
			self:SetMinimized(not self.Minimized)
		end))
		self.Cleanup:Add(closeButton.MouseButton1Click:Connect(function()
			if options.DestroyOnClose then
				self:Destroy()
			else
				self:Hide()
			end
		end))
		self.Cleanup:Add(search:GetPropertyChangedSignal("Text"):Connect(function()
			if self.ActiveTab then
				self.ActiveTab:Filter(search.Text)
			end
		end))

		self:_BindDragging()
		self:_BindResizing(resizeHandle)
		self:_BindToggleKey(options.Keybind or Enum.KeyCode.RightControl)
		self:_BindFocus()
		if library.Mode == "Mobile" then
			resizeHandle.Visible = false
			self.Frame.Size = options.MobileSize or UDim2.new(0.92, 0, 0.78, 0)
			self.Frame.Position = UDim2.fromScale(0.5, 0.5)
			self.Shadow.Visible = false
		end
		return self
	end

	function Window:_BindFocus()
		self.Cleanup:Add(self.Frame.InputBegan:Connect(function(input)
			if isPrimaryInput(input) then
				self.Library:_FocusWindow(self)
			end
		end))
	end

	function Window:_SyncShadow()
		self.Shadow.Position = UDim2.new(
			self.Frame.Position.X.Scale,
			self.Frame.Position.X.Offset + 8,
			self.Frame.Position.Y.Scale,
			self.Frame.Position.Y.Offset + 11
		)
		self.Shadow.Size = UDim2.new(
			self.Frame.Size.X.Scale,
			self.Frame.Size.X.Offset + 20,
			self.Frame.Size.Y.Scale,
			self.Frame.Size.Y.Offset + 24
		)
	end

	function Window:_BindDragging()
		local dragging = false
		local startInput
		local startPosition
		self.Cleanup:Add(self.Topbar.InputBegan:Connect(function(input)
			if isPrimaryInput(input) then
				dragging = true
				startInput = input.Position
				startPosition = self.Frame.Position
				self.Library:_FocusWindow(self)
			end
		end))
		self.Cleanup:Add(UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - startInput
				self.Frame.Position = UDim2.new(
					startPosition.X.Scale,
					startPosition.X.Offset + delta.X,
					startPosition.Y.Scale,
					startPosition.Y.Offset + delta.Y
				)
				self:_SyncShadow()
			end
		end))
		self.Cleanup:Add(UserInputService.InputEnded:Connect(function(input)
			if isPrimaryInput(input) then
				dragging = false
			end
		end))
	end

	function Window:_BindResizing(handle)
		local resizing = false
		local startInput
		local startSize
		local minimum = self.Options.MinimumSize or Vector2.new(520, 340)
		local maximum = self.Options.MaximumSize or Vector2.new(1100, 800)
		self.Cleanup:Add(handle.InputBegan:Connect(function(input)
			if isPrimaryInput(input) and not self.Minimized then
				resizing = true
				startInput = input.Position
				startSize = self.Frame.AbsoluteSize
			end
		end))
		self.Cleanup:Add(UserInputService.InputChanged:Connect(function(input)
			if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - startInput
				local width = math.clamp(startSize.X + delta.X, minimum.X, maximum.X)
				local height = math.clamp(startSize.Y + delta.Y, minimum.Y, maximum.Y)
				self.Frame.Size = UDim2.fromOffset(width, height)
				self.NormalSize = self.Frame.Size
				self:_SyncShadow()
			end
		end))
		self.Cleanup:Add(UserInputService.InputEnded:Connect(function(input)
			if isPrimaryInput(input) then
				resizing = false
			end
		end))
	end

	function Window:_BindToggleKey(keybind)
		self.ToggleKey = keybind
		self.Cleanup:Add(UserInputService.InputBegan:Connect(function(input, processed)
			if not processed and input.KeyCode == self.ToggleKey then
				self:SetVisible(not self.Visible)
			end
		end))
	end

	function Window:CreateTab(options)
		local tab = Tab.new(self, options)
		table.insert(self.Tabs, tab)
		if not self.ActiveTab then
			self:SelectTab(tab)
		end
		return tab
	end

	function Window:AddTab(options)
		return self:CreateTab(options)
	end

	function Window:SelectTab(tab)
		if self.ActiveTab == tab then
			return self
		end
		for _, candidate in ipairs(self.Tabs) do
			candidate:_SetActive(candidate == tab)
		end
		self.ActiveTab = tab
		tab:Filter(self.SearchBox.Text)
		return self
	end

	function Window:SetSidebarCollapsed(collapsed)
		self.SidebarCollapsed = collapsed == true
		local width = self.SidebarCollapsed and 58 or 190
		self.SearchBox.Visible = not self.SidebarCollapsed
		self.TabList.Position = UDim2.fromOffset(self.SidebarCollapsed and 8 or 10, self.SidebarCollapsed and 10 or 52)
		self.TabList.Size = UDim2.new(1, self.SidebarCollapsed and -16 or -20, 1, self.SidebarCollapsed and -20 or -62)
		for _, tab in ipairs(self.Tabs) do
			tab:SetSidebarCollapsed(self.SidebarCollapsed)
		end
		self.Library.AnimationManager:Play(self.Sidebar, { Size = UDim2.new(0, width, 1, 0) }, 0.2)
		self.Library.AnimationManager:Play(self.Content, {
			Position = UDim2.fromOffset(width, 0),
			Size = UDim2.new(1, -width, 1, 0),
		}, 0.2)
		return self
	end

	function Window:SetMinimized(minimized)
		self.Minimized = minimized == true
		if self.Minimized then
			self.NormalSize = self.Frame.Size
		end
		self.Body.Visible = not self.Minimized
		self.Library.AnimationManager:Play(self.Frame, {
			Size = self.Minimized and UDim2.new(self.NormalSize.X.Scale, self.NormalSize.X.Offset, 0, 56)
				or self.NormalSize,
		}, 0.22)
		task.delay(0.23, function()
			if self.Frame and self.Frame.Parent then
				self:_SyncShadow()
			end
		end)
		return self
	end

	function Window:SetVisible(visible)
		visible = visible == true
		if self.Visible == visible then
			return self
		end
		self.Visible = visible
		self.Frame.Visible = self.Visible
		self.Shadow.Visible = self.Visible and self.Library.Mode ~= "Mobile"
		if self.Options.Acrylic ~= false then
			if self.Visible and not self._BlurActive then
				self._BlurActive = true
				self.Library:_AcquireBlur()
			elseif not self.Visible and self._BlurActive then
				self._BlurActive = false
				self.Library:_ReleaseBlur()
			end
		end
		return self
	end

	function Window:Hide()
		return self:SetVisible(false)
	end

	function Window:Show()
		return self:SetVisible(true)
	end

	function Window:SetTitle(title)
		self.TitleLabel.Text = tostring(title or "")
		return self
	end

	function Window:SetDescription(description)
		self.SubtitleLabel.Text = tostring(description or "")
		return self
	end

	function Window:SetKeybind(keybind)
		self.ToggleKey = keybind
		return self
	end

	function Window:Destroy()
		if self.Closed then
			return
		end
		self.Closed = true
		for index = #self.Tabs, 1, -1 do
			self.Tabs[index]:Destroy()
		end
		self.Cleanup:Destroy()
		if self._BlurActive then
			self._BlurActive = false
			self.Library:_ReleaseBlur()
		end
		self.Frame:Destroy()
		self.Shadow:Destroy()
		self.Library:_RemoveWindow(self)
	end

	return Window
end
