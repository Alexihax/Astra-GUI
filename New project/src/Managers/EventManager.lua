return function(Require)
	local Signal = Require("Utils.Signals")
	local EventManager = {}
	EventManager.__index = EventManager

	function EventManager.new()
		return setmetatable({
			_events = {},
		}, EventManager)
	end

	function EventManager:Get(name)
		if not self._events[name] then
			self._events[name] = Signal.new()
		end
		return self._events[name]
	end

	function EventManager:On(name, callback)
		return self:Get(name):Connect(callback)
	end

	function EventManager:Once(name, callback)
		return self:Get(name):Once(callback)
	end

	function EventManager:Emit(name, ...)
		self:Get(name):Fire(...)
	end

	function EventManager:Destroy()
		for _, signal in pairs(self._events) do
			signal:Destroy()
		end
		table.clear(self._events)
	end

	return EventManager
end
