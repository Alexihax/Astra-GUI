--!strict

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local ClickGui = {}
ClickGui.__index = ClickGui

export type Theme = {
	Background: Color3,
	Surface: Color3,
	SurfaceHover: Color3,
	Accent: Color3,
	Text: Color3,
	MutedText: Color3,
	CornerRadius: UDim,
}

local DEFAULT_THEME: Theme = {
	Background = Color3.fromRGB(18, 18, 23),
	Surface = Color3.fromRGB(29, 29, 37),
	SurfaceHover = Color3.fromRGB(39, 39, 50),
	Accent = Color3.fromRGB(111, 92, 255),
	Text = Color3.fromRGB(245, 245, 250),
	MutedText = Color3.fromRGB(165, 165, 180),
	CornerRadius = UDim.new(0, 7),
}

local function create(className: string, properties: {[string]: any}?, children: {Instance}?): Instance
	local instance = Instance.new(className)
	if properties then
		for property, value in properties do
			(instance :: any)[property] = value
		end
	end
	if children then
		for _, child in children do
			child.Parent = instance
		end
	end
	return instance
end

local function corner(radius: UDim): UICorner
	return create("UICorner", {CornerRadius = radius}) :: UICorner
end

local function padding(value: number): UIPadding
	return create("UIPadding", {
		PaddingTop = UDim.new(0, value),
		PaddingBottom = UDim.new(0, value),
		PaddingLeft = UDim.new(0, value),
		PaddingRight = UDim.new(0, value),
	}) :: UIPadding
end

local function tween(instance: Instance, properties: {[string]: any}, duration: number?)
	TweenService:Create(
		instance,
		TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		properties
	):Play()
end

local function bindCanvasSize(scroller: ScrollingFrame, layout: UIListLayout, extra: number?)
	local function update()
		scroller.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + (extra or 0))
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	update()
end

local function makeDraggable(handle: GuiObject, target: GuiObject)
	local dragging = false
	local dragStart = Vector2.zero
	local startPosition = target.Position

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = target.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local function mergeTheme(customTheme: {[string]: any}?): Theme
	local result = table.clone(DEFAULT_THEME) :: any
	if customTheme then
		for key, value in customTheme do
			result[key] = value
		end
	end
	return result
end

function ClickGui.new(config: {[string]: any}?)
	config = config or {}
	local self = setmetatable({}, ClickGui)
	self.Theme = mergeTheme(config.Theme)
	self.ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift
	self.Visible = true
	self.Windows = {}
	self.Connections = {}

	local screenGui = create("ScreenGui", {
		Name = config.Name or "ClickGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = config.DisplayOrder or 100,
	}) :: ScreenGui

	local parent = config.Parent
	if parent == nil then
		local ok, result = pcall(function()
			return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		end)
		parent = if ok then result else CoreGui
	end
	screenGui.Parent = parent
	self.ScreenGui = screenGui

	table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == self.ToggleKey then
			self:Toggle()
		end
	end))

	return self
end

function ClickGui:Toggle(force: boolean?)
	if force == nil then
		self.Visible = not self.Visible
	else
		self.Visible = force
	end
	self.ScreenGui.Enabled = self.Visible
end

function ClickGui:Destroy()
	for _, connection in self.Connections do
		connection:Disconnect()
	end
	table.clear(self.Connections)
	self.ScreenGui:Destroy()
end

function ClickGui:Notify(options: {[string]: any}?)
	options = options or {}
	local theme = self.Theme
	local notification = create("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 330, 1, -20),
		Size = UDim2.fromOffset(300, 76),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Parent = self.ScreenGui,
	}, {
		corner(theme.CornerRadius),
		padding(12),
	}) :: Frame

	create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Text = options.Title or "Notification",
		TextColor3 = theme.Text,
		TextSize = 15,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = notification,
	})

	create("TextLabel", {
		Position = UDim2.fromOffset(0, 26),
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		Text = options.Text or "",
		TextColor3 = theme.MutedText,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = notification,
	})

	tween(notification, {Position = UDim2.new(1, -20, 1, -20)}, 0.3)
	task.delay(options.Duration or 3, function()
		if notification.Parent then
			tween(notification, {Position = UDim2.new(1, 330, 1, -20)}, 0.25)
			task.delay(0.3, function()
				notification:Destroy()
			end)
		end
	end)
end

function ClickGui:CreateWindow(options: {[string]: any}?)
	options = options or {}
	local library = self
	local theme = self.Theme
	local window = {Tabs = {}, ActiveTab = nil}

	local frame = create("Frame", {
		Name = options.Title or "Window",
		Position = options.Position or UDim2.fromOffset(120 + (#self.Windows * 30), 100 + (#self.Windows * 30)),
		Size = options.Size or UDim2.fromOffset(520, 390),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = self.ScreenGui,
	}, {
		corner(theme.CornerRadius),
	}) :: Frame
	window.Frame = frame

	local topbar = create("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Parent = frame,
	}) :: Frame

	create("TextLabel", {
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -60, 1, 0),
		BackgroundTransparency = 1,
		Text = options.Title or "Click GUI",
		TextColor3 = theme.Text,
		TextSize = 16,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topbar,
	})

	local close = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		Text = "X",
		TextColor3 = theme.MutedText,
		TextSize = 20,
		Font = Enum.Font.Gotham,
		AutoButtonColor = false,
		Parent = topbar,
	}, {
		corner(UDim.new(0, 6)),
	}) :: TextButton
	close.MouseButton1Click:Connect(function()
		frame.Visible = false
	end)

	makeDraggable(topbar, frame)

	local sidebar = create("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 44),
		Size = UDim2.new(0, 145, 1, -44),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.fromOffset(0, 0),
		Parent = frame,
	}, {
		padding(9),
	}) :: ScrollingFrame
	local sideLayout = create("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sidebar,
	}) :: UIListLayout
	bindCanvasSize(sidebar, sideLayout, 18)

	local content = create("Frame", {
		Position = UDim2.fromOffset(145, 44),
		Size = UDim2.new(1, -145, 1, -44),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = frame,
	}) :: Frame

	function window:SetVisible(visible: boolean)
		frame.Visible = visible
	end

	function window:Destroy()
		frame:Destroy()
	end

	function window:CreateTab(tabOptions: any)
		if type(tabOptions) == "string" then
			tabOptions = {Name = tabOptions}
		end
		tabOptions = tabOptions or {}

		local tab = {}
		local tabButton = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = theme.Surface,
			BorderSizePixel = 0,
			Text = tabOptions.Name or "Tab",
			TextColor3 = theme.MutedText,
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false,
			Parent = sidebar,
		}, {
			corner(UDim.new(0, 6)),
			padding(10),
		}) :: TextButton

		local page = create("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = theme.Accent,
			CanvasSize = UDim2.fromOffset(0, 0),
			Visible = false,
			Parent = content,
		}, {
			padding(12),
		}) :: ScrollingFrame
		local layout = create("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = page,
		}) :: UIListLayout
		bindCanvasSize(page, layout, 24)

		local function activate()
			for _, otherTab in window.Tabs do
				otherTab.Page.Visible = false
				tween(otherTab.Button, {
					BackgroundColor3 = theme.Surface,
					TextColor3 = theme.MutedText,
				})
			end
			page.Visible = true
			tween(tabButton, {
				BackgroundColor3 = theme.Accent,
				TextColor3 = theme.Text,
			})
			window.ActiveTab = tab
		end

		tabButton.MouseButton1Click:Connect(activate)
		tab.Button = tabButton
		tab.Page = page

		local function row(height: number): Frame
			return create("Frame", {
				Size = UDim2.new(1, 0, 0, height),
				BackgroundColor3 = theme.Surface,
				BorderSizePixel = 0,
				Parent = page,
			}, {
				corner(theme.CornerRadius),
			}) :: Frame
		end

		function tab:AddLabel(text: string)
			return create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = theme.MutedText,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = page,
			}) :: TextLabel
		end

		function tab:AddButton(buttonOptions: any)
			if type(buttonOptions) == "string" then
				buttonOptions = {Text = buttonOptions}
			end
			buttonOptions = buttonOptions or {}
			local button = create("TextButton", {
				Size = UDim2.new(1, 0, 0, 42),
				BackgroundColor3 = theme.Surface,
				BorderSizePixel = 0,
				Text = buttonOptions.Text or "Button",
				TextColor3 = theme.Text,
				TextSize = 14,
				Font = Enum.Font.GothamMedium,
				AutoButtonColor = false,
				Parent = page,
			}, {
				corner(theme.CornerRadius),
			}) :: TextButton
			button.MouseEnter:Connect(function()
				tween(button, {BackgroundColor3 = theme.SurfaceHover})
			end)
			button.MouseLeave:Connect(function()
				tween(button, {BackgroundColor3 = theme.Surface})
			end)
			button.MouseButton1Click:Connect(function()
				if buttonOptions.Callback then
					task.spawn(buttonOptions.Callback)
				end
			end)
			return button
		end

		function tab:AddToggle(toggleOptions: {[string]: any}?)
			toggleOptions = toggleOptions or {}
			local value = toggleOptions.Default == true
			local container = row(46)
			create("TextLabel", {
				Position = UDim2.fromOffset(12, 0),
				Size = UDim2.new(1, -66, 1, 0),
				BackgroundTransparency = 1,
				Text = toggleOptions.Text or "Toggle",
				TextColor3 = theme.Text,
				TextSize = 14,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = container,
			})
			local track = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.fromOffset(38, 20),
				BackgroundColor3 = if value then theme.Accent else theme.SurfaceHover,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				Parent = container,
			}, {
				corner(UDim.new(1, 0)),
			}) :: TextButton
			local knob = create("Frame", {
				Position = if value then UDim2.fromOffset(20, 3) else UDim2.fromOffset(3, 3),
				Size = UDim2.fromOffset(14, 14),
				BackgroundColor3 = theme.Text,
				BorderSizePixel = 0,
				Parent = track,
			}, {
				corner(UDim.new(1, 0)),
			}) :: Frame

			local controller = {}
			function controller:Set(newValue: boolean, silent: boolean?)
				value = newValue
				tween(track, {BackgroundColor3 = if value then theme.Accent else theme.SurfaceHover})
				tween(knob, {Position = if value then UDim2.fromOffset(20, 3) else UDim2.fromOffset(3, 3)})
				if not silent and toggleOptions.Callback then
					task.spawn(toggleOptions.Callback, value)
				end
			end
			function controller:Get(): boolean
				return value
			end
			track.MouseButton1Click:Connect(function()
				controller:Set(not value)
			end)
			return controller
		end

		function tab:AddSlider(sliderOptions: {[string]: any}?)
			sliderOptions = sliderOptions or {}
			local minimum = sliderOptions.Min or 0
			local maximum = sliderOptions.Max or 100
			local step = sliderOptions.Step or 1
			local value = math.clamp(sliderOptions.Default or minimum, minimum, maximum)
			local container = row(62)

			create("TextLabel", {
				Position = UDim2.fromOffset(12, 7),
				Size = UDim2.new(1, -70, 0, 20),
				BackgroundTransparency = 1,
				Text = sliderOptions.Text or "Slider",
				TextColor3 = theme.Text,
				TextSize = 14,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = container,
			}) :: TextLabel
			local valueLabel = create("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -12, 0, 7),
				Size = UDim2.fromOffset(50, 20),
				BackgroundTransparency = 1,
				Text = tostring(value),
				TextColor3 = theme.MutedText,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = container,
			}) :: TextLabel
			local track = create("TextButton", {
				Position = UDim2.fromOffset(12, 39),
				Size = UDim2.new(1, -24, 0, 7),
				BackgroundColor3 = theme.SurfaceHover,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				Parent = container,
			}, {
				corner(UDim.new(1, 0)),
			}) :: TextButton
			local fill = create("Frame", {
				Size = UDim2.fromScale(
					if maximum == minimum then 0 else (value - minimum) / (maximum - minimum),
					1
				),
				BackgroundColor3 = theme.Accent,
				BorderSizePixel = 0,
				Parent = track,
			}, {
				corner(UDim.new(1, 0)),
			}) :: Frame

			local controller = {}
			function controller:Set(newValue: number, silent: boolean?)
				newValue = math.clamp(newValue, minimum, maximum)
				value = math.round(newValue / step) * step
				value = math.clamp(value, minimum, maximum)
				local alpha = if maximum == minimum then 0 else (value - minimum) / (maximum - minimum)
				fill.Size = UDim2.fromScale(alpha, 1)
				valueLabel.Text = tostring(value)
				if not silent and sliderOptions.Callback then
					task.spawn(sliderOptions.Callback, value)
				end
			end
			function controller:Get(): number
				return value
			end

			local sliding = false
			local function update(input: InputObject)
				local alpha = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				controller:Set(minimum + (maximum - minimum) * alpha)
			end
			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					sliding = true
					update(input)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch) then
					update(input)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					sliding = false
				end
			end)
			return controller
		end

		function tab:AddDropdown(dropdownOptions: {[string]: any}?)
			dropdownOptions = dropdownOptions or {}
			local values = dropdownOptions.Values or {}
			local selected = dropdownOptions.Default
			local open = false
			local container = row(44)
			container.ClipsDescendants = true

			local header = create("TextButton", {
				Size = UDim2.new(1, 0, 0, 44),
				BackgroundTransparency = 1,
				Text = "",
				Parent = container,
			}) :: TextButton
			create("TextLabel", {
				Position = UDim2.fromOffset(12, 0),
				Size = UDim2.new(0.5, -12, 0, 44),
				BackgroundTransparency = 1,
				Text = dropdownOptions.Text or "Dropdown",
				TextColor3 = theme.Text,
				TextSize = 14,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = header,
			})
			local selectedLabel = create("TextLabel", {
				Position = UDim2.new(0.5, 0, 0, 0),
				Size = UDim2.new(0.5, -12, 0, 44),
				BackgroundTransparency = 1,
				Text = selected and tostring(selected) or "Select",
				TextColor3 = theme.MutedText,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = header,
			}) :: TextLabel

			local optionsHolder = create("Frame", {
				Position = UDim2.fromOffset(8, 44),
				Size = UDim2.new(1, -16, 0, #values * 34),
				BackgroundTransparency = 1,
				Parent = container,
			}) :: Frame
			create("UIListLayout", {
				Padding = UDim.new(0, 3),
				Parent = optionsHolder,
			})

			local controller = {}
			function controller:Set(newValue: any, silent: boolean?)
				selected = newValue
				selectedLabel.Text = tostring(newValue)
				if not silent and dropdownOptions.Callback then
					task.spawn(dropdownOptions.Callback, selected)
				end
			end
			function controller:Get(): any
				return selected
			end

			for _, option in values do
				local optionButton = create("TextButton", {
					Size = UDim2.new(1, 0, 0, 31),
					BackgroundColor3 = theme.SurfaceHover,
					BorderSizePixel = 0,
					Text = tostring(option),
					TextColor3 = theme.Text,
					TextSize = 13,
					Font = Enum.Font.Gotham,
					AutoButtonColor = false,
					Parent = optionsHolder,
				}, {
					corner(UDim.new(0, 5)),
				}) :: TextButton
				optionButton.MouseButton1Click:Connect(function()
					controller:Set(option)
					open = false
					tween(container, {Size = UDim2.new(1, 0, 0, 44)})
				end)
			end

			header.MouseButton1Click:Connect(function()
				open = not open
				tween(container, {
					Size = UDim2.new(1, 0, 0, if open then 52 + (#values * 34) else 44),
				})
			end)
			return controller
		end

		table.insert(window.Tabs, tab)
		if #window.Tabs == 1 then
			activate()
		end
		return tab
	end

	table.insert(self.Windows, window)
	return window
end

return ClickGui
