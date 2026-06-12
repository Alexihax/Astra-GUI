return function(Require)
	local UI = Require("Utils.UI")
	local Icons = Require("Utils.Icons")
	local CleanupManager = Require("Managers.CleanupManager")
	local Section = Require("Section")
	local Tab = {}
	Tab.__index = Tab

	function Tab.new(window, options)
		if type(options) == "string" then
			options = { Title = options }
		end
		options = options or {}
		local library = window.Library
		local button = UI.Create("TextButton", {
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = #window.Tabs + 1,
			Size = UDim2.new(1, 0, 0, 39),
			Text = "",
			Parent = window.TabList,
		}, { UI.Corner(8) })

		local iconData = Icons.Resolve(options.Icon or "Home")
		local icon
		if iconData and iconData.Type == "Image" then
			icon = UI.Create("ImageLabel", {
				BackgroundTransparency = 1,
				Image = iconData.Value,
				Position = UDim2.fromOffset(12, 10),
				Size = UDim2.fromOffset(19, 19),
				Parent = button,
			})
		else
			icon = UI.Text(iconData and iconData.Value or "", 12, Enum.Font.GothamBold)
			icon.Position = UDim2.fromOffset(11, 9)
			icon.Size = UDim2.fromOffset(20, 20)
			icon.TextXAlignment = Enum.TextXAlignment.Center
			icon.Parent = button
			library.ThemeManager:Bind(icon, { TextColor3 = "MutedText" })
		end

		local label = UI.Text(options.Title or "Tab", 13, Enum.Font.GothamMedium)
		label.Position = UDim2.fromOffset(40, 0)
		label.Size = UDim2.new(1, -48, 1, 0)
		label.TextTruncate = Enum.TextTruncate.AtEnd
		label.Parent = button
		library.ThemeManager:Bind(label, { TextColor3 = "MutedText" })

		local page = UI.Create("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.None,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.fromOffset(0, 0),
			ScrollBarImageTransparency = 0.3,
			ScrollBarThickness = 3,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			Parent = window.Content,
		}, {
			UI.Padding(15, 16, 18, 16),
			UI.List(12),
		})
		library.ThemeManager:Bind(page, { ScrollBarImageColor3 = "Accent" })
		local layout = page:FindFirstChildOfClass("UIListLayout")

		local self = setmetatable({
			Library = library,
			Window = window,
			Options = options,
			Button = button,
			Icon = icon,
			Label = label,
			Page = page,
			Layout = layout,
			Sections = {},
			Components = {},
			Active = false,
			Loaded = false,
			LazyLoader = options.Loader,
			_order = 0,
			Cleanup = CleanupManager.new(),
		}, Tab)

		self.Cleanup:Add(UI.SetCanvasFromLayout(page, layout, 34))
		self.Cleanup:Add(button.MouseButton1Click:Connect(function()
			window:SelectTab(self)
		end))
		return self
	end

	function Tab:_NextOrder()
		self._order = self._order + 1
		return self._order
	end

	function Tab:_TrackSection(section)
		table.insert(self.Sections, section)
	end

	function Tab:_TrackComponent(component)
		table.insert(self.Components, component)
	end

	function Tab:_EnsureLoaded()
		if self.Loaded then
			return
		end
		self.Loaded = true
		if type(self.LazyLoader) == "function" then
			local ok, err = xpcall(function()
				self.LazyLoader(self)
			end, debug.traceback)
			if not ok then
				warn("[ModernUI] Lazy tab loader failed:", err)
			end
		end
	end

	function Tab:SetLazyLoader(loader)
		self.LazyLoader = loader
		self.Loaded = false
		return self
	end

	function Tab:CreateSection(options)
		self:_EnsureLoaded()
		return Section.new(self, options)
	end

	function Tab:AddSection(options)
		return self:CreateSection(options)
	end

	function Tab:_SetActive(active)
		self.Active = active == true
		self.Page.Visible = self.Active
		local theme = self.Library.ThemeManager.Current
		self.Library.AnimationManager:Play(self.Button, {
			BackgroundTransparency = self.Active and 0 or 1,
			BackgroundColor3 = self.Active and theme.SurfaceHover or theme.Surface,
		}, 0.15)
		self.Label.TextColor3 = self.Active and theme.Text or theme.MutedText
		if self.Icon:IsA("TextLabel") then
			self.Icon.TextColor3 = self.Active and theme.AccentAlt or theme.MutedText
		elseif self.Icon:IsA("ImageLabel") then
			self.Icon.ImageColor3 = self.Active and theme.AccentAlt or theme.MutedText
		end
		if self.Active then
			self:_EnsureLoaded()
		end
	end

	function Tab:SetSidebarCollapsed(collapsed)
		self.Label.Visible = not collapsed
		self.Button.Size = UDim2.new(1, 0, 0, 39)
		self.Icon.Position = collapsed and UDim2.fromOffset(12, 9) or UDim2.fromOffset(11, 9)
	end

	function Tab:Filter(query)
		for _, section in ipairs(self.Sections) do
			section:_Filter(query)
		end
		return self
	end

	function Tab:SetTitle(title)
		self.Label.Text = tostring(title or "")
		return self
	end

	function Tab:SetVisible(visible)
		self.Button.Visible = visible == true
		if not visible and self.Active then
			self.Page.Visible = false
		end
		return self
	end

	function Tab:Hide()
		return self:SetVisible(false)
	end

	function Tab:Show()
		return self:SetVisible(true)
	end

	function Tab:Destroy()
		for index = #self.Sections, 1, -1 do
			self.Sections[index]:Destroy()
		end
		self.Cleanup:Destroy()
		self.Button:Destroy()
		self.Page:Destroy()
	end

	return Tab
end
