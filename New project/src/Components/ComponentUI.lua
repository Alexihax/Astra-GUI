return function(Require)
	local UI = Require("Utils.UI")
	local ComponentUI = {}

	function ComponentUI.Card(section, options, height)
		local library = section.Library
		local root = UI.Create("Frame", {
			Name = (options.Title or options.Name or "Component") .. "Component",
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			LayoutOrder = section:_NextOrder(),
			Size = UDim2.new(1, 0, 0, height or 48),
			Parent = section.Content,
		}, {
			UI.Corner(9),
			UI.Stroke(),
		})
		library.ThemeManager:Bind(root, {
			BackgroundColor3 = "SurfaceAlt",
		})
		library.ThemeManager:Bind(root:FindFirstChildOfClass("UIStroke"), {
			Color = "Border",
		})

		local title = UI.Text(options.Title or options.Name or "", 14, Enum.Font.GothamSemibold)
		title.Name = "Title"
		title.Position = UDim2.fromOffset(13, options.Description and 7 or 0)
		title.Size = UDim2.new(1, -26, 0, options.Description and 20 or height or 48)
		title.Parent = root
		library.ThemeManager:Bind(title, {
			TextColor3 = "Text",
		})

		local description = UI.Text(options.Description or "", 12, Enum.Font.Gotham)
		description.Name = "Description"
		description.Position = UDim2.fromOffset(13, 26)
		description.Size = UDim2.new(1, -26, 0, 18)
		description.Visible = options.Description ~= nil and options.Description ~= ""
		description.Parent = root
		library.ThemeManager:Bind(description, {
			TextColor3 = "MutedText",
		})

		return root, title, description
	end

	function ComponentUI.AttachBase(base, title, description)
		base.TitleLabel = title
		base.DescriptionLabel = description
		return base
	end

	function ComponentUI.CopyBaseMethods(target, base)
		target._base = base
		target.Options = base.Options
		target.Library = base.Library
		target.Section = base.Section
		target.Title = base.Title
		target.Description = base.Description
		target.Flag = base.Flag
		for _, method in ipairs({
			"GetValue",
			"SetTitle",
			"SetDescription",
			"SetVisible",
			"Hide",
			"Show",
			"Destroy",
		}) do
			target[method] = function(self, ...)
				return base[method](base, ...)
			end
		end
		target.Changed = base.Changed
		target.Root = base.Root
		return target
	end

	return ComponentUI
end
