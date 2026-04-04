-- CENDOL HUB V3 - GUI EDITION (by Architect 03)
-- Full GUI | Lock On | Camera Follow | Body Rotate | Side Dash 180°

loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========== SETTINGS ==========
local Settings = {
    Enabled = false,
    LockPlayer = true,
    LockNPC = true,
    CameraFollow = true,
    BodyRotate = true,
    MaxDistance = 200,
    SideDashEnabled = true,
}

local CurrentTarget = nil
local DashCooldown = false
local MainGui = nil

-- ========== UTILITIES ==========
local function IsAlive(c)
    if not c then return false end
    local h = c:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function GetClosestTarget()
    local closest = nil
    local closestDist = Settings.MaxDistance
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myPos = myChar:FindFirstChild("HumanoidRootPart")
    if not myPos then return nil end
    
    if Settings.LockPlayer then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local c = p.Character
                if c and IsAlive(c) then
                    local r = c:FindFirstChild("HumanoidRootPart")
                    if r then
                        local d = (r.Position - myPos.Position).Magnitude
                        if d < closestDist then
                            closestDist = d
                            closest = c
                        end
                    end
                end
            end
        end
    end
    
    if Settings.LockNPC then
        local NPCKeywords = {"Cursed", "Spirit", "Curse", "NPC", "Mob", "Enemy", "Boss", "Raid", "Demon", "Shadow", "Monster", "Training", "Dummy", "Zombie", "Skeleton"}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= myChar then
                local h = obj:FindFirstChild("Humanoid")
                local r = obj:FindFirstChild("HumanoidRootPart")
                if h and r and h.Health > 0 then
                    local isNPC = true
                    if Players:GetPlayerFromCharacter(obj) then isNPC = false end
                    if isNPC then
                        local d = (r.Position - myPos.Position).Magnitude
                        if d < closestDist then
                            closestDist = d
                            closest = obj
                        end
                    end
                end
            end
        end
    end
    
    return closest
end

-- ========== CAMERA FOLLOW ==========
local function UpdateCameraFollow()
    if not Settings.CameraFollow then return end
    if not Settings.Enabled or not CurrentTarget then return end
    
    local targetPart = CurrentTarget:FindFirstChild("Head") or CurrentTarget:FindFirstChild("HumanoidRootPart")
    if not targetPart then return end
    
    local targetPos = targetPart.Position + Vector3.new(0, 2, 0)
    local currentCFrame = Camera.CFrame
    local desiredCFrame = CFrame.new(currentCFrame.Position, targetPos)
    Camera.CFrame = currentCFrame:Lerp(desiredCFrame, 0.25)
end

-- ========== BODY ROTATE ==========
local function RotateToTarget()
    if not Settings.BodyRotate then return end
    if not Settings.Enabled or not CurrentTarget then return end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = CurrentTarget:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return end
    
    local direction = (targetRoot.Position - myRoot.Position).Unit
    myChar:SetPrimaryPartCFrame(CFrame.new(myRoot.Position, myRoot.Position + direction))
end

-- ========== SIDE DASH 180° ==========
local function PerformSideDash()
    if not Settings.SideDashEnabled or DashCooldown then return end
    if not Settings.Enabled or not CurrentTarget then return end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = CurrentTarget:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return end
    
    DashCooldown = true
    
    local toTarget = (targetRoot.Position - myRoot.Position).Unit
    local dashPosition = myRoot.Position + (-toTarget * 15)
    
    local tween = TweenService:Create(myRoot, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
        CFrame = CFrame.new(dashPosition, myRoot.Position + toTarget)
    })
    tween:Play()
    
    tween.Completed:Connect(function()
        task.wait(0.3)
        DashCooldown = false
    end)
end

-- ========== CREATE MAIN GUI ==========
local function CreateGUI()
    for i = 1, 20 do
        if LocalPlayer:FindFirstChild("PlayerGui") then break end
        task.wait(0.5)
    end
    
    local playerGui = LocalPlayer.PlayerGui
    
    -- ScreenGui utama
    MainGui = Instance.new("ScreenGui")
    MainGui.Name = "CendolHubGUI"
    MainGui.Parent = playerGui
    MainGui.ResetOnSpawn = false
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 380)
    mainFrame.Position = UDim2.new(0, 15, 0, 100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = MainGui
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 12)
    frameCorner.Parent = mainFrame
    
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(255, 80, 120)
    frameStroke.Thickness = 1.5
    frameStroke.Transparency = 0.5
    frameStroke.Parent = mainFrame
    
    -- Title Bar (buat drag)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 80, 120)
    titleBar.BackgroundTransparency = 0.3
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.Text = "⚡ CENDOL HUB V3"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.BackgroundTransparency = 1
    titleText.TextScaled = true
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.Parent = titleBar
    
    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -40, 0, 5)
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    minBtn.BackgroundTransparency = 0.5
    minBtn.TextScaled = true
    minBtn.Font = Enum.Font.GothamBold
    minBtn.BorderSizePixel = 0
    minBtn.Parent = titleBar
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(1, 0)
    minCorner.Parent = minBtn
    
    -- Content Frame
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -60)
    content.Position = UDim2.new(0, 10, 0, 50)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Lock Toggle (besar)
    local lockToggle = Instance.new("TextButton")
    lockToggle.Size = UDim2.new(1, 0, 0, 50)
    lockToggle.Position = UDim2.new(0, 0, 0, 0)
    lockToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    lockToggle.Text = "🔒 LOCK OFF"
    lockToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    lockToggle.TextScaled = true
    lockToggle.Font = Enum.Font.GothamBold
    lockToggle.BorderSizePixel = 0
    lockToggle.Parent = content
    
    local lockCorner = Instance.new("UICorner")
    lockCorner.CornerRadius = UDim.new(0, 8)
    lockCorner.Parent = lockToggle
    
    lockToggle.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        if Settings.Enabled then
            lockToggle.Text = "🔒 LOCK ON"
            lockToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            CurrentTarget = GetClosestTarget()
        else
            lockToggle.Text = "🔒 LOCK OFF"
            lockToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            CurrentTarget = nil
        end
    end)
    
    -- Camera Follow Toggle
    local camToggle = Instance.new("TextButton")
    camToggle.Size = UDim2.new(1, 0, 0, 40)
    camToggle.Position = UDim2.new(0, 0, 0, 60)
    camToggle.BackgroundColor3 = Settings.CameraFollow and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 100)
    camToggle.Text = Settings.CameraFollow and "📷 CAMERA: ON" or "📷 CAMERA: OFF"
    camToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    camToggle.TextScaled = true
    camToggle.Font = Enum.Font.GothamBold
    camToggle.BorderSizePixel = 0
    camToggle.Parent = content
    
    local camCorner = Instance.new("UICorner")
    camCorner.CornerRadius = UDim.new(0, 8)
    camCorner.Parent = camToggle
    
    camToggle.MouseButton1Click:Connect(function()
        Settings.CameraFollow = not Settings.CameraFollow
        camToggle.Text = Settings.CameraFollow and "📷 CAMERA: ON" or "📷 CAMERA: OFF"
        camToggle.BackgroundColor3 = Settings.CameraFollow and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 100)
    end)
    
    -- Body Rotate Toggle
    local bodyToggle = Instance.new("TextButton")
    bodyToggle.Size = UDim2.new(1, 0, 0, 40)
    bodyToggle.Position = UDim2.new(0, 0, 0, 110)
    bodyToggle.BackgroundColor3 = Settings.BodyRotate and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 100)
    bodyToggle.Text = Settings.BodyRotate and "🔄 BODY ROTATE: ON" or "🔄 BODY ROTATE: OFF"
    bodyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    bodyToggle.TextScaled = true
    bodyToggle.Font = Enum.Font.GothamBold
    bodyToggle.BorderSizePixel = 0
    bodyToggle.Parent = content
    
    local bodyCorner = Instance.new("UICorner")
    bodyCorner.CornerRadius = UDim.new(0, 8)
    bodyCorner.Parent = bodyToggle
    
    bodyToggle.MouseButton1Click:Connect(function()
        Settings.BodyRotate = not Settings.BodyRotate
        bodyToggle.Text = Settings.BodyRotate and "🔄 BODY ROTATE: ON" or "🔄 BODY ROTATE: OFF"
        bodyToggle.BackgroundColor3 = Settings.BodyRotate and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 100)
    end)
    
    -- Side Dash Toggle
    local dashToggle = Instance.new("TextButton")
    dashToggle.Size = UDim2.new(1, 0, 0, 40)
    dashToggle.Position = UDim2.new(0, 0, 0, 160)
    dashToggle.BackgroundColor3 = Settings.SideDashEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 100)
    dashToggle.Text = Settings.SideDashEnabled and "💨 SIDE DASH: ON" or "💨 SIDE DASH: OFF"
    dashToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    dashToggle.TextScaled = true
    dashToggle.Font = Enum.Font.GothamBold
    dashToggle.BorderSizePixel = 0
    dashToggle.Parent = content
    
    local dashCorner = Instance.new("UICorner")
    dashCorner.CornerRadius = UDim.new(0, 8)
    dashCorner.Parent = dashToggle
    
    dashToggle.MouseButton1Click:Connect(function()
        Settings.SideDashEnabled = not Settings.SideDashEnabled
        dashToggle.Text = Settings.SideDashEnabled and "💨 SIDE DASH: ON" or "💨 SIDE DASH: OFF"
        dashToggle.BackgroundColor3 = Settings.SideDashEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 100)
    end)
    
    -- Player/NPC Row
    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(1, 0, 0, 45)
    rowFrame.Position = UDim2.new(0, 0, 0, 210)
    rowFrame.BackgroundTransparency = 1
    rowFrame.Parent = content
    
    local playerToggle = Instance.new("TextButton")
    playerToggle.Size = UDim2.new(0.48, 0, 1, 0)
    playerToggle.Position = UDim2.new(0, 0, 0, 0)
    playerToggle.BackgroundColor3 = Settings.LockPlayer and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 100)
    playerToggle.Text = "👤 PLAYER"
    playerToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerToggle.TextScaled = true
    playerToggle.Font = Enum.Font.GothamBold
    playerToggle.BorderSizePixel = 0
    playerToggle.Parent = rowFrame
    
    local playerCorner = Instance.new("UICorner")
    playerCorner.CornerRadius = UDim.new(0, 8)
    playerCorner.Parent = playerToggle
    
    playerToggle.MouseButton1Click:Connect(function()
        Settings.LockPlayer = not Settings.LockPlayer
        playerToggle.BackgroundColor3 = Settings.LockPlayer and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 100)
        if Settings.Enabled then CurrentTarget = GetClosestTarget() end
    end)
    
    local npcToggle = Instance.new("TextButton")
    npcToggle.Size = UDim2.new(0.48, 0, 1, 0)
    npcToggle.Position = UDim2.new(0.52, 0, 0, 0)
    npcToggle.BackgroundColor3 = Settings.LockNPC and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 100)
    npcToggle.Text = "👹 NPC"
    npcToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    npcToggle.TextScaled = true
    npcToggle.Font = Enum.Font.GothamBold
    npcToggle.BorderSizePixel = 0
    npcToggle.Parent = rowFrame
    
    local npcCorner = Instance.new("UICorner")
    npcCorner.CornerRadius = UDim.new(0, 8)
    npcCorner.Parent = npcToggle
    
    npcToggle.MouseButton1Click:Connect(function()
        Settings.LockNPC = not Settings.LockNPC
        npcToggle.BackgroundColor3 = Settings.LockNPC and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 100)
        if Settings.Enabled then CurrentTarget = GetClosestTarget() end
    end)
    
    -- Range Slider
    local rangeLabel = Instance.new("TextLabel")
    rangeLabel.Size = UDim2.new(1, 0, 0, 25)
    rangeLabel.Position = UDim2.new(0, 0, 0, 265)
    rangeLabel.Text = "🎯 MAX DISTANCE: " .. Settings.MaxDistance
    rangeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    rangeLabel.BackgroundTransparency = 1
    rangeLabel.TextScaled = true
    rangeLabel.Font = Enum.Font.Gotham
    rangeLabel.Parent = content
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 4)
    slider.Position = UDim2.new(0, 0, 0, 293)
    slider.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    slider.BorderSizePixel = 0
    slider.Parent = content
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = slider
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(Settings.MaxDistance / 300, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 80, 120)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 15, 0, 15)
    sliderButton.Position = UDim2.new(Settings.MaxDistance / 300, -7.5, 0.5, -7.5)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = slider
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = sliderButton
    
    local dragging = false
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
        while dragging and sliderButton and sliderButton.Parent do
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = slider.AbsolutePosition.X
            local sliderWidth = slider.AbsoluteSize.X
            local percent = math.clamp((mousePos.X - sliderPos) / sliderWidth, 0, 1)
            local newDist = math.floor(percent * 300)
            if newDist >= 10 then
                Settings.MaxDistance = newDist
                rangeLabel.Text = "🎯 MAX DISTANCE: " .. Settings.MaxDistance
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                sliderButton.Position = UDim2.new(percent, -7.5, 0.5, -7.5)
            end
            task.wait()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Minimize functionality
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        mainFrame.Visible = not minimized
        if minimized then
            minBtn.Text = "+"
        else
            minBtn.Text = "−"
        end
    end)
    
    -- Drag functionality
    local dragStart, startPos, draggingFrame = nil
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingFrame = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingFrame and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingFrame = false
        end
    end)
end

-- ========== DASH DETECTION ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode
        if key == Enum.KeyCode.F or key == Enum.KeyCode.Q or key == Enum.KeyCode.LeftShift then
            if Settings.Enabled and CurrentTarget then
                task.spawn(PerformSideDash)
            end
        end
    end
end)

-- ========== MAIN LOOP ==========
RunService.RenderStepped:Connect(function()
    if Settings.Enabled then
        if not CurrentTarget or not IsAlive(CurrentTarget) then
            CurrentTarget = GetClosestTarget()
        end
        
        if CurrentTarget and IsAlive(CurrentTarget) then
            UpdateCameraFollow()
            RotateToTarget()
        end
    end
end)

-- ========== INIT ==========
spawn(function()
    task.wait(1)
    CreateGUI()
    print("=== CENDOL HUB V3 GUI LOADED ===")
    print("=== Drag title bar buat mindahin GUI ===")
    print("=== Tekan F/Q/Shift buat side dash ===")
end)
]])()
