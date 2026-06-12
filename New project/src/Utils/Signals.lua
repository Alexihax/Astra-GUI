return function()
	local Signal = {}
	Signal.__index = Signal

	local Connection = {}
	Connection.__index = Connection

	function Connection.new(signal, callback)
		return setmetatable({
			Connected = true,
			_signal = signal,
			_callback = callback,
		}, Connection)
	end

	function Connection:Disconnect()
		if not self.Connected then
			return
		end
		self.Connected = false
		self._signal._connections[self] = nil
	end

	function Signal.new()
		return setmetatable({
			_connections = {},
			_waiting = {},
			_destroyed = false,
		}, Signal)
	end

	function Signal:Connect(callback)
		assert(type(callback) == "function", "Signal:Connect expects a function")
		assert(not self._destroyed, "Cannot connect to a destroyed signal")
		local connection = Connection.new(self, callback)
		self._connections[connection] = true
		return connection
	end

	function Signal:Once(callback)
		local connection
		connection = self:Connect(function(...)
			connection:Disconnect()
			callback(...)
		end)
		return connection
	end

	function Signal:Fire(...)
		if self._destroyed then
			return
		end
		local arguments = table.pack(...)
		for connection in pairs(self._connections) do
			if connection.Connected then
				task.spawn(connection._callback, table.unpack(arguments, 1, arguments.n))
			end
		end
		for thread in pairs(self._waiting) do
			self._waiting[thread] = nil
			task.spawn(thread, table.unpack(arguments, 1, arguments.n))
		end
	end

	function Signal:Wait()
		assert(not self._destroyed, "Cannot wait on a destroyed signal")
		local thread = coroutine.running()
		self._waiting[thread] = true
		return coroutine.yield()
	end

	function Signal:Destroy()
		self._destroyed = true
		for connection in pairs(self._connections) do
			connection:Disconnect()
		end
		for thread in pairs(self._waiting) do
			task.cancel(thread)
		end
		table.clear(self._connections)
		table.clear(self._waiting)
	end

	return Signal
end
