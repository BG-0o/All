local Tox = getgenv().Tox
local Page = Tox.Pages["MISC"]
local Settings = Tox.Settings
local S = Tox.Services

Tox.UI.CreateToggle("Ctrl Click TP", Page, Settings.CtrlClickTP, function(v) Settings.CtrlClickTP = v end)
Tox.UI.CreateToggle("No Fall Damage", Page, Settings.NoFallDamage, function(v) Settings.NoFallDamage = v end)
Tox.UI.CreateToggle("Anti Void", Page, Settings.AntiVoid, function(v) Settings.AntiVoid = v end)
Tox.UI.CreateToggle("Anti Fling", Page, Settings.AntiFling, function(v) Settings.AntiFling = v end)

-- Ctrl Click Teleport Logic
S.UserInputService.InputBegan:Connect(function(input, processed)
    if processed or Tox.Destroyed then return end
    if Settings.CtrlClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if S.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or S.UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            local mouse = Tox.Player:GetMouse()
            if mouse.Target and Tox.RootPart then
                Tox.RootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

-- Anti-Fling Loop
S.RunService.Stepped:Connect(function()
    if Tox.Destroyed or not Settings.AntiFling then return end
    for _, p in ipairs(S.Players:GetPlayers()) do
        if p ~= Tox.Player and p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end
    end
end)
