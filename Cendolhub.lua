-- CENDOL HUB V2 - TBO JUJUTSU SHENANIGANS EDITION
-- With Volume Button Toggle (Hide/Show UI)
-- By: Architect 03 (RianModss Filter)

loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========== MOVESET CONFIG ==========
local MovesetConfig = {
    Z = {Name = "Quickstep", Key = "Z", Color = Color3.fromRGB(100, 200, 255)},
    One = {Name = "Point Blank", Key = "1", Color = Color3.fromRGB(255, 100, 100)},
    Two = {Name = "Soul Impale", Key = "2", Color = Color3.fromRGB(200, 100, 255)},
    Three = {Name = "Insane Slashes", Key = "3", Color = Color3.fromRGB(255, 200, 100)},
    Four = {Name = "Split Soul Evade", Key = "4", Color = Color3.fromRGB(100, 255, 150)}
}

-- ========== CHARACTER DATA ==========
local Characters = {
    {Name = "Yuji Itadori", Type = "Brawler", Moveset = "Divergent Fist | Black Flash"},
    {Name = "Gojo Satoru", Type = "Limitless", Moveset = "Infinity | Hollow Purple"},
    {Name = "Fushiguro Megumi", Type = "Ten Shadows", Moveset = "Nue | Mahoraga"},
    {Name = "Kugisaki Nobara", Type = "Straw Doll", Moveset = "Resonance | Hairpin"},
    {Name = "Sukuna", Type = "King of Curses", Moveset = "Cleave | Malevolent Shrine"},
    {Name = "Toji Fushiguro", Type = "Heavenly Restriction", Moveset = "Inverted Spear | Soul Split"},
    {Name = "Geto Suguru", Type = "Curse Manipulation", Moveset = "Uzumaki | Rainbow Dragon"},
    {Name = "Mahito", Type = "Idle Transfiguration", Moveset = "Body Repel | Domain"},
    {Name = "Jogo", Type = "Disaster Flames", Moveset = "Ember Insects | Maximum Meteor"},
    {Name = "Custom", Type = "???", Moveset = "Choose Your Own"}
}

local CurrentCharacter = 1
local CurrentMoveset = "N/A"
local CharacterStatus = "Idle"
local UIHidden = false

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
local MainPanel = nil
local MinimizedBar = nil
local ScreenGui = nil

-- HITBOXES
local Hitboxes = {"Head", "UpperTorso", "HumanoidRootPart", "Torso"}

-- NPC DETECTION
local NPCKeywords = {"Cursed", "Spirit", "Curse", "NPC", "Mob", "Enemy", "Boss", "Raid", "Demon", "Shadow", "Monster"}

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

-- ========== HIDE/SHOW UI FUNCTION ==========
local function ToggleUI()
    UIHidden = not UIHidden
    
    if MainPanel and MinimizedBar then
        local targetPanel = (not Settings.UIMinimized and MainPanel) or MinimizedBar
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        if UIHidden then
            -- Hide with animation
            local tween = TweenService:Create(targetPanel, tweenInfo, {BackgroundTransparency = 1})
            tween:Play()
            targetPanel.Visible = false
            
            -- Also hide crosshair
            local crosshairGui = LocalPlayer.PlayerGui:FindFirstChild("CendolCrosshair")
            if crosshairGui then
                crosshairGui.Enabled = false
            end
        else
            -- Show with animation
            targetPanel.Visible = true
            targetPanel.BackgroundTransparency = 0.15
            local tween = TweenService:Create(targetPanel, tweenInfo, {BackgroundTransparency = 0.15})
            tween:Play()
            
            -- Show crosshair
            local crosshairGui = LocalPlayer.PlayerGui:FindFirstChild("CendolCrosshair")
            if crosshairGui then
                crosshairGui.Enabled = true
            end
        end
    end
end

-- ========== VOLUME BUTTON DETECTION ==========
local function SetupVolumeButtonToggle()
    -- Method 1: ContextActionService for mobile volume buttons
    ContextActionService:BindAction("ToggleUI", function(actionName, inputState, inputObject)
        if inputState == Enum.UserInputState.Begin then
            -- Check if it's volume button
            local keyCode = inputObject.KeyCode
            if keyCode == Enum.KeyCode.VolumeDown or keyCode == Enum.KeyCode.VolumeUp then
                ToggleUI()
                return Enum.ContextActionResult.Sink
            end
        end
        return Enum.ContextActionResult.Pass
    end, false, Enum.KeyCode.VolumeDown, Enum.KeyCode.VolumeUp)
    
    -- Method 2: UserInputService for keyboard fallback (F12 as alternative)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Volume Down on emulator usually mapped to F1/F2, but we use F12 as backup
        if input.KeyCode == Enum.KeyCode.F12 or input.KeyCode == Enum.KeyCode.VolumeDown then
            ToggleUI()
        end
    end)
    
    -- Method 3: For mobile touch volume button detection (works on some executors)
    -- Monitor for key press events
    local oldInputBegan
    oldInputBegan = hookfunction(UserInputService.InputBegan, function(self, input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.VolumeDown or input.KeyCode == Enum.KeyCode.VolumeUp then
            ToggleUI()
        end
        return oldInputBegan(self, input, gameProcessed)
    end)
end

-- ========== UI CREATION (MIRROR TIKTOK) ==========
local function CreateUI()
    for i = 1, 10 do
        if LocalPlayer:FindFirstChild("PlayerGui") then break end
        wait(0.5)
    end
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CendolHub"
    ScreenGui.Parent = LocalPlayer.PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- MAIN PANEL (mirip screenshot)
    MainPanel = Instance.new("Frame")
    MainPanel.Size = UDim2.new(0, 340, 0, 420)
    MainPanel.Position = UDim2.new(0, 15, 0, 80)
    MainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainPanel.BackgroundTransparency = 0.15
    MainPanel.BorderSizePixel = 0
    MainPanel.Visible = not Settings.UIMinimized
    MainPanel.ZIndex = 5
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 20)
    panelCorner.Parent = MainPanel
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(255, 80, 80)
    uiStroke.Thickness = 2
    uiStroke.Transparency = 0.5
    uiStroke.Parent = MainPanel
    
    -- Header with Discord button
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    header.BorderSizePixel = 0
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Text = "⚔️ CENDOL HUB V2"
    title.TextColor3 = Color3.fromRGB(255, 100, 100)
    title.BackgroundTransparency = 1
    title.TextScaled = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.Parent = header
    
    -- Volume toggle indicator
    local volumeHint = Instance.new("TextLabel")
    volumeHint.Size = UDim2.new(0, 80, 0, 25)
    volumeHint.Position = UDim2.new(0.4, 0, 0, 35)
    volumeHint.Text = "🔊 VOL ↓"
    volumeHint.TextColor3 = Color3.fromRGB(150, 150, 150)
    volumeHint.BackgroundTransparency = 1
    volumeHint.TextScaled = true
    volumeHint.Font = Enum.Font.Gotham
    volumeHint.Parent = header
    
    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.new(0, 100, 0, 40)
    discordBtn.Position = UDim2.new(1, -110, 0, 10)
    discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordBtn.Text = "💬 DISCORD"
    discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordBtn.TextScaled = true
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.BorderSizePixel = 0
    
    local discCorner = Instance.new("UICorner")
    discCorner.CornerRadius = UDim.new(0, 12)
    discCorner.Parent = discordBtn
    
    discordBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/cendolhub")
        volumeHint.Text = "✓ COPIED!"
        task.wait(1)
        volumeHint.Text = "🔊 VOL ↓"
    end)
    discordBtn.Parent = header
    
    -- SEARCH BAR
    local searchBar = Instance.new("Frame")
    searchBar.Size = UDim2.new(1, -30, 0, 40)
    searchBar.Position = UDim2.new(0, 15, 0, 75)
    searchBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    searchBar.BorderSizePixel = 0
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 12)
    searchCorner.Parent = searchBar
    
    local searchIcon = Instance.new("TextLabel")
    searchIcon.Size = UDim2.new(0, 30, 1, 0)
    searchIcon.Text = "🔍"
    searchIcon.BackgroundTransparency = 1
    searchIcon.TextScaled = true
    searchIcon.Font = Enum.Font.Gotham
    searchIcon.Parent = searchBar
    
    local searchInput = Instance.new("TextBox")
    searchInput.Size = UDim2.new(1, -40, 1, 0)
    searchInput.Position = UDim2.new(0, 35, 0, 0)
    searchInput.PlaceholderText = "Player Name..."
    searchInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchInput.Text = ""
    searchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchInput.BackgroundTransparency = 1
    searchInput.TextScaled = true
    searchInput.Font = Enum.Font.Gotham
    searchInput.Parent = searchBar
    
    -- CHARACTER SELECTION SECTION
    local charSection = Instance.new("Frame")
    charSection.Size = UDim2.new(1, -30, 0, 80)
    charSection.Position = UDim2.new(0, 15, 0, 125)
    charSection.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    charSection.BorderSizePixel = 0
    
    local charCorner = Instance.new("UICorner")
    charCorner.CornerRadius = UDim.new(0, 12)
    charCorner.Parent = charSection
    
    local charLabel = Instance.new("TextLabel")
    charLabel.Size = UDim2.new(1, 0, 0, 25)
    charLabel.Text = "⚡ CHARACTER"
    charLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    charLabel.BackgroundTransparency = 1
    charLabel.TextScaled = true
    charLabel.TextXAlignment = Enum.TextXAlignment.Left
    charLabel.Font = Enum.Font.GothamBold
    charLabel.Parent = charSection
    
    local charScroll = Instance.new("ScrollingFrame")
    charScroll.Size = UDim2.new(1, 0, 1, -30)
    charScroll.Position = UDim2.new(0, 0, 0, 30)
    charScroll.BackgroundTransparency = 1
    charScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    charScroll.ScrollBarThickness = 4
    charScroll.Parent = charSection
    
    local charButtons = {}
    for i, char in ipairs(Characters) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 40)
        btn.Position = UDim2.new(0, 5, 0, (i-1) * 45)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        btn.Text = char.Name .. " | " .. char.Type
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            CurrentCharacter = i
            CurrentMoveset = char.Moveset
            CharacterStatus = "Selected"
            for _, b in ipairs(charButtons) do
                b.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            end
            btn.BackgroundColor3 = Color3.fromRGB(100, 80, 150)
        end)
        
        btn.Parent = charScroll
        table.insert(charButtons, btn)
    end
    charScroll.CanvasSize = UDim2.new(0, 0, 0, #Characters * 45 + 10)
    
    -- STATUS PANEL (Moveset & Status)
    local statusPanel = Instance.new("Frame")
    statusPanel.Size = UDim2.new(1, -30, 0, 70)
    statusPanel.Position = UDim2.new(0, 15, 0, 215)
    statusPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    statusPanel.BorderSizePixel = 0
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 12)
    statusCorner.Parent = statusPanel
    
    local movesetLabel = Instance.new("TextLabel")
    movesetLabel.Size = UDim2.new(1, 0, 0, 30)
    movesetLabel.Text = "Moveset: N/A"
    movesetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    movesetLabel.BackgroundTransparency = 1
    movesetLabel.TextScaled = true
    movesetLabel.TextXAlignment = Enum.TextXAlignment.Left
    movesetLabel.Font = Enum.Font.Gotham
    movesetLabel.Parent = statusPanel
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 30)
    statusLabel.Position = UDim2.new(0, 0, 0, 35)
    statusLabel.Text = "Status: Idle"
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextScaled = true
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = statusPanel
    
    -- MOVESET BUTTONS (Z,1,2,3,4)
    local movesetFrame = Instance.new("Frame")
    movesetFrame.Size = UDim2.new(1, -30, 0, 65)
    movesetFrame.Position = UDim2.new(0, 15, 0, 295)
    movesetFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    movesetFrame.BorderSizePixel = 0
    
    local movesetCorner = Instance.new("UICorner")
    movesetCorner.CornerRadius = UDim.new(0, 12)
    movesetCorner.Parent = movesetFrame
    
    local moveButtons = {}
    local moveOrder = {"Z", "One", "Two", "Three", "Four"}
    local movePositions = {0, 0.2, 0.4, 0.6, 0.8}
    
    for idx, moveKey in ipairs(moveOrder) do
        local move = MovesetConfig[moveKey]
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.18, 0, 0.7, 0)
        btn.Position = UDim2.new(movePositions[idx] + 0.01, 0, 0.15, 0)
        btn.BackgroundColor3 = move.Color
        btn.BackgroundTransparency = 0.3
        btn.Text = move.Key .. "\n" .. move.Name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            CharacterStatus = "Using " .. move.Name
            statusLabel.Text = "Status: Using " .. move.Name
            task.wait(0.3)
            CharacterStatus = "Idle"
            statusLabel.Text = "Status: Idle"
        end)
        
        btn.Parent = movesetFrame
        table.insert(moveButtons, btn)
    end
    
    -- LOCK SECTION
    local lockSection = Instance.new("Frame")
    lockSection.Size = UDim2.new(1, -30, 0, 45)
    lockSection.Position = UDim2.new(0, 15, 0, 370)
    lockSection.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    lockSection.BorderSizePixel = 0
    
    local lockCorner = Instance.new("UICorner")
    lockCorner.CornerRadius = UDim.new(0, 12)
    lockCorner.Parent = lockSection
    
    local lockBtn = Instance.new("TextButton")
    lockBtn.Size = UDim2.new(1, 0, 1, 0)
    lockBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 50, 50)
    lockBtn.Text = Settings.Enabled and "🔒 AIMLOCK ACTIVE" or "🔓 AIMLOCK OFF"
    lockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    lockBtn.TextScaled = true
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.BorderSizePixel = 0
    
    local lockCornerBtn = Instance.new("UICorner")
    lockCornerBtn.CornerRadius = UDim.new(0, 12)
    lockCornerBtn.Parent = lockBtn
    
    lockBtn.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        lockBtn.Text = Settings.Enabled and "🔒 AIMLOCK ACTIVE" or "🔓 AIMLOCK OFF"
        lockBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 50, 50)
        if not Settings.Enabled then
            CurrentTarget = nil
            TargetPart = nil
        end
    end)
    lockBtn.Parent = lockSection
    
    -- MINIMIZED BAR
    MinimizedBar = Instance.new("Frame")
    MinimizedBar.Size = UDim2.new(0, 340, 0, 45)
    MinimizedBar.Position = UDim2.new(0, 15, 0, 80)
    MinimizedBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MinimizedBar.BackgroundTransparency = 0.2
    MinimizedBar.BorderSizePixel = 0
    MinimizedBar.Visible = Settings.UIMinimized
    MinimizedBar.ZIndex = 5
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 16)
    barCorner.Parent = MinimizedBar
    
    local barStroke = Instance.new("UIStroke")
    barStroke.Color = Color3.fromRGB(255, 80, 80)
    barStroke.Thickness = 1
    barStroke.Transparency = 0.7
    barStroke.Parent = MinimizedBar
    
    local barTitle = Instance.new("TextLabel")
    barTitle.Size = UDim2.new(1, -80, 1, 0)
    barTitle.Position = UDim2.new(0, 15, 0, 0)
    barTitle.Text = "⚡ CENDOL HUB V2"
    barTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    barTitle.BackgroundTransparency = 1
    barTitle.TextScaled = true
    barTitle.TextXAlignment = Enum.TextXAlignment.Left
    barTitle.Font = Enum.Font.GothamBold
    barTitle.Parent = MinimizedBar
    
    local barHint = Instance.new("TextLabel")
    barHint.Size = UDim2.new(0, 70, 1, 0)
    barHint.Position = UDim2.new(0.65, 0, 0, 0)
    barHint.Text = "🔊 VOL ↓"
    barHint.TextColor3 = Color3.fromRGB(150, 150, 150)
    barHint.BackgroundTransparency = 1
    barHint.TextScaled = true
    barHint.Font = Enum.Font.Gotham
    barHint.Parent = MinimizedBar
    
    local barStatus = Instance.new("TextLabel")
    barStatus.Size = UDim2.new(0, 50, 1, 0)
    barStatus.Position = UDim2.new(0.82, 0, 0, 0)
    barStatus.Text = ""
    barStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
    barStatus.BackgroundTransparency = 1
    barStatus.TextScaled = true
    barStatus.Font = Enum.Font.Gotham
    barStatus.Parent = MinimizedBar
    
    spawn(function()
        while MinimizedBar and MinimizedBar.Parent do
            if CurrentTarget and IsAlive(CurrentTarget) then
                local targetType = IsNPC(CurrentTarget) and "👹" or "👤"
                barStatus.Text = targetType
            else
                barStatus.Text = Settings.Enabled and "🔒" or "⏸"
            end
            task.wait(0.3)
        end
    end)
    
    -- Minimize/Maximize functionality
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
        Settings.UIMinimized = true
        MainPanel.Visible = false
        MinimizedBar.Visible = true
        MinimizedBar.Position = MainPanel.Position
    end)
    minimizeBtn.Parent = MainPanel
    
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
        Settings.UIMinimized = false
        MainPanel.Visible = true
        MinimizedBar.Visible = false
        MainPanel.Position = MinimizedBar.Position
    end)
    maximizeBtn.Parent = MinimizedBar
    
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
                if MainPanel and MinimizedBar then
                    MainPanel.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
                    MinimizedBar.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
                end
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragFrame = false
            end
        end)
    end
    
    MakeDraggable(MainPanel)
    MakeDraggable(MinimizedBar)
    
    -- ASSEMBLE
    header.Parent = MainPanel
    searchBar.Parent = MainPanel
    charSection.Parent = MainPanel
    statusPanel.Parent = MainPanel
    movesetFrame.Parent = MainPanel
    lockSection.Parent = MainPanel
    MainPanel.Parent = ScreenGui
    MinimizedBar.Parent = ScreenGui
    
    -- UPDATE STATUS LOOP
    spawn(function()
        while statusPanel and statusPanel.Parent do
            if CurrentCharacter and Characters[CurrentCharacter] then
                movesetLabel.Text = "Moveset: " .. Characters[CurrentCharacter].Moveset
            end
            if CurrentTarget and IsAlive(CurrentTarget) then
                statusLabel.Text = "Status: Combat | Target: " .. (CurrentTarget.Name or "?")
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            else
                statusLabel.Text = "Status: Idle"
                statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
            task.wait(0.2)
        end
    end)
    
    return true
end

-- ========== CROSSHAIR ==========
local function CreateCrosshair()
    for i = 1, 10 do
        if LocalPlayer:FindFirstChild("PlayerGui") then break end
        wait(0.5)
    end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "CendolCrosshair"
    sg.Parent = LocalPlayer.PlayerGui
    sg.ResetOnSpawn = false
    
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
    inner.Position = UDim2.new(0.
