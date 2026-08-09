-- ========================================================
-- ToxConfig.lua - Módulo para a Aba CONFIG
-- ========================================================

local env = getgenv().ToxEnv
if not env then return end

local ConfigPage = env.ConfigPage
local Settings = env.Settings

local CreateKeybind = env.CreateKeybind
local CreateButton = env.CreateButton
local CustomNotify = env.CustomNotify

CreateKeybind("Menu Open Keybind", ConfigPage, Settings.GUIKeybind, function(key)
    Settings.GUIKeybind = key
    CustomNotify("GUI Keybind updated!", Color3.fromRGB(100, 255, 100))
end)

CreateButton("Save Settings", ConfigPage, function()
    if env.AutoSaveConfiguration then
        env.AutoSaveConfiguration()
        CustomNotify("Configuration Saved!", Color3.fromRGB(100, 255, 100))
    end
end)

CreateButton("Unload Script", ConfigPage, function()
    env.Destroyed = true
    if env.ClearAllESP then env.ClearAllESP() end
    if env.Gui then env.Gui:Destroy() end
    if env.NotifGui then env.NotifGui:Destroy() end
    CustomNotify("Tox Script Unloaded!", Color3.fromRGB(255, 100, 100))
end)
