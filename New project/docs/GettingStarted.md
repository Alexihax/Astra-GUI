# Getting Started

## Load the Library

The `dist/AstraUI.lua` file is the only file consumers need:

```lua
local Library = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/OWNER/AstraUI/main/dist/AstraUI.lua"
))()

local UI = Library.new({
	Name = "MyInterface",
	Theme = "Astra",
	ConfigFolder = "MyInterface",
	AutoSave = true,
	AutoSaveName = "settings",
})
```

`Library.new()` creates an isolated library instance. Multiple instances can
exist at the same time.

For a single interface, the lazy default instance can be used directly:

```lua
local Window = Library:CreateWindow({
	Title = "Default instance",
})

Library:Notify({
	Title = "Ready",
	Content = "No explicit Library.new() call was required.",
	Type = "Success",
})
```

## Create a Window

```lua
local Window = UI:CreateWindow({
	Title = "My Script",
	Subtitle = UI.Capabilities.Name,
	Size = UDim2.fromOffset(700, 470),
	Keybind = Enum.KeyCode.RightControl,
	Acrylic = true,
	DestroyOnClose = false,
})
```

The window can be dragged from its title bar and resized from its lower-right
corner. The sidebar button collapses navigation, the minus button minimizes,
and the close button hides or destroys the window based on `DestroyOnClose`.

## Add Tabs and Sections

```lua
local Main = Window:CreateTab({
	Title = "Main",
	Icon = "Home",
})

local General = Main:CreateSection({
	Title = "General",
	Description = "Primary controls",
	Collapsible = true,
})
```

Components are added to sections:

```lua
local Enabled = General:AddToggle({
	Title = "Enabled",
	Flag = "Enabled",
	Default = false,
})
```

All flagged values are available through the flag manager:

```lua
print(UI.Flags:Get("Enabled"))
UI.Flags:Set("Enabled", true)
```

## Visibility Dependencies

Any component can depend on another component:

```lua
General:AddSlider({
	Title = "Intensity",
	Min = 0,
	Max = 100,
	Default = 50,
	DependsOn = {
		Component = Enabled,
		Value = true,
	},
})
```

Or create a whole dependency box:

```lua
local Advanced = General:AddDependencyBox({
	Title = "Enabled settings",
	DependsOn = {
		Flag = "Enabled",
		Value = true,
	},
})

Advanced:AddInput({
	Title = "Profile",
	Default = "Default",
})
```

## Lazy Tabs

Use a lazy loader when a tab is expensive to populate:

```lua
local AdvancedTab = Window:CreateTab("Advanced")

AdvancedTab:SetLazyLoader(function(Tab)
	local Section = Tab:CreateSection("Loaded on demand")
	Section:AddParagraph({
		Title = "Ready",
		Content = "This content was created on first activation.",
	})
end)
```

## Cleanup

Destroy the complete interface and all connections:

```lua
UI:Destroy()
```

Destroy individual objects with their own `:Destroy()` method.
