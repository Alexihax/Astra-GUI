# API Reference

## Library

Create an instance:

```lua
local UI = Library.new(options)
```

Important options:

| Option | Type | Description |
| --- | --- | --- |
| `Name` | string | ScreenGui name |
| `Parent` | Instance | Optional explicit GUI parent |
| `Theme` | string/table | Initial theme |
| `DisplayOrder` | number | ScreenGui display order |
| `ReducedMotion` | boolean | Disables tweened transitions |
| `ConfigFolder` | string | Config storage folder |
| `AutoSave` | boolean | Enables automatic config saves |
| `MaxNotifications` | number | Simultaneous notification limit |
| `AlwaysShowMobileButton` | boolean | Shows the floating UI toggle |

Methods:

```lua
UI:CreateWindow(options)
UI:Notify(options)
UI:Dialog(options)
UI:CreateWatermark(options)
UI:SetTheme(nameOrTheme)
UI:SetAccent(color)
UI:GetTheme()
UI:GetThemes()
UI:RegisterTheme(name, theme)
UI:RegisterLocale(locale, translations)
UI:SetLocale(locale)
UI:Translate(key, fallback, replacements)
UI:SaveConfig(name)
UI:LoadConfig(name, options)
UI:DeleteConfig(name)
UI:ExportConfig()
UI:ImportConfig(json, options)
UI:SetVisible(visible)
UI:Show()
UI:Hide()
UI:Toggle()
UI:Destroy()
```

Public managers:

```lua
UI.ThemeManager
UI.ConfigManager
UI.StateManager
UI.EventManager
UI.FlagManager
UI.AnimationManager
```

Runtime capabilities:

```lua
UI.Capabilities.Name
UI.Capabilities.IsExecutor
UI.Capabilities.FileSystem
UI.Capabilities.Clipboard
UI.Capabilities.Request
UI.Capabilities.ProtectGui
```

## Window

```lua
local Window = UI:CreateWindow({
	Title = "Window",
	Subtitle = "Subtitle",
	Size = UDim2.fromOffset(700, 470),
	Position = UDim2.fromScale(0.5, 0.5),
	MinimumSize = Vector2.new(520, 340),
	MaximumSize = Vector2.new(1100, 800),
	Keybind = Enum.KeyCode.RightControl,
	Acrylic = true,
	DestroyOnClose = false,
})
```

Methods:

```lua
Window:CreateTab(options)
Window:AddTab(options)
Window:SelectTab(tab)
Window:SetSidebarCollapsed(collapsed)
Window:SetMinimized(minimized)
Window:SetKeybind(key)
Window:SetTitle(title)
Window:SetDescription(subtitle)
Window:SetVisible(visible)
Window:Show()
Window:Hide()
Window:Destroy()
```

## Tab

```lua
local Tab = Window:CreateTab({
	Title = "Main",
	Icon = "Home",
	Loader = function(tab)
		-- Optional lazy content.
	end,
})
```

Methods:

```lua
Tab:CreateSection(options)
Tab:AddSection(options)
Tab:SetLazyLoader(callback)
Tab:Filter(query)
Tab:SetTitle(title)
Tab:SetVisible(visible)
Tab:Show()
Tab:Hide()
Tab:Destroy()
```

Icons can be a built-in name, an asset ID number, or an
`rbxassetid://...` string.

Built-in marks include `Astra`, `Dashboard`, `Home`, `Combat`, `Player`,
`Visuals`, `Palette`, `Theme`, `Settings`, `Config`, `Cloud`, `Info`, `Code`,
`Shield`, `Target`, and `Lightning`.

## Section

```lua
local Section = Tab:CreateSection({
	Title = "General",
	Description = "Settings",
	Collapsible = true,
	Collapsed = false,
	DependsOn = {
		Flag = "Enabled",
		Value = true,
	},
})
```

Methods:

```lua
Section:AddButton(options)
Section:AddToggle(options)
Section:AddSlider(options)
Section:AddDropdown(options)
Section:AddMultiDropdown(options)
Section:AddInput(options)
Section:AddKeybind(options)
Section:AddColorPicker(options)
Section:AddParagraph(options)
Section:AddDivider(options)
Section:AddImage(options)
Section:AddDependencyBox(options)
Section:SetCollapsed(collapsed)
Section:SetTitle(title)
Section:SetDescription(description)
Section:SetVisible(visible)
Section:Show()
Section:Hide()
Section:Destroy()
```

## Events

Named events:

```lua
local connection = UI.EventManager:On("ThemeChanged", function(theme, name)
	print(name)
end)

UI.EventManager:Emit("CustomEvent", 123)
connection:Disconnect()
```

Built-in events include `WindowCreated`, `ThemeChanged`, `LocaleChanged`, and
`ResponsiveChanged`.

## State

```lua
UI.StateManager:Set("CustomKey", "value")
print(UI.StateManager:Get("CustomKey"))

local connection = UI.StateManager:Observe("CustomKey", function(value, previous)
	print(value, previous)
end, true)
```

## Cleanup

Every library, window, tab, section, component, notification, and dialog owns
its connections. Calling `:Destroy()` disconnects those connections and removes
its instances. Destroying the library recursively destroys every child object.
