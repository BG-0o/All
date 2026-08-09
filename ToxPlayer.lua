-- ========================================================
-- ToxPlayer.lua - Aba PLAYER
-- ========================================================

local env = getgenv().ToxEnv
if not env then return end

local PlayerPage = env.PlayerPage
local Settings = env.Settings

local CreateToggle = env.CreateToggle
local CreateToggleWithValue = env.CreateToggleWithValue
local CreateTeleportRow = env.CreateTeleportRow

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
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

-- SPEED & JUMP
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

-- NOCLIP COM DESATIVAÇÃO CORRETA
local noclipConn
local function StartNoclip()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = RunService.Stepped:Connect(function()
        if env.Destroyed or not Settings.Noclip or not LocalPlayer.Character then
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            return
        end
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
end

local function DisableNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                if part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "LowerTorso" or part.Name == "Head" then
                    part.CanCollide = true
                end
            end
        end
    end
end

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

-- FLY CAR LOGIC COM NOTIFICAÇÃO DE ASSENTO
local flyCarVel, flyCarGyro, flyCarConn
local function StopFlyCar()
	if flyCarConn then flyCarConn:Disconnect(); flyCarConn = nil end
	if flyCarVel then flyCarVel:Destroy(); flyCarVel = nil end
	if flyCarGyro then flyCarGyro:Destroy(); flyCarGyro = nil end
end

local function StartFlyCar()
	StopFlyCar()
	local Seat = Humanoid and Humanoid.SeatPart
	if not Seat then
		if env.Message then env.Message("Flycar Error", "You must be sitting in a vehicle seat!", 3) end
		Settings.FlyCar = false
		return
	end

	local Root = Seat.Parent:IsA("Model") and (Seat.Parent.PrimaryPart or Seat) or Seat
	flyCarVel = Instance.new("BodyVelocity") flyCarVel.MaxForce = Vector3.new(1e9, 1e9, 1e9); flyCarVel.Parent = Root
	flyCarGyro = Instance.new("BodyGyro") flyCarGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9); flyCarGyro.CFrame = Root.CFrame; flyCarGyro.Parent = Root

	flyCarConn = RunService.RenderStepped:Connect(function()
		if env.Destroyed or not Settings.FlyCar or not Seat or not Seat.Parent then
			StopFlyCar()
			Settings.FlyCar = false
			return
		end

		local CamCF = workspace.CurrentCamera.CFrame
		local Direction = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then Direction += CamCF.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then Direction -= CamCF.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then Direction -= CamCF.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then Direction += CamCF.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then Direction += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then Direction -= Vector3.new(0, 1, 0) end

		if Direction.Magnitude > 0 then Direction = Direction.Unit end
		flyCarVel.Velocity = Direction * (Settings.FlyCarSpeed * 10)
		flyCarGyro.CFrame = CamCF
	end)
end

-- FLOAT LOGIC
local floatVel
RunService.RenderStepped:Connect(function()
    if not env.Destroyed and Settings.Float and RootPart then
        if not floatVel or floatVel.Parent ~= RootPart then
            floatVel = Instance.new("BodyVelocity")
            floatVel.MaxForce = Vector3.new(0, 100000, 0)
            floatVel.Parent = RootPart
        end
        local YVel = 0
        if UserInputService:IsKeyDown(Settings.UpBind) then YVel += Settings.FloatStrength end
        if UserInputService:IsKeyDown(Settings.DownBind) then YVel -= Settings.FloatStrength end
        floatVel.Velocity = Vector3.new(0, YVel, 0)
    else
        if floatVel then floatVel:Destroy(); floatVel = nil end
    end
end)

-- TELEPORT HELPERS
local loopTPConn, loopTPPlayer
local function GetPlayerByNick(Name)
	if not Name or Name == "" then return nil end
	Name = Name:lower()
	for _, x in ipairs(Players:GetPlayers()) do
		if x ~= LocalPlayer then
			if x.Name:lower():sub(1, #Name) == Name or x.DisplayName:lower():sub(1, #Name) == Name then
				return x
			end
		end
	end
	return nil
end

local function TeleportToPlayer(targetName)
	local target = GetPlayerByNick(targetName)
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and RootPart then
		RootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
	else
		if env.Message then env.Message("Teleport", "Player not found", 3) end
	end
end

-- CONSTRUÇÃO DOS ELEMENTOS DA ABA PLAYER (EXATAMENTE COMO NO SEU SCRIPT ANTIGO)
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

CreateToggleWithValue("Flycar", PlayerPage, Settings.FlyCar, Settings.FlyCarSpeed, function(v)
    Settings.FlyCar = v
    if v then StartFlyCar() else StopFlyCar() end
end, function(v) Settings.FlyCarSpeed = v end)

CreateToggleWithValue("Float", PlayerPage, Settings.Float, Settings.FloatStrength, function(v)
    Settings.Float = v
end, function(v) Settings.FloatStrength = v end)

CreateToggle("Noclip", PlayerPage, Settings.Noclip, function(v)
    Settings.Noclip = v
    if v then StartNoclip() else DisableNoclip() end
end)

CreateToggle("Infinite Jump", PlayerPage, Settings.InfiniteJump, function(v) Settings.InfiniteJump = v end)

CreateTeleportRow("Teleport", PlayerPage, function(nick)
    TeleportToPlayer(nick)
end, function(enabled, nick)
    Settings.LoopTP = enabled
    if loopTPConn then loopTPConn:Disconnect(); loopTPConn = nil end
    if enabled then
        loopTPPlayer = GetPlayerByNick(nick)
        if loopTPPlayer then
            loopTPConn = RunService.Heartbeat:Connect(function()
                if env.Destroyed or not Settings.LoopTP or not loopTPPlayer or not loopTPPlayer.Character then
                    if loopTPConn then loopTPConn:Disconnect(); loopTPConn = nil end
                    return
                end
                if loopTPPlayer.Character:FindFirstChild("HumanoidRootPart") and RootPart then
                    RootPart.CFrame = loopTPPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
            end)
        else
            if env.Message then env.Message("Loop TP", "Player not found", 3) end
            Settings.LoopTP = false
        end
    end
end)
