-- CENDOL HUB - BODY LOCK PLAYER + NPC
-- Lock 1 target (player/npc) | Body follow | Skill auto aim
-- Ganti target: matiin lalu idupin
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
    LockPlayer = true,        -- LOCK PLAYER ON/OFF
    LockNPC = true,           -- LOCK NPC ON/OFF
    BodyFollow = true,        
    BodyFollowSpeed = 0.3,    
    Smoothness = 0.4,         
    MaxDistance = 150         
}

local CurrentTarget = nil
local TargetPart = nil
local TargetHumanoid = nil

-- HITBOXES
local Hitboxes = {"Head", "UpperTorso", "HumanoidRootPart", "Torso"}

-- NPC DETECTION KEYWORDS
local NPCKeywords = {
    "Cursed", "Spirit", "Curse", "NPC", "Mob", "Enemy", "Boss",
    "Raid", "Demon", "Shadow", "Monster", "Training", "Dummy",
    "Villain", "Fodder", "Minion", "Creep", "Zombie"
}

-- UTILITIES
local function IsAlive(c)
    if not c then return false end
    local h = c:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function IsNPC(character)
    -- Cek kalo bukan player
    if Players:GetPlayerFromCharacter(character) then
        return false
    end
    -- Cek nama character
    local name = character.Name:lower()
    for _, keyword in ipairs(NPCKeywords) do
        if name:find(keyword:lower()) then
            return true
        end
    end
    -- Kalo ada Humanoid tapi bukan player, anggap NPC
    if character:FindFirstChild("Humanoid") then
        return true
    end
    return false
end

local function GetDistance(a, b)
    return (a.Position - b.Position).Magnitude
end

-- GET TARGET TERDEKAT (PLAYER + NPC)
local function GetClosestTarget()
    local closest = nil
    local closestDist = Settings.MaxDistance
    local closestType = nil
    local myChar = LocalPlayer.Character
    if not myChar then return nil, nil end
    local myPos = myChar:FindFirstChild("HumanoidRootPart")
    if not myPos then return nil, nil end
    
    -- PLAYERS
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
                            closestType = "PLAYER"
                        end
                    end
                end
            end
        end
    end
    
    -- NPC
    if Settings.LockNPC then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= myChar then
                if IsNPC(obj) then
                    local h = obj:FindFirstChild("Humanoid")
                    local r = obj:FindFirstChild("HumanoidRootPart")
                    if h and r and h.Health > 0 then
                        local d = GetDistance(r, myPos)
                        if d < closestDist then
                            closestDist = d
                            closest = obj
                            closestType = "NPC"
                        end
                    end
                end
            end
        end
    end
    
    return closest, closestType
end

-- DAPATIN HITBOX TERBAIK
local function GetBestHitbox(char)
    local head = char:FindFirstChild("Head")
    if head and head:IsA("BasePart") then return head end
    
    for _, h in ipairs(Hitboxes) do
        local part = char:FindFirstChild(h)
        if part and part:IsA("BasePart") then return part end
    end
    return char:FindFirstChild("HumanoidRootPart")
end

-- BODY LOCK - Karakter ngikutin target
local function BodyFollowTarget()
    if not Settings.BodyFollow then return end
    if not CurrentTarget or not IsAlive(CurrentTarget) then return end
    
    local myChar = LocalPlayer.Character
    local targetRoot = CurrentTarget:FindFirstChild("HumanoidRootPart")
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot or not myRoot then return end
    
    local distance = GetDistance(targetRoot, myRoot)
    
    -- Kalo terlalu jauh, gerakin karakter ke target
    if distance > 8 then
        local direction = (targetRoot.Position - myRoot.Position).Unit
        local moveDirection = direction * Settings.BodyFollowSpeed
        local newPos = myRoot.Position + moveDirection
        
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(myRoot, tweenInfo, {Position = newPos})
        tween:Play()
    end
    
    -- Auto arahin karakter ke target (biar skill kena)
    local lookAt = CFrame.new(myRoot.Position, targetRoot.Position)
    myChar:SetPrimaryPartCFrame(lookAt)
end

-- SIMPLE GUI
local function CreateGUI()
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
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 240, 0, 200)
    frame.Position = UDim2.new(0, 10, 0, 80)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    -- Title (draggable)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    titleBar.BackgroundTransparency = 0.4
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
    
    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -35)
    content.Position = UDim2.new(0, 0, 0, 35)
    content.BackgroundTransparency = 1
    
    -- Lock ON/OFF Button (utama)
    local lockBtn = Instance.new("TextButton")
    lockBtn.Size = UDim2.new(0.9, 0, 0, 40)
    lockBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
    lockBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 50, 50)
    lockBtn.Text = Settings.Enabled and "🔒 LOCK ACTIVE" or "🔓 LOCK OFF"
    lockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    lockBtn.TextScaled = true
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = lockBtn
    
    lockBtn.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        lockBtn.Text = Settings.Enabled and "🔒 LOCK ACTIVE" or "🔓 LOCK OFF"
        lockBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 50, 50)
        
        if not Settings.Enabled then
            CurrentTarget = nil
            TargetPart = nil
        else
            CurrentTarget = nil -- reset target biar cari baru
        end
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "CENDOL HUB",
            Text = Settings.Enabled and "LOCK ACTIVE" or "LOCK OFF",
            Duration = 1
        })
    end)
    
    -- Lock Player Toggle
    local playerBtn = Instance.new("TextButton")
    playerBtn.Size = UDim2.new(0.43, 0, 0, 30)
    playerBtn.Position = UDim2.new(0.05, 0, 0.28, 0)
    playerBtn.BackgroundColor3 = Settings.LockPlayer and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    playerBtn.Text = Settings.LockPlayer and "👤 PLAYER" or "👤 PLAYER"
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
        if Settings.Enabled then
            CurrentTarget = nil -- reset target
        end
    end)
    
    -- Lock NPC Toggle
    local npcBtn = Instance.new("TextButton")
    npcBtn.Size = UDim2.new(0.43, 0, 0, 30)
    npcBtn.Position = UDim2.new(0.52, 0, 0.28, 0)
    npcBtn.BackgroundColor3 = Settings.LockNPC and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    npcBtn.Text = Settings.LockNPC and "👹 NPC" or "👹 NPC"
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
        if Settings.Enabled then
            CurrentTarget = nil -- reset target
        end
    end)
    
    -- Target Info
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(0.9, 0, 0, 35)
    targetLabel.Position = UDim2.new(0.05, 0, 0.45, 0)
    targetLabel.Text = "🎯 No Target"
    targetLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    targetLabel.BackgroundTransparency = 1
    targetLabel.TextScaled = true
    targetLabel.Font = Enum.Font.Gotham
    targetLabel.Parent = content
    
    -- Distance Info
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(0.9, 0, 0, 25)
    distLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
    distLabel.Text = "📏 --m"
    distLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    distLabel.BackgroundTransparency = 1
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = content
    
    -- Type Info
    local typeLabel = Instance.new("TextLabel")
    typeLabel.Size = UDim2.new(0.9, 0, 0, 25)
    typeLabel.Position = UDim2.new(0.05, 0, 0.8, 0)
    typeLabel.Text = ""
    typeLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
    typeLabel.BackgroundTransparency = 1
    typeLabel.TextScaled = true
    typeLabel.Font = Enum.Font.Gotham
    typeLabel.Parent = content
    
    -- Footer
    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, 0, 0, 18)
    footer.Position = UDim2.new(0, 0, 1, -18)
    footer.Text = "Off/On to change target"
    footer.TextColor3 = Color3.fromRGB(100, 100, 100)
    footer.BackgroundTransparency = 1
    footer.TextScaled = true
    footer.Font = Enum.Font.Gotham
    footer.Parent = frame
    
    -- Assemble
    titleBar.Parent = frame
    content.Parent = frame
    lockBtn.Parent = content
    playerBtn.Parent = content
    npcBtn.Parent = content
    targetLabel.Parent = content
    distLabel.Parent = content
    typeLabel.Parent = content
    frame.Parent = sg
    
    -- UPDATE INFO LOOP
    spawn(function()
        while frame and frame.Parent do
            if CurrentTarget and IsAlive(CurrentTarget) then
                local dist = TargetPart and math.floor((TargetPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
                local targetType = IsNPC(CurrentTarget) and "👹 NPC" or "👤 PLAYER"
                targetLabel.Text = "🎯 " .. (CurrentTarget.Name or "?")
                targetLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                distLabel.Text = "📏 " .. dist .. "m"
                typeLabel.Text = targetType
                typeLabel.TextColor3 = IsNPC(CurrentTarget) and Color3.fromRGB(255, 150, 50) or Color3.fromRGB(80, 150, 255)
            else
                targetLabel.Text = "🎯 No Target"
                targetLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                distLabel.Text = "📏 --m"
                typeLabel.Text = ""
            end
            task.wait(0.3)
        end
    end)
    
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
end

-- ========== MAIN LOOP ==========
RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character then return end
    
    if Settings.Enabled then
        -- Cari target terdekat (player atau NPC)
        if not CurrentTarget or not IsAlive(CurrentTarget) then
            local newTarget, targetType = GetClosestTarget()
            if newTarget then
                CurrentTarget = newTarget
                TargetPart = GetBestHitbox(CurrentTarget)
                TargetHumanoid = CurrentTarget:FindFirstChild("Humanoid")
            end
        end
        
        -- Kalo target mati, clear
        if CurrentTarget and not IsAlive(CurrentTarget) then
            CurrentTarget = nil
            TargetPart = nil
            TargetHumanoid = nil
        end
        
        -- LOCK CAMERA ke target
        if CurrentTarget and TargetPart and TargetPart.Parent then
            local targetPos = TargetPart.Position
            local currentPos = Camera.CFrame.Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(currentPos, targetPos), Settings.Smoothness)
        end
        
        -- BODY FOLLOW - karakter ngikutin target
        BodyFollowTarget()
    end
end)

-- INIT
spawn(function()
    wait(1)
    pcall(CreateGUI)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚡ CENDOL HUB",
        Text = "Player + NPC Lock | Body Follow | Off/On to change target",
        Duration = 3
    })
    print("=== CENDOL HUB PLAYER+NPC BODY LOCK LOADED ===")
end)
]])()
