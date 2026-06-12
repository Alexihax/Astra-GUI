# Roblox ClickGui

A reusable Luau click GUI library for Roblox experiences.

## Installation

1. Create a `ModuleScript` named `ClickGui` in `ReplicatedStorage`.
2. Paste the contents of `src/ClickGui.lua` into it.
3. Put `example.client.lua` in a `LocalScript`, such as
   `StarterPlayerScripts/Example.client.lua`.

The GUI must be created from a client script.

## Components

- Draggable windows
- Tabs
- Labels
- Buttons
- Toggles
- Sliders
- Dropdowns
- Notifications
- Configurable theme
- RightShift visibility toggle by default
- Mouse and touch input

## Basic usage

```lua
local ClickGui = require(game.ReplicatedStorage.ClickGui)

local ui = ClickGui.new()
local window = ui:CreateWindow({Title = "Control Panel"})
local tab = window:CreateTab("Main")

tab:AddButton({
	Text = "Click me",
	Callback = function()
		print("Clicked")
	end,
})
```

See `example.client.lua` for every included component.
