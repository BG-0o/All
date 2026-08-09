local Tox = getgenv().Tox
local Page = Tox.Pages["PLAYER"]
local Settings = Tox.Settings
local S = Tox.Services

Tox.UI.CreateToggleWithValue("Speed", Page, Settings.Speed, Settings.SpeedValue, function(v) Settings.Speed = v end, function(val) Settings.SpeedValue = val end)
Tox.UI.CreateToggleWithValue("Jump", Page, Settings.Jump, Settings.JumpValue, function(v) Settings.Jump = v end, function(val) Settings.JumpValue = val end)
Tox.UI.CreateToggleWithValue("Fly", Page, Settings.Fly, Settings.FlySpeed, function(v) Settings.Fly = v end, function(val) Settings.FlySpeed = val end)
Tox.UI.CreateToggleWithValue("Flycar", Page, Settings.FlyCar, Settings.FlyCarSpeed, function(v) Settings.FlyCar = v end, function(val) Settings.FlyCarSpeed = val end)
Tox.UI.CreateToggleWithValue("Float", Page, Settings.Float, Settings.FloatStrength, function(v) Settings.Float = v end, function(val) Settings.FloatStrength = val end)
Tox.UI.CreateToggle("Noclip", Page, Settings.Noclip, function(v) Settings.Noclip = v end)
Tox.UI.CreateToggle("Infinite Jump", Page, Settings.InfiniteJump, function(v) Settings.InfiniteJump = v end)

-- Loop de Movimentação e Noclip
S.RunService.Stepped:Connect(function()
    if Tox.Destroyed then return end
    if Settings.Speed and Tox.Humanoid then Tox.Humanoid.WalkSpeed = Settings.SpeedValue end
    if Settings.Jump and Tox.Humanoid then Tox.Humanoid.JumpPower = Settings.JumpValue end
    if Settings.Noclip and Tox.Character then
        for _, p in ipairs(Tox.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

S.UserInputService.JumpRequest:Connect(function()
    if not Tox.Destroyed and Settings.InfiniteJump and Tox.Humanoid then
        Tox.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
