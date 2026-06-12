# Configs

ModernUI serializes flagged component values and the current theme to JSON.
`Color3`, `EnumItem`, tables, strings, booleans, and numbers are supported.

## Flags

Assign a unique flag to any value component:

```lua
Section:AddToggle({
	Title = "Enabled",
	Flag = "Enabled",
	Default = false,
})

Section:AddColorPicker({
	Title = "Accent",
	Flag = "Accent",
	Default = Color3.fromRGB(71, 137, 255),
})
```

Read and update flags:

```lua
local enabled = UI.Flags:Get("Enabled")
UI.Flags:Set("Enabled", true)
```

## Save and Load

```lua
local saved, saveResult = UI:SaveConfig("main")
local loaded, loadResult = UI:LoadConfig("main")
```

When executor file APIs are available, configs are stored as:

```text
ConfigFolder/config-name.json
```

Without file APIs, configs remain available in memory for the current session.

## Delete

```lua
local deleted, reason = UI:DeleteConfig("main")
```

## Export and Import

```lua
local json = UI:ExportConfig()
print(json)

local imported, result = UI:ImportConfig(json)
```

Use silent import to suppress component callbacks:

```lua
UI:ImportConfig(json, {
	Silent = true,
})
```

## Auto-Save

Enable it while creating the library:

```lua
local UI = Library.new({
	ConfigFolder = "MyScript",
	AutoSave = true,
	AutoSaveName = "autosave",
	AutoSaveDelay = 0.75,
})
```

Or configure it later:

```lua
UI.ConfigManager:SetFolder("MyScript")
UI.ConfigManager:SetAutoSave(true, "autosave", 0.75)
```

Auto-save is debounced, so rapid slider and input changes produce a single
write after activity settles.

## List Configs

```lua
for _, name in ipairs(UI.ConfigManager:ListConfigs()) do
	print(name)
end
```
