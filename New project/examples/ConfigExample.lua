local Library = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/OWNER/AstraUI/main/dist/AstraUI.lua"
))()

local UI = Library.new({
	Theme = "Midnight",
	ConfigFolder = "AstraUIExample",
	AutoSave = true,
	AutoSaveName = "settings",
})

local Window = UI:CreateWindow({
	Title = "Configuration",
	Subtitle = UI.Capabilities.FileSystem and "Persistent storage available" or "Memory storage mode",
})

local Tab = Window:CreateTab("Settings")
local Values = Tab:CreateSection("Saved values")

Values:AddToggle({
	Title = "Auto farm",
	Flag = "AutoFarm",
	Default = false,
})

Values:AddMultiDropdown({
	Title = "Targets",
	Flag = "Targets",
	Values = { "Coins", "Crates", "Bosses" },
	Default = { "Coins" },
})

Values:AddInput({
	Title = "Profile name",
	Flag = "ProfileName",
	Default = "Default",
})

local Actions = Tab:CreateSection("Config actions")

Actions:AddButton({
	Title = "Save settings",
	Callback = function()
		local ok, result = UI:SaveConfig("settings")
		UI:Notify({
			Title = ok and "Config saved" or "Save failed",
			Content = ok and "settings.json was updated." or tostring(result),
			Type = ok and "Success" or "Error",
		})
	end,
})

Actions:AddButton({
	Title = "Load settings",
	Callback = function()
		local ok, result = UI:LoadConfig("settings")
		UI:Notify({
			Title = ok and "Config loaded" or "Load failed",
			Content = ok and "Flags and theme were restored." or tostring(result),
			Type = ok and "Success" or "Error",
		})
	end,
})
