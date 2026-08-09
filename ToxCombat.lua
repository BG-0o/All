-- ========================================================
-- ToxCombat.lua - Aba COMBAT
-- ========================================================

local env = getgenv().ToxEnv
if not env then return end

local CombatPage = env.CombatPage
local Settings = env.Settings
local ColorMap = env.ColorMap

local CreateToggle = env.CreateToggle
local CreateToggleWithValue = env.CreateToggleWithValue
local CreateDropdown = env.CreateDropdown
local CreateKeybind = env.CreateKeybind
local CreateInputWithToggle = env.CreateInputWithToggle

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = env.Player or Players.LocalPlayer
local Camera = workspace.CurrentCamera

Settings.Combat = Settings.Combat or {
    Aimbot = false,
    UseLeftClick = true,
    UseCustomKey = false,
    UseGuiInset = true,
    AimKey = Enum.KeyCode.E,
    AimPart = "Head",
    AimType = "Camera",
    IgnoreFriends = false,
    PredictMovement = false,
    TeamCheck = false,
    WallCheck = false,
    Blatant = false,
    Sensitivity = 8,
    AimRange = 500,
    XOffset = 0,
    YOffset = 0,
    AimTargets = "Players Only",
    LockRadius = 110,
    FOVCircle = false,
    CircleColor = "Purple",
    TriggerBot = false,
    TriggerSpeed = 5,
    AimLock = false,
    AimLockTarget = ""
}

local Combat = Settings.Combat

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

RunService.RenderStepped:Connect(function()
    if env.Destroyed then
        FOVCircle.Visible = false
        pcall(function() FOVCircle:Remove() end)
        return
    end

    if Combat.FOVCircle then
        FOVCircle.Visible = true
        FOVCircle.Radius = Combat.LockRadius
        FOVCircle.Color = ColorMap[Combat.CircleColor] or Color3.fromRGB(150, 50, 255)
        
        local mousePos = UserInputService:GetMouseLocation()
        if not Combat.UseGuiInset then
            local inset = GuiService:GetGuiInset()
            mousePos = Vector2.new(mousePos.X, mousePos.Y - inset.Y)
        end
        FOVCircle.Position = mousePos
    else
        FOVCircle.Visible = false
    end
end)

local function GetTargetPartFromModel(model, partName)
    if not model then return nil end
    if partName == "Torso" then
        return model:FindFirstChild("Torso") 
            or model:FindFirstChild("UpperTorso") 
            or model:FindFirstChild("LowerTorso") 
            or model:FindFirstChild("HumanoidRootPart")
    elseif partName == "Head" then
        return model:FindFirstChild("Head")
    elseif partName == "HumanoidRootPart" then
        return model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
    end
    return model:FindFirstChild(partName)
end

local function IsPartVisible(targetPart)
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = RaycastFilterType.Exclude
    
    local ignoreList = {Camera}
    if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
    raycastParams.FilterDescendantsInstances = ignoreList

    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function GetAimLockTargetPart()
    if not Combat.AimLock or Combat.AimLockTarget == "" then return nil end
    local query = Combat.AimLockTarget:lower()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local pName = player.Name:lower()
            local dName = player.DisplayName:lower()
            if pName:sub(1, #query) == query or dName:sub(1, #query) == query or pName:find(query, 1, true) or dName:find(query, 1, true) then
                return GetTargetPartFromModel(player.Character, Combat.AimPart)
            end
        end
    end
    return nil
end

local function GetClosestTarget()
    local lockPart = GetAimLockTargetPart()
    if lockPart then return lockPart end

    local closestTarget = nil
    local shortestDistance = Combat.LockRadius
    local mousePos = UserInputService:GetMouseLocation()
    local targetsToProcess = {}

    if Combat.AimTargets == "Players Only" or Combat.AimTargets == "All" then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if Combat.TeamCheck and player.Team == LocalPlayer.Team then continue end
                if Combat.IgnoreFriends and LocalPlayer:IsFriendsWith(player.UserId) then continue end
                table.insert(targetsToProcess, player.Character)
            end
        end
    end

    if Combat.AimTargets == "NPCs" or Combat.AimTargets == "All" then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Parent and obj.Health > 0 then
                local model = obj.Parent
                if model:IsA("Model") and not Players:GetPlayerFromCharacter(model) and model ~= LocalPlayer.Character then
                    table.insert(targetsToProcess, model)
                end
            end
        end
    end

    for _, model in ipairs(targetsToProcess) do
        local targetPart = GetTargetPartFromModel(model, Combat.AimPart)
        if targetPart then
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local worldDist = (targetPart.Position - Camera.CFrame.Position).Magnitude
                if worldDist <= Combat.AimRange then
                    if not Combat.WallCheck or IsPartVisible(targetPart) then
                        local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                        if distToMouse < shortestDistance then
                            shortestDistance = distToMouse
                            closestTarget = targetPart
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

local isLeftClicking = false
local isCustomKeyHolding = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or env.Destroyed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then isLeftClicking = true end
    if Combat.AimKey and (input.KeyCode == Combat.AimKey or input.UserInputType == Combat.AimKey) then isCustomKeyHolding = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then isLeftClicking = false end
    if Combat.AimKey and (input.KeyCode == Combat.AimKey or input.UserInputType == Combat.AimKey) then isCustomKeyHolding = false end
end)

local function ShouldAim()
    if not Combat.Aimbot then return false end
    if Combat.UseLeftClick and not isLeftClicking then return false end
    if Combat.UseCustomKey and not isCustomKeyHolding then return false end
    return true
end

RunService.RenderStepped:Connect(function()
    if env.Destroyed then return end

    if ShouldAim() then
        local targetPart = GetClosestTarget()
        if targetPart then
            local targetPos = targetPart.Position

            if Combat.PredictMovement and targetPart.Parent:FindFirstChild("HumanoidRootPart") then
                local vel = targetPart.Parent.HumanoidRootPart.AssemblyLinearVelocity
                targetPos = targetPos + (vel * 0.05)
            end

            targetPos = targetPos + Vector3.new(Combat.XOffset, Combat.YOffset, 0)

            if Combat.AimType == "Camera" then
                if Combat.Blatant then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                else
                    local alpha = math.clamp((11 - Combat.Sensitivity) * 0.05, 0.01, 1)
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), alpha)
                end
            end
        end
    end

    if Combat.TriggerBot then
        local mouse = LocalPlayer:GetMouse()
        if mouse.Target and mouse.Target.Parent and mouse.Target.Parent:FindFirstChildOfClass("Humanoid") then
            local targetChar = mouse.Target.Parent
            local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
            if targetPlayer and targetPlayer ~= LocalPlayer then
                if not (Combat.TeamCheck and targetPlayer.Team == LocalPlayer.Team) then
                    if mouse1click then
                        mouse1click()
                        task.wait(1 / math.max(Combat.TriggerSpeed, 1))
                    end
                end
            end
        end
    end
end)

CreateToggle("Aimbot", CombatPage, Combat.Aimbot, function(v) Combat.Aimbot = v end)
CreateToggle("Use Left Click", CombatPage, Combat.UseLeftClick, function(v) Combat.UseLeftClick = v end)
CreateToggle("Use Custom Key", CombatPage, Combat.UseCustomKey, function(v) Combat.UseCustomKey = v end)
CreateToggle("Use Gui Inset", CombatPage, Combat.UseGuiInset, function(v) Combat.UseGuiInset = v end)

CreateKeybind("Aim Key", CombatPage, Combat.AimKey, function(k) Combat.AimKey = k end)
CreateDropdown("Aim Part", {"Head", "HumanoidRootPart", "Torso"}, CombatPage, Combat.AimPart, function(v) Combat.AimPart = v end)
CreateDropdown("Aim Type", {"Camera", "Mouse"}, CombatPage, Combat.AimType, function(v) Combat.AimType = v end)

CreateToggle("Ignore Friends", CombatPage, Combat.IgnoreFriends, function(v) Combat.IgnoreFriends = v end)
CreateToggle("Predict Movement", CombatPage, Combat.PredictMovement, function(v) Combat.PredictMovement = v end)
CreateToggle("Team Check", CombatPage, Combat.TeamCheck, function(v) Combat.TeamCheck = v end)
CreateToggle("Wall Check", CombatPage, Combat.WallCheck, function(v) Combat.WallCheck = v end)
CreateToggle("Blatant", CombatPage, Combat.Blatant, function(v) Combat.Blatant = v end)

CreateToggleWithValue("Sensitivity", CombatPage, false, Combat.Sensitivity, function() end, function(v) Combat.Sensitivity = v end)
CreateToggleWithValue("Aim Range", CombatPage, false, Combat.AimRange, function() end, function(v) Combat.AimRange = v end)
CreateToggleWithValue("X Offset", CombatPage, false, Combat.XOffset, function() end, function(v) Combat.XOffset = v end)
CreateToggleWithValue("Y Offset", CombatPage, false, Combat.YOffset, function() end, function(v) Combat.YOffset = v end)

CreateDropdown("Aim Targets", {"Players Only", "NPCs", "All"}, CombatPage, Combat.AimTargets, function(v) Combat.AimTargets = v end)
CreateToggleWithValue("Lock Radius", CombatPage, false, Combat.LockRadius, function() end, function(v) Combat.LockRadius = v end)

CreateToggle("FOV Circle", CombatPage, Combat.FOVCircle, function(v) Combat.FOVCircle = v end)
CreateDropdown("Circle Color", {"Purple", "White", "Red", "Green", "Blue", "Yellow", "Cyan"}, CombatPage, Combat.CircleColor, function(v) Combat.CircleColor = v end)

CreateToggleWithValue("Trigger Bot", CombatPage, Combat.TriggerBot, Combat.TriggerSpeed, function(v) Combat.TriggerBot = v end, function(v) Combat.TriggerSpeed = v end)

CreateInputWithToggle("Aim Lock", CombatPage, Combat.AimLockTarget, function(v, txt)
    Combat.AimLock = v
    Combat.AimLockTarget = txt
end)
