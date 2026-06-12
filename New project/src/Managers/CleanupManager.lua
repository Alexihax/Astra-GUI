return function()
	local CleanupManager = {}
	CleanupManager.__index = CleanupManager

	function CleanupManager.new()
		return setmetatable({
			_tasks = {},
			_destroyed = false,
		}, CleanupManager)
	end

	function CleanupManager:Add(taskValue)
		if self._destroyed then
			self:_CleanTask(taskValue)
			return taskValue
		end
		table.insert(self._tasks, taskValue)
		return taskValue
	end

	function CleanupManager:_CleanTask(taskValue)
		local valueType = typeof(taskValue)
		if valueType == "RBXScriptConnection" then
			taskValue:Disconnect()
		elseif valueType == "Instance" then
			taskValue:Destroy()
		elseif type(taskValue) == "function" then
			taskValue()
		elseif type(taskValue) == "thread" then
			task.cancel(taskValue)
		elseif type(taskValue) == "table" then
			if type(taskValue.Destroy) == "function" then
				taskValue:Destroy()
			elseif type(taskValue.Disconnect) == "function" then
				taskValue:Disconnect()
			elseif type(taskValue.Cancel) == "function" then
				taskValue:Cancel()
			end
		end
	end

	function CleanupManager:Remove(taskValue)
		local index = table.find(self._tasks, taskValue)
		if index then
			table.remove(self._tasks, index)
			self:_CleanTask(taskValue)
			return true
		end
		return false
	end

	function CleanupManager:Clean()
		for index = #self._tasks, 1, -1 do
			local taskValue = table.remove(self._tasks, index)
			local ok, err = pcall(function()
				self:_CleanTask(taskValue)
			end)
			if not ok then
				warn("[ModernUI] Cleanup error:", err)
			end
		end
	end

	function CleanupManager:Destroy()
		if self._destroyed then
			return
		end
		self._destroyed = true
		self:Clean()
	end

	return CleanupManager
end
