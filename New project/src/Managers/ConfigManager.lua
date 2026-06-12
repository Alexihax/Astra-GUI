return function(Require)
	local Signal = Require("Utils.Signals")
	local HttpService = game:GetService("HttpService")
	local ConfigManager = {}
	ConfigManager.__index = ConfigManager

	local function encodeValue(value)
		local valueType = typeof(value)
		if valueType == "Color3" then
			return {
				__type = "Color3",
				r = value.R,
				g = value.G,
				b = value.B,
			}
		end
		if valueType == "EnumItem" then
			return {
				__type = "EnumItem",
				enum = tostring(value.EnumType),
				name = value.Name,
			}
		end
		if type(value) == "table" then
			local result = {}
			for key, child in pairs(value) do
				result[key] = encodeValue(child)
			end
			return result
		end
		return value
	end

	local function decodeValue(value)
		if type(value) ~= "table" then
			return value
		end
		if value.__type == "Color3" then
			return Color3.new(value.r, value.g, value.b)
		end
		if value.__type == "EnumItem" then
			local enumName = string.match(value.enum or "", "Enum%.(.+)")
			local enumType = enumName and Enum[enumName]
			return enumType and enumType[value.name] or value.name
		end
		local result = {}
		for key, child in pairs(value) do
			result[key] = decodeValue(child)
		end
		return result
	end

	local function cleanName(name)
		return string.gsub(tostring(name or "default"), "[^%w%-%_]", "_")
	end

	function ConfigManager.new(flagManager, themeManager, capabilities)
		local self = setmetatable({
			Flags = flagManager,
			Themes = themeManager,
			Capabilities = capabilities,
			Folder = "ModernUI",
			Memory = {},
			AutoSave = false,
			AutoSaveName = "autosave",
			AutoSaveDelay = 0.75,
			_pendingAutoSave = nil,
			Saved = Signal.new(),
			Loaded = Signal.new(),
		}, ConfigManager)

		self._flagConnection = flagManager.Changed:Connect(function()
			self:_ScheduleAutoSave()
		end)
		return self
	end

	function ConfigManager:SetFolder(folder)
		self.Folder = cleanName(folder)
		return self
	end

	function ConfigManager:_Path(name)
		return self.Folder .. "/" .. cleanName(name) .. ".json"
	end

	function ConfigManager:_EnsureFolder()
		if self.Capabilities.FileSystem and type(makefolder) == "function" then
			if type(isfolder) ~= "function" or not isfolder(self.Folder) then
				pcall(makefolder, self.Folder)
			end
		end
	end

	function ConfigManager:_Payload()
		return {
			version = 1,
			theme = self.Themes.CurrentName,
			flags = encodeValue(self.Flags:Export()),
			savedAt = os.time(),
		}
	end

	function ConfigManager:ExportConfig()
		return HttpService:JSONEncode(self:_Payload())
	end

	function ConfigManager:ImportConfig(json, options)
		options = options or {}
		local ok, payload = pcall(function()
			return HttpService:JSONDecode(json)
		end)
		if not ok or type(payload) ~= "table" then
			return false, "Invalid config JSON"
		end
		if payload.theme and self.Themes:Get(payload.theme) then
			self.Themes:Set(payload.theme)
		end
		self.Flags:Import(decodeValue(payload.flags or {}), options.Silent == true)
		self.Loaded:Fire(payload)
		return true, payload
	end

	function ConfigManager:SaveConfig(name)
		name = cleanName(name)
		local json = self:ExportConfig()
		self.Memory[name] = json
		if self.Capabilities.FileSystem then
			self:_EnsureFolder()
			local ok, err = pcall(writefile, self:_Path(name), json)
			if not ok then
				return false, err
			end
		end
		self.Saved:Fire(name, json)
		return true, json
	end

	function ConfigManager:LoadConfig(name, options)
		name = cleanName(name)
		local json = self.Memory[name]
		if self.Capabilities.FileSystem and isfile(self:_Path(name)) then
			local ok, result = pcall(readfile, self:_Path(name))
			if not ok then
				return false, result
			end
			json = result
		end
		if not json then
			return false, "Config not found: " .. name
		end
		return self:ImportConfig(json, options)
	end

	function ConfigManager:DeleteConfig(name)
		name = cleanName(name)
		self.Memory[name] = nil
		if self.Capabilities.FileSystem and isfile(self:_Path(name)) then
			if type(delfile) ~= "function" then
				return false, "Executor does not support delfile"
			end
			local ok, err = pcall(delfile, self:_Path(name))
			if not ok then
				return false, err
			end
		end
		return true
	end

	function ConfigManager:ListConfigs()
		local names = {}
		local seen = {}
		for name in pairs(self.Memory) do
			seen[name] = true
			table.insert(names, name)
		end
		if self.Capabilities.FileSystem and type(listfiles) == "function" then
			self:_EnsureFolder()
			local ok, files = pcall(listfiles, self.Folder)
			if ok then
				for _, path in ipairs(files) do
					local name = string.match(path, "([^/\\]+)%.json$")
					if name and not seen[name] then
						seen[name] = true
						table.insert(names, name)
					end
				end
			end
		end
		table.sort(names)
		return names
	end

	function ConfigManager:SetAutoSave(enabled, name, delay)
		self.AutoSave = enabled == true
		self.AutoSaveName = cleanName(name or self.AutoSaveName)
		self.AutoSaveDelay = math.max(0.1, delay or self.AutoSaveDelay)
		return self
	end

	function ConfigManager:_ScheduleAutoSave()
		if not self.AutoSave then
			return
		end
		if self._pendingAutoSave then
			task.cancel(self._pendingAutoSave)
		end
		self._pendingAutoSave = task.delay(self.AutoSaveDelay, function()
			self._pendingAutoSave = nil
			self:SaveConfig(self.AutoSaveName)
		end)
	end

	function ConfigManager:Destroy()
		if self._flagConnection then
			self._flagConnection:Disconnect()
		end
		if self._pendingAutoSave then
			task.cancel(self._pendingAutoSave)
		end
		self.Saved:Destroy()
		self.Loaded:Destroy()
	end

	return ConfigManager
end
