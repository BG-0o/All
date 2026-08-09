-- ToxPlayer.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

local ToxConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxConfig.lua"))()

local ToxPlayer = {
    AntiVoidConnection = nil,
    LastSafeCFrame = nil,
    NoclipConnection = nil,
    NoFallConnection = nil,
    AntiFlingConnection = nil,
    LoopTPConnection = nil
}

-- FIX: Anti-Void Corrigido
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
    local function CreateToggleWithValue(Name, Page, DefaultToggle, DefaultValue, CallbackToggle, CallbackValue)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, -5, 0, 39)
        Container.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        Container.BorderSizePixel = 0
        Container.Parent = Page

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -125, 1, 0)
        Label.Position = UDim2.new(0, 12, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.TextColor3 = Color3.fromRGB(240, 240, 240)
        Label.TextSize = 13
        Label.Font = Enum.Font.GothamMedium
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Container

        local Input = Instance.new("TextBox")
        Input.Size = UDim2.new(0, 55, 0, 25)
        Input.Position = UDim2.new(1, -112, 0.5, -12)
        Input.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
        Input.BorderSizePixel = 0
        Input.Text = tostring(DefaultValue)
        Input.TextColor3 = Color3.fromRGB(255, 255, 255)
        Input.TextSize = 12
        Input.Font = Enum.Font.Gotham
        Input.ClearTextOnFocus = false
        Input.Parent = Container

        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 4)
        InputCorner.Parent = Input

        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 38, 0, 20)
        ToggleButton.Position = UDim2.new(1, -48, 0.5, -10)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Text = ""
        ToggleButton.AutoButtonColor = false
        ToggleButton.Parent = Container

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 4)
        ToggleCorner.Parent = ToggleButton

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 14, 0, 14)
        Indicator.Position = UDim2.new(0, 3, 0.5, -7)
        Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Indicator.BorderSizePixel = 0
        Indicator.Parent = ToggleButton

        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 3)
        IndicatorCorner.Parent = Indicator

        local Enabled = DefaultToggle or false

        local function UpdateToggle()
            if Enabled then
                ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 70)
                Indicator.Position = UDim2.new(1, -17, 0.5, -7)
            else
                ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
                Indicator.Position = UDim2.new(0, 3, 0.5, -7)
            end
        end

        ToggleButton.MouseButton1Click:Connect(function()
            Enabled = not Enabled
            UpdateToggle()
            CallbackToggle(Enabled)
            ToxConfig:Save()
        end)

        Input.FocusLost:Connect(function()
            local Number = tonumber(Input.Text)
            if Number then
                CallbackValue(Number)
                ToxConfig:Save()
            else
                Input.Text = tostring(DefaultValue)
            end
        end)

        UpdateToggle()
        return Container
    end

    local function CreateToggle(Name, Page, DefaultValue, Callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -5, 0, 39)
        Button.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        Button.BorderSizePixel = 0
        Button.Text = ""
        Button.AutoButtonColor = false
        Button.Parent = Page

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -65, 1, 0)
        Label.Position = UDim2.new(0, 12, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.TextColor3 = Color3.fromRGB(240, 240, 240)
        Label.TextSize = 13
        Label.Font = Enum.Font.GothamMedium
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Button

        local Toggle = Instance.new("Frame")
        Toggle.Size = UDim2.new(0, 38, 0, 20)
        Toggle.Position = UDim2.new(1, -48, 0.5, -10)
        Toggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        Toggle.BorderSizePixel = 0
        Toggle.Parent = Button

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 4)
        ToggleCorner.Parent = Toggle

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 14, 0, 14)
        Indicator.Position = UDim2.new(0, 3, 0.5, -7)
        Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Indicator.BorderSizePixel = 0
        Indicator.Parent = Toggle

        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 3)
        IndicatorCorner.Parent = Indicator

        local Enabled = DefaultValue or false

        local function Update()
            if Enabled then
                Toggle.BackgroundColor3 = Color3.fromRGB(50, 180, 70)
                Indicator.Position = UDim2.new(1, -17, 0.5, -7)
            else
                Toggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
                Indicator.Position = UDim2.new(0, 3, 0.5, -7)
            end
        end

        Button.MouseButton1Click:Connect(function()
            Enabled = not Enabled
            Update()
            Callback(Enabled)
            ToxConfig:Save()
        end)

        Update()
        return Button
    end

    CreateToggleWithValue("Speed", parentPage, ToxConfig.Settings.Speed, ToxConfig.Settings.SpeedValue, function(v) ToxConfig.Settings.Speed = v end, function(val) ToxConfig.Settings.SpeedValue = val end)
    CreateToggleWithValue("Jump", parentPage, ToxConfig.Settings.Jump, ToxConfig.Settings.JumpValue, function(v) ToxConfig.Settings.Jump = v end, function(val) ToxConfig.Settings.JumpValue = val end)
    CreateToggle("Noclip", parentPage, ToxConfig.Settings.Noclip, function(v) ToxConfig.Settings.Noclip = v end)
    CreateToggle("Infinite Jump", parentPage, ToxConfig.Settings.InfiniteJump, function(v) ToxConfig.Settings.InfiniteJump = v end)
    CreateToggle("Anti Void", parentPage, ToxConfig.Settings.AntiVoid, function(v) ToxConfig.Settings.AntiVoid = v if v then self:StartAntiVoid(hub) else self:StopAntiVoid() end end)

    if ToxConfig.Settings.AntiVoid then self:StartAntiVoid(hub) end
end

return ToxPlayer
