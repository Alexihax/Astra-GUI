local Library = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/OWNER/AstraUI/main/dist/AstraUI.lua"
))()

local UI = Library.new({
	Theme = "Astra",
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
	Values = UI:GetThemes(),
	Default = "Astra",
	Callback = function(theme)
		UI:SetTheme(theme)
	end,
})

Picker:AddColorPicker({
	Title = "Custom accent",
	Default = UI:GetTheme().Accent,
	ApplyAccent = true,
})
