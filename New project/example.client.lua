local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClickGui = require(ReplicatedStorage:WaitForChild("ClickGui"))

local ui = ClickGui.new({
	Name = "ExampleClickGui",
	ToggleKey = Enum.KeyCode.RightShift,
})

local window = ui:CreateWindow({
	Title = "My Script",
	Size = UDim2.fromOffset(540, 400),
})

local main = window:CreateTab("Main")
main:AddLabel("A reusable Roblox click GUI library.")

main:AddButton({
	Text = "Send notification",
	Callback = function()
		ui:Notify({
			Title = "Hello",
			Text = "The button was clicked.",
		})
	end,
})

main:AddToggle({
	Text = "Enabled",
	Default = false,
	Callback = function(value)
		print("Enabled:", value)
	end,
})

main:AddSlider({
	Text = "Walk speed",
	Min = 16,
	Max = 100,
	Default = 16,
	Step = 1,
	Callback = function(value)
		print("Walk speed:", value)
	end,
})

main:AddDropdown({
	Text = "Mode",
	Values = {"Legit", "Rage", "Custom"},
	Default = "Legit",
	Callback = function(value)
		print("Mode:", value)
	end,
})

local settings = window:CreateTab("Settings")
settings:AddLabel("Press RightShift to show or hide the interface.")
