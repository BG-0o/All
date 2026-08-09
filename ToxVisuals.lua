local E = getgenv().ToxEnv
local Settings = E.Settings
local VisualsPage = E.Pages["VISUALS"]

E.CreateToggleWithValue("Enable ESP", VisualsPage, Settings.ESP, Settings.EspSize, function(v) Settings.ESP = v if not v and not Settings.Chams then E.ClearAllESP() end end, function(val) Settings.EspSize = val end)
E.CreateDropdown("ESP Color", {"White", "Red", "Green", "Blue", "Yellow", "Cyan", "Magenta", "Orange", "Purple"}, VisualsPage, Settings.EspColorName, function(v) Settings.EspColorName = v Settings.EspColor = E.ColorMap[v] or Color3.fromRGB(255, 255, 255) E.ClearAllESP() end)
E.CreateDropdown("Name Display", {"Display", "Username"}, VisualsPage, Settings.NameType, function(v) Settings.NameType = v end)
E.CreateToggle("Show Health", VisualsPage, Settings.ShowHealth, function(v) Settings.ShowHealth = v end)
E.CreateToggle("Chams / Highlight", VisualsPage, Settings.Chams, function(v) Settings.Chams = v if not v and not Settings.ESP then E.ClearAllESP() end end)
E.CreateToggle("Use Team Color", VisualsPage, Settings.ShowTeamColor, function(v) Settings.ShowTeamColor = v end)
E.CreateToggle("Ignore Team", VisualsPage, Settings.DisableTeam, function(v) Settings.DisableTeam = v E.ClearAllESP() end)

E.CreateInputWithToggle("Spectate Player", VisualsPage, "", function(enabled, nick)
    Settings.Spectating = enabled
    if enabled then E.StartSpectate(nick) else E.StopSpectate() end
end)

E.CreateToggle("Freecam", VisualsPage, false, function(v) E.ToggleFreecam(v) end)
E.CreateToggleWithValue("FOV Editor", VisualsPage, false, 70, function(v) Settings.FOVEnabled = v if not v then workspace.CurrentCamera.FieldOfView = 70 end end, function(val) Settings.FOVValue = val if Settings.FOVEnabled then workspace.CurrentCamera.FieldOfView = val end end)
E.CreateToggle("Fullbright", VisualsPage, false, function(v) E.ToggleFullbright(v) end)
