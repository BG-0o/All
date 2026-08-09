-- ========================================================
-- ToxPlayer.lua - Módulo para a Aba PLAYER
-- ========================================================

local env = getgenv().ToxEnv
if not env then return end

local PlayerPage = env.PlayerPage
local Settings = env.Settings

local CreateToggle = env.CreateToggle
local CreateToggleWithValue = env.CreateToggleWithValue

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = env.Player

local Humanoid, RootPart

local function GetCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    return char
end
GetCharacter()
LocalPlayer.CharacterAdded:Connect(GetCharacter)

-- SPEED & JUMP POWER
RunService.RenderStepped:Connect(function()
    if env.Destroyed or not Humanoid then return end
    if Settings.Speed then Humanoid.WalkSpeed = Settings.SpeedValue end
    if Settings.Jump then 
        Humanoid.UseJumpPower = true 
        Humanoid.JumpPower = Settings.JumpValue 
    end
end)

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if not env.Destroyed and Settings.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if not env.Destroyed and Settings.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- FLY LOGIC
local flyVel
RunService.RenderStepped:Connect(function()
    if not env.Destroyed and Settings.Fly and RootPart then
        if not flyVel or flyVel.Parent ~= RootPart then
            flyVel = Instance.new("BodyVelocity")
            flyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyVel.Parent = RootPart
        end
        local Cam = workspace.CurrentCamera
        local Dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then Dir += Cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then Dir -= Cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then Dir -= Cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then Dir += Cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then Dir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then Dir -= Vector3.new(0, 1, 0) end
        
        flyVel.Velocity = Dir.Magnitude > 0 and (Dir.Unit * (Settings.FlySpeed * 10)) or Vector3.zero
    else
        if flyVel then flyVel:Destroy(); flyVel = nil end
    end
end)

-- BOTÕES DA UI
CreateToggleWithValue("WalkSpeed", PlayerPage, Settings.Speed, Settings.SpeedValue, function(v)
    Settings.Speed = v
    if not v and Humanoid then Humanoid.WalkSpeed = 16 end
end, function(v) Settings.SpeedValue = v end)

CreateToggleWithValue("JumpPower", PlayerPage, Settings.Jump, Settings.JumpValue, function(v)
    Settings.Jump = v
    if not v and Humanoid then Humanoid.JumpPower = 50 end
end, function(v) Settings.JumpValue = v end)

CreateToggleWithValue("Fly", PlayerPage, Settings.Fly, Settings.FlySpeed, function(v)
    Settings.Fly = v
end, function(v) Settings.FlySpeed = v end)

CreateToggleWithValue("Fly Car", PlayerPage, Settings.FlyCar, Settings.FlyCarSpeed, function(v)
    Settings.FlyCar = v
end, function(v) Settings.FlyCarSpeed = v end)

CreateToggle("Noclip", PlayerPage, Settings.Noclip, function(v) Settings.Noclip = v end)
CreateToggle("Infinite Jump", PlayerPage, Settings.InfiniteJump, function(v) Settings.InfiniteJump = v end)
CreateToggle("CTRL + Click TP", PlayerPage, Settings.CtrlClickTP, function(v) Settings.CtrlClickTP = v end)
