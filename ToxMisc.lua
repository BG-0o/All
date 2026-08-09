-- ========================================================
-- ToxMisc.lua - Aba MISC
-- ========================================================

local env = getgenv().ToxEnv
if not env then return end

local FlingPage = env.MiscPage or env.FlingPage
local Settings = env.Settings

local CreateToggle = env.CreateToggle
local CreateInputWithButton = env.CreateInputWithButton
local CreateButton = env.CreateButton

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = env.Player

-- CTRL + CLICK TELEPORT CORRIGIDO
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or env.Destroyed or not Settings.CtrlClickTP then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            local mouse = LocalPlayer:GetMouse()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if mouse and mouse.Hit and root then
                root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

-- FLING ALL USANDO A SUA URL DO GITHUB
local function ExecuteFling(TargetInput)
	if TargetInput and TargetInput:lower() == "all" then
		pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/FlingAll.lua"))()
		end)
	else
		pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/FlingAll.lua"))()
		end)
	end
end

-- NO FALL DAMAGE
local noFallConn
local function StartNoFall()
	if noFallConn then noFallConn:Disconnect(); noFallConn = nil end
	noFallConn = RunService.PreRender:Connect(function()
		if env.Destroyed or not Settings.NoFallDamage then
			if noFallConn then noFallConn:Disconnect(); noFallConn = nil end
			return
		end
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root and root.AssemblyLinearVelocity.Y < -75 then
			root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, -75, root.AssemblyLinearVelocity.Z)
		end
	end)
end

-- ANTI VOID
local antiVoidConn, lastSafeCFrame
local function StartAntiVoid()
	if antiVoidConn then antiVoidConn:Disconnect(); antiVoidConn = nil end
	antiVoidConn = RunService.Heartbeat:Connect(function()
		if env.Destroyed or not Settings.AntiVoid then
			if antiVoidConn then antiVoidConn:Disconnect(); antiVoidConn = nil end
			return
		end
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if hum and root then
			if hum.FloorMaterial ~= Enum.Material.Air and root.Velocity.Y > -10 then
				lastSafeCFrame = root.CFrame
			end
			if root.Position.Y <= -250 then
				root.Velocity = Vector3.zero
				root.RotVelocity = Vector3.zero
				if lastSafeCFrame then root.CFrame = lastSafeCFrame + Vector3.new(0, 3, 0)
				else root.CFrame = CFrame.new(root.Position.X, 100, root.Position.Z) end
				if env.CustomNotify then env.CustomNotify("Anti Void Rescued You!", Color3.fromRGB(100, 255, 100)) end
			end
		end
	end)
end

-- ANTI FLING
local antiFlingConn
local function StartAntiFling()
	if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn = nil end
	antiFlingConn = RunService.Stepped:Connect(function()
		if env.Destroyed or not Settings.AntiFling then
			if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn = nil end
			return
		end
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				for _, part in ipairs(p.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
						part.AssemblyLinearVelocity = Vector3.zero
						part.AssemblyAngularVelocity = Vector3.zero
					end
				end
			end
		end
	end)
end

-- BOTÕES DA ABA MISC
CreateToggle("Ctrl Click TP", FlingPage, Settings.CtrlClickTP, function(v) Settings.CtrlClickTP = v end)

CreateToggle("No Fall Damage", FlingPage, Settings.NoFallDamage, function(v)
    Settings.NoFallDamage = v
    if v then StartNoFall() end
end)

CreateToggle("Anti Void", FlingPage, Settings.AntiVoid, function(v)
    Settings.AntiVoid = v
    if v then StartAntiVoid() end
end)

CreateToggle("Anti Fling", FlingPage, Settings.AntiFling, function(v)
    Settings.AntiFling = v
    if v then StartAntiFling() end
end)

CreateInputWithButton("Target Fling", FlingPage, "", "Fling", function(text)
    ExecuteFling(text)
end)

CreateButton("Music Player", FlingPage, function()
    if env.MusicGui then env.MusicGui.Visible = not env.MusicGui.Visible end
end)

if Settings.AntiFling then StartAntiFling() end
if Settings.AntiVoid then StartAntiVoid() end
if Settings.NoFallDamage then StartNoFall() end
