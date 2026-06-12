local Library = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/OWNER/AstraUI/main/dist/AstraUI.lua"
))()

local UI = Library.new({
	Name = "AstraUIShowcase",
	Theme = "Astra",
	ConfigFolder = "AstraUI",
	MaxNotifications = 3,
})

local Window = UI:CreateWindow({
	Title = "Astra UI",
	Subtitle = "A cosmic interface system",
	Acrylic = true,
	Keybind = Enum.KeyCode.RightShift,
	MinimumSize = Vector2.new(600, 390),
})

UI:CreateWatermark({
	Text = "Astra UI",
	ShowFPS = true,
})

local Dashboard = Window:CreateTab({
	Title = "Dashboard",
	Icon = "Dashboard",
})

local Controls = Dashboard:CreateSection({
	Title = "Flight Controls",
	Description = "Core controls and live state",
	Collapsible = true,
})

Controls:AddButton({
	Title = "Launch Notification",
	Description = "Test Astra's notification queue",
	Callback = function()
		UI:Notify({
			Title = "Launch successful",
			Content = "Astra UI is online and responding.",
			Duration = 4,
			Type = "Success",
		})
	end,
})

local Master = Controls:AddToggle({
	Title = "Enable Flight Systems",
	Description = "Reveals the dependent controls",
	Flag = "FlightEnabled",
	Default = false,
})

Controls:AddSlider({
	Title = "Engine Output",
	Flag = "EngineOutput",
	Min = 0,
	Max = 100,
	Step = 1,
	Default = 42,
	Suffix = "%",
})

Controls:AddMultiDropdown({
	Title = "Target Classes",
	Flag = "Targets",
	Values = { "Players", "NPCs", "Bosses", "Loot" },
	Default = { "Players", "Loot" },
})

local FlightSettings = Controls:AddDependencyBox({
	Title = "Active Flight Settings",
	DependsOn = {
		Component = Master,
		Value = true,
	},
})

FlightSettings:AddKeybind({
	Title = "Pulse Key",
	Flag = "PulseKey",
	Default = Enum.KeyCode.F,
	OnPressed = function()
		UI:Notify({
			Title = "Pulse triggered",
			Content = "The flight-system keybind was pressed.",
			Type = "Info",
		})
	end,
})

local Appearance = Window:CreateTab({
	Title = "Appearance",
	Icon = "Palette",
})

local Themes = Appearance:CreateSection({
	Title = "Cosmic Themes",
	Description = "Switch the entire interface instantly",
})

Themes:AddDropdown({
	Title = "Theme Preset",
	Flag = "ThemePreset",
	Values = {
		"Astra",
		"Nebula",
		"Eclipse",
		"SolarFlare",
		"Aurora",
		"Starlight",
		"Midnight",
		"Ocean",
		"Crimson",
	},
	Default = "Astra",
	Callback = function(theme)
		UI:SetTheme(theme)
	end,
})

Themes:AddColorPicker({
	Title = "Accent Override",
	Description = "Drag the H, S, and V bars to recolor Astra",
	Flag = "AccentOverride",
	Default = UI:GetTheme().Accent,
	ApplyAccent = true,
})

local Configs = Window:CreateTab({
	Title = "Configs",
	Icon = "Config",
})

local ConfigActions = Configs:CreateSection("Configuration")

ConfigActions:AddInput({
	Title = "Profile Name",
	Flag = "ProfileName",
	Default = "Astra",
	Placeholder = "Enter config name...",
})

ConfigActions:AddButton({
	Title = "Save Profile",
	Callback = function()
		local name = UI.Flags:Get("ProfileName", "Astra")
		local ok, result = UI:SaveConfig(name)
		UI:Notify({
			Title = ok and "Profile saved" or "Save failed",
			Content = ok and ("Saved " .. name .. ".") or tostring(result),
			Type = ok and "Success" or "Error",
		})
	end,
})

ConfigActions:AddButton({
	Title = "Load Profile",
	Callback = function()
		local name = UI.Flags:Get("ProfileName", "Astra")
		local ok, result = UI:LoadConfig(name)
		UI:Notify({
			Title = ok and "Profile loaded" or "Load failed",
			Content = ok and ("Loaded " .. name .. ".") or tostring(result),
			Type = ok and "Success" or "Error",
		})
	end,
})

local About = Window:CreateTab({
	Title = "About",
	Icon = "Info",
})

local AboutSection = About:CreateSection("Astra UI")

AboutSection:AddParagraph({
	Title = "Version " .. Library.Version,
	Content = "A modular, responsive Luau interface with themes, configs, dependencies, and cleanup.",
})

AboutSection:AddButton({
	Title = "Open Dialog",
	Callback = function()
		UI:Dialog({
			Title = "Astra UI",
			Content = "The interface, accent system, and tab marks are working.",
		})
	end,
})

UI:Notify({
	Title = "Welcome aboard",
	Content = "Astra UI loaded with the Astra theme.",
	Duration = 5,
	Type = "Success",
})
