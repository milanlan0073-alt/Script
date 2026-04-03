-- CENDOL HUB V2 - RANGE 5-500 STUDS
-- AUTO BLOCK + AUTO COUNTER + DASH 180° + SEEK BAR
-- JUJUTSU SHENANIGANS - ARCHITECT 03 EDITION

loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local CoreGui = game:GetService("CoreGui")

local Settings = {
    -- LOCK ON
    Enabled = false,
    LockPlayer = true,
    LockNPC = true,
    CameraSmoothness = 0.3,
    BodyRotate = true,
    MaxDistance = 150,
    CameraOffset = Vector3.new(0, 1.5, 0),
    RotateCamera = true,
    Minimized = false,
    
    -- DASH
    SideDashEnabled = false,
    
    -- AUTO BLOCK
    AutoBlock = false,
    
    -- AUTO COUNTER
    AutoCounter = false
}

local CurrentTarget = nil
local TargetPart = nil
local MainFrame = nil
local lastDashTime = 0
local dashCooldown = 0.5
local lastBlockTime = 0
local blockCooldown = 0.3
local lastCounterTime = 0
local counterCooldown = 0.5

-- SLIDER
local RangeSlider = nil
local RangeFill = nil
local RangeValueLabel = nil
local isDraggingSlider = false

local Hitboxes = {"Head", "UpperTorso", "HumanoidRootPart", "Torso", "Chest"}

local NPCKeywords = {
    "Cursed", "Spirit", "Curse", "NPC", "Mob", "Enemy", "Boss", "Raid",
    "Demon", "Shadow", "Monster", "Dummy", "Training", "Zombie", "Sukuna",
    "Gojo", "Geto", "Kenjaku", "Mahito", "Jogo", "Hanami", "Dagon", "Toji"
}

local function IsAlive(c)
    if not c then return false end
    local h = c:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function IsNPC(character)
    if Players:GetPlayerFromCharacter(character) then return false end
    local name = character.Name:lower()
    for _, kw in ipairs(NPCKeywords) do
        if name:find(kw:lower()) then return true end
    end
    return character:FindFirstChild("Humanoid") ~= nil and not character:FindFirstChild("PlayerName")
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

    local targets = {}

    if Settings.LockPlayer then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local c = p.Character
                if c and IsAlive(c) then
                    local r = c:FindFirstChild("HumanoidRootPart")
                    if r then
                        local dist = GetDistance(r, myPos)
                        if dist <= Settings.MaxDistance then
                            table.insert(targets, {char = c, dist = dist})
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
                    local dist = GetDistance(r, myPos)
                    if dist <= Settings.MaxDistance then
                        table.insert(targets, {char = obj, dist = dist})
                    end
                end
            end
        end
    end

    table.sort(targets, function(a,b) return a.dist < b.dist end)

    if #targets > 0 then
        closest = targets[1].char
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
    local targetRoot = CurrentTarget and CurrentTarget:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return end
    local direction = (targetRoot.Position - myRoot.Position).Unit
    local lookAt = CFrame.new(myRoot.Position, myRoot.Position + direction)
    pcall(function()
        myChar:SetPrimaryPartCFrame(lookAt)
    end)
end

-- DASH 180°
local function SideDash180()
    if not Settings.SideDashEnabled then return end
    if not CurrentTarget or not IsAlive(CurrentTarget) then return end
    
    local currentTime = tick()
    if currentTime - lastDashTime < dashCooldown then return end
    lastDashTime = currentTime
    
    local myChar = LocalPlayer.Character
    local rootPart = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = CurrentTarget and CurrentTarget:FindFirstChild("HumanoidRootPart")
    if not myChar or not rootPart or not targetRoot then return end
    
    local toTarget = (targetRoot.Position - rootPart.Position).Unit
    local dashDirection = -toTarget
    local dashPosition = rootPart.Position + (dashDirection * 12)
    
    pcall(function()
        local tween = TweenService:Create(rootPart, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {CFrame = CFrame.new(dashPosition, dashPosition + toTarget)})
        tween:Play()
    end)
end

-- AUTO BLOCK
local function TriggerBlock()
    if not Settings.AutoBlock then return end
    local currentTime = tick()
    if currentTime - lastBlockTime < blockCooldown then return end
    lastBlockTime = currentTime
    
    -- Cari tombol block di UI
    local function findBlockButton(parent)
        if not parent then return nil end
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("ImageButton") or child:IsA("TextButton") then
                local name = string.lower(child.Name or "")
                local text = string.lower(child.Text or "")
                if name:find("block") or name:find("guard") or name:find("defend") or
                   text:find("block") or text:find("guard") or text:find("defend") then
                    return child
                end
            end
            local found = findBlockButton(child)
            if found then return found end
        end
        return nil
    end
    
    local blockBtn = findBlockButton(LocalPlayer.PlayerGui)
    if blockBtn then
        pcall(function()
            blockBtn:Click()
        end)
    end
    
    -- Alternative: cari remote buat block
    pcall(function()
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Block")
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer()
        end
    end)
end

-- AUTO COUNTER
local function TriggerCounter()
    if not Settings.AutoCounter then return end
    local currentTime = tick()
    if currentTime - lastCounterTime < counterCooldown then return end
    lastCounterTime = currentTime
    
    -- Cari tombol counter di UI
    local function findCounterButton(parent)
        if not parent then return nil end
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("ImageButton") or child:IsA("TextButton") then
                local name = string.lower(child.Name or "")
                local text = string.lower(child.Text or "")
                if name:find("counter") or name:find("parry") or name:find("reflect") or
                   text:find("counter") or text:find("parry") or text:find("reflect") then
                    return child
                end
            end
            local found = findCounterButton(child)
            if found then return found end
        end
        return nil
    end
    
    local counterBtn = findCounterButton(LocalPlayer.PlayerGui)
    if counterBtn then
        pcall(function()
            counterBtn:Click()
        end)
    end
    
    -- Alternative: cari remote buat counter
    pcall(function()
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Counter")
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer()
        end
    end)
end

-- UPDATE SLIDER
local function UpdateSliderValue(input)
    if not RangeSlider or not RangeFill or not RangeValueLabel then return end
    
    local sliderFrame = RangeSlider.Parent
    local relativeX = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
    
    -- RANGE 5 - 500 STUDS
    local minRange = 5
    local maxRange = 500
    local rangeValue = minRange + (maxRange - minRange) * relativeX
    rangeValue = math.floor(rangeValue + 0.5)
    
    Settings.MaxDistance = rangeValue
    RangeFill.Size = UDim2.new(relativeX, 0, 1, 0)
    RangeValueLabel.Text = tostring(rangeValue) .. " studs"
end

-- CREATE SEEK BAR
local function CreateSeekBar(parent, yPos)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.9, 0, 0, 40)
    container.Position = UDim2.new(0.05, 0, yPos, 0)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "🔍 Lock Range:"
    label.TextColor3 = Color3.fromRGB(200, 200, 255)
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    RangeValueLabel = Instance.new("TextLabel")
    RangeValueLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
    RangeValueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    RangeValueLabel.BackgroundTransparency = 1
    RangeValueLabel.Text = "150 studs"
    RangeValueLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    RangeValueLabel.TextSize = 11
    RangeValueLabel.Font = Enum.Font.GothamBold
    RangeValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    RangeValueLabel.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0.7, 0)
    sliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = sliderBg
    
    RangeFill = Instance.new("Frame")
    RangeFill.Size = UDim2.new((Settings.MaxDistance - 5) / 495, 0, 1, 0)
    RangeFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    RangeFill.BorderSizePixel = 0
    RangeFill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = RangeFill
    
    RangeSlider = Instance.new("TextButton")
    RangeSlider.Size = UDim2.new(0, 16, 0, 16)
    RangeSlider.Position = UDim2.new((Settings.MaxDistance - 5) / 495, -8, 0.7, -4)
    RangeSlider.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    RangeSlider.BorderSizePixel = 0
    RangeSlider.Text = ""
    RangeSlider.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = RangeSlider
    
    -- DRAG SLIDER
    RangeSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingSlider = true
            UpdateSliderValue(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSliderValue(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingSlider = false
        end
    end)
    
    -- UPDATE POSISI SLIDER KETIKA RANGE BERUBAH
    local function updateSliderPosition()
        if RangeSlider and RangeFill then
            local t = (Settings.MaxDistance - 5) / 495
            RangeSlider.Position = UDim2.new(t, -8, 0.7, -4)
            RangeFill.Size = UDim2.new(t, 0, 1, 0)
            if RangeValueLabel then
                RangeValueLabel.Text = tostring(Settings.MaxDistance) .. " studs"
            end
        end
    end
    
    -- HOOK UPDATE
    local oldMaxDistance = Settings.MaxDistance
    return updateSliderPosition
end

-- DETECT ENEMY ATTACK (buat auto block & counter)
local function DetectEnemyAttack()
    task.spawn(function()
        while task.wait(0.05) do
            if Settings.AutoBlock or Settings.AutoCounter then
                local myChar = LocalPlayer.Character
                if myChar and CurrentTarget and IsAlive(CurrentTarget) then
                    -- Cek apakah target sedang attack (dari animasi)
                    local humanoid = CurrentTarget:FindFirstChild("Humanoid")
                    if humanoid and humanoid:GetPlayingAnimationTracks() then
                        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                            local animName = track.Animation and track.Animation.AnimationId or ""
                            if animName:find("attack") or animName:find("punch") or animName:find("slash") then
                                if Settings.AutoBlock then
                                    TriggerBlock()
                                end
                                if Settings.AutoCounter then
                                    task.wait(Settings.CounterDelay)
                                    TriggerCounter()
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- BUAT UI
local function CreateUI()
    local container = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "CendolHubV2"
    MainFrame.Size = UDim2.new(0, 240, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -120, 0.02, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    MainFrame.ZIndex = 10
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = MainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 20, 0)
    title.BackgroundTransparency = 0.3
    title.Text = "⚡ CENDOL HUB V2 ⚡"
    title.TextColor3 = Color3.fromRGB(0, 255, 0)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.ZIndex = 10
    title.Parent = MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title
    
    -- LOCK ON BUTTON
    local LockButton = Instance.new("TextButton")
    LockButton.Size = UDim2.new(0, 100, 0, 35)
    LockButton.Position = UDim2.new(0.5, -105, 0, 45)
    LockButton.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    LockButton.BackgroundTransparency = 0.2
    LockButton.Text = "🔒 LOCK OFF"
    LockButton.TextColor3 = Color3.fromRGB(200, 200, 255)
    LockButton.TextSize = 12
    LockButton.Font = Enum.Font.GothamBold
    LockButton.BorderSizePixel = 0
    LockButton.ZIndex = 10
    
    local lockCorner = Instance.new("UICorner")
    lockCorner.CornerRadius = UDim.new(0, 8)
    lockCorner.Parent = LockButton
    
    LockButton.Parent = MainFrame
    
    -- DASH BUTTON
    local DashButton = Instance.new("TextButton")
    DashButton.Size = UDim2.new(0, 100, 0, 35)
    DashButton.Position = UDim2.new(0.5, 5, 0, 45)
    DashButton.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    DashButton.BackgroundTransparency = 0.2
    DashButton.Text = "💨 DASH OFF"
    DashButton.TextColor3 = Color3.fromRGB(200, 200, 255)
    DashButton.TextSize = 12
    DashButton.Font = Enum.Font.GothamBold
    DashButton.BorderSizePixel = 0
    DashButton.ZIndex = 10
    
    local dashCorner = Instance.new("UICorner")
    dashCorner.CornerRadius = UDim.new(0, 8)
    dashCorner.Parent = DashButton
    
    DashButton.Parent = MainFrame
    
    -- AUTO BLOCK BUTTON
    local BlockButton = Instance.new("TextButton")
    BlockButton.Size = UDim2.new(0, 100, 0, 35)
    BlockButton.Position = UDim2.new(0.5, -105, 0, 90)
    BlockButton.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    BlockButton.BackgroundTransparency = 0.2
    BlockButton.Text = "🛡️ BLOCK OFF"
    BlockButton.TextColor3 = Color3.fromRGB(200, 200, 255)
    BlockButton.TextSize = 12
    BlockButton.Font = Enum.Font.GothamBold
    BlockButton.BorderSizePixel = 0
    BlockButton.ZIndex = 10
    
    local blockCorner = Instance.new("UICorner")
    blockCorner.CornerRadius = UDim.new(0, 8)
    blockCorner.Parent = BlockButton
    
    BlockButton.Parent = MainFrame
    
    -- AUTO COUNTER BUTTON
    local CounterButton = Instance.new("TextButton")
    CounterButton.Size = UDim2.new(0, 100, 0, 35)
    CounterButton.Position = UDim2.new(0.5, 5, 0, 90)
    CounterButton.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    CounterButton.BackgroundTransparency = 0.2
    CounterButton.Text = "⚔️ COUNTER OFF"
    CounterButton.TextColor3 = Color3.fromRGB(200, 200, 255)
    CounterButton.TextSize = 12
    CounterButton.Font = Enum.Font.GothamBold
    CounterButton.BorderSizePixel = 0
    CounterButton.ZIndex = 10
    
    local counterCorner = Instance.new("UICorner")
    counterCorner.CornerRadius = UDim.new(0, 8)
    counterCorner.Parent = CounterButton
    
    CounterButton.Parent = MainFrame
    
    -- SEEK BAR RANGE (5 - 500 studs)
    local updateSlider = CreateSeekBar(MainFrame, 0.5)
    
    -- MINIMIZE BUTTON
    local MinButton = Instance.new("TextButton")
    MinButton.Size = UDim2.new(0, 30, 0, 30)
    MinButton.Position = UDim2.new(1, -35, 0, 5)
    MinButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MinButton.BackgroundTransparency = 0.3
    MinButton.Text = "−"
    MinButton.TextColor3 = Color3.fromRGB(0, 255, 0)
    MinButton.TextSize = 18
    MinButton.Font = Enum.Font.GothamBold
    MinButton.BorderSizePixel = 0
    MinButton.ZIndex = 10
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = MinButton
    
    local minimized = false
    MinButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            LockButton.Visible = false
            DashButton.Visible = false
            BlockButton.Visible = false
            CounterButton.Visible = false
            MainFrame.Size = UDim2.new(0, 240, 0, 45)
            MinButton.Text = "□"
        else
            LockButton.Visible = true
            DashButton.Visible = true
            BlockButton.Visible = true
            CounterButton.Visible = true
            MainFrame.Size = UDim2.new(0, 240, 0, 280)
            MinButton.Text = "−"
        end
    end)
    
    MinButton.Parent = MainFrame
    
    -- DRAG MOVE
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- BUTTON LOGIC
    LockButton.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        if Settings.Enabled then
            local newTarget = GetClosestTarget()
            if newTarget then
                CurrentTarget = newTarget
                TargetPart = GetBestHitbox(CurrentTarget)
            end
            LockButton.Text = "🔒 LOCK ON"
            LockButton.TextColor3 = Color3.fromRGB(0, 255, 0)
            LockButton.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
        else
            CurrentTarget = nil
            TargetPart = nil
            LockButton.Text = "🔒 LOCK OFF"
            LockButton.TextColor3 = Color3.fromRGB(200, 200, 255)
            LockButton.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        end
    end)
    
    DashButton.MouseButton1Click:Connect(function()
        Settings.SideDashEnabled = not Settings.SideDashEnabled
        if Settings.SideDashEnabled then
            DashButton.Text = "💨 DASH ON"
            DashButton.TextColor3 = Color3.fromRGB(0, 255, 0)
            DashButton.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
        else
            DashButton.Text = "💨 DASH OFF"
            DashButton.TextColor3 = Color3.fromRGB(200, 200, 255)
            DashButton.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        end
    end)
    
    BlockButton.MouseButton1Click:Connect(function()
        Settings.AutoBlock = not Settings.AutoBlock
        if Settings.AutoBlock then
            BlockButton.Text = "🛡️ BLOCK ON"
            BlockButton.TextColor3 = Color3.fromRGB(0, 255, 0)
            BlockButton.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
        else
            BlockButton.Text = "🛡️ BLOCK OFF"
            BlockButton.TextColor3 = Color3.fromRGB(200, 200, 255)
            BlockButton.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        end
    end)
    
    CounterButton.MouseButton1Click:Connect(function()
        Settings.AutoCounter = not Settings.AutoCounter
        if Settings.AutoCounter then
            CounterButton.Text = "⚔️ COUNTER ON"
            CounterButton.TextColor3 = Color3.fromRGB(0, 255, 0)
            CounterButton.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
        else
            CounterButton.Text = "⚔️ COUNTER OFF"
            CounterButton.TextColor3 = Color3.fromRGB(200, 200, 255)
            CounterButton.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        end
    end)
    
    MainFrame.Parent = container
    
    -- INDICATOR CIRCLE
    local indicator = Instance.new("Frame")
    indicator.Name = "LockIndicator"
    indicator.Size = UDim2.new(0, 60, 0, 60)
    indicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    indicator.BackgroundTransparency = 0.7
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.ZIndex = 20
    
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator
    
    local indStroke = Instance.new("UIStroke")
    indStroke.Color = Color3.fromRGB(0, 255, 0)
    indStroke.Thickness = 3
    indStroke.Transparency = 0.3
    indStroke.Parent = indicator
    
    indicator.Parent = container
    
    RunService.RenderStepped:Connect(function()
        if Settings.Enabled and CurrentTarget and TargetPart and TargetPart.Parent then
            indicator.Visible = true
            local pos, onScreen = Camera:WorldToViewportPoint(TargetPart.Position + Vector3.new(0, 1.5, 0))
            if onScreen then
                indicator.Position = UDim2.new(0, pos.X - 30, 0, pos.Y - 30)
                local distance = (Camera.CFrame.Position - TargetPart.Position).Magnitude
                local size = math.clamp(80 - distance / 5, 25, 80)
                indicator.Size = UDim2.new(0, size, 0, size)
            else
                indicator.Visible = false
            end
        else
            indicator.Visible = false
        end
    end)
    
    return LockButton
end

-- HOOK NATIVE DASH
local function HookNativeDash()
    task.wait(3)
    local function findDashButton(parent)
        if not parent then return nil end
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("ImageButton") or child:IsA("TextButton") then
                local name = string.lower(child.Name or "")
                local text = string.lower(child.Text or "")
                if name:find("dash") or name:find("evade") or name:find("roll") or
                   text:find("dash") or text:find("evade") then
                    return child
                end
            end
            local found = findDashButton(child)
            if found then return found end
        end
        return nil
    end
    
    for i = 1, 10 do
        task.wait(0.5)
        local dashBtn = findDashButton(LocalPlayer.PlayerGui)
        if dashBtn then
            dashBtn.MouseButton1Click:Connect(function()
                if Settings.SideDashEnabled then
                    task.spawn(function() SideDash180() end)
                end
            end)
            break
        end
    end
end

-- MAIN LOOP
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
        if CurrentTarget and TargetPart and TargetPart.Parent then
            if Settings.RotateCamera then
                local targetPos = TargetPart.Position + Settings.CameraOffset
                local currentCFrame = Camera.CFrame
                local desiredCFrame = CFrame.new(currentCFrame.Position, targetPos)
                Camera.CFrame = currentCFrame:Lerp(desiredCFrame, Settings.CameraSmoothness)
            end
        end
        RotateToTarget()
    end
end)

-- INIT
spawn(function()
    wait(1)
    CreateUI()
    HookNativeDash()
    DetectEnemyAttack()
    print("✅ CENDOL HUB V2 - FULL VERSION READY!")
    print("✅ RANGE SLIDER: 5 - 500 STUDS!")
    print("✅ Auto Block + Auto Counter + Dash 180°")
    print("✅ Lock On + Indicator")
    print("✅ Geser slider buat ngatur jarak lock-on!")
end)
]]
