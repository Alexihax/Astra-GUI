return function(Require)
	local Signal = Require("Utils.Signals")
	local StateManager = {}
	StateManager.__index = StateManager

	function StateManager.new(initialState)
		return setmetatable({
			_values = table.clone(initialState or {}),
			_signals = {},
			Changed = Signal.new(),
		}, StateManager)
	end

	function StateManager:Get(key, defaultValue)
		local value = self._values[key]
		if value == nil then
			return defaultValue
		end
		return value
	end

	function StateManager:Set(key, value)
		local previous = self._values[key]
		if previous == value then
			return value
		end
		self._values[key] = value
		self.Changed:Fire(key, value, previous)
		if self._signals[key] then
			self._signals[key]:Fire(value, previous)
		end
		return value
	end

	function StateManager:Observe(key, callback, fireImmediately)
		if not self._signals[key] then
			self._signals[key] = Signal.new()
		end
		local connection = self._signals[key]:Connect(callback)
		if fireImmediately then
			task.spawn(callback, self._values[key], nil)
		end
		return connection
	end

	function StateManager:Snapshot()
		return table.clone(self._values)
	end

	function StateManager:Destroy()
		self.Changed:Destroy()
		for _, signal in pairs(self._signals) do
			signal:Destroy()
		end
		table.clear(self._signals)
		table.clear(self._values)
	end

	return StateManager
end
