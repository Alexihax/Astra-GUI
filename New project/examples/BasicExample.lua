local Library = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/OWNER/ModernUILibrary/main/dist/ModernUI.lua"
))()

local UI = Library.new({
	Name = "ModernUIExample",
	Theme = "Dark",
})

local Window = UI:CreateWindow({
	Title = "ModernUI",
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
