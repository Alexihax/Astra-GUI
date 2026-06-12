local Library = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/OWNER/ModernUILibrary/main/dist/ModernUI.lua"
))()

local UI = Library.new({
	Theme = "Ocean",
})

local Window = UI:CreateWindow({
	Title = "Theme Studio",
	Subtitle = "Built-in and custom themes",
	Acrylic = true,
})

local Themes = Window:CreateTab({
	Title = "Themes",
	Icon = "Settings",
})

local Picker = Themes:CreateSection("Appearance")

Picker:AddDropdown({
	Title = "Built-in theme",
	Values = {
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
	},
	Default = "Ocean",
	Callback = function(theme)
		UI:SetTheme(theme)
	end,
})

Picker:AddColorPicker({
	Title = "Custom accent",
	Default = Color3.fromRGB(255, 145, 70),
	Callback = function(color)
		local custom = table.clone(UI:GetTheme())
		custom.Name = "MyCustomTheme"
		custom.Accent = color
		custom.AccentAlt = color:Lerp(Color3.new(1, 1, 1), 0.22)
		UI:RegisterTheme("MyCustomTheme", custom)
		UI:SetTheme("MyCustomTheme")
	end,
})
