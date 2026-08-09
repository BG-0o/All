local E = getgenv().ToxEnv
local Settings = E.Settings
local PlayerPage = E.Pages["PLAYER"]

E.CreateToggleWithValue("Speed", PlayerPage, Settings.Speed, Settings.SpeedValue, function(v) Settings.Speed = v end, function(val) Settings.SpeedValue = val end)
E.CreateToggleWithValue("Jump", PlayerPage, Settings.Jump, Settings.JumpValue, function(v) Settings.Jump = v end, function(val) Settings.JumpValue = val end)
E.CreateToggleWithValue("Fly", PlayerPage, Settings.Fly, Settings.FlySpeed, function(v) Settings.Fly = v if v then E.StartFly() else E.StopFly() end end, function(val) Settings.FlySpeed = val end)
E.CreateToggleWithValue("Flycar", PlayerPage, Settings.FlyCar, Settings.FlyCarSpeed, function(v) Settings.FlyCar = v if v then E.StartFlyCar() else E.StopFlyCar() end end, function(val) Settings.FlyCarSpeed = val end)
E.CreateToggleWithValue("Float", PlayerPage, Settings.Float, Settings.FloatStrength, function(v) Settings.Float = v if not v then E.StopFloat() end end, function(val) Settings.FloatStrength = val end)
E.CreateToggle("Noclip", PlayerPage, Settings.Noclip, function(v) Settings.Noclip = v if v then E.StartNoclip() else E.DisableNoclip() end end)
E.CreateToggle("Infinite Jump", PlayerPage, Settings.InfiniteJump, function(v) Settings.InfiniteJump = v end)

E.CreateTeleportRow("Teleport", PlayerPage, function(nick)
    E.TeleportToPlayer(nick)
end, function(enabled, nick)
    Settings.LoopTP = enabled
    if enabled then E.StartLoopTP(nick) else E.StopLoopTP() end
end)
