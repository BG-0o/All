local env = getgenv().ToxEnv
if not env or not env.FlingPage then return end

local FlingPage = env.FlingPage

-- Botões para a aba MISC
env.CreateInputWithButton("Target Fling", FlingPage, "", "Fling", function(targetText)
    env.ExecuteFling(targetText)
end)

env.CreateToggle("Walk Fling", FlingPage, env.Settings.WalkFling, function(v)
    env.Settings.WalkFling = v
    if v then env.StartWalkFling() else env.StopWalkFling() end
end)

env.CreateToggle("Anti Fling", FlingPage, env.Settings.AntiFling, function(v)
    env.Settings.AntiFling = v
    if v then env.StartAntiFling() else env.StopAntiFling() end
end)
