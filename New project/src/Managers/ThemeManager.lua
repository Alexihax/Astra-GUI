return function(Require)
	local Signal = Require("Utils.Signals")
	local ThemeManager = {}
	ThemeManager.__index = ThemeManager

	local requiredTokens = {
		"Background",
		"Surface",
		"SurfaceAlt",
		"SurfaceHover",
		"Accent",
		"AccentAlt",
		"Text",
		"MutedText",
		"Border",
		"Success",
		"Warning",
		"Error",
		"Shadow",
	}

	function ThemeManager.new()
		local self = setmetatable({
			Themes = {},
			Bindings = setmetatable({}, { __mode = "k" }),
			Changed = Signal.new(),
		}, ThemeManager)

		for _, name in ipairs({
			"Dark",
			"Light",
			"Midnight",
			"Crimson",
			"Emerald",
			"Ocean",
			"Purple",
			"Rose",
			"Discord",
			"FluentInspired",
			"RayfieldInspired",
		}) do
			self:Register(name, Require("Themes." .. name))
		end
		self.CurrentName = "Dark"
		self.Current = self.Themes.Dark
		return self
	end

	function ThemeManager:Register(name, theme)
		assert(type(name) == "string" and name ~= "", "Theme name is required")
		assert(type(theme) == "table", "Theme must be a table")
		local base = self.Themes.Dark
		local normalized = base and table.clone(base) or {}
		for key, value in pairs(theme) do
			normalized[key] = value
		end
		normalized.Name = name
		for _, token in ipairs(requiredTokens) do
			assert(normalized[token] ~= nil, "Theme is missing token: " .. token)
		end
		self.Themes[name] = normalized
		return normalized
	end

	function ThemeManager:Get(name)
		return self.Themes[name or self.CurrentName]
	end

	function ThemeManager:Bind(instance, propertyMap)
		if not instance then
			return
		end
		self.Bindings[instance] = propertyMap
		self:ApplyTo(instance, propertyMap)
	end

	function ThemeManager:ApplyTo(instance, propertyMap)
		if not instance.Parent and not instance:IsA("ScreenGui") then
			return
		end
		for property, token in pairs(propertyMap) do
			local value = type(token) == "function" and token(self.Current) or self.Current[token]
			if value ~= nil then
				local ok, err = pcall(function()
					instance[property] = value
				end)
				if not ok then
					warn("[ModernUI] Theme binding failed:", err)
				end
			end
		end
	end

	function ThemeManager:Set(theme)
		local resolved
		local name
		if type(theme) == "string" then
			resolved = self.Themes[theme]
			name = theme
		else
			name = theme.Name or "Custom"
			resolved = self:Register(name, theme)
		end
		assert(resolved, "Unknown theme: " .. tostring(theme))
		self.CurrentName = name
		self.Current = resolved
		for instance, propertyMap in pairs(self.Bindings) do
			if instance.Parent then
				self:ApplyTo(instance, propertyMap)
			else
				self.Bindings[instance] = nil
			end
		end
		self.Changed:Fire(resolved, name)
		return resolved
	end

	function ThemeManager:Destroy()
		self.Changed:Destroy()
		table.clear(self.Bindings)
	end

	return ThemeManager
end
