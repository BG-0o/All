-- ToxPlayer.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ToxConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxConfig.lua"))()

local ToxPlayer = {
    AntiVoidConnection = nil,
    LastSafeCFrame = nil,
    NoclipConn = nil,
    FlyConn = nil,
    Flying = false
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

            -- Salva posição segura quando encosta no chão
            if hum.FloorMaterial ~= Enum.Material.Air and hrp.Position.Y > (workspace.FallenPartsDestroyHeight + 30) then
                self.LastSafeCFrame = hrp.CFrame
            end

            -- Verifica se caiu no Void
            local voidThreshold = workspace.FallenPartsDestroyHeight + 15
            if hrp.Position.Y <= voidThreshold or hrp.Position.Y < -150 then
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

function ToxPlayer:SetWalkSpeed(speed)
    ToxConfig:Set("Player", "WalkSpeed", speed)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speed
    end
end

function ToxPlayer:SetJumpPower(power)
    ToxConfig:Set("Player", "JumpPower", power)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.UseJumpPower = true
        char.Humanoid.JumpPower = power
    end
end

function ToxPlayer:SetNoclip(enabled)
    ToxConfig:Set("Player", "Noclip", enabled)
    if self.NoclipConn then
        self.NoclipConn:Disconnect()
        self.NoclipConn = nil
    end
    if enabled then
        self.NoclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
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

    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(0, 4)
    avCorner.Parent = avBtn

    avBtn.MouseButton1Click:Connect(function()
        local state = not ToxConfig:Get("Player", "AntiVoid", false)
        self:SetAntiVoid(state)
        avBtn.Text = "Anti Void: " .. (state and "ON" or "OFF")
        avBtn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(40, 40, 40)
    end)

    -- Noclip Toggle
    local ncBtn = Instance.new("TextButton")
    ncBtn.Size = UDim2.new(1, -10, 0, 32)
    ncBtn.BackgroundColor3 = ToxConfig:Get("Player", "Noclip", false) and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(40, 40, 40)
    ncBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ncBtn.Text = "Noclip: " .. (ToxConfig:Get("Player", "Noclip", false) and "ON" or "OFF")
    ncBtn.Font = Enum.Font.SourceSansBold
    ncBtn.TextSize = 14
    ncBtn.Parent = parentFrame

    local ncCorner = Instance.new("UICorner")
    ncCorner.CornerRadius = UDim.new(0, 4)
    ncCorner.Parent = ncBtn

    ncBtn.MouseButton1Click:Connect(function()
        local state = not ToxConfig:Get("Player", "Noclip", false)
        self:SetNoclip(state)
        ncBtn.Text = "Noclip: " .. (state and "ON" or "OFF")
        ncBtn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(40, 40, 40)
    end)

    -- WalkSpeed Box
    local wsBox = Instance.new("TextBox")
    wsBox.Size = UDim2.new(1, -10, 0, 30)
    wsBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    wsBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    wsBox.PlaceholderText = "WalkSpeed (Default: 16)"
    wsBox.Text = tostring(ToxConfig:Get("Player", "WalkSpeed", 16))
    wsBox.Font = Enum.Font.SourceSans
    wsBox.TextSize = 14
    wsBox.Parent = parentFrame

    local wsCorner = Instance.new("UICorner")
    wsCorner.CornerRadius = UDim.new(0, 4)
    wsCorner.Parent = wsBox

    wsBox.FocusLost:Connect(function()
        local val = tonumber(wsBox.Text) or 16
        self:SetWalkSpeed(val)
    end)

    -- Aplica salvamentos automáticos
    if ToxConfig:Get("Player", "AntiVoid", false) then self:SetAntiVoid(true) end
    if ToxConfig:Get("Player", "Noclip", false) then self:SetNoclip(true) end
    self:SetWalkSpeed(ToxConfig:Get("Player", "WalkSpeed", 16))
end

return ToxPlayer
