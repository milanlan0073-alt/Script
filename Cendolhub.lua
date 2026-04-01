-- CENDOL HUB - CROSSHAIR + BODY ROTATION
-- Crosshair target | Karakter auto rotate ke target | Camera lock
-- By: milanlan0073-alt

loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========== SETTINGS ==========
local Settings = {
    Enabled = true,
    LockPlayer = true,
    LockNPC = true,
    CameraLock = true,
    BodyRotate = true,        -- Karakter muter ke target (tanpa gerak)
    MaxDistance = 150,
    Smoothness = 0.4
}

local CurrentTarget = nil
local TargetPart = nil
local Crosshair = nil

-- HITBOXES
local Hitboxes = {"Head", "UpperTorso", "HumanoidRootPart", "Torso"}

-- NPC DETECTION
local NPCKeywords = {
    "Cursed", "Spirit", "Curse", "NPC", "Mob", "Enemy", "Boss",
    "Raid", "Demon", "Shadow", "Monster", "Training", "Dummy"
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

-- ========== BODY ROTATION ==========
-- Karakter langsung muter ke target (tanpa gerak)
local function RotateToTarget()
    if not Settings.BodyRotate then return end
    if not CurrentTarget or not IsAlive(CurrentTarget) then return end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = CurrentTarget:FindFirstChild("HumanoidRootPart")
    
    if not myRoot or not targetRoot then return end
    
    -- Hitung arah ke target
    local direction = (targetRoot.Position - myRoot.Position).Unit
    local lookAt = CFrame.new(myRoot.Position, myRoot.Position + direction)
    
    -- Langsung rotasi karakter ke target
    myChar:SetPrimaryPartCFrame(lookAt)
end

-- ========== CROSSHAIR ==========
local function CreateCrosshair()
    -- Tunggu PlayerGui
    for i = 1, 10 do
        if LocalPlayer:FindFirstChild("PlayerGui") then
            break
        end
        wait(0.5)
    end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "CendolCrosshair"
    sg.Parent = LocalPlayer.PlayerGui
    sg.ResetOnSpawn = false
    
    -- Lingkaran luar
    local outer = Instance.new("Frame")
    outer.Size = UDim2.new(0, 40, 0, 40)
    outer.Position = UDim2.new(0.5, -20, 0.5, -20)
    outer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    outer.BackgroundTransparency = 0.8
    outer.BorderSizePixel = 0
    outer.ZIndex = 10
    
    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(1, 0)
    outerCorner.Parent = outer
    
    -- Lingkaran dalam (warna berubah kalo ada target)
    local inner = Instance.new("Frame")
    inner.Size = UDim2.new(0, 20, 0, 20)
    inner.Position = UDim2.new(0.5, -10, 0.5, -10)
    inner.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    inner.BackgroundTransparency = 0.5
    inner.BorderSizePixel = 0
    inner.ZIndex = 11
    
    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(1, 0)
    innerCorner.Parent = inner
    
    -- Titik tengah
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 4, 0, 4)
    dot.Position = UDim2.new(0.5, -2, 0.5, -2)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.ZIndex = 12
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    
    -- Target Info Text
    local targetText = Instance.new("TextLabel")
    targetText.Size = UDim2.new(0, 200, 0, 25)
    targetText.Position = UDim2.new(0.5, -100, 0.5, 30)
    targetText.BackgroundTransparency = 1
    targetText.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetText.TextStrokeTransparency = 0.5
    targetText.TextScaled = true
    targetText.Font = Enum.Font.GothamBold
    targetText.Text = ""
    targetText.ZIndex = 10
    
    -- Distance Text
    local distText = Instance.new("TextLabel")
    distText.Size = UDim2.new(0, 100, 0, 20)
    distText.Position = UDim2.new(0.5, -50, 0.5, 55)
    distText.BackgroundTransparency = 1
    distText.TextColor3 = Color3.fromRGB(200, 200, 200)
    distText.TextScaled = true
    distText.Font = Enum.Font.Gotham
    distText.Text = ""
    distText.ZIndex = 10
    
    inner.Parent = outer
    dot.Parent = inner
    targetText.Parent = sg
    distText.Parent = sg
    outer.Parent = sg
    
    return {outer, inner, targetText, distText}
end

-- Update crosshair berdasarkan target
local function UpdateCrosshair()
    if not Crosshair then return end
    local outer, inner, targetText, distText = unpack(Crosshair)
    
    if CurrentTarget and IsAlive(CurrentTarget) then
        -- Ada target: inner jadi merah terang
        inner.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        inner.BackgroundTransparency = 0.3
        outer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        
        local targetType = IsNPC(CurrentTarget) and "👹 " or "👤 "
        local dist = TargetPart and math.floor((TargetPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
        targetText.Text = targetType .. (CurrentTarget.Name or "Target")
        distText.Text = dist .. "m"
    else
        -- Ga ada target: inner jadi abu-abu
        inner.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        inner.BackgroundTransparency = 0.6
        outer.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        targetText.Text = ""
        distText.Text = ""
    end
end

-- ========== SIMPLE GUI ==========
local function CreateGUI()
    for i = 1, 10 do
        if LocalPlayer:FindFirstChild("PlayerGui") then break end
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
    
    -- Lock ON/OFF
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
            CurrentTarget = nil
        end
        UpdateCrosshair()
    end)
    
    -- Lock Player Toggle
    local playerBtn = Instance.new("TextButton")
    playerBtn.Size = UDim2.new(0.43, 0, 0, 30)
    playerBtn.Position = UDim2.new(0.05, 0, 0.28, 0)
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
    npcBtn.Size = UDim2.new(0.43, 0, 0, 30)
    npcBtn.Position = UDim2.new(0.52, 0, 0.28, 0)
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
    
    -- Body Rotate Toggle
    local rotateBtn = Instance.new("TextButton")
    rotateBtn.Size = UDim2.new(0.9, 0, 0, 35)
    rotateBtn.Position = UDim2.new(0.05, 0, 0.43, 0)
    rotateBtn.BackgroundColor3 = Settings.BodyRotate and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    rotateBtn.Text = Settings.BodyRotate and "🔄 BODY ROTATE: ON" or "🔄 BODY ROTATE: OFF"
    rotateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rotateBtn.TextScaled = true
    rotateBtn.Font = Enum.Font.GothamBold
    rotateBtn.BorderSizePixel = 0
    
    local rotateCorner = Instance.new("UICorner")
    rotateCorner.CornerRadius = UDim.new(0, 8)
    rotateCorner.Parent = rotateBtn
    
    rotateBtn.MouseButton1Click:Connect(function()
        Settings.BodyRotate = not Settings.BodyRotate
        rotateBtn.Text = Settings.BodyRotate and "🔄 BODY ROTATE: ON" or "🔄 BODY ROTATE: OFF"
        rotateBtn.BackgroundColor3 = Settings.BodyRotate and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    end)
    
    -- Target Info
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(0.9, 0, 0, 30)
    targetLabel.Position = UDim2.new(0.05, 0, 0.63, 0)
    targetLabel.Text = "🎯 No Target"
    targetLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    targetLabel.BackgroundTransparency = 1
    targetLabel.TextScaled = true
    targetLabel.Font = Enum.Font.Gotham
    targetLabel.Parent = content
    
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
    rotateBtn.Parent = content
    targetLabel.Parent = content
    frame.Parent = sg
    
    -- UPDATE INFO LOOP
    spawn(function()
        while frame and frame.Parent do
            if CurrentTarget and IsAlive(CurrentTarget) then
                local targetType = IsNPC(CurrentTarget) and "👹" or "👤"
                local dist = TargetPart and math.floor((TargetPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
                targetLabel.Text = "🎯 " .. targetType .. " " .. (CurrentTarget.Name or "?") .. " (" .. dist .. "m)"
                targetLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                targetLabel.Text = "🎯 No Target"
                targetLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
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
        -- Cari target
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
        
        -- Camera Lock
        if Settings.CameraLock and CurrentTarget and TargetPart and TargetPart.Parent then
            local targetPos = TargetPart.Position
            local currentPos = Camera.CFrame.Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(currentPos, targetPos), Settings.Smoothness)
        end
        
        -- Body Rotation (karakter muter ke target)
        RotateToTarget()
    end
    
    -- Update crosshair setiap frame
    UpdateCrosshair()
end)

-- INIT
spawn(function()
    wait(1)
    Crosshair = CreateCrosshair()
    pcall(CreateGUI)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚡ CENDOL HUB",
        Text = "Crosshair Active | Karakter auto rotate ke target",
        Duration = 3
    })
    print("=== CENDOL HUB CROSSHAIR LOADED ===")
end)
]])()
