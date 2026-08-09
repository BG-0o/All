-- ToxCombat.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ToxConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxConfig.lua"))()

local ToxCombat = {
    IsFlinging = false
}

-- FIX: Sistema Universal de Busca de Alvos
function ToxCombat:GetTargets(str)
    if not str or str == "" then return {} end
    str = string.lower(str):match("^%s*(.-)%s*$")
    local targets = {}

    if str == "all" or str == "others" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(targets, p) end
        end
    elseif str == "random" then
        local plrs = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(plrs, p) end
        end
        if #plrs > 0 then
            table.insert(targets, plrs[math.random(1, #plrs)])
        end
    elseif str == "me" then
        table.insert(targets, LocalPlayer)
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local uName = string.lower(p.Name)
                local dName = string.lower(p.DisplayName)
                if string.find(uName, str) or string.find(dName, str) then
                    table.insert(targets, p)
                end
            end
        end
    end
    return targets
end

-- FIX: Execução de Fling
function ToxCombat:Fling(targetString)
    local targets = self:GetTargets(targetString)
    if #targets == 0 then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local oldPos = hrp.CFrame
    self.IsFlinging = true

    local bav = Instance.new("BodyAngularVelocity")
    bav.Name = "ToxSpin"
    bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bav.AngularVelocity = Vector3.new(0, 999999, 0)
    bav.Parent = hrp

    for _, target in ipairs(targets) do
        if not self.IsFlinging then break end
        local tChar = target.Character
        local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")

        if tHrp then
            local start = tick()
            while tick() - start < 1.2 and self.IsFlinging do
                if not tHrp or not hrp then break end
                hrp.CFrame = tHrp.CFrame * CFrame.Angles(math.rad(math.random(-180,180)), math.rad(math.random(-180,180)), 0)
                hrp.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
                RunService.Heartbeat:Wait()
            end
        end
    end

    bav:Destroy()
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = oldPos
    self.IsFlinging = false
end

function ToxCombat:Init(parentFrame, hub)
    local targetBox = Instance.new("TextBox")
    targetBox.Size = UDim2.new(1, -10, 0, 30)
    targetBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    targetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetBox.PlaceholderText = "Target: ALL / RANDOM / Nick / Display"
    targetBox.Text = ToxConfig:Get("Combat", "Target", "all")
    targetBox.Font = Enum.Font.SourceSans
    targetBox.TextSize = 14
    targetBox.Parent = parentFrame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = targetBox

    targetBox.FocusLost:Connect(function()
        ToxConfig:Set("Combat", "Target", targetBox.Text)
    end)

    local flingBtn = Instance.new("TextButton")
    flingBtn.Size = UDim2.new(1, -10, 0, 32)
    flingBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    flingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    flingBtn.Text = "Executar Fling"
    flingBtn.Font = Enum.Font.SourceSansBold
    flingBtn.TextSize = 14
    flingBtn.Parent = parentFrame

    local flingCorner = Instance.new("UICorner")
    flingCorner.CornerRadius = UDim.new(0, 4)
    flingCorner.Parent = flingBtn

    flingBtn.MouseButton1Click:Connect(function()
        self:Fling(targetBox.Text)
    end)
end

return ToxCombat
