-- CENDOL HUB - FULL CONTROL GUI
-- ESP | Auto Lock | Distance Slider | Android
-- By: milanlan0073-alt

loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========== SETTINGS ==========
local Settings = {
    AutoLock = true,      -- Auto lock ON/OFF
    ShowESP = true,       -- ESP ON/OFF
    MaxDistance = 150,
    Smoothness = 0.4
}

local CurrentTarget = nil
local TargetPart = nil
local ESPObjects = {}
local MenuOpen = true

-- HITBOXES
local Hitboxes = {"Head", "UpperTorso", "HumanoidRootPart", "Torso"}

-- UTILITIES
local function IsAlive(c)
    if not c then return false end
    local h = c:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function GetDistance(a, b)
    return (a.Position - b.Position).Magnitude
end

-- GET TARGET TERDEKAT
local function GetClosestTarget()
    local closest = nil
    local closestDist = Settings.MaxDistance
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myPos = myChar:FindFirstChild("HumanoidRootPart")
    if not myPos then return nil end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local c = p.Character
            if c and IsAlive(c) then
                local r = c:FindFirstChild("HumanoidRootPart")
                if r then
                    local d = GetDistance(r, myPos)
                    if d < closestDist then
                        closestDist = d
                        closest = c
                    end
                end
            end
        end
    end
    return closest
end

-- DAPATIN HITBOX TERBAIK
local function GetBestHitbox(char)
    for _, h in ipairs(Hitboxes) do
        local part = char:FindFirstChild(h)
        if part and part:IsA("BasePart") then return part end
    end
    return char:FindFirstChild("HumanoidRootPart")
end

-- ========== ESP ==========
local function CreateESP(target)
    if not Settings.ShowESP then return end
    if ESPObjects[target] then 
        pcall(function() ESPObjects[target]:Destroy() end) 
    end
    
    local root = target:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CendolESP"
    billboard.Size = UDim2.new(0, 90, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = root
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    frame.BackgroundTransparency = 0.5
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.6, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = target.Name or "?"
    
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 0.25, 0)
    healthBar.Position = UDim2.new(0, 0, 0.7, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BackgroundTransparency = 0.3
    
    label.Parent = frame
    healthBar.Parent = frame
    frame.Parent = billboard
    billboard.Parent = root
    ESPObjects[target] = billboard
    
    -- Update health bar
    local function updateHealth()
        while billboard and billboard.Parent and IsAlive(target) do
            local hpPercent = target.Humanoid.Health / target.Humanoid.MaxHealth
            healthBar.Size = UDim2.new(hpPercent, 0, 0.25, 0)
            healthBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
            task.wait(0.2)
        end
    end
    spawn(updateHealth)
end

local function ClearESP()
    for _, esp in pairs(ESPObjects) do
        pcall(function() esp:Destroy() end)
    end
    ESPObjects = {}
end

-- ========== GUI ==========
local function CreateGUI()
    -- Tunggu PlayerGui
    for i = 1, 10 do
        if LocalPlayer:FindFirstChild("PlayerGui") then
            break
        end
        wait(0.5)
    end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "CendolHub"
    sg.Parent = LocalPlayer.PlayerGui
    sg.ResetOnSpawn = false
    
    -- MAIN FRAME
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 240, 0, 260)
    frame.Position = UDim2.new(0, 10, 0, 80)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    -- TITLE (bisa drag)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    titleBar.BackgroundTransparency = 0.3
    titleBar.BorderSizePixel = 0
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.Text = "⚡ CENDOL HUB"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = titleBar
    
    -- CONTENT
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -40)
    content.Position = UDim2.new(0, 0, 0, 40)
    content.BackgroundTransparency = 1
    
    -- AUTO LOCK TOGGLE
    local lockBtn = Instance.new("TextButton")
    lockBtn.Size = UDim2.new(0.9, 0, 0, 45)
    lockBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
    lockBtn.BackgroundColor3 = Settings.AutoLock and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 50, 50)
    lockBtn.Text = Settings.AutoLock and "🔒 AUTO LOCK: ON" or "🔓 AUTO LOCK: OFF"
    lockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    lockBtn.TextScaled = true
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.BorderSizePixel = 0
    
    local lockCorner = Instance.new("UICorner")
    lockCorner.CornerRadius = UDim.new(0, 8)
    lockCorner.Parent = lockBtn
    
    lockBtn.MouseButton1Click:Connect(function()
        Settings.AutoLock = not Settings.AutoLock
        lockBtn.Text = Settings.AutoLock and "🔒 AUTO LOCK: ON" or "🔓 AUTO LOCK: OFF"
        lockBtn.BackgroundColor3 = Settings.AutoLock and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 50, 50)
        if not Settings.AutoLock then
            CurrentTarget = nil
            TargetPart = nil
        end
    end)
    
    -- ESP TOGGLE
    local espBtn = Instance.new("TextButton")
    espBtn.Size = UDim2.new(0.9, 0, 0, 45)
    espBtn.Position = UDim2.new(0.05, 0, 0.22, 0)
    espBtn.BackgroundColor3 = Settings.ShowESP and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 50, 50)
    espBtn.Text = Settings.ShowESP and "👁️ ESP: ON" or "👁️ ESP: OFF"
    espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    espBtn.TextScaled = true
    espBtn.Font = Enum.Font.GothamBold
    espBtn.BorderSizePixel = 0
    
    local espCorner = Instance.new("UICorner")
    espCorner.CornerRadius = UDim.new(0, 8)
    espCorner.Parent = espBtn
    
    espBtn.MouseButton1Click:Connect(function()
        Settings.ShowESP = not Settings.ShowESP
        espBtn.Text = Settings.ShowESP and "👁️ ESP: ON" or "👁️ ESP: OFF"
        espBtn.BackgroundColor3 = Settings.ShowESP and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 50, 50)
        if not Settings.ShowESP then
            ClearESP()
        end
    end)
    
    -- DISTANCE SLIDER
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(0.9, 0, 0, 25)
    distLabel.Position = UDim2.new(0.05, 0, 0.39, 0)
    distLabel.Text = "📏 DISTANCE: " .. Settings.MaxDistance .. "m"
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.BackgroundTransparency = 1
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = content
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.9, 0, 0, 8)
    sliderBg.Position = UDim2.new(0.05, 0, 0.48, 0)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBg.BorderSizePixel = 0
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(Settings.MaxDistance / 300, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    sliderFill.BorderSizePixel = 0
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(0, 20, 0, 20)
    sliderBtn.Position = UDim2.new(Settings.MaxDistance / 300, -0.04, -0.75, 0)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderBtn.Text = ""
    sliderBtn.BorderSizePixel = 0
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBtn
    
    sliderFill.Parent = sliderBg
    sliderBtn.Parent = sliderBg
    sliderBg.Parent = content
    
    -- DRAG SLIDER
    local dragging = false
    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = input.Position.X
            local framePos = sliderBg.AbsolutePosition.X
            local newPercent = math.clamp((pos - framePos) / sliderBg.AbsoluteSize.X, 0, 1)
            local newDist = math.floor(newPercent * 300)
            newDist = math.clamp(newDist, 50, 300)
            Settings.MaxDistance = newDist
            sliderFill.Size = UDim2.new(newDist / 300, 0, 1, 0)
            sliderBtn.Position = UDim2.new(newDist / 300, -0.04, -0.75, 0)
            distLabel.Text = "📏 DISTANCE: " .. newDist .. "m"
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- SMOOTHNESS SLIDER
    local smoothLabel = Instance.new("TextLabel")
    smoothLabel.Size = UDim2.new(0.9, 0, 0, 25)
    smoothLabel.Position = UDim2.new(0.05, 0, 0.57, 0)
    smoothLabel.Text = "🎯 SMOOTHNESS: " .. string.format("%.2f", Settings.Smoothness)
    smoothLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    smoothLabel.BackgroundTransparency = 1
    smoothLabel.TextScaled = true
    smoothLabel.Font = Enum.Font.Gotham
    smoothLabel.Parent = content
    
    local smoothBg = Instance.new("Frame")
    smoothBg.Size = UDim2.new(0.9, 0, 0, 8)
    smoothBg.Position = UDim2.new(0.05, 0, 0.66, 0)
    smoothBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    smoothBg.BorderSizePixel = 0
    
    local smoothFill = Instance.new("Frame")
    smoothFill.Size = UDim2.new((1 - Settings.Smoothness) / 0.9, 0, 1, 0)
    smoothFill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    smoothFill.BorderSizePixel = 0
    
    local smoothBtn = Instance.new("TextButton")
    smoothBtn.Size = UDim2.new(0, 20, 0, 20)
    smoothBtn.Position = UDim2.new((1 - Settings.Smoothness) / 0.9, -0.04, -0.75, 0)
    smoothBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    smoothBtn.Text = ""
    smoothBtn.BorderSizePixel = 0
    
    local smoothBtnCorner = Instance.new("UICorner")
    smoothBtnCorner.CornerRadius = UDim.new(1, 0)
    smoothBtnCorner.Parent = smoothBtn
    
    smoothFill.Parent = smoothBg
    smoothBtn.Parent = smoothBg
    smoothBg.Parent = content
    
    local draggingSmooth = false
    smoothBtn.MouseButton1Down:Connect(function()
        draggingSmooth = true
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingSmooth and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = input.Position.X
            local framePos = smoothBg.AbsolutePosition.X
            local newPercent = math.clamp((pos - framePos) / smoothBg.AbsoluteSize.X, 0, 1)
            local newSmooth = 1 - (newPercent * 0.9)
            newSmooth = math.clamp(newSmooth, 0.1, 0.9)
            Settings.Smoothness = newSmooth
            smoothFill.Size = UDim2.new(newPercent, 0, 1, 0)
            smoothBtn.Position = UDim2.new(newPercent, -0.04, -0.75, 0)
            smoothLabel.Text = "🎯 SMOOTHNESS: " .. string.format("%.2f", newSmooth)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSmooth = false
        end
    end)
    
    -- STATUS
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
    statusLabel.Position = UDim2.new(0.05, 0, 0.76, 0)
    statusLabel.Text = "🎯 TARGET: None"
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = content
    
    -- FOOTER
    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, 0, 0, 25)
    footer.Position = UDim2.new(0, 0, 1, -25)
    footer.Text = "© milanlan0073-alt"
    footer.TextColor3 = Color3.fromRGB(100, 100, 100)
    footer.BackgroundTransparency = 1
    footer.TextScaled = true
    footer.Font = Enum.Font.Gotham
    footer.Parent = frame
    
    -- ASSEMBLE
    titleBar.Parent = frame
    content.Parent = frame
    lockBtn.Parent = content
    espBtn.Parent = content
    frame.Parent = sg
    
    -- DRAG FRAME
    local dragFrame = false
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragFrame = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragFrame and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragFrame = false
        end
    end)
    
    -- UPDATE STATUS LOOP
    spawn(function()
        while frame and frame.Parent do
            if CurrentTarget and IsAlive(CurrentTarget) then
                local dist = TargetPart and math.floor((TargetPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
                statusLabel.Text = "🎯 " .. (CurrentTarget.Name or "?") .. " (" .. dist .. "m)"
            else
                statusLabel.Text = "🎯 TARGET: None"
            end
            task.wait(0.3)
        end
    end)
end

-- ========== MAIN LOOP ==========
RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character then return end
    
    -- Auto Lock
    if Settings.AutoLock then
        local newTarget = GetClosestTarget()
        if newTarget and newTarget ~= CurrentTarget then
            CurrentTarget = newTarget
            TargetPart = GetBestHitbox(CurrentTarget)
        end
        
        if CurrentTarget and not IsAlive(CurrentTarget) then
            CurrentTarget = nil
            TargetPart = nil
        end
        
        -- Lock camera
        if CurrentTarget and TargetPart and TargetPart.Parent then
            local targetPos = TargetPart.Position
            local currentPos = Camera.CFrame.Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(currentPos, targetPos), Settings.Smoothness)
        end
    end
    
    -- ESP
    if Settings.ShowESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and IsAlive(p.Character) then
                if not ESPObjects[p.Character] then
                    CreateESP(p.Character)
                end
            end
        end
        -- Bersihkan ESP yang mati
        for char, esp in pairs(ESPObjects) do
            if not char or not char.Parent or not IsAlive(char) then
                pcall(function() esp:Destroy() end)
                ESPObjects[char] = nil
            end
        end
    else
        ClearESP()
    end
end)

-- INIT
spawn(function()
    wait(1)
    pcall(CreateGUI)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚡ CENDOL HUB",
        Text = "Loaded! Use GUI to toggle ESP & Auto Lock",
        Duration = 3
    })
    print("=== CENDOL HUB LOADED ===")
end)
]])()
