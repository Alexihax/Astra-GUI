local Library = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/OWNER/ModernUILibrary/main/dist/ModernUI.lua"
))()

local UI = Library.new({
	Theme = "FluentInspired",
	Locale = "en",
	MaxNotifications = 3,
})

UI:RegisterLocale("da", {
	window_title = "Kontrolpanel",
	status = "Status",
})

local Window = UI:CreateWindow({
	Title = UI:Translate("window_title", "Control Center"),
	Subtitle = UI.Capabilities.Name .. " | " .. UI.Mode,
	Acrylic = true,
	Keybind = Enum.KeyCode.RightShift,
	MinimumSize = Vector2.new(560, 360),
})

UI:CreateWatermark({
	Text = "ModernUI",
	ShowFPS = true,
})

local Dashboard = Window:CreateTab({
	Title = "Dashboard",
	Icon = "Home",
})

Dashboard:SetLazyLoader(function(Tab)
	local Status = Tab:CreateSection({
		Title = UI:Translate("status", "Status"),
		Collapsible = true,
	})

	Status:AddParagraph({
		Title = "Runtime",
		Content = "This tab was created lazily the first time it became active.",
	})

	local Master = Status:AddToggle({
		Title = "Master switch",
		Flag = "Master",
		Default = false,
		Tooltip = "Controls the dependent settings below.",
	})

	local DependencyBox = Status:AddDependencyBox({
		Title = "Master settings",
		DependsOn = {
			Component = Master,
			Value = true,
		},
	})

	DependencyBox:AddSlider({
		Title = "Intensity",
		Flag = "Intensity",
		Min = 0,
		Max = 1,
		Step = 0.05,
		Default = 0.5,
	})

	DependencyBox:AddKeybind({
		Title = "Action key",
		Flag = "ActionKey",
		Default = Enum.KeyCode.F,
		OnPressed = function()
			UI:Notify({
				Title = "Keybind",
				Content = "The action key was pressed.",
				Type = "Info",
			})
		end,
	})

	Status:AddImage({
		Title = "Preview",
		Image = "rbxassetid://0",
		Height = 150,
	})

	Status:AddDivider("Dialog")

	Status:AddButton({
		Title = "Open confirmation",
		Callback = function()
			UI:Dialog({
				Title = "Confirm action",
				Content = "This dialog supports custom buttons and callbacks.",
				Callback = function(value)
					print("Dialog result:", value)
				end,
			})
		end,
	})
end)
