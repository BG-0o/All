-- ToxPlayer.lua (Módulo Player com Anti-Void Corrigido)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ToxConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxConfig.lua"))()

local ToxPlayer = {
    AntiVoidConnection = nil,
    LastSafeCFrame = nil,
    NoclipConn = nil
}

-- FIX: Anti Void Totalmente Operacional
function ToxPlayer:SetAntiVoid(enabled)
    ToxConfig:Set("Player", "AntiVoid", enabled)
    
    if self.AntiVoidConnection then
        self.AntiVoidConnection:Disconnect()
        self.AntiVoidConnection = nil
    end

    if enabled then
        self.AntiVoidConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if not hrp or not hum then return end

            -- Atualiza posição segura quando grounded
            if hum.FloorMaterial ~= Enum.Material.Air and hrp.Position.Y > (workspace.FallenPartsDestroyHeight + 25) then
                self.LastSafeCFrame = hrp.CFrame
            end

            -- Intercepta Queda no Void
            local voidThreshold = workspace.FallenPartsDestroyHeight + 15
            if hrp.Position.Y <= voidThreshold then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                
                if self.LastSafeCFrame then
                    hrp.CFrame = self.LastSafeCFrame + Vector3.new(0, 4, 0)
                else
                    hrp.CFrame = CFrame.new(0, 50, 0)
                end
            end
        end)
    end
end

function ToxPlayer:SetWalkSpeed(val)
    ToxConfig:Set("Player", "WalkSpeed", val)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = val
    end
end

function ToxPlayer:SetJumpPower(val)
    ToxConfig:Set("Player", "JumpPower", val)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.UseJumpPower = true
        char.Humanoid.JumpPower = val
    end
end

function ToxPlayer:Init(parentFrame, hub)
    -- Anti Void Toggle
    local avBtn = Instance.new("TextButton")
    avBtn.Size = UDim2.new(1, -10, 0, 32)
    avBtn.BackgroundColor3 = ToxConfig:Get("Player", "AntiVoid", false) and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(40, 40, 40)
    avBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    avBtn.Text = "Anti Void: " .. (ToxConfig:Get("Player", "AntiVoid", false) and "ON" or "OFF")
    avBtn.Font = Enum.Font.SourceSansBold
    avBtn.TextSize = 14
    avBtn.Parent = parentFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = avBtn

    avBtn.MouseButton1Click:Connect(function()
        local state = not ToxConfig:Get("Player", "AntiVoid", false)
        self:SetAntiVoid(state)
        avBtn.Text = "Anti Void: " .. (state and "ON" or "OFF")
        avBtn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(40, 40, 40)
    end)

    -- Aplica o AntiVoid caso ativado via Config
    if ToxConfig:Get("Player", "AntiVoid", false) then
        self:SetAntiVoid(true)
    end
end

return ToxPlayer
