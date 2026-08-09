-- ToxPlayer.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local ToxConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxConfig.lua"))()

local ToxPlayer = {
    AntiVoidConnection = nil,
    LastSafeCFrame = nil,
    NoclipConn = nil
}

-- FIX: Anti-Void Totalmente Operacional
function ToxPlayer:StartAntiVoid(hub)
	self:StopAntiVoid()
	self.AntiVoidConnection = RunService.Heartbeat:Connect(function()
		if not ToxConfig.Settings.AntiVoid or not Player.Character then return end
        local char = Player.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum then return end

		if hum.FloorMaterial ~= Enum.Material.Air and root.AssemblyLinearVelocity.Y > -10 then
			self.LastSafeCFrame = root.CFrame
		end

		local fpdh = workspace.FallenPartsDestroyHeight or -500
		local isFallingOut = false
		if root.Position.Y <= (fpdh + 25) or root.Position.Y <= -250 then
			isFallingOut = true
		end

		if isFallingOut then
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			if self.LastSafeCFrame then
				root.CFrame = self.LastSafeCFrame + Vector3.new(0, 3, 0)
			else
				root.CFrame = CFrame.new(root.Position.X, 100, root.Position.Z)
			end
			if hub then hub:CustomNotify("Anti Void Rescued You!", Color3.fromRGB(100, 255, 100)) end
		end
	end)
end

function ToxPlayer:StopAntiVoid()
	if self.AntiVoidConnection then self.AntiVoidConnection:Disconnect() self.AntiVoidConnection = nil end
end

function ToxPlayer:Init(parentPage, hub)
    hub:CreateToggleWithValue("Speed", parentPage, ToxConfig.Settings.Speed, ToxConfig.Settings.SpeedValue, function(v) ToxConfig.Settings.Speed = v end, function(val) ToxConfig.Settings.SpeedValue = val end)
    hub:CreateToggleWithValue("Jump", parentPage, ToxConfig.Settings.Jump, ToxConfig.Settings.JumpValue, function(v) ToxConfig.Settings.Jump = v end, function(val) ToxConfig.Settings.JumpValue = val end)
    hub:CreateToggleWithValue("Fly", parentPage, ToxConfig.Settings.Fly, ToxConfig.Settings.FlySpeed, function(v) ToxConfig.Settings.Fly = v end, function(val) ToxConfig.Settings.FlySpeed = val end)
    hub:CreateToggleWithValue("Flycar", parentPage, ToxConfig.Settings.FlyCar, ToxConfig.Settings.FlyCarSpeed, function(v) ToxConfig.Settings.FlyCar = v end, function(val) ToxConfig.Settings.FlyCarSpeed = val end)
    hub:CreateToggleWithValue("Float", parentPage, ToxConfig.Settings.Float, ToxConfig.Settings.FloatStrength, function(v) ToxConfig.Settings.Float = v end, function(val) ToxConfig.Settings.FloatStrength = val end)
    hub:CreateToggle("Noclip", parentPage, ToxConfig.Settings.Noclip, function(v) ToxConfig.Settings.Noclip = v end)
    hub:CreateToggle("Infinite Jump", parentPage, ToxConfig.Settings.InfiniteJump, function(v) ToxConfig.Settings.InfiniteJump = v end)
    
    hub:CreateTeleportRow("Teleport", parentPage, function(nick)
        -- Teleport Logic
    end, function(enabled, nick)
        ToxConfig.Settings.LoopTP = enabled
    end)

    if ToxConfig.Settings.AntiVoid then self:StartAntiVoid(hub) end
end

return ToxPlayer
