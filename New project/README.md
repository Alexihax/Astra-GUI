# ModernUI

ModernUI is a modular Luau ClickGUI library with an executor-ready single-file
distribution. It provides a polished window system, complete component set,
themes, JSON configs, responsive layouts, and strict resource cleanup.

The visual language is influenced by modern desktop UI libraries while keeping
its own compact, high-contrast identity.

> Use executor functionality only in experiences you own or have explicit
> permission to test.

## Features

- Draggable, resizable, minimizable, multi-window interface
- Collapsible sidebar, animated tabs, search, and lazy-loaded content
- Collapsible sections and dependency boxes
- Buttons, toggles, sliders, dropdowns, multi-dropdowns, inputs, keybinds,
  color pickers, paragraphs, dividers, images, notifications, and dialogs
- Eleven built-in themes plus custom theme registration
- JSON configs with flags, import/export, auto-save, and file persistence
- Desktop and mobile layouts with responsive scaling
- Acrylic blur, shadows, rounded corners, tooltips, and TweenService animation
- Watermarks, FPS counter, localization, state, flags, and named events
- Executor capability detection and proper connection cleanup
- Modular source plus a generated `loadstring` bundle

## Installation

Upload this repository to GitHub, then load the generated distribution file:

```lua
local Library = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/OWNER/ModernUILibrary/main/dist/ModernUI.lua"
))()

local UI = Library.new({
	Theme = "Dark",
	ConfigFolder = "MyScript",
})
```

Replace `OWNER` with your GitHub username. The repository must be public unless
your HTTP environment supports authenticated requests.

The returned export also supports `Library:CreateWindow(...)` directly through
a lazy default instance. Use `Library.new(...)` when you want explicit,
independent instances.

## Quick Start

```lua
local Window = UI:CreateWindow({
	Title = "Control Center",
	Subtitle = "RightControl toggles the window",
	Keybind = Enum.KeyCode.RightControl,
	Acrylic = true,
})

local Main = Window:CreateTab({
	Title = "Main",
	Icon = "Home",
})

local General = Main:CreateSection("General")

General:AddToggle({
	Title = "Enabled",
	Flag = "Enabled",
	Default = false,
	Callback = function(value)
		print("Enabled:", value)
	end,
})

General:AddSlider({
	Title = "Speed",
	Flag = "Speed",
	Min = 0,
	Max = 100,
	Step = 1,
	Default = 25,
})

UI:Notify({
	Title = "Loaded",
	Content = "ModernUI is ready.",
	Duration = 5,
	Type = "Success",
})
```

## Repository Layout

```text
src/                 Modular source files
src/Components/      UI controls, notifications, and dialogs
src/Managers/        Theme, config, state, event, flag, animation, cleanup
src/Themes/          Built-in theme definitions
src/Utils/           Signals, UI helpers, blur, icons, responsive utilities
dist/ModernUI.lua    Generated single-file executor distribution
examples/            Basic, theme, config, and advanced examples
docs/                Full usage and API documentation
scripts/build.ps1    Deterministic source bundler and dependency validator
```

## Building

Run from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\build.ps1
```

The build validates every internal `Require("Module.Name")` reference and writes
`dist/ModernUI.lua` without a UTF-8 byte-order mark.

Edit files in `src/`, then rebuild. Do not edit the generated distribution file
directly.

## Documentation

- [Getting Started](docs/GettingStarted.md)
- [Components](docs/Components.md)
- [Themes](docs/Themes.md)
- [Configs](docs/Configs.md)
- [API Reference](docs/API.md)

## License

ModernUI is available under the [MIT License](LICENSE).
