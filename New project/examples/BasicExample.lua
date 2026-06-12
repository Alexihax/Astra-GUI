local Library = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/OWNER/AstraUI/main/dist/AstraUI.lua"
))()

local UI = Library.new({
	Name = "AstraUIExample",
	Theme = "Astra",
})

local Window = UI:CreateWindow({
	Title = "Astra UI",
	Subtitle = "Basic example",
	Keybind = Enum.KeyCode.RightControl,
})

local Main = Window:CreateTab({
	Title = "Main",
	Icon = "Home",
})

local Controls = Main:CreateSection({
	Title = "Controls",
	Description = "Common interactive components",
})

Controls:AddButton({
	Title = "Run action",
	Description = "Calls a callback when clicked",
	Callback = function()
		UI:Notify({
			Title = "Action complete",
			Content = "The button callback ran successfully.",
			Duration = 4,
			Type = "Success",
		})
	end,
})

Controls:AddToggle({
	Title = "Enabled",
	Flag = "Enabled",
	Default = true,
	Callback = function(value)
		print("Enabled:", value)
	end,
})

Controls:AddSlider({
	Title = "Walk speed",
	Flag = "WalkSpeed",
	Min = 16,
	Max = 100,
	Step = 1,
	Default = 16,
	Suffix = " studs",
})

Controls:AddDropdown({
	Title = "Mode",
	Flag = "Mode",
	Values = { "Legit", "Balanced", "Aggressive" },
	Default = "Balanced",
})
