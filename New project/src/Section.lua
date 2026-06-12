return function(Require)
	local UI = Require("Utils.UI")
	local CleanupManager = Require("Managers.CleanupManager")
	local Button = Require("Components.Button")
	local Toggle = Require("Components.Toggle")
	local Slider = Require("Components.Slider")
	local Dropdown = Require("Components.Dropdown")
	local Input = Require("Components.Input")
	local Keybind = Require("Components.Keybind")
	local ColorPicker = Require("Components.ColorPicker")
	local Paragraph = Require("Components.Paragraph")
	local Divider = Require("Components.Divider")
	local Image = Require("Components.Image")

	local Section = {}
	Section.__index = Section

	function Section.new(tab, options, parent)
		if type(options) == "string" then
			options = { Title = options }
		end
		options = options or {}
		local library = tab.Library
		local root = UI.Create("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = tab:_NextOrder(),
			Size = UDim2.new(1, 0, 0, 0),
			Parent = parent or tab.Page,
		})

		local header = UI.Create("TextButton", {
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 0,
			Size = UDim2.new(1, 0, 0, options.Description and 45 or 34),
			Text = "",
			Parent = root,
		})

		local title = UI.Text(options.Title or "Section", 13, Enum.Font.GothamBold)
		title.Position = UDim2.fromOffset(2, 0)
		title.Size = UDim2.new(1, -30, 0, 30)
		title.Parent = header
		library.ThemeManager:Bind(title, { TextColor3 = "Text" })

		local description
		if options.Description then
			description = UI.Text(options.Description, 11, Enum.Font.Gotham)
			description.Position = UDim2.fromOffset(2, 23)
			description.Size = UDim2.new(1, -30, 0, 18)
			description.Parent = header
			library.ThemeManager:Bind(description, { TextColor3 = "MutedText" })
		end

		local chevron = UI.Text("v", 12, Enum.Font.GothamBold)
		chevron.AnchorPoint = Vector2.new(1, 0.5)
		chevron.Position = UDim2.new(1, -3, 0, 17)
		chevron.Size = UDim2.fromOffset(20, 20)
		chevron.TextXAlignment = Enum.TextXAlignment.Center
		chevron.Parent = header
		library.ThemeManager:Bind(chevron, { TextColor3 = "MutedText" })

		local content = UI.Create("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 0),
			Parent = root,
		}, {
			UI.List(7),
		})
		UI.List(0).Parent = root

		local self = setmetatable({
			Library = library,
			Tab = tab,
			Options = options,
			Root = root,
			Header = header,
			TitleLabel = title,
			DescriptionLabel = description,
			Chevron = chevron,
			Content = content,
			Components = {},
			Children = {},
			Collapsed = options.Collapsed == true,
			Visible = options.Visible ~= false,
			DependencyVisible = true,
			SearchVisible = true,
			_order = 0,
			Cleanup = CleanupManager.new(),
			Destroyed = false,
		}, Section)

		self.Cleanup:Add(header.MouseButton1Click:Connect(function()
			if options.Collapsible ~= false then
				self:SetCollapsed(not self.Collapsed)
			end
		end))
		self:_BindDependency()
		self:SetCollapsed(self.Collapsed, true)
		if not parent then
			tab:_TrackSection(self)
		end
		return self
	end

	function Section:_NextOrder()
		self._order = self._order + 1
		return self._order
	end

	function Section:_Track(component)
		table.insert(self.Components, component)
		self.Tab:_TrackComponent(component)
		return component
	end

	function Section:_BindDependency()
		local dependency = self.Options.DependsOn
		if type(dependency) ~= "table" then
			self:_RefreshVisibility()
			return
		end
		local function update()
			local value
			if dependency.Component then
				value = dependency.Component:GetValue()
			elseif dependency.Flag then
				value = self.Library.FlagManager:Get(dependency.Flag)
			end
			local passes
			if dependency.Predicate then
				local ok, result = pcall(dependency.Predicate, value)
				passes = ok and result ~= false
			elseif dependency.Value ~= nil then
				passes = value == dependency.Value
			else
				passes = value == true
			end
			self.DependencyVisible = passes
			self:_RefreshVisibility()
		end
		if dependency.Component and dependency.Component.Changed then
			self.Cleanup:Add(dependency.Component.Changed:Connect(update))
		elseif dependency.Flag then
			self.Cleanup:Add(self.Library.FlagManager.Changed:Connect(function(flag)
				if flag == dependency.Flag then
					update()
				end
			end))
		end
		update()
	end

	function Section:_RefreshVisibility()
		self.Root.Visible = self.Visible and self.DependencyVisible and self.SearchVisible
	end

	function Section:AddButton(options)
		return self:_Track(Button.new(self, options))
	end

	function Section:AddToggle(options)
		return self:_Track(Toggle.new(self, options))
	end

	function Section:AddSlider(options)
		return self:_Track(Slider.new(self, options))
	end

	function Section:AddDropdown(options)
		options = options or {}
		options.Multi = false
		return self:_Track(Dropdown.new(self, options))
	end

	function Section:AddMultiDropdown(options)
		options = options or {}
		options.Multi = true
		return self:_Track(Dropdown.new(self, options))
	end

	function Section:AddInput(options)
		return self:_Track(Input.new(self, options))
	end

	function Section:AddKeybind(options)
		return self:_Track(Keybind.new(self, options))
	end

	function Section:AddColorPicker(options)
		return self:_Track(ColorPicker.new(self, options))
	end

	function Section:AddParagraph(options)
		return self:_Track(Paragraph.new(self, options))
	end

	function Section:AddDivider(options)
		return self:_Track(Divider.new(self, options))
	end

	function Section:AddImage(options)
		return self:_Track(Image.new(self, options))
	end

	function Section:AddDependencyBox(options)
		local child = Section.new(self.Tab, options, self.Content)
		table.insert(self.Children, child)
		return child
	end

	function Section:SetCollapsed(collapsed, instant)
		self.Collapsed = collapsed == true
		self.Content.Visible = not self.Collapsed
		self.Chevron.Text = self.Collapsed and ">" or "v"
		if not instant then
			self.Library.AnimationManager:Play(self.Chevron, {
				Rotation = self.Collapsed and -90 or 0,
			}, 0.16)
		end
		return self
	end

	function Section:SetTitle(title)
		self.TitleLabel.Text = tostring(title or "")
		return self
	end

	function Section:SetDescription(description)
		if self.DescriptionLabel then
			self.DescriptionLabel.Text = tostring(description or "")
		end
		return self
	end

	function Section:SetVisible(visible)
		self.Visible = visible == true
		self:_RefreshVisibility()
		return self
	end

	function Section:Hide()
		return self:SetVisible(false)
	end

	function Section:Show()
		return self:SetVisible(true)
	end

	function Section:_Filter(query)
		query = string.lower(query or "")
		local sectionText = string.lower(
			(self.TitleLabel.Text or "") .. " " .. (self.DescriptionLabel and self.DescriptionLabel.Text or "")
		)
		local sectionMatches = query == "" or string.find(sectionText, query, 1, true) ~= nil
		local anyVisible = sectionMatches
		for _, component in ipairs(self.Components) do
			local base = component._base
			if base then
				local text = string.lower((base.Title or "") .. " " .. (base.Description or ""))
				local matches = sectionMatches or query == "" or string.find(text, query, 1, true) ~= nil
				base:_SetSearchVisible(matches)
				anyVisible = anyVisible or matches
			end
		end
		for _, child in ipairs(self.Children) do
			anyVisible = child:_Filter(query) or anyVisible
		end
		self.SearchVisible = anyVisible
		self:_RefreshVisibility()
		return anyVisible
	end

	function Section:Destroy()
		if self.Destroyed then
			return
		end
		self.Destroyed = true
		for index = #self.Components, 1, -1 do
			self.Components[index]:Destroy()
		end
		for index = #self.Children, 1, -1 do
			self.Children[index]:Destroy()
		end
		self.Cleanup:Destroy()
		if self.Root then
			self.Root:Destroy()
			self.Root = nil
		end
	end

	return Section
end
