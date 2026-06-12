return function()
	local Icons = {}

	local glyphs = {
		Astra = "✦",
		Dashboard = "✦",
		Home = "⌂",
		Combat = "⚔",
		Player = "◉",
		User = "◉",
		Visuals = "◇",
		Eye = "◇",
		Theme = "◆",
		Palette = "◆",
		Settings = "⚙",
		Config = "▣",
		Folder = "▣",
		Cloud = "☁",
		Search = "⌕",
		Info = "ⓘ",
		Code = "</>",
		Shield = "⬡",
		Target = "◎",
		Lightning = "ϟ",
		Success = "✓",
		Error = "×",
		Warning = "!",
		Close = "×",
		Minimize = "−",
		Menu = "≡",
		Chevron = "›",
		Check = "✓",
	}

	function Icons.Resolve(icon)
		if type(icon) == "number" then
			return { Type = "Image", Value = "rbxassetid://" .. tostring(icon) }
		end
		if type(icon) == "string" then
			if string.find(icon, "rbxassetid://", 1, true) or string.find(icon, "http", 1, true) then
				return { Type = "Image", Value = icon }
			end
			return { Type = "Text", Value = glyphs[icon] or "✦" }
		end
		return nil
	end

	function Icons.Register(name, value)
		assert(type(name) == "string", "Icon name must be a string")
		glyphs[name] = value
	end

	return Icons
end
