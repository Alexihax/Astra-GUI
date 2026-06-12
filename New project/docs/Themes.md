# Themes

## Built-In Themes

- `Dark`
- `Light`
- `Midnight`
- `Crimson`
- `Emerald`
- `Ocean`
- `Purple`
- `Rose`
- `Discord`
- `FluentInspired`
- `RayfieldInspired`

Switch themes at runtime:

```lua
UI:SetTheme("Emerald")
print(UI.ThemeManager.CurrentName)
```

All registered UI bindings update immediately.

## Custom Themes

Clone an existing theme and override selected tokens:

```lua
local Custom = table.clone(UI:GetTheme())
Custom.Name = "Solar"
Custom.Background = Color3.fromRGB(24, 20, 12)
Custom.Surface = Color3.fromRGB(37, 31, 18)
Custom.SurfaceAlt = Color3.fromRGB(49, 41, 24)
Custom.SurfaceHover = Color3.fromRGB(64, 53, 31)
Custom.Accent = Color3.fromRGB(245, 166, 35)
Custom.AccentAlt = Color3.fromRGB(255, 194, 85)

UI:RegisterTheme("Solar", Custom)
UI:SetTheme("Solar")
```

## Theme Tokens

Every theme contains:

| Token | Purpose |
| --- | --- |
| `Background` | Window background |
| `Surface` | Sidebar, dialogs, and notifications |
| `SurfaceAlt` | Component cards |
| `SurfaceHover` | Hover and selected surfaces |
| `Accent` | Primary interactive color |
| `AccentAlt` | Secondary accent and emphasis |
| `Text` | Primary text |
| `MutedText` | Secondary text |
| `Border` | Strokes and separators |
| `Success` | Positive notification state |
| `Warning` | Warning notification state |
| `Error` | Error notification state |
| `Shadow` | Window shadows |
| `AcrylicTransparency` | Acrylic surface transparency |

Custom themes inherit missing values from `Dark`, but defining all tokens is
recommended for predictable results.
