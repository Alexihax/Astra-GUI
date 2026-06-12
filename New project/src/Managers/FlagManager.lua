return function(Require)
	local Signal = Require("Utils.Signals")
	local FlagManager = {}
	FlagManager.__index = FlagManager

	function FlagManager.new()
		return setmetatable({
			_components = {},
			_values = {},
			Changed = Signal.new(),
		}, FlagManager)
	end

	function FlagManager:Register(flag, component)
		if not flag or flag == "" then
			return
		end
		if self._components[flag] and self._components[flag] ~= component then
			warn("[Astra UI] Flag '" .. flag .. "' was registered more than once")
		end
		self._components[flag] = component
		self._values[flag] = component:GetValue()
	end

	function FlagManager:Unregister(flag, component)
		if self._components[flag] == component then
			self._components[flag] = nil
			self._values[flag] = nil
		end
	end

	function FlagManager:Update(flag, value, source)
		if not flag or flag == "" then
			return
		end
		local previous = self._values[flag]
		self._values[flag] = value
		if previous ~= value then
			self.Changed:Fire(flag, value, previous, source)
		end
	end

	function FlagManager:Get(flag, defaultValue)
		local value = self._values[flag]
		if value == nil then
			return defaultValue
		end
		return value
	end

	function FlagManager:Set(flag, value, silent)
		local component = self._components[flag]
		if component then
			component:SetValue(value, silent)
		else
			self:Update(flag, value)
		end
	end

	function FlagManager:Export()
		return table.clone(self._values)
	end

	function FlagManager:Import(values, silent)
		for flag, value in pairs(values or {}) do
			self:Set(flag, value, silent)
		end
	end

	function FlagManager:Destroy()
		self.Changed:Destroy()
		table.clear(self._components)
		table.clear(self._values)
	end

	return FlagManager
end
