-- ToxMisc.lua
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local ToxConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxConfig.lua"))()

local ToxMisc = {}

function ToxMisc:SetAntiAFK(state)
    ToxConfig:Set("Misc", "AntiAFK", state)
    if state and not self.AFKConn then
        self.AFKConn = LocalPlayer.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    elseif not state and self.AFKConn then
        self.AFKConn:Disconnect()
        self.AFKConn = nil
    end
end

function ToxMisc:Init(parentFrame, hub)
    local afkBtn = Instance.new("TextButton")
    afkBtn.Size = UDim2.new(1, -10, 0, 32)
    afkBtn.BackgroundColor3 = ToxConfig:Get("Misc", "AntiAFK", true) and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(40, 40, 40)
    afkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    afkBtn.Text = "Anti AFK: " .. (ToxConfig:Get("Misc", "AntiAFK", true) and "ON" or "OFF")
    afkBtn.Font = Enum.Font.SourceSansBold
    afkBtn.TextSize = 14
    afkBtn.Parent = parentFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = afkBtn

    afkBtn.MouseButton1Click:Connect(function()
        local state = not ToxConfig:Get("Misc", "AntiAFK", true)
        self:SetAntiAFK(state)
        afkBtn.Text = "Anti AFK: " .. (state and "ON" or "OFF")
        afkBtn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(40, 40, 40)
    end)

    local rejBtn = Instance.new("TextButton")
    rejBtn.Size = UDim2.new(1, -10, 0, 32)
    rejBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    rejBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rejBtn.Text = "Reentrar no Servidor (Rejoin)"
    rejBtn.Font = Enum.Font.SourceSansBold
    rejBtn.TextSize = 14
    rejBtn.Parent = parentFrame

    local rejCorner = Instance.new("UICorner")
    rejCorner.CornerRadius = UDim.new(0, 4)
    rejCorner.Parent = rejBtn

    rejBtn.MouseButton1Click:Connect(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)

    if ToxConfig:Get("Misc", "AntiAFK", true) then
        self:SetAntiAFK(true)
    end
end

return ToxMisc
