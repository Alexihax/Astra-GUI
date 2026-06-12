# Components

Every component supports:

```lua
Component:SetValue(value, silent)
Component:GetValue()
Component:SetTitle(title)
Component:SetDescription(description)
Component:SetVisible(visible)
Component:Hide()
Component:Show()
Component:Destroy()
```

When `silent` is `true`, the value and flag update without calling the component
callback.

Shared options include `Title`, `Description`, `Flag`, `Default`, `Callback`,
`Tooltip`, `Visible`, `VisibleWhen`, and `DependsOn`.

## Button

```lua
local Button = Section:AddButton({
	Title = "Execute",
	Description = "Runs the action once",
	Tooltip = "This can be updated later",
	Callback = function(clickCount)
		print("Clicks:", clickCount)
	end,
})

Button:Press()
```

## Toggle

```lua
local Toggle = Section:AddToggle({
	Title = "Enabled",
	Flag = "Enabled",
	Default = true,
	Callback = function(value)
		print(value)
	end,
})

Toggle:SetValue(false)
```

## Slider

```lua
local Slider = Section:AddSlider({
	Title = "Volume",
	Flag = "Volume",
	Min = 0,
	Max = 1,
	Step = 0.05,
	Default = 0.5,
	Suffix = "%",
})

Slider:SetValue(0.75)
```

## Dropdown

```lua
local Dropdown = Section:AddDropdown({
	Title = "Mode",
	Flag = "Mode",
	Values = { "A", "B", "C" },
	Default = "A",
})

Dropdown:SetValues({ "A", "B", "C", "D" }, true)
Dropdown:SetValue("D")
```

## Multi-Dropdown

```lua
local Multi = Section:AddMultiDropdown({
	Title = "Targets",
	Flag = "Targets",
	Values = { "Coins", "Crates", "Bosses" },
	Default = { "Coins", "Crates" },
})

Multi:SetValue({ "Bosses" })
```

## Input

```lua
local Input = Section:AddInput({
	Title = "Username",
	Flag = "Username",
	Placeholder = "Enter a name...",
	Default = "",
	FinishedOnly = true,
})
```

Set `Numeric = true` to return numbers. Set `FinishedOnly = false` to update on
every text change.

## Keybind

```lua
local Keybind = Section:AddKeybind({
	Title = "Action key",
	Flag = "ActionKey",
	Default = Enum.KeyCode.F,
	Mode = "Toggle",
	OnPressed = function(active)
		print("Pressed, toggle state:", active)
	end,
})

Keybind:SetValue(Enum.KeyCode.G)
```

## Color Picker

```lua
local Color = Section:AddColorPicker({
	Title = "Accent",
	Flag = "Accent",
	Default = Color3.fromRGB(71, 137, 255),
	Callback = function(value)
		print(Color:GetHex(), value)
	end,
})

Color:SetValue("#FF7A45")
```

## Paragraph

```lua
local Paragraph = Section:AddParagraph({
	Title = "Information",
	Content = "Paragraphs support wrapped multi-line content.",
	Height = 90,
})

Paragraph:SetValue("Updated content")
```

## Divider

```lua
local Divider = Section:AddDivider("Advanced")
Divider:SetTitle("Expert settings")
```

## Image

```lua
local Image = Section:AddImage({
	Title = "Preview",
	Image = "rbxassetid://123456789",
	Height = 180,
	ScaleType = Enum.ScaleType.Crop,
})

Image:SetValue("rbxassetid://987654321")
```

## Notifications

```lua
local Notification = UI:Notify({
	Title = "Saved",
	Content = "Your configuration was saved.",
	Duration = 5,
	Type = "Success",
})

Notification:SetDescription("Updated notification content")
```

Available types are `Success`, `Error`, `Warning`, and `Info`. Notifications are
queued automatically when the active limit is reached.

## Dialogs

```lua
local Dialog = UI:Dialog({
	Title = "Delete config?",
	Content = "This action cannot be undone.",
	Buttons = {
		{ Title = "Cancel", Value = false },
		{ Title = "Delete", Value = true, Primary = true },
	},
	Callback = function(confirmed)
		print("Confirmed:", confirmed)
	end,
})
```

## Conditions

Function-based visibility:

```lua
Section:AddButton({
	Title = "Only in advanced mode",
	VisibleWhen = function(flags)
		return flags.Mode == "Advanced"
	end,
})
```

Flag dependency:

```lua
Section:AddInput({
	Title = "Custom value",
	DependsOn = {
		Flag = "Enabled",
		Predicate = function(value)
			return value == true
		end,
	},
})
```
