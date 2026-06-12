return function(Require)
	local UI = Require("Utils.UI")
	local ComponentBase = Require("Components.ComponentBase")
	local ComponentUI = Require("Components.ComponentUI")
	local Image = {}
	Image.__index = Image

	local function normalize(value)
		if type(value) == "number" then
			return "rbxassetid://" .. tostring(value)
		end
		return tostring(value or "")
	end

	function Image.new(section, options)
		options = options or {}
		local height = options.Height or 180
		local root, title, description = ComponentUI.Card(section, options, height)
		if options.Title and options.Title ~= "" then
			title.Size = UDim2.new(1, -26, 0, 24)
		else
			title.Visible = false
		end
		local image = UI.Create("ImageLabel", {
			BackgroundTransparency = 1,
			Image = "",
			ImageColor3 = options.ImageColor or Color3.new(1, 1, 1),
			ImageTransparency = options.ImageTransparency or 0,
			Position = UDim2.fromOffset(10, options.Title and 34 or 10),
			ScaleType = options.ScaleType or Enum.ScaleType.Crop,
			Size = UDim2.new(1, -20, 1, options.Title and -44 or -20),
			Parent = root,
		}, { UI.Corner(options.CornerRadius or 7) })
		local base = ComponentUI.AttachBase(ComponentBase.new(section, options, root), title, description)
		local self = ComponentUI.CopyBaseMethods(setmetatable({}, Image), base)
		self.ImageLabel = image
		self:SetValue(options.Image or options.Default or "", true)
		return self
	end

	function Image:SetValue(value, silent)
		value = normalize(value)
		self._base:_Commit(value, silent)
		self.ImageLabel.Image = value
		return self
	end

	return Image
end
