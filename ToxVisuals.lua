local Tox = getgenv().Tox
local Page = Tox.Pages["VISUALS"]
local Settings = Tox.Settings
local S = Tox.Services

Tox.UI.CreateToggleWithValue("Enable ESP", Page, Settings.ESP, Settings.EspSize, function(v) Settings.ESP = v end, function(val) Settings.EspSize = val end)
Tox.UI.CreateDropdown("ESP Color", {"White", "Red", "Green", "Blue", "Yellow", "Cyan", "Magenta", "Orange", "Purple"}, Page, Settings.EspColorName, function(v) 
    Settings.EspColorName = v 
    Settings.EspColor = Tox.ColorMap[v] or Color3.fromRGB(255, 255, 255)
end)
Tox.UI.CreateDropdown("Name Display", {"Display", "Username"}, Page, Settings.NameType, function(v) Settings.NameType = v end)
Tox.UI.CreateToggle("Show Health", Page, Settings.ShowHealth, function(v) Settings.ShowHealth = v end)
Tox.UI.CreateToggle("Chams / Highlight", Page, Settings.Chams, function(v) Settings.Chams = v end)
Tox.UI.CreateToggle("Use Team Color", Page, Settings.ShowTeamColor, function(v) Settings.ShowTeamColor = v end)
Tox.UI.CreateToggle("Ignore Team", Page, Settings.DisableTeam, function(v) Settings.DisableTeam = v end)

Tox.UI.CreateToggle("Fullbright", Page, Settings.Fullbright, function(v) 
    Settings.Fullbright = v 
    if not v then
        S.Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        S.Lighting.Brightness = 1
    end
end)

S.RunService.RenderStepped:Connect(function()
    if Tox.Destroyed then return end
    if Settings.Fullbright then
        S.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        S.Lighting.Brightness = 2
    end
end)
