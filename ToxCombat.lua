local E = getgenv().ToxEnv
local Settings = E.Settings
local FlingPage = E.Pages["MISC"]

E.CreateToggle("Ctrl Click TP", FlingPage, Settings.CtrlClickTP, function(v) Settings.CtrlClickTP = v end)
E.CreateToggle("No Fall Damage", FlingPage, Settings.NoFallDamage, function(v) Settings.NoFallDamage = v if v then E.StartNoFall() else E.StopNoFall() end end)
E.CreateToggle("Anti Void", FlingPage, Settings.AntiVoid, function(v) Settings.AntiVoid = v if v then E.StartAntiVoid() else E.StopAntiVoid() end end)
E.CreateToggle("Anti Fling", FlingPage, Settings.AntiFling, function(v) Settings.AntiFling = v if v then E.StartAntiFling() else E.StopAntiFling() end end)
E.CreateInputWithButton("Target Fling", FlingPage, "", "Fling", function(text) E.ExecuteFling(text) end)

E.CreateButton("Music Player", FlingPage, function()
    E.MusicGui.Visible = not E.MusicGui.Visible
end)
