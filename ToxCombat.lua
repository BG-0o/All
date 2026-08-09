-- ToxCombat.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ToxConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxConfig.lua"))()

local ToxCombat = {}

-- FIX: Busca de Alvos Universal
function ToxCombat:GetPlayer(Name)
	if not Name or Name == "" then return nil end
	Name = string.lower(Name)

	if Name == "all" or Name == "others" then
		return "all"
	elseif Name == "random" then
		local GetPlayers = Players:GetPlayers()
		if table.find(GetPlayers, LocalPlayer) then 
			table.remove(GetPlayers, table.find(GetPlayers, LocalPlayer)) 
		end
		if #GetPlayers > 0 then
			return GetPlayers[math.random(#GetPlayers)]
		end
		return nil
	else
		for _, x in ipairs(Players:GetPlayers()) do
			if x ~= LocalPlayer then
				if string.find(string.lower(x.Name), Name) or string.find(string.lower(x.DisplayName), Name) then
					return x
				end
			end
		end
	end
	return nil
end

function ToxCombat:SkidFling(TargetPlayer, hub)
	if not TargetPlayer or not TargetPlayer.Character then return end

	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local RootPart = Humanoid and Humanoid.RootPart or Character:FindFirstChild("HumanoidRootPart")

	local TCharacter = TargetPlayer.Character
	local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
	local TRootPart = THumanoid and THumanoid.RootPart or TCharacter:FindFirstChild("HumanoidRootPart")

	if Character and Humanoid and RootPart and TRootPart then
		local oldPos = RootPart.CFrame
        local bav = Instance.new("BodyAngularVelocity")
        bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bav.AngularVelocity = Vector3.new(0, 999999, 0)
        bav.Parent = RootPart

        local startTime = tick()
        while tick() - startTime < 1.5 do
            if not TRootPart or not RootPart then break end
            RootPart.CFrame = TRootPart.CFrame * CFrame.Angles(math.rad(math.random(-180,180)), math.rad(math.random(-180,180)), 0)
            RootPart.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
            RunService.Heartbeat:Wait()
        end

        bav:Destroy()
        RootPart.AssemblyLinearVelocity = Vector3.zero
        RootPart.AssemblyAngularVelocity = Vector3.zero
        RootPart.CFrame = oldPos
	end
end

function ToxCombat:ExecuteFling(TargetInput, hub)
	if not TargetInput or TargetInput == "" then
		if hub then hub:CustomNotify("Please enter a target name or 'all'", Color3.fromRGB(255, 100, 100)) end
		return
	end

	local LowerInput = string.lower(TargetInput)

	if LowerInput == "all" or LowerInput == "others" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then self:SkidFling(p, hub) end
		end
	else
		local TargetObj = self:GetPlayer(TargetInput)
		if TargetObj == "all" then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then self:SkidFling(p, hub) end
			end
		elseif typeof(TargetObj) == "Instance" and TargetObj:IsA("Player") then
			self:SkidFling(TargetObj, hub)
		else
			if hub then hub:CustomNotify("Username/Target Invalid", Color3.fromRGB(255, 100, 100)) end
		end
	end
end

function ToxCombat:Init(parentPage, hub)
    hub:CreateInputWithButton("Target Fling", parentPage, "", "Fling", function(text)
        self:ExecuteFling(text, hub)
    end)
end

return ToxCombat
