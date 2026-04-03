-- CENDOL HUB V2 - ENHANCED CAMERA & UI + AUTO BLOCK/COUNTER
-- Camera Follow | Crosshair | Body Rotate | Auto Block | Auto Counter
-- Range: 11 STUDS ONLY
-- By: milanlan0073-alt + Architect 03

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
    UIMinimized = false,
    AutoBlock = true,
    AutoCounter = true,
    BlockCooldown = 0.5,
    CounterDelay = 0.2,
    CombatRange = 11 -- JARAK 11 STUDS BOS!
}

local CurrentTarget = nil
local TargetPart = nil
local Crosshair = nil
local UI = {}
local lastBlockTime = 0
local lastCounterTime = 0

-- HITBOXES (prioritas)
local Hitboxes = {"Head", "UpperTorso", "HumanoidRootPart", "Torso"}

-- NPC DETECTION
local NPCKeywords = {
    "Cursed", "Spirit", "Curse", "NPC", "Mob", "Enemy", "Boss",
    "Raid", "Demon", "Shadow", "Monster", "Training", "Dummy",
    "Zombie", "Skeleton", "Goblin", "Orc", "Troll", "Dragon"
}

-- ========== AUTO BLOCK & COUNTER FUNCTIONS ==========
local function GetDistanceToTarget()
    if not CurrentTarget then return math.huge end
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = CurrentTarget:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return math.huge end
    return (myRoot.Position - targetRoot.Position).Magnitude
end

local function IsInCombatRange()
    return GetDistanceToTarget() <= Settings.CombatRange
end

local function FindBlockButton()
    local playerGui = LocalPlayer.PlayerGui
    if not playerGui then return nil end
    
    local function search(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("ImageButton") or child:IsA("TextButton") then
                local nameLower = string.lower(child.Name or "")
                local textLower = string.lower(child.Text or "")
                if nameLower:find("block") or textLower:find("block") or 
                   nameLower:find("guard") or textLower:find("guard") or
                   nameLower:find("parry") or textLower:find("parry") then
                    return child
                end
            end
            local found = search(child)
            if found then return found end
        end
        return nil
    end
    
    return search(playerGui)
end

local function FindCounterButton()
    local playerGui = LocalPlayer.PlayerGui
    if not playerGui then return nil end
    
    local function search(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("ImageButton") or child:IsA("TextButton") then
                local nameLower = string.lower(child.Name or "")
                local textLower = string.lower(child.Text or "")
                if nameLower:find("counter") or textLower:find("counter") or
                   nameLower:find("attack") or textLower:find("attack") or
                   nameLower:find("m1") or textLower:find("click") or
                   nameLower:find("hit") or textLower:find("punch") then
                    return child
                end
            end
            local found = search(child)
            if found then return found end
        end
        return nil
    end
    
    return search(playerGui)
end

local function IsEnemyAttacking()
    if not CurrentTarget then return false end
    if not IsInCombatRange() then return false end -- GAK AKAN BLOCK KALAU JAUH
    
    local char = CurrentTarget
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    -- Deteksi animasi serangan dari musuh
    local animTracks = humanoid:GetPlayingAnimationTracks()
    for _, track in ipairs(animTracks) do
        local animName = string.lower(track.Animation.AnimationId or "")
        if animName:find("attack") or animName:find("slash") or 
           animName:find("punch") or animName:find("kick") or
           animName:find("hit") or animName:find("swing") or
           animName:find("combo") or animName:find("heavy") then
            return true
        end
    end
    
    -- Deteksi dari tool yang dipakai (kecepatan handle)
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool and tool:FindFirstChild("Handle") then
        local handle = tool.Handle
        if handle and handle.Velocity and handle.Velocity.Magnitude > 30 then
            return true
        end
    end
    
    return false
end

local function PerformBlock()
    if not IsInCombatRange() then return false end -- JARAK JAUH GAK USAH BLOCK
    
    local now = tick()
    if now - lastBlockTime < Settings.BlockCooldown then return false end
    
    local blockBtn = FindBlockButton()
    if blockBtn then
        lastBlockTime = now
        blockBtn:Click()
        return true
    end
    return false
end

local function PerformCounter()
    if not IsInCombatRange() then return false end -- JARAK JAUH GAK USAH COUNTER
    
    local now = tick()
    if now - lastCounterTime < Settings.BlockCooldown then return false end
    
    local counterBtn = FindCounterButton()
    if counterBtn then
        lastCounterTime = now
        counterBtn:Click()
        return true
    end
    return false
end

-- Auto Block & Counter Loop (Cuma aktif kalo jarak ≤ 11 studs)
local function AutoCombatLoop()
    while true do
        task.wait(0.05) -- 50ms loop
        
        if not Settings.Enabled then 
            task.wait(0.5)
        end
        
        if not CurrentTarget or not IsAlive(CurrentTarget) then 
            task.wait(0.5)
        end
        
        -- CEK JARAK DULU SEBELUM ACTION
        local distance = GetDistanceToTarget()
        local inRange = distance <= Settings.CombatRange
        
        if not inRange then
            task.wait(0.1)
        end
        
        local isAttacking = IsEnemyAttacking()
        
        -- AUTO BLOCK (hanya jika dalam range)
        if Settings.AutoBlock and inRange and isAttacking then
            PerformBlock()
        end
        
        -- AUTO COUNTER (hanya jika dalam range)
        if Settings.AutoCounter and inRange then
            if not isAttacking or (lastBlockTime and tick() - lastBlockTime < 0.3) then
                PerformCounter()
            end
        end
    end
end

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

-- GET TARGET TERDEKAT
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

-- CAMERA FOLLOW
local function UpdateCameraFollow()
    if not Settings.CameraFollow then return end
    if not CurrentTarget or not IsAlive(CurrentTarget) then return end
    if not TargetPart or not TargetPart.Parent then return end
    
    local targetPos = TargetPart.Position + Settings.CameraOffset
    local currentCFrame = Camera.CFrame
    local desiredCFrame = CFrame.new(currentCFrame.Position, targetPos)
    local newCFrame = currentCFrame:Lerp(desiredCFrame, Settings.CameraSmoothness)
    Camera.CFrame = newCFrame
end

-- CROSSHAIR
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
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0.5, -3, 0.5, -3)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.ZIndex = 12
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    
    inner.Parent = outer
    dot.Parent = inner
    outer.Parent = sg
    
    return {outer, inner}
end

local function UpdateCrosshair()
    if not Crosshair then return end
    local outer, inner = unpack(Crosshair)
    
    if CurrentTarget and IsAlive(CurrentTarget) then
        local inRange = GetDistanceToTarget() <= Settings.CombatRange
        if inRange then
            inner.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            inner.BackgroundTransparency = 0.1
            outer.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            outer.BackgroundTransparency = 0.6
        else
            inner.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            inner.BackgroundTransparency = 0.3
            outer.BackgroundColor3 = Color3.fromRGB(255, 150, 150)
            outer.BackgroundTransparency = 0.7
        end
    else
        inner.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        inner.BackgroundTransparency = 0.6
        outer.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        outer.BackgroundTransparency = 0.85
    end
end

-- UI
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
    
    local mainPanel = Instance.new("Frame")
    mainPanel.Size = UDim2.new(0, 300, 0, 300)
    mainPanel.Position = UDim2.new(0, 15, 0, 80)
    mainPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainPanel.BackgroundTransparency = 0.3
    mainPanel.BorderSizePixel = 0
    mainPanel.Visible = not Settings.UIMinimized
    mainPanel.ZIndex = 5
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 16)
    panelCorner.Parent = mainPanel
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(255, 80, 80)
    uiStroke.Thickness = 1
    uiStroke.Transparency = 0.7
    uiStroke.Parent = mainPanel
    
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
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -50)
    content.Position = UDim2.new(0, 10, 0, 45)
    content.BackgroundTransparency = 1
    
    -- Range Info
    local rangeInfo = Instance.new("TextLabel")
    rangeInfo.Size = UDim2.new(1, 0, 0, 25)
    rangeInfo.Position = UDim2.new(0, 0, 0, 0)
    rangeInfo.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    rangeInfo.BackgroundTransparency = 0.5
    rangeInfo.Text = "🎯 COMBAT RANGE: 11 STUDS"
    rangeInfo.TextColor3 = Color3.fromRGB(255, 200, 0)
    rangeInfo.TextScaled = true
    rangeInfo.Font = Enum.Font.GothamBold
    rangeInfo.BorderSizePixel = 0
    
    local rangeCorner = Instance.new("UICorner")
    rangeCorner.CornerRadius = UDim.new(0, 8)
    rangeCorner.Parent = rangeInfo
    
    -- Lock ON/OFF
    local lockBtn = Instance.new("TextButton")
    lockBtn.Size = UDim2.new(1, 0, 0, 40)
    lockBtn.Position = UDim2.new(0, 0, 0, 35)
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
        end
        UpdateCrosshair()
    end)
    
    -- Auto Block Toggle
    local blockBtn = Instance.new("TextButton")
    blockBtn.Size = UDim2.new(1, 0, 0, 40)
    blockBtn.Position = UDim2.new(0, 0, 0, 85)
    blockBtn.BackgroundColor3 = Settings.AutoBlock and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    blockBtn.Text = Settings.AutoBlock and "🛡️ AUTO BLOCK: ON (11 studs)" or "🛡️ AUTO BLOCK: OFF"
    blockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    blockBtn.TextScaled = true
    blockBtn.Font = Enum.Font.GothamBold
    blockBtn.BorderSizePixel = 0
    
    local blockCorner = Instance.new("UICorner")
    blockCorner.CornerRadius = UDim.new(0, 10)
    blockCorner.Parent = blockBtn
    
    blockBtn.MouseButton1Click:Connect(function()
        Settings.AutoBlock = not Settings.AutoBlock
        blockBtn.Text = Settings.AutoBlock and "🛡️ AUTO BLOCK: ON (11 studs)" or "🛡️ AUTO BLOCK: OFF"
        blockBtn.BackgroundColor3 = Settings.AutoBlock and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    end)
    
    -- Auto Counter Toggle
    local counterBtn = Instance.new("TextButton")
    counterBtn.Size = UDim2.new(1, 0, 0, 40)
    counterBtn.Position = UDim2.new(0, 0, 0, 135)
    counterBtn.BackgroundColor3 = Settings.AutoCounter and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    counterBtn.Text = Settings.AutoCounter and "⚔️ AUTO COUNTER: ON (11 studs)" or "⚔️ AUTO COUNTER: OFF"
    counterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    counterBtn.TextScaled = true
    counterBtn.Font = Enum.Font.GothamBold
    counterBtn.BorderSizePixel = 0
    
    local counterCorner = Instance.new("UICorner")
    counterCorner.CornerRadius = UDim.new(0, 10)
    counterCorner.Parent = counterBtn
    
    counterBtn.MouseButton1Click:Connect(function()
        Settings.AutoCounter = not Settings.AutoCounter
        counterBtn.Text = Settings.AutoCounter and "⚔️ AUTO COUNTER: ON (11 studs)" or "⚔️ AUTO COUNTER: OFF"
        counterBtn.BackgroundColor3 = Settings.AutoCounter and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    end)
    
    -- Player/NPC Toggle Row
    local toggleRow = Instance.new("Frame")
    toggleRow.Size = UDim2.new(1, 0, 0, 40)
    toggleRow.Position = UDim2.new(0, 0, 0, 185)
    toggleRow.BackgroundTransparency = 1
    
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
    
    -- Body Rotate & Camera Follow
    local rotateBtn = Instance.new("TextButton")
    rotateBtn.Size = UDim2.new(0.48, 0, 0, 35)
    rotateBtn.Position = UDim2.new(0, 0, 0, 235)
    rotateBtn.BackgroundColor3 = Settings.BodyRotate and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    rotateBtn.Text = "🔄 ROTATE"
    rotateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rotateBtn.TextScaled = true
    rotateBtn.Font = Enum.Font.GothamBold
    rotateBtn.BorderSizePixel = 0
    
    local rotateCorner = Instance.new("UICorner")
    rotateCorner.CornerRadius = UDim.new(0, 8)
    rotateCorner.Parent = rotateBtn
    
    rotateBtn.MouseButton1Click:Connect(function()
        Settings.BodyRotate = not Settings.BodyRotate
        rotateBtn.BackgroundColor3 = Settings.BodyRotate and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    end)
    
    local cameraBtn = Instance.new("TextButton")
    cameraBtn.Size = UDim2.new(0.48, 0, 0, 35)
    cameraBtn.Position = UDim2.new(0.52, 0, 0, 235)
    cameraBtn.BackgroundColor3 = Settings.CameraFollow and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    cameraBtn.Text = "📷 CAMERA"
    cameraBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cameraBtn.TextScaled = true
    cameraBtn.Font = Enum.Font.GothamBold
    cameraBtn.BorderSizePixel = 0
    
    local cameraCorner = Instance.new("UICorner")
    cameraCorner.CornerRadius = UDim.new(0, 8)
    cameraCorner.Parent = cameraBtn
    
    cameraBtn.MouseButton1Click:Connect(function()
        Settings.CameraFollow = not Settings.CameraFollow
        cameraBtn.BackgroundColor3 = Settings.CameraFollow and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    end)
    
    -- Assemble UI
    titleBar.Parent = mainPanel
    content.Parent = mainPanel
    rangeInfo.Parent = content
    lockBtn.Parent = content
    blockBtn.Parent = content
    counterBtn.Parent = content
    toggleRow.Parent = content
    rotateBtn.Parent = content
    cameraBtn.Parent = content
    
    -- Minimized Bar
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
    
    local btnCornerMini = Instance.new("UICorner")
    btnCornerMini.CornerRadius = UDim.new(1, 0)
    btnCornerMini.Parent = minimizeBtn
    
    minimizeBtn.MouseButton1Click:Connect(function()
        Settings.UIMinimized = true
        mainPanel.Visible = false
        minimizedBar.Visible = true
        minimizedBar.Position = mainPanel.Position
    end)
    minimizeBtn.Parent = mainPanel
    
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
    
    local btnCornerMax = Instance.new("UICorner")
    btnCornerMax.CornerRadius = UDim.new(1, 0)
    btnCornerMax.Parent = maximizeBtn
    
    maximizeBtn.MouseButton1Click:Connect(function()
        Settings.UIMinimized = false
        mainPanel.Visible = true
        minimizedBar.Visible = false
        mainPanel.Position = minimizedBar.Position
    end)
    maximizeBtn.Parent = minimizedBar
    
    mainPanel.Parent = sg
    minimizedBar.Parent = sg
    
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
                if frame == minimizedBar then
                    mainPanel.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
                end
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragFrame = false
            end
        end)
    end
    
    MakeDraggable(mainPanel)
    MakeDraggable(minimizedBar)
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
    AutoCombatLoop() -- JALANKAN AUTO COMBAT LOOP
    print("=== CENDOL HUB V2 LOADED ===")
    print("=== Combat Range: 11 STUDS ===")
    print("=== Auto Block & Counter Active ===")
end)
]])()
