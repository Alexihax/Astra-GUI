return function()
	local Icons = {}

	local glyphs = {
		Home = "H",
		Settings = "S",
		Search = "?",
		User = "U",
		Info = "i",
		Success = "+",
		Error = "!",
		Warning = "!",
		Close = "X",
		Minimize = "-",
		Menu = "=",
		Chevron = ">",
		Check = "+",
	}

	function Icons.Resolve(icon)
		if type(icon) == "number" then
			return { Type = "Image", Value = "rbxassetid://" .. tostring(icon) }
		end
		if type(icon) == "string" then
			if string.find(icon, "rbxassetid://", 1, true) or string.find(icon, "http", 1, true) then
				return { Type = "Image", Value = icon }
			end
			return { Type = "Text", Value = glyphs[icon] or string.sub(icon, 1, 1) }
		end
		return nil
	end

	function Icons.Register(name, value)
		assert(type(name) == "string", "Icon name must be a string")
		glyphs[name] = value
	end

	return Icons
end
