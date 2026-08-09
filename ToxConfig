local Tox = getgenv().Tox
local Page = Tox.Pages["CONFIG"]
local Settings = Tox.Settings
local S = Tox.Services

Tox.UI.CreateToggle("Anti AFK", Page, Settings.AntiAFK, function(v) Settings.AntiAFK = v end)
Tox.UI.CreateToggle("3D Rendering", Page, Settings.Render3D, function(v)
    Settings.Render3D = v
    pcall(function() S.RunService:Set3dRenderingEnabled(v) end)
end)

Tox.UI.CreateKeybind("GUI Keybind", Page, Settings.GUIKeybind, function(key)
    Settings.GUIKeybind = key
end)

Tox.UI.CreateButton("Rejoin", Page, function()
    if #S.Players:GetPlayers() <= 1 then
        S.TeleportService:Teleport(game.PlaceId, Tox.Player)
    else
        S.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Tox.Player)
    end
end)

Tox.UI.CreateButton("DESTROY GUI", Page, function()
    Tox.Destroyed = true
    pcall(function() S.RunService:Set3dRenderingEnabled(true) end)
    if Tox.Gui then Tox.Gui:Destroy() end
    if Tox.NotifGui then Tox.NotifGui:Destroy() end
end)

-- Anti AFK Event
Tox.Player.Idled:Connect(function()
    if Settings.AntiAFK and not Tox.Destroyed then
        S.VirtualUser:CaptureController()
        S.VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)
