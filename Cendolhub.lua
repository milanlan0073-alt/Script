-- CENDOL HUB V2 - ENHANCED CAMERA & UI
-- Camera Follow | Crosshair | Body Rotate
-- By: milanlan0073-alt

loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========== SETTINGS ==========
local Settings = {
    Enabled = true,
    LockPlayer = true,
    LockNPC = true,
    CameraFollow = true,
    CameraSmoothness = 0.25,
    BodyRotate = true,
    MaxDistance = 200,
    CameraOffset = Vector3.new(0, 2, 0),
    UIMinimized = false
}

local CurrentTarget = nil
local TargetPart = nil
local Crosshair = nil
local UI = {}

-- HITBOXES (prioritas)
local Hitboxes = {"Head", "UpperTorso", "HumanoidRootPart", "Torso"}

-- NPC DETECTION
local NPCKeywords = {
    "Cursed", "Spirit", "Curse", "NPC", "Mob", "Enemy", "Boss",
    "Raid", "Demon", "Shadow", "Monster", "Training", "Dummy",
    "Zombie", "Skeleton", "Goblin", "Orc", "Troll", "Dragon"
}

-- UTILITIES
local function IsAlive(c)
    if not c then return false end
    local h = c:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function IsNPC(character)
    if Players:GetPlayerFromCharacter(character) then return false end
    local name = character.Name:lower()
    for _, keyword in ipairs(NPCKeywords) do
        if name:find(keyword:lower()) then return true end
    end
    return character:FindFirstChild("Humanoid") ~= nil
end

local function GetDistance(a, b)
    return (a.Position - b.Position).Magnitude
end

-- GET TARGET TERDEKAT (OPTIMIZED)
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
                        local d = GetDistance(r, myPos)
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
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= myChar and IsNPC(obj) then
                local h = obj:FindFirstChild("Humanoid")
                local r = obj:FindFirstChild("HumanoidRootPart")
                if h and r and h.Health > 0 then
                    local d = GetDistance(r, myPos)
                    if d < closestDist then
                        closestDist = d
                        closest = obj
                    end
                end
            end
        end
    end
    
    return closest
end

local function GetBestHitbox(char)
    local head = char:FindFirstChild("Head")
    if head and head:IsA("BasePart") then return head end
    for _, h in ipairs(Hitboxes) do
        local part = char:FindFirstChild(h)
        if part and part:IsA("BasePart") then return part end
    end
    return char:FindFirstChild("HumanoidRootPart")
end

-- BODY ROTATION
local function RotateToTarget()
    if not Settings.BodyRotate then return end
    if not CurrentTarget or not IsAlive(CurrentTarget) then return end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = CurrentTarget:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return end
    
    local direction = (targetRoot.Position - myRoot.Position).Unit
    local lookAt = CFrame.new(myRoot.Position, myRoot.Position + direction)
    myChar:SetPrimaryPartCFrame(lookAt)
end

-- ========== ENHANCED CAMERA FOLLOW ==========
local function UpdateCameraFollow()
    if not Settings.CameraFollow then return end
    if not CurrentTarget or not IsAlive(CurrentTarget) then return end
    if not TargetPart or not TargetPart.Parent then return end
    
    local targetPos = TargetPart.Position + Settings.CameraOffset
    local currentCFrame = Camera.CFrame
    local desiredCFrame = CFrame.new(currentCFrame.Position, targetPos)
    
    -- Smooth interpolation
    local newCFrame = currentCFrame:Lerp(desiredCFrame, Settings.CameraSmoothness)
    Camera.CFrame = newCFrame
end

-- ========== CROSSHAIR ENHANCED ==========
local function CreateCrosshair()
    for i = 1, 10 do
        if LocalPlayer:FindFirstChild("PlayerGui") then break end
        wait(0.5)
    end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "CendolCrosshair"
    sg.Parent = LocalPlayer.PlayerGui
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Outer circle
    local outer = Instance.new("Frame")
    outer.Size = UDim2.new(0, 44, 0, 44)
    outer.Position = UDim2.new(0.5, -22, 0.5, -22)
    outer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    outer.BackgroundTransparency = 0.85
    outer.BorderSizePixel = 0
    outer.ZIndex = 10
    
    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(1, 0)
    outerCorner.Parent = outer
    
    -- Inner circle
    local inner = Instance.new("Frame")
    inner.Size = UDim2.new(0, 24, 0, 24)
    inner.Position = UDim2.new(0.5, -12, 0.5, -12)
    inner.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    inner.BackgroundTransparency = 0.4
    inner.BorderSizePixel = 0
    inner.ZIndex = 11
    
    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(1, 0)
    innerCorner.Parent = inner
    
    -- Center dot
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0.5, -3, 0.5, -3)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.ZIndex = 12
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    
    -- Target info panel
    local targetPanel = Instance.new("Frame")
    targetPanel.Size = UDim2.new(0, 280, 0, 60)
    targetPanel.Position = UDim2.new(0.5, -140, 0.5, 80)
    targetPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    targetPanel.BackgroundTransparency = 0.6
    targetPanel.BorderSizePixel = 0
    targetPanel.ZIndex = 10
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 12)
    panelCorner.Parent = targetPanel
    
    local targetName = Instance.new("TextLabel")
    targetName.Size = UDim2.new(1, 0, 0.5, 0)
    targetName.Position = UDim2.new(0, 0, 0, 0)
    targetName.BackgroundTransparency = 1
    targetName.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetName.TextScaled = true
    targetName.Font = Enum.Font.GothamBold
    targetName.Text = ""
    targetName.ZIndex = 11
    targetName.Parent = targetPanel
    
    local targetDist = Instance.new("TextLabel")
    targetDist.Size = UDim2.new(1, 0, 0.5, 0)
    targetDist.Position = UDim2.new(0, 0, 0.5, 0)
    targetDist.BackgroundTransparency = 1
    targetDist.TextColor3 = Color3.fromRGB(200, 200, 200)
    targetDist.TextScaled = true
    targetDist.Font = Enum.Font.Gotham
    targetDist.Text = ""
    targetDist.ZIndex = 11
    targetDist.Parent = targetPanel
    
    inner.Parent = outer
    dot.Parent = inner
    outer.Parent = sg
    targetPanel.Parent = sg
    
    return {outer, inner, targetName, targetDist, targetPanel}
end

local function UpdateCrosshair()
    if not Crosshair then return end
    local outer, inner, targetName, targetDist, targetPanel = unpack(Crosshair)
    
    if CurrentTarget and IsAlive(CurrentTarget) then
        inner.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        inner.BackgroundTransparency = 0.2
        outer.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        outer.BackgroundTransparency = 0.7
        
        local targetType = IsNPC(CurrentTarget) and "👹 NPC" or "👤 PLAYER"
        local dist = TargetPart and math.floor((TargetPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
        local health = CurrentTarget:FindFirstChild("Humanoid") and math.floor(CurrentTarget.Humanoid.Health) or 0
        
        targetName.Text = targetType .. " | " .. (CurrentTarget.Name or "Target")
        targetDist.Text = "📏 " .. dist .. "m | ❤️ " .. health .. " HP"
        targetPanel.Visible = true
    else
        inner.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        inner.BackgroundTransparency = 0.6
        outer.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        outer.BackgroundTransparency = 0.85
        targetPanel.Visible = false
    end
end

-- ========== ENHANCED UI (LEBAR & RAPIH) ==========
local function CreateUI()
    for i = 1, 10 do
        if LocalPlayer:FindFirstChild("PlayerGui") then break end
        wait(0.5)
    end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "CendolHub"
    sg.Parent = LocalPlayer.PlayerGui
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- MAIN PANEL (LEBAR)
    local mainPanel = Instance.new("Frame")
    mainPanel.Size = UDim2.new(0, 300, 0, 280)
    mainPanel.Position = UDim2.new(0, 15, 0, 80)
    mainPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainPanel.BackgroundTransparency = 0.3
    mainPanel.BorderSizePixel = 0
    mainPanel.Visible = not Settings.UIMinimized
    mainPanel.ZIndex = 5
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 16)
    panelCorner.Parent = mainPanel
    
    -- GLOW EFFECT
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(255, 80, 80)
    uiStroke.Thickness = 1
    uiStroke.Transparency = 0.7
    uiStroke.Parent = mainPanel
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    titleBar.BackgroundTransparency = 0.5
    titleBar.BorderSizePixel = 0
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 16)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "⚡ CENDOL HUB V2"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.TextScaled = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.Parent = titleBar
    
    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -50)
    content.Position = UDim2.new(0, 10, 0, 45)
    content.BackgroundTransparency = 1
    
    -- Lock ON/OFF (Big Button)
    local lockBtn = Instance.new("TextButton")
    lockBtn.Size = UDim2.new(1, 0, 0, 45)
    lockBtn.Position = UDim2.new(0, 0, 0, 0)
    lockBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 50, 50)
    lockBtn.Text = Settings.Enabled and "🔒 LOCK ACTIVE" or "🔓 LOCK OFF"
    lockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    lockBtn.TextScaled = true
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = lockBtn
    
    lockBtn.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        lockBtn.Text = Settings.Enabled and "🔒 LOCK ACTIVE" or "🔓 LOCK OFF"
        lockBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 50, 50)
        if not Settings.Enabled then
            CurrentTarget = nil
            TargetPart = nil
        else
            CurrentTarget = nil
        end
        UpdateCrosshair()
    end)
    
    -- Toggle Row (Player & NPC)
    local toggleRow = Instance.new("Frame")
    toggleRow.Size = UDim2.new(1, 0, 0, 40)
    toggleRow.Position = UDim2.new(0, 0, 0, 55)
    toggleRow.BackgroundTransparency = 1
    
    -- Lock Player Toggle
    local playerBtn = Instance.new("TextButton")
    playerBtn.Size = UDim2.new(0.48, 0, 1, 0)
    playerBtn.Position = UDim2.new(0, 0, 0, 0)
    playerBtn.BackgroundColor3 = Settings.LockPlayer and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    playerBtn.Text = "👤 PLAYER"
    playerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerBtn.TextScaled = true
    playerBtn.Font = Enum.Font.GothamBold
    playerBtn.BorderSizePixel = 0
    
    local playerCorner = Instance.new("UICorner")
    playerCorner.CornerRadius = UDim.new(0, 8)
    playerCorner.Parent = playerBtn
    
    playerBtn.MouseButton1Click:Connect(function()
        Settings.LockPlayer = not Settings.LockPlayer
        playerBtn.BackgroundColor3 = Settings.LockPlayer and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
        if Settings.Enabled then CurrentTarget = nil end
    end)
    
    -- Lock NPC Toggle
    local npcBtn = Instance.new("TextButton")
    npcBtn.Size = UDim2.new(0.48, 0, 1, 0)
    npcBtn.Position = UDim2.new(0.52, 0, 0, 0)
    npcBtn.BackgroundColor3 = Settings.LockNPC and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    npcBtn.Text = "👹 NPC"
    npcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    npcBtn.TextScaled = true
    npcBtn.Font = Enum.Font.GothamBold
    npcBtn.BorderSizePixel = 0
    
    local npcCorner = Instance.new("UICorner")
    npcCorner.CornerRadius = UDim.new(0, 8)
    npcCorner.Parent = npcBtn
    
    npcBtn.MouseButton1Click:Connect(function()
        Settings.LockNPC = not Settings.LockNPC
        npcBtn.BackgroundColor3 = Settings.LockNPC and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
        if Settings.Enabled then CurrentTarget = nil end
    end)
    
    playerBtn.Parent = toggleRow
    npcBtn.Parent = toggleRow
    
    -- Body Rotate Toggle
    local rotateBtn = Instance.new("TextButton")
    rotateBtn.Size = UDim2.new(1, 0, 0, 40)
    rotateBtn.Position = UDim2.new(0, 0, 0, 105)
    rotateBtn.BackgroundColor3 = Settings.BodyRotate and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    rotateBtn.Text = Settings.BodyRotate and "🔄 BODY ROTATE: ON" or "🔄 BODY ROTATE: OFF"
    rotateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rotateBtn.TextScaled = true
    rotateBtn.Font = Enum.Font.GothamBold
    rotateBtn.BorderSizePixel = 0
    
    local rotateCorner = Instance.new("UICorner")
    rotateCorner.CornerRadius = UDim.new(0, 10)
    rotateCorner.Parent = rotateBtn
    
    rotateBtn.MouseButton1Click:Connect(function()
        Settings.BodyRotate = not Settings.BodyRotate
        rotateBtn.Text = Settings.BodyRotate and "🔄 BODY ROTATE: ON" or "🔄 BODY ROTATE: OFF"
        rotateBtn.BackgroundColor3 = Settings.BodyRotate and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    end)
    
    -- Camera Follow Toggle
    local cameraBtn = Instance.new("TextButton")
    cameraBtn.Size = UDim2.new(1, 0, 0, 40)
    cameraBtn.Position = UDim2.new(0, 0, 0, 155)
    cameraBtn.BackgroundColor3 = Settings.CameraFollow and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    cameraBtn.Text = Settings.CameraFollow and "📷 CAMERA FOLLOW: ON" or "📷 CAMERA FOLLOW: OFF"
    cameraBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cameraBtn.TextScaled = true
    cameraBtn.Font = Enum.Font.GothamBold
    cameraBtn.BorderSizePixel = 0
    
    local cameraCorner = Instance.new("UICorner")
    cameraCorner.CornerRadius = UDim.new(0, 10)
    cameraCorner.Parent = cameraBtn
    
    cameraBtn.MouseButton1Click:Connect(function()
        Settings.CameraFollow = not Settings.CameraFollow
        cameraBtn.Text = Settings.CameraFollow and "📷 CAMERA FOLLOW: ON" or "📷 CAMERA FOLLOW: OFF"
        cameraBtn.BackgroundColor3 = Settings.CameraFollow and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    end)
    
    -- Target Info Panel
    local targetInfo = Instance.new("Frame")
    targetInfo.Size = UDim2.new(1, 0, 0, 50)
    targetInfo.Position = UDim2.new(0, 0, 0, 205)
    targetInfo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    targetInfo.BackgroundTransparency = 0.5
    targetInfo.BorderSizePixel = 0
    
    local targetInfoCorner = Instance.new("UICorner")
    targetInfoCorner.CornerRadius = UDim.new(0, 10)
    targetInfoCorner.Parent = targetInfo
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, 0, 1, 0)
    targetLabel.BackgroundTransparency = 1
    targetLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    targetLabel.TextScaled = true
    targetLabel.Font = Enum.Font.GothamBold
    targetLabel.Text = "🎯 No Target"
    targetLabel.Parent = targetInfo
    
    -- Assemble Main Panel
    titleBar.Parent = mainPanel
    content.Parent = mainPanel
    lockBtn.Parent = content
    toggleRow.Parent = content
    rotateBtn.Parent = content
    cameraBtn.Parent = content
    targetInfo.Parent = content
    
    -- MINIMIZED BAR
    local minimizedBar = Instance.new("Frame")
    minimizedBar.Size = UDim2.new(0, 300, 0, 40)
    minimizedBar.Position = UDim2.new(0, 15, 0, 80)
    minimizedBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    minimizedBar.BackgroundTransparency = 0.4
    minimizedBar.BorderSizePixel = 0
    minimizedBar.Visible = Settings.UIMinimized
    minimizedBar.ZIndex = 5
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 16)
    barCorner.Parent = minimizedBar
    
    local barStroke = Instance.new("UIStroke")
    barStroke.Color = Color3.fromRGB(255, 80, 80)
    barStroke.Thickness = 1
    barStroke.Transparency = 0.7
    barStroke.Parent = minimizedBar
    
    local barTitle = Instance.new("TextLabel")
    barTitle.Size = UDim2.new(1, -40, 1, 0)
    barTitle.Position = UDim2.new(0, 10, 0, 0)
    barTitle.Text = "⚡ CENDOL HUB V2"
    barTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    barTitle.BackgroundTransparency = 1
    barTitle.TextScaled = true
    barTitle.TextXAlignment = Enum.TextXAlignment.Left
    barTitle.Font = Enum.Font.GothamBold
    barTitle.Parent = minimizedBar
    
    local barStatus = Instance.new("TextLabel")
    barStatus.Size = UDim2.new(0.4, 0, 1, 0)
    barStatus.Position = UDim2.new(0.6, 0, 0, 0)
    barStatus.Text = ""
    barStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
    barStatus.BackgroundTransparency = 1
    barStatus.TextScaled = true
    barStatus.Font = Enum.Font.Gotham
    barStatus.Parent = minimizedBar
    
    -- Update status di minimized bar
    spawn(function()
        while minimizedBar and minimizedBar.Parent do
            if CurrentTarget and IsAlive(CurrentTarget) then
                local targetType = IsNPC(CurrentTarget) and "👹" or "👤"
                barStatus.Text = targetType .. " " .. (CurrentTarget.Name or "?")
            else
                barStatus.Text = Settings.Enabled and "🔍 LOCK" or "⏸ OFF"
            end
            task.wait(0.3)
        end
    end)
    
    -- UPDATE TARGET INFO
    spawn(function()
        while targetInfo and targetInfo.Parent do
            if CurrentTarget and IsAlive(CurrentTarget) then
                local targetType = IsNPC(CurrentTarget) and "👹 NPC" or "👤 PLAYER"
                local dist = TargetPart and math.floor((TargetPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
                local health = CurrentTarget:FindFirstChild("Humanoid") and math.floor(CurrentTarget.Humanoid.Health) or 0
                targetLabel.Text = "🎯 " .. targetType .. " | " .. (CurrentTarget.Name or "Target") .. " | 📏 " .. dist .. "m | ❤️ " .. health
                targetLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            else
                targetLabel.Text = "🎯 No Target Selected"
                targetLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            task.wait(0.2)
        end
    end)
    
    -- Drag functionality
    local function MakeDraggable(frame)
        local dragFrame = false
        local dragStart, startPos
        
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragFrame = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragFrame and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local delta = input.Position - dragStart
                local newX = startPos.X.Offset + delta.X
                local newY = startPos.Y.Offset + delta.Y
                frame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
                mainPanel.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragFrame = false
            end
        end)
    end
    
    MakeDraggable(minimizedBar)
    MakeDraggable(mainPanel)
    
    -- Minimize/Maximize functions
    local function MinimizeUI()
        if Settings.UIMinimized then return end
        Settings.UIMinimized = true
        mainPanel.Visible = false
        minimizedBar.Visible = true
        minimizedBar.Position = mainPanel.Position
    end
    
    local function MaximizeUI()
        if not Settings.UIMinimized then return end
        Settings.UIMinimized = false
        mainPanel.Visible = true
        minimizedBar.Visible = false
        mainPanel.Position = minimizedBar.Position
    end
    
    -- Tombol minimize di main panel
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    minimizeBtn.Position = UDim2.new(1, -40, 0, 4)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    minimizeBtn.BackgroundTransparency = 0.5
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextScaled = true
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.ZIndex = 10
    
    local btnCornerMini = Instance.new("UICorner")
    btnCornerMini.CornerRadius = UDim.new(1, 0)
    btnCornerMini.Parent = minimizeBtn
    
    minimizeBtn.MouseButton1Click:Connect(function()
        MinimizeUI()
    end)
    minimizeBtn.Parent = mainPanel
    
    -- Tombol maximize di minimized bar
    local maximizeBtn = Instance.new("TextButton")
    maximizeBtn.Size = UDim2.new(0, 32, 0, 32)
    maximizeBtn.Position = UDim2.new(1, -40, 0, 4)
    maximizeBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    maximizeBtn.BackgroundTransparency = 0.5
    maximizeBtn.Text = "+"
    maximizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    maximizeBtn.TextScaled = true
    maximizeBtn.Font = Enum.Font.GothamBold
    maximizeBtn.BorderSizePixel = 0
    maximizeBtn.ZIndex = 10
    
    local btnCornerMax = Instance.new("UICorner")
    btnCornerMax.CornerRadius = UDim.new(1, 0)
    btnCornerMax.Parent = maximizeBtn
    
    maximizeBtn.MouseButton1Click:Connect(function()
        MaximizeUI()
    end)
    maximizeBtn.Parent = minimizedBar
    
    mainPanel.Parent = sg
    minimizedBar.Parent = sg
    
    return {MinimizeUI, MaximizeUI}
end

-- ========== MAIN LOOP ==========
RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character then return end
    
    if Settings.Enabled then
        if not CurrentTarget or not IsAlive(CurrentTarget) then
            local newTarget = GetClosestTarget()
            if newTarget then
                CurrentTarget = newTarget
                TargetPart = GetBestHitbox(CurrentTarget)
            end
        end
        
        if CurrentTarget and not IsAlive(CurrentTarget) then
            CurrentTarget = nil
            TargetPart = nil
        end
        
        UpdateCameraFollow()
        RotateToTarget()
    end
    
    UpdateCrosshair()
end)

-- INIT
spawn(function()
    wait(1)
    Crosshair = CreateCrosshair()
    CreateUI()
    print("=== CENDOL HUB V2 LOADED ===")
    print("=== Camera Follow Active | Enhanced UI ===")
end)
]])()
