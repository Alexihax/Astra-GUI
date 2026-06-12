return function(Require)
	local Signal = Require("Utils.Signals")
	local CleanupManager = Require("Managers.CleanupManager")
	local ComponentBase = {}
	ComponentBase.__index = ComponentBase

	function ComponentBase.new(section, options, root)
		options = options or {}
		local self = setmetatable({
			Library = section.Library,
			Section = section,
			Options = options,
			Root = root,
			Title = options.Title or options.Name or "",
			Description = options.Description or "",
			Value = options.Default,
			Flag = options.Flag,
			Visible = options.Visible ~= false,
			SearchVisible = true,
			Destroyed = false,
			Changed = Signal.new(),
			Cleanup = CleanupManager.new(),
		}, ComponentBase)

		if self.Flag then
			self.Library.FlagManager:Register(self.Flag, self)
		end
		self:_BindTooltip()
		self:_BindConditions()
		return self
	end

	function ComponentBase:_BindTooltip()
		local tooltip = self.Options.Tooltip
		if not tooltip or tooltip == "" then
			return
		end
		self.Cleanup:Add(self.Root.MouseEnter:Connect(function()
			self.Library:_ShowTooltip(tostring(tooltip), self.Root)
		end))
		self.Cleanup:Add(self.Root.MouseLeave:Connect(function()
			self.Library:_HideTooltip()
		end))
	end

	function ComponentBase:_BindConditions()
		local dependency = self.Options.DependsOn
		if type(dependency) == "table" then
			local component = dependency.Component
			if component and component.Changed then
				self.Cleanup:Add(component.Changed:Connect(function()
					self:_RefreshVisibility()
				end))
			elseif dependency.Flag then
				self.Cleanup:Add(self.Library.FlagManager.Changed:Connect(function(flag)
					if flag == dependency.Flag then
						self:_RefreshVisibility()
					end
				end))
			end
		end
		self:_RefreshVisibility()
	end

	function ComponentBase:_ConditionPasses()
		local visibleWhen = self.Options.VisibleWhen
		if type(visibleWhen) == "function" then
			local ok, result = pcall(visibleWhen, self.Library.FlagManager:Export(), self)
			return ok and result ~= false
		end

		local dependency = self.Options.DependsOn
		if type(dependency) ~= "table" then
			return true
		end
		local value
		if dependency.Component and dependency.Component.GetValue then
			value = dependency.Component:GetValue()
		elseif dependency.Flag then
			value = self.Library.FlagManager:Get(dependency.Flag)
		end
		if dependency.Predicate then
			local ok, result = pcall(dependency.Predicate, value)
			return ok and result ~= false
		end
		if dependency.Value ~= nil then
			return value == dependency.Value
		end
		return value == true
	end

	function ComponentBase:_RefreshVisibility()
		if self.Root then
			self.Root.Visible = self.Visible and self.SearchVisible and self:_ConditionPasses()
		end
	end

	function ComponentBase:_SetSearchVisible(visible)
		self.SearchVisible = visible == true
		self:_RefreshVisibility()
	end

	function ComponentBase:_Commit(value, silent)
		local previous = self.Value
		self.Value = value
		if self.Flag then
			self.Library.FlagManager:Update(self.Flag, value, self)
		end
		if previous ~= value then
			self.Changed:Fire(value, previous)
		end
		if not silent then
			local callback = self.Options.Callback
			if type(callback) == "function" then
				task.spawn(function()
					local ok, err = xpcall(function()
						callback(value, previous, self)
					end, debug.traceback)
					if not ok then
						warn("[ModernUI] Component callback failed:", err)
					end
				end)
			end
		end
		return value
	end

	function ComponentBase:GetValue()
		return self.Value
	end

	function ComponentBase:SetValue(value, silent)
		return self:_Commit(value, silent)
	end

	function ComponentBase:SetTitle(title)
		self.Title = tostring(title or "")
		if self.TitleLabel then
			self.TitleLabel.Text = self.Title
		end
		return self
	end

	function ComponentBase:SetDescription(description)
		local hadDescription = self.Description ~= ""
		self.Description = tostring(description or "")
		self.Options.Description = self.Description
		if self.DescriptionLabel then
			self.DescriptionLabel.Text = self.Description
			self.DescriptionLabel.Visible = self.Description ~= ""
			local hasDescription = self.Description ~= ""
			if self.TitleLabel then
				self.TitleLabel.Position = UDim2.fromOffset(13, hasDescription and 7 or 0)
				self.TitleLabel.Size = UDim2.new(
					self.TitleLabel.Size.X.Scale,
					self.TitleLabel.Size.X.Offset,
					0,
					hasDescription and 20 or math.max(self.Root.Size.Y.Offset, 20)
				)
			end
			if hadDescription ~= hasDescription and self.Root then
				local delta = hasDescription and 12 or -12
				self.Root.Size = UDim2.new(
					self.Root.Size.X.Scale,
					self.Root.Size.X.Offset,
					self.Root.Size.Y.Scale,
					math.max(24, self.Root.Size.Y.Offset + delta)
				)
			end
		end
		return self
	end

	function ComponentBase:SetVisible(visible)
		self.Visible = visible == true
		self:_RefreshVisibility()
		return self
	end

	function ComponentBase:Hide()
		return self:SetVisible(false)
	end

	function ComponentBase:Show()
		return self:SetVisible(true)
	end

	function ComponentBase:Destroy()
		if self.Destroyed then
			return
		end
		self.Destroyed = true
		if self.Flag then
			self.Library.FlagManager:Unregister(self.Flag, self)
		end
		self.Changed:Destroy()
		self.Cleanup:Destroy()
		if self.Root then
			self.Root:Destroy()
			self.Root = nil
		end
	end

	return ComponentBase
end
