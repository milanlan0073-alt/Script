-- CENDOL HUB - JUJUTSU SHENANIGANS
-- Premium UI Edition | Draigón UI v2.0
-- By: milanlan0073-alt | Powered by Architect 03

loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ========== SETTINGS ==========
local Settings = {
    Enabled = true,
    Keybind = "Q",
    AutoLock = true,
    MaxDistance = 150,
    TargetPriority = "Closest",
    SmoothCamera = true,
    Smoothness = 0.35,
    ShowESP = true,
    ESPColor = Color3.fromRGB(255, 50, 50),
    RainbowESP = false,
    ShowHealthBar = true
}

-- ========== VARIABLES ==========
local CurrentTarget = nil
local TargetPart = nil
local ESPObjects = {}
local UI = {}
local RainbowHue = 0

-- ========== HITBOXES ==========
local Hitboxes = {"Head", "UpperTorso", "HumanoidRootPart", "Torso"}

-- ========== UTILITIES ==========
local function IsAlive(c)
    if not c then return false end
    local h = c:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function GetDistance(a, b)
    return (a.Position - b.Position).Magnitude
end

-- ========== GET TARGETS ==========
local function GetAllTargets()
    local targets = {}
    local myChar = LocalPlayer.Character
    if not myChar then return targets end
    local myPos = myChar:FindFirstChild("HumanoidRootPart")
    if not myPos then return targets end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local c = p.Character
            if c and IsAlive(c) then
                local r = c:FindFirstChild("HumanoidRootPart")
                if r then
                    local d = GetDistance(r, myPos)
                    if d <= Settings.MaxDistance then
                        table.insert(targets, {
                            Character = c,
                            Root = r,
                            Distance = d,
                            Health = c.Humanoid.Health,
                            MaxHealth = c.Humanoid.MaxHealth,
                            Name = p.Name
                        })
                    end
                end
            end
        end
    end
    
    if Settings.TargetPriority == "Closest" then
        table.sort(targets, function(a,b) return a.Distance < b.Distance end)
    elseif Settings.TargetPriority == "LowestHP" then
        table.sort(targets, function(a,b) return (a.Health/a.MaxHealth) < (b.Health/b.MaxHealth) end)
    end
    
    return targets
end

local function GetBestHitbox(char)
    for _, h in ipairs(Hitboxes) do
        local part = char:FindFirstChild(h)
        if part and part:IsA("BasePart") then return part end
    end
    return char:FindFirstChild("HumanoidRootPart")
end

-- ========== ESP WITH RAINBOW ==========
local function CreateESP(target)
    if not Settings.ShowESP then return end
    if ESPObjects[target] then pcall(function() ESPObjects[target]:Destroy() end) end
    
    local root = target:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local espColor = Settings.ESPColor
    if Settings.RainbowESP then
        RainbowHue = (RainbowHue + 0.01) % 1
        espColor = Color3.fromHSV(RainbowHue, 1, 1)
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CendolHub_ESP"
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = root
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 1
    
    -- Name Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = target.Name or "?"
    
    -- Health Bar
    local healthFrame = Instance.new("Frame")
    healthFrame.Size = UDim2.new(1, 0, 0.25, 0)
    healthFrame.Position = UDim2.new(0, 0, 0.45, 0)
    healthFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthFrame.BorderSizePixel = 0
    
    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthFill.BorderSizePixel = 0
    
    -- Distance Label
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.25, 0)
    distLabel.Position = UDim2.new(0, 0, 0.75, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Gotham
    distLabel.Text = math.floor(GetDistance(root, LocalPlayer.Character.HumanoidRootPart)) .. "m"
    
    -- Outline Effect
    local outline = Instance.new("UICorner")
    outline.CornerRadius = UDim.new(0, 4)
    
    healthFill.Parent = healthFrame
    healthFrame.Parent = mainFrame
    nameLabel.Parent = mainFrame
    distLabel.Parent = mainFrame
    mainFrame.Parent = billboard
    billboard.Parent = root
    
    ESPObjects[target] = {billboard, healthFill, distLabel}
    
    -- Update health bar color based on HP
    local hpPercent = target.Humanoid.Health / target.Humanoid.MaxHealth
    healthFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
end

local function UpdateESP()
    for target, data in pairs(ESPObjects) do
        if not target or not target.Parent or not IsAlive(target) then
            pcall(function() data[1]:Destroy() end)
            ESPObjects[target] = nil
        elseif IsAlive(target) and data then
            local root = target:FindFirstChild("HumanoidRootPart")
            if root and data[3] then
                local dist = math.floor(GetDistance(root, LocalPlayer.Character.HumanoidRootPart))
                data[3].Text = dist .. "m"
            end
            if Settings.ShowHealthBar and data[2] then
                local hpPercent = target.Humanoid.Health / target.Humanoid.MaxHealth
                data[2].Size = UDim2.new(hpPercent, 0, 1, 0)
                data[2].BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
            end
            if Settings.RainbowESP and data[1] then
                RainbowHue = (RainbowHue + 0.01) % 1
                local frame = data[1]:FindFirstChild("Frame")
                if frame then
                    frame.BackgroundColor3 = Color3.fromHSV(RainbowHue, 1, 1)
                end
            end
        end
    end
end

-- ========== LOCK-ON CORE ==========
local function FindBestTarget()
    local targets = GetAllTargets()
    if #targets > 0 then
        local best = targets[1]
        return best.Character, GetBestHitbox(best.Character)
    end
    return nil, nil
end

local function UpdateLockOn()
    if not Settings.Enabled then return end
    if not CurrentTarget or not IsAlive(CurrentTarget) then
        if Settings.AutoLock then
            CurrentTarget, TargetPart = FindBestTarget()
            if CurrentTarget then CreateESP(CurrentTarget) end
        end
    end
end

local function SmoothLock()
    if not Settings.Enabled or not TargetPart or not TargetPart.Parent then return end
    
    local targetPos = TargetPart.Position
    local currentPos = Camera.CFrame.Position
    
    if Settings.SmoothCamera then
        local newCFrame = CFrame.new(currentPos, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Settings.Smoothness)
    else
        Camera.CFrame = CFrame.new(currentPos, targetPos)
    end
end

-- ========== KEYBIND ==========
local KeyMap = {Q=Enum.KeyCode.Q, E=Enum.KeyCode.E, R=Enum.KeyCode.R, F=Enum.KeyCode.F}
UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    local k = KeyMap[Settings.Keybind]
    if i.KeyCode == k then
        Settings.Enabled = not Settings.Enabled
        if not Settings.Enabled then
            CurrentTarget = nil
            TargetPart = nil
            for _, data in pairs(ESPObjects) do
                pcall(function() data[1]:Destroy() end)
            end
            ESPObjects = {}
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "⚔️ CENDOL HUB",
            Text = Settings.Enabled and "🔴 LOCK-ON ACTIVE" or "⚫ LOCK-ON OFF",
            Duration = 1.5
        })
        if UI.ToggleButton then
            UI.ToggleButton.Text = Settings.Enabled and "▶ ACTIVE" or "⏸ OFF"
            UI.ToggleButton.TextColor3 = Settings.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        end
    end
end)

-- ========== PREMIUM UI ==========
local function CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CendolHubUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    
    -- Main Container
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 280, 0, 380)
    container.Position = UDim2.new(0, 15, 0, 100)
    container.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    container.BackgroundTransparency = 0.1
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    
    -- Shadow
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0
    shadow.Parent = container
    
    -- Corner Radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    container:AddTag("UICorner")
    pcall(function() container.UICorner = corner end)
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    header.BackgroundTransparency = 0.85
    header.BorderSizePixel = 0
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    header.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.Text = "⚡ CENDOL HUB ⚡"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = header
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0.3, 0)
    subtitle.Position = UDim2.new(0, 0, 0.7, 0)
    subtitle.Text = "JUJUTSU SHENANIGANS"
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    subtitle.BackgroundTransparency = 1
    subtitle.TextScaled = true
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = header
    
    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -70)
    content.Position = UDim2.new(0, 0, 0, 70)
    content.BackgroundTransparency = 1
    content.Parent = container
    
    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
    toggleBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
    toggleBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(150, 50, 50)
    toggleBtn.Text = Settings.Enabled and "▶ ACTIVE" or "⏸ OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    toggleBtn.Parent = toggleBtn
    
    toggleBtn.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        toggleBtn.Text = Settings.Enabled and "▶ ACTIVE" or "⏸ OFF"
        toggleBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(150, 50, 50)
        if not Settings.Enabled then
            CurrentTarget = nil
            TargetPart = nil
            for _, data in pairs(ESPObjects) do
                pcall(function() data[1]:Destroy() end)
            end
            ESPObjects = {}
        end
    end)
    
    -- Keybind Display
    local keyFrame = Instance.new("Frame")
    keyFrame.Size = UDim2.new(0.9, 0, 0, 45)
    keyFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    keyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    keyFrame.BackgroundTransparency = 0.5
    keyFrame.BorderSizePixel = 0
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 8)
    keyFrame.Parent = keyFrame
    
    local keyText = Instance.new("TextLabel")
    keyText.Size = UDim2.new(1, 0, 1, 0)
    keyText.Text = "🔘 TOGGLE KEY: " .. Settings.Keybind
    keyText.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyText.BackgroundTransparency = 1
    keyText.TextScaled = true
    keyText.Font = Enum.Font.Gotham
    keyText.Parent = keyFrame
    
    -- Distance Slider
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(0.9, 0, 0, 25)
    distLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
    distLabel.Text = "📏 MAX DISTANCE: " .. Settings.MaxDistance .. "m"
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.BackgroundTransparency = 1
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = content
    
    -- Status Display
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0.9, 0, 0, 60)
    statusFrame.Position = UDim2.new(0.05, 0, 0.45, 0)
    statusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    statusFrame.BackgroundTransparency = 0.3
    statusFrame.BorderSizePixel = 0
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusFrame.Parent = statusFrame
    
    local targetStatus = Instance.new("TextLabel")
    targetStatus.Size = UDim2.new(1, 0, 0.5, 0)
    targetStatus.Position = UDim2.new(0, 0, 0, 0)
    targetStatus.Text = "🎯 TARGET: None"
    targetStatus.TextColor3 = Color3.fromRGB(255, 200, 100)
    targetStatus.BackgroundTransparency = 1
    targetStatus.TextScaled = true
    targetStatus.Font = Enum.Font.Gotham
    targetStatus.Parent = statusFrame
    
    local lockStatus = Instance.new("TextLabel")
    lockStatus.Size = UDim2.new(1, 0, 0.5, 0)
    lockStatus.Position = UDim2.new(0, 0, 0.5, 0)
    lockStatus.Text = "🔒 STATUS: " .. (Settings.Enabled and "LOCKED" or "OFF")
    lockStatus.TextColor3 = Settings.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    lockStatus.BackgroundTransparency = 1
    lockStatus.TextScaled = true
    lockStatus.Font = Enum.Font.Gotham
    lockStatus.Parent = statusFrame
    
    -- Footer
    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, 0, 0, 30)
    footer.Position = UDim2.new(0, 0, 1, -30)
    footer.Text = "© milanlan0073-alt | Architect 03"
    footer.TextColor3 = Color3.fromRGB(100, 100, 100)
    footer.BackgroundTransparency = 1
    footer.TextScaled = true
    footer.Font = Enum.Font.Gotham
    footer.Parent = container
    
    -- Assemble
    header.Parent = container
    toggleBtn.Parent = content
    keyFrame.Parent = content
    distLabel.Parent = content
    statusFrame.Parent = content
    footer.Parent = container
    container.Parent = screenGui
    
    -- Store references
    UI.ToggleButton = toggleBtn
    UI.TargetStatus = targetStatus
    UI.LockStatus = lockStatus
    UI.DistLabel = distLabel
    UI.Container = container
    
    -- Update loop for UI
    spawn(function()
        while container and container.Parent do
            if UI.TargetStatus then
                if CurrentTarget and IsAlive(CurrentTarget) then
                    local dist = TargetPart and math.floor((TargetPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
                    UI.TargetStatus.Text = "🎯 TARGET: " .. (CurrentTarget.Name or "Unknown") .. " (" .. dist .. "m)"
                else
                    UI.TargetStatus.Text = "🎯 TARGET: None"
                end
                UI.LockStatus.Text = "🔒 STATUS: " .. (Settings.Enabled and "LOCKED" or "OFF")
                UI.LockStatus.TextColor3 = Settings.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
                UI.DistLabel.Text = "📏 MAX DISTANCE: " .. Settings.MaxDistance .. "m"
            end
            task.wait(0.3)
        end
    end)
    
    -- Draggable
    local dragging = false
    local dragStart, startPos
    
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = container.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ========== INITIALIZE ==========
spawn(function()
    wait(1)
    pcall(CreateUI)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚡ CENDOL HUB",
        Text = "Premium UI Loaded | Press " .. Settings.Keybind .. " to toggle",
        Duration = 3
    })
    print("=== CENDOL HUB PREMIUM LOADED ===")
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    UpdateLockOn()
    UpdateESP()
    if Settings.Enabled and TargetPart then
        SmoothLock()
    end
end)

-- Rainbow ESP Update
if Settings.RainbowESP then
    spawn(function()
        while true do
            task.wait(0.05)
            if Settings.RainbowESP then
                RainbowHue = (RainbowHue + 0.005) % 1
            end
        end
    end)
end
]])()
