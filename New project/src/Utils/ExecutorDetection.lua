return function()
	local ExecutorDetection = {}

	local function global(name)
		local environment = getgenv and getgenv() or _G
		return environment and environment[name]
	end

	function ExecutorDetection.Detect()
		local name = "Roblox"
		if type(identifyexecutor) == "function" then
			local ok, result = pcall(identifyexecutor)
			if ok and result then
				name = tostring(result)
			end
		elseif type(getexecutorname) == "function" then
			local ok, result = pcall(getexecutorname)
			if ok and result then
				name = tostring(result)
			end
		elseif global("syn") then
			name = "Synapse"
		elseif global("KRNL_LOADED") then
			name = "KRNL"
		end

		return {
			Name = name,
			IsExecutor = name ~= "Roblox",
			FileSystem = type(writefile) == "function"
				and type(readfile) == "function"
				and type(isfile) == "function",
			Clipboard = type(setclipboard) == "function",
			Request = type(request) == "function"
				or type(http_request) == "function"
				or (global("syn") and type(global("syn").request) == "function"),
			ProtectGui = type(protectgui) == "function"
				or (global("syn") and type(global("syn").protect_gui) == "function"),
		}
	end

	return ExecutorDetection
end
