local E = getgenv().ToxEnv
local Settings = E.Settings
local ConfigPage = E.Pages["CONFIG"]

E.CreateToggle("Anti AFK", ConfigPage, Settings.AntiAFK, function(v) Settings.AntiAFK = v if v then E.StartAntiAFK() else E.StopAntiAFK() end end)
E.CreateToggle("Chat Logs", ConfigPage, Settings.ChatLogs, function(v) 
    Settings.ChatLogs = v 
    E.ChatLogGui.Visible = v
    if v then E.StartChatLogs() else E.StopChatLogs() end 
end)
E.CreateToggle("3D Rendering", ConfigPage, Settings.Render3D, function(v) E.Toggle3DRendering(v) end)
E.CreateKeybind("GUI Keybind", ConfigPage, Settings.GUIKeybind, function(key) Settings.GUIKeybind = key end)

E.CreateButton("Rejoin", ConfigPage, function()
	E.ApplyTeleportQueue()
	if #E.Players:GetPlayers() <= 1 then
		E.TeleportService:Teleport(game.PlaceId, E.Player)
	else
		E.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, E.Player)
	end
end)

E.CreateButton("DESTROY", ConfigPage, function()
	E.StopFly() E.StopFlyCar() E.StopFloat() E.DisableNoclip() E.StopAntiFling() E.StopAntiAFK() E.StopAntiVoid() E.StopNoFall() E.ClearAllESP() E.StopSpectate() E.StopLoopTP() E.StopChatLogs() E.ToggleFullbright(false) E.ToggleFreecam(false) E.Toggle3DRendering(true)
	if E.CustomSound then E.CustomSound:Stop() E.CustomSound:Destroy() end
    if E.Humanoid then E.Humanoid.WalkSpeed = 16 E.Humanoid.JumpPower = 50 end
    E.NotifGui:Destroy()
	E.Gui:Destroy()
end)
