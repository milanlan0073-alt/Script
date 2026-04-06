-- ARCHITECT 03 - JUJUTSU SHENANIGANS (ANDROID EDITION)
-- FITUR: Lock-On, Auto-Block, ESP, Fly, MINIMIZE/MAXIMIZE

local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local tweenService = game:GetService("TweenService")

-- =========== VARIABLES ===========
local lockOnTarget = nil
local characterLockActive = false
local cameraRotateActive = false
local autoBlockActive = false
local visualIndicator = nil
local isMinimized = false

-- =========== FUNGSI LOCK-ON ===========
local function getClosestPlayer()
    local closest = nil
    local closestDist = math.huge
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (v.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < closestDist and dist < 70 then
                closestDist = dist
                closest = v
            end
        end
    end
    return closest
end

local function getNextTarget()
    local players = game:GetService("Players"):GetPlayers()
    local targets = {}
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    for _, v in pairs(players) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (v.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            table.insert(targets, {player = v, dist = dist})
        end
    end
    
    table.sort(targets, function(a, b) return a.dist < b.dist end)
    if #targets > 0 then
        return targets[1].player
    end
    return nil
end

local function createVisualIndicator(target)
    destroyVisualIndicator()
    if not target or not target.Character then return end
    
    local circle = Instance.new("CircleHandleAdornment")
    circle.Name = "LockOnIndicator"
    circle.Radius = 3
    circle.Color3 = Color3.fromRGB(255, 50, 80)
    circle.Thickness = 5
    circle.Transparency = 0.3
    circle.AlwaysOnTop = true
    circle.Adornee = target.Character:FindFirstChild("HumanoidRootPart")
    circle.Parent = target.Character
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "LockOnArrow"
    billboard.Adornee = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = target.Character
    
    local arrow = Instance.new("TextLabel")
    arrow.Parent = billboard
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(255, 50, 80)
    arrow.TextSize = 30
    arrow.Font = Enum.Font.GothamBold
    arrow.Size = UDim2.new(1, 0, 1, 0)
    
    visualIndicator = {circle, billboard}
end

local function destroyVisualIndicator()
    if visualIndicator then
        for _, obj in pairs(visualIndicator) do
            pcall(function() obj:Destroy() end)
        end
        visualIndicator = nil
    end
end

local function updateCharacterLock()
    if not characterLockActive or not lockOnTarget then return end
    if not lockOnTarget.Character or not lockOnTarget.Character:FindFirstChild("HumanoidRootPart") then
        lockOnTarget = getNextTarget()
        if not lockOnTarget then
            characterLockActive = false
            cameraRotateActive = false
            destroyVisualIndicator()
            return
        else
            createVisualIndicator(lockOnTarget)
        end
        return
    end
    
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local targetHrp = lockOnTarget.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetHrp then return end
    
    local direction = (targetHrp.Position - hrp.Position).Unit
    local targetAngle = math.atan2(direction.X, direction.Z)
    hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, targetAngle, 0)
    
    if cameraRotateActive then
        local newCameraCFrame = CFrame.new(camera.CFrame.Position, targetHrp.Position)
        camera.CFrame = camera.CFrame:Lerp(newCameraCFrame, 0.25)
    end
end

-- =========== AUTO-BLOCK ===========
local blockCooldown = false
local function isBeingAttacked()
    if not player.Character then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    local health = humanoid.Health
    task.wait(0.03)
    if humanoid.Health < health then
        return true
    end
    
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v ~= player and v.Character then
            local animator = v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid:FindFirstChild("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    local trackName = track.Name:lower()
                    if trackName:find("attack") or trackName:find("hit") or trackName:find("combo") then
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        local targetHrp = v.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and targetHrp and (hrp.Position - targetHrp.Position).Magnitude < 12 then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

local function autoBlock()
    if not autoBlockActive or blockCooldown then return end
    if isBeingAttacked() then
        blockCooldown = true
        pcall(function()
            local VirtualInput = game:GetService("VirtualInputManager")
            if VirtualInput then
                VirtualInput:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait(0.05)
                VirtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end
        end)
        task.wait(0.3)
        blockCooldown = false
    end
end

-- =========== UI LIBRARY DENGAN MINIMIZE/MAXIMIZE ===========
local mainGui, mainFrame, tabContainer, contentContainer, minimizeBtn
local originalSize, originalPosition

function CreateUI()
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "JJK_Android_Full"
    mainGui.Parent = game:GetService("CoreGui")
    mainGui.Enabled = true
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local screenSize = workspace.CurrentCamera.ViewportSize
    local frameWidth = math.min(650, screenSize.X - 40)
    local frameHeight = math.min(500, screenSize.Y - 60)
    
    originalSize = UDim2.new(0, frameWidth, 0, frameHeight)
    originalPosition = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
    
    -- MAIN FRAME
    mainFrame = Instance.new("Frame")
    mainFrame.Parent = mainGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderColor3 = Color3.fromRGB(100, 70, 180)
    mainFrame.BorderSizePixel = 1
    mainFrame.ClipsDescendants = true
    mainFrame.Position = originalPosition
    mainFrame.Size = originalSize
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- HEADER
    local header = Instance.new("Frame")
    header.Parent = mainFrame
    header.BackgroundColor3 = Color3.fromRGB(30, 25, 55)
    header.Size = UDim2.new(1, 0, 0, 55)
    header.Position = UDim2.new(0, 0, 0, 0)
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = header
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "JJK Shenanigans — Architect 03"
    titleLabel.TextColor3 = Color3.fromRGB(200, 170, 255)
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Position = UDim2.new(0, 12, 0.5, -12)
    titleLabel.Size = UDim2.new(0, 280, 0, 28)
    
    -- MINIMIZE BUTTON (Tombol minus/garis)
    minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Parent = header
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
    minimizeBtn.BackgroundTransparency = 0.2
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 24
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Position = UDim2.new(1, -95, 0.5, -18)
    minimizeBtn.Size = UDim2.new(0, 36, 0, 36)
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(1, 0)
    minCorner.Parent = minimizeBtn
    
    -- CLOSE BUTTON
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = header
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 70)
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 22
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Position = UDim2.new(1, -48, 0.5, -18)
    closeBtn.Size = UDim2.new(0, 36, 0, 36)
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn
    closeBtn.MouseButton1Click:Connect(function()
        mainGui.Enabled = false
    end)
    
    -- TAB CONTAINER
    tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Parent = mainFrame
    tabContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
    tabContainer.BackgroundTransparency = 0
    tabContainer.Size = UDim2.new(0, 130, 1, -55)
    tabContainer.Position = UDim2.new(0, 0, 0, 55)
    tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContainer.ScrollBarThickness = 3
    
    local tabList = Instance.new("UIListLayout")
    tabList.Parent = tabContainer
    tabList.Padding = UDim.new(0, 8)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    
    tabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, tabList.AbsoluteContentSize.Y + 10)
    end)
    
    -- CONTENT CONTAINER
    contentContainer = Instance.new("Frame")
    contentContainer.Parent = mainFrame
    contentContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    contentContainer.BackgroundTransparency = 0
    contentContainer.Size = UDim2.new(1, -145, 1, -65)
    contentContainer.Position = UDim2.new(0, 135, 0, 60)
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentContainer
    
    -- FLOATING BUTTON (muncul pas minimize)
    local floatingBtn = Instance.new("TextButton")
    floatingBtn.Parent = mainGui
    floatingBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 180)
    floatingBtn.Text = "🪄"
    floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatingBtn.TextSize = 28
    floatingBtn.Font = Enum.Font.GothamBold
    floatingBtn.Position = UDim2.new(0.85, 0, 0.85, 0)
    floatingBtn.Size = UDim2.new(0, 55, 0, 55)
    floatingBtn.Visible = false
    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(1, 0)
    floatCorner.Parent = floatingBtn
    
    -- DRAG untuk floating button
    local floatDrag = false
    local floatDragStart = nil
    floatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            floatDrag = true
            floatDragStart = input.Position
        end
    end)
    userInput.InputChanged:Connect(function(input)
        if floatDrag and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - floatDragStart
            local newPos = floatingBtn.Position + UDim2.new(0, delta.X, 0, delta.Y)
            floatingBtn.Position = newPos
            floatDragStart = input.Position
        end
    end)
    userInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            floatDrag = false
        end
    end)
    
    -- FUNGSI MINIMIZE/MAXIMIZE
    local function minimizeWindow()
        if isMinimized then return end
        isMinimized = true
        
        -- Sembunyikan konten
        tabContainer.Visible = false
        contentContainer.Visible = false
        
        -- Kecilkan frame jadi cuma header
        local targetSize = UDim2.new(0, 200, 0, 55)
        local targetPos = UDim2.new(1, -210, 0.85, 0)
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local sizeTween = tweenService:Create(mainFrame, tweenInfo, {Size = targetSize, Position = targetPos})
        sizeTween:Play()
        
        -- Ubah tombol minimize jadi maximize (+)
        minimizeBtn.Text = "+"
        
        -- Tampilkan floating button
        floatingBtn.Visible = true
    end
    
    local function maximizeWindow()
        if not isMinimized then return end
        isMinimized = false
        
        -- Tampilkan konten
        tabContainer.Visible = true
        contentContainer.Visible = true
        
        -- Kembalikan ke ukuran semula
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local sizeTween = tweenService:Create(mainFrame, tweenInfo, {Size = originalSize, Position = originalPosition})
        sizeTween:Play()
        
        -- Ubah tombol kembali jadi minus
        minimizeBtn.Text = "−"
        
        -- Sembunyikan floating button
        floatingBtn.Visible = false
    end
    
    -- Tombol minimize
    minimizeBtn.MouseButton1Click:Connect(function()
        if isMinimized then
            maximizeWindow()
        else
            minimizeWindow()
        end
    end)
    
    -- Floating button buat maximize
    floatingBtn.MouseButton1Click:Connect(function()
        maximizeWindow()
    end)
    
    -- DRAG WINDOW (cuma bisa kalo gak minimized)
    local dragging = false
    local dragStart = nil
    local frameStart = nil
    
    header.InputBegan:Connect(function(input)
        if isMinimized then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = mainFrame.Position
        end
    end)
    
    userInput.InputChanged:Connect(function(input)
        if dragging and not isMinimized and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
            -- Update original position juga
            originalPosition = mainFrame.Position
        end
    end)
    
    userInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return {tabContainer = tabContainer, contentContainer = contentContainer, mainFrame = mainFrame}
end

-- =========== MEMBUAT TAB ===========
local ui = CreateUI()
local tabs = {}
local currentContent = nil

function CreateTab(tabName)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Parent = ui.tabContainer
    tabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    tabBtn.Text = tabName
    tabBtn.TextColor3 = Color3.fromRGB(190, 190, 210)
    tabBtn.TextSize = 13
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.Size = UDim2.new(1, -10, 0, 45)
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabBtn
    
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Parent = ui.contentContainer
    contentFrame.BackgroundTransparency = 1
    contentFrame.Size = UDim2.new(1, -15, 1, -15)
    contentFrame.Position = UDim2.new(0, 8, 0, 8)
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.ScrollBarThickness = 4
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 70, 180)
    contentFrame.Visible = (#tabs == 0)
    
    local list = Instance.new("UIListLayout")
    list.Parent = contentFrame
    list.Padding = UDim.new(0, 15)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function updateCanvas()
        task.wait()
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 30)
    end
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    updateCanvas()
    
    table.insert(tabs, {btn = tabBtn, content = contentFrame, list = list})
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(tabs) do
            v.content.Visible = false
            v.btn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
            v.btn.TextColor3 = Color3.fromRGB(190, 190, 210)
        end
        contentFrame.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 180)
        tabBtn.TextColor3 = Color3.fromRGB(255, 230, 255)
        updateCanvas()
    end)
    
    if #tabs == 1 then
        tabBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 180)
        tabBtn.TextColor3 = Color3.fromRGB(255, 230, 255)
    end
    
    local function addButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Parent = contentFrame
        btn.BackgroundColor3 = Color3.fromRGB(55, 45, 85)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(240, 235, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.Size = UDim2.new(1, -10, 0, 45)
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            callback()
            local orig = btn.BackgroundColor3
            btn.BackgroundColor3 = Color3.fromRGB(150, 100, 250)
            task.wait(0.08)
            btn.BackgroundColor3 = orig
        end)
        
        updateCanvas()
        return btn
    end
    
    local function addToggle(text, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Parent = contentFrame
        toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        toggleFrame.Size = UDim2.new(1, -10, 0, 50)
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 8)
        frameCorner.Parent = toggleFrame
        
        local label = Instance.new("TextLabel")
        label.Parent = toggleFrame
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 195, 230)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.Position = UDim2.new(0, 12, 0.5, -10)
        label.Size = UDim2.new(0, 240, 0, 26)
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Parent = toggleFrame
        toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 60, 100)
        toggleBtn.Text = ""
        toggleBtn.Size = UDim2.new(0, 55, 0, 34)
        toggleBtn.Position = UDim2.new(1, -65, 0.5, -17)
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1, 0)
        toggleCorner.Parent = toggleBtn
        
        local indicator = Instance.new("Frame")
        indicator.Parent = toggleBtn
        indicator.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
        indicator.Size = UDim2.new(0, 26, 0, 26)
        indicator.Position = UDim2.new(0, 4, 0.5, -13)
        local indCorner = Instance.new("UICorner")
        indCorner.CornerRadius = UDim.new(1, 0)
        indCorner.Parent = indicator
        
        local toggled = false
        toggleBtn.MouseButton1Click:Connect(function()
            toggled = not toggled
            if toggled then
                toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 80, 210)
                indicator.Position = UDim2.new(1, -30, 0.5, -13)
            else
                toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 60, 100)
                indicator.Position = UDim2.new(0, 4, 0.5, -13)
            end
            callback(toggled)
        end)
        
        updateCanvas()
        return toggleBtn
    end
    
    return {
        addButton = addButton,
        addToggle = addToggle
    }
end

-- =========== MEMBUAT TAB-TAB ===========
-- TAB 1: LOCK-ON
local lockTab = CreateTab("🎯 Lock-On")
lockTab.addButton("🔒 Lock Nearest Target", function()
    lockOnTarget = getClosestPlayer()
    if lockOnTarget then
        characterLockActive = true
        createVisualIndicator(lockOnTarget)
    end
end)
lockTab.addButton("🔄 Switch Target", function()
    lockOnTarget = getNextTarget()
    if lockOnTarget then
        createVisualIndicator(lockOnTarget)
    end
end)
lockTab.addButton("❌ Clear Target", function()
    lockOnTarget = nil
    characterLockActive = false
    cameraRotateActive = false
    destroyVisualIndicator()
end)
lockTab.addToggle("🔒 Character Lock-On (Rotate)", function(state)
    characterLockActive = state
    if state and not lockOnTarget then
        lockOnTarget = getClosestPlayer()
        if lockOnTarget then createVisualIndicator(lockOnTarget) end
    elseif not state then
        destroyVisualIndicator()
    end
end)
lockTab.addToggle("📷 Camera Rotate", function(state)
    cameraRotateActive = state
end)

-- TAB 2: AUTO-BLOCK
local blockTab = CreateTab("🛡️ Block")
blockTab.addToggle("🛡️ Auto-Block", function(state)
    autoBlockActive = state
    if state then
        spawn(function()
            while autoBlockActive do
                autoBlock()
                task.wait(0.05)
            end
        end)
    end
end)

-- TAB 3: COMBAT
local combatTab = CreateTab("⚔️ Combat")
combatTab.addButton("💀 Kill All Players", function()
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Humanoid") then
            v.Character.Humanoid.Health = 0
        end
    end
end)
combatTab.addButton("🔪 Kill Locked Target", function()
    if lockOnTarget and lockOnTarget.Character and lockOnTarget.Character:FindFirstChild("Humanoid") then
        lockOnTarget.Character.Humanoid.Health = 0
    end
end)
combatTab.addButton("🔪 Kill Nearest", function()
    local closest = getClosestPlayer()
    if closest and closest.Character and closest.Character:FindFirstChild("Humanoid") then
        closest.Character.Humanoid.Health = 0
    end
end)

-- TAB 4: TELEPORT
local tpTab = CreateTab("🌀 Teleport")
tpTab.addButton("📍 Teleport to Target", function()
    if lockOnTarget and lockOnTarget.Character and lockOnTarget.Character:FindFirstChild("HumanoidRootPart") then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = lockOnTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end
end)
tpTab.addButton("👥 Bring All to Me", function()
    local myPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if myPos then
        for _, v in pairs(game:GetService("Players"):GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.CFrame = myPos.CFrame
            end
        end
    end
end)

-- TAB 5: VISUALS
local visTab = CreateTab("👁️ Visuals")
local espActive = false
visTab.addToggle("📦 ESP Box + Name", function(state)
    espActive = state
    if state then
        for _, v in pairs(game:GetService("Players"):GetPlayers()) do
            if v ~= player and v.Character then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "ESPBox"
                box.Adornee = v.Character
                box.Size = Vector3.new(4, 5, 2.5)
                box.Color3 = Color3.fromRGB(255, 80, 120)
                box.Transparency = 0.5
                box.AlwaysOnTop = true
                box.Parent = v.Character
                
                local nameTag = Instance.new("BillboardGui")
                nameTag.Name = "ESPName"
                nameTag.Adornee = v.Character
                nameTag.Size = UDim2.new(0, 200, 0, 50)
                nameTag.StudsOffset = Vector3.new(0, 2.8, 0)
                nameTag.Parent = v.Character
                
                local text = Instance.new("TextLabel")
                text.Parent = nameTag
                text.BackgroundTransparency = 1
                text.Text = v.Name
                text.TextColor3 = Color3.fromRGB(255, 200, 200)
                text.TextSize = 13
                text.Font = Enum.Font.GothamBold
                text.Size = UDim2.new(1, 0, 1, 0)
            end
        end
    else
        for _, v in pairs(game:GetService("Players"):GetPlayers()) do
            if v.Character then
                for _, obj in pairs(v.Character:GetChildren()) do
                    if obj:IsA("BoxHandleAdornment") or obj:IsA("BillboardGui") then
                        obj:Destroy()
                    end
                end
            end
        end
    end
end)

-- TAB 6: MISC
local miscTab = CreateTab("✨ Misc")
local flyState = false
local flyBV = nil
local flyCon = nil

miscTab.addToggle("🕊️ Fly Mode", function(state)
    flyState = state
    if state then
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            flyBV.Velocity = Vector3.new(0, 0, 0)
            flyBV.Parent = hrp
            
            flyCon = runService.RenderStepped:Connect(function()
                if not flyState or not player.Character then return end
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp or not flyBV or flyBV.Parent ~= hrp then return end
                
                local moveDir = Vector3.new()
                if userInput:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
                if userInput:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
                if userInput:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
                if userInput:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
                if userInput:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if userInput:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                
                if moveDir.Magnitude > 0 then
                    flyBV.Velocity = moveDir.Unit * 60
                else
                    flyBV.Velocity = Vector3.new(0, 0, 0)
                end
                hrp.CanCollide = false
            end)
        end
    else
        if flyCon then flyCon:Disconnect() end
        if flyBV then flyBV:Destroy() end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CanCollide = true
        end
    end
end)

miscTab.addButton("📜 Load Infinite Yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

miscTab.addButton("🔄 Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end)

-- =========== RUN LOOP ===========
runService.RenderStepped:Connect(function()
    updateCharacterLock()
end)

-- Toggle UI dengan Volume Down
userInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.VolumeDown then
        if isMinimized then
            -- Kalo minimized, maximize dulu
            local oldMinimized = isMinimized
            if isMinimized then
                maximizeWindow()
                task.wait(0.2)
            end
            mainGui.Enabled = not mainGui.Enabled
            if oldMinimized and not mainGui.Enabled then
                -- kalo tadi minimized trus dimatiin, floating btn juga matiin
                floatingBtn.Visible = false
            elseif not mainGui.Enabled then
                floatingBtn.Visible = false
            elseif isMinimized then
                floatingBtn.Visible = true
            end
        else
            mainGui.Enabled = not mainGui.Enabled
            if mainGui.Enabled and isMinimized then
                floatingBtn.Visible = true
            elseif not mainGui.Enabled then
                floatingBtn.Visible = false
            end
        end
    end
end)

-- Handle player added/removed for ESP
game:GetService("Players").PlayerAdded:Connect(function(newPlayer)
    if espActive then
        task.wait(0.5)
        if newPlayer ~= player and newPlayer.Character then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "ESPBox"
            box.Adornee = newPlayer.Character
            box.Size = Vector3.new(4, 5, 2.5)
            box.Color3 = Color3.fromRGB(255, 80, 120)
            box.Transparency = 0.5
            box.AlwaysOnTop = true
            box.Parent = newPlayer.Character
            
            local nameTag = Instance.new("BillboardGui")
            nameTag.Name = "ESPName"
            nameTag.Adornee = newPlayer.Character
            nameTag.Size = UDim2.new(0, 200, 0, 50)
            nameTag.StudsOffset = Vector3.new(0, 2.8, 0)
            nameTag.Parent = newPlayer.Character
            
            local text = Instance.new("TextLabel")
            text.Parent = nameTag
            text.BackgroundTransparency = 1
            text.Text = newPlayer.Name
            text.TextColor3 = Color3.fromRGB(255, 200, 200)
            text.TextSize = 13
            text.Font = Enum.Font.GothamBold
            text.Size = UDim2.new(1, 0, 1, 0)
        end
    end
end)

game:GetService("Players").PlayerRemoving:Connect(function(leavingPlayer)
    if lockOnTarget == leavingPlayer then
        lockOnTarget = nil
        characterLockActive = false
        cameraRotateActive = false
        destroyVisualIndicator()
    end
    if espActive and leavingPlayer.Character then
        for _, obj in pairs(leavingPlayer.Character:GetChildren()) do
            if obj:IsA("BoxHandleAdornment") or obj:IsA("BillboardGui") then
                obj:Destroy()
            end
        end
    end
end)

-- Character added untuk re-apply ESP
local function onCharacterAdded(plr, char)
    if espActive and plr ~= player then
        task.wait(0.3)
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESPBox"
        box.Adornee = char
        box.Size = Vector3.new(4, 5, 2.5)
        box.Color3 = Color3.fromRGB(255, 80, 120)
        box.Transparency = 0.5
        box.AlwaysOnTop = true
        box.Parent = char
        
        local nameTag = Instance.new("BillboardGui")
        nameTag.Name = "ESPName"
        nameTag.Adornee = char
        nameTag.Size = UDim2.new(0, 200, 0, 50)
        nameTag.StudsOffset = Vector3.new(0, 2.8, 0)
        nameTag.Parent = char
        
        local text = Instance.new("TextLabel")
        text.Parent = nameTag
        text.BackgroundTransparency = 1
        text.Text = plr.Name
        text.TextColor3 = Color3.fromRGB(255, 200, 200)
        text.TextSize = 13
        text.Font = Enum.Font.GothamBold
        text.Size = UDim2.new(1, 0, 1, 0)
    end
end

game:GetService("Players").PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char) onCharacterAdded(plr, char) end)
end)

-- Re-apply for existing players' characters
for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
    if plr ~= player and plr.Character then
        onCharacterAdded(plr, plr.Character)
    end
    plr.CharacterAdded:Connect(function(char) onCharacterAdded(plr, char) end)
end

-- Auto-unlock when target dies
runService.RenderStepped:Connect(function()
    if lockOnTarget and lockOnTarget.Character and lockOnTarget.Character:FindFirstChild("Humanoid") then
        if lockOnTarget.Character.Humanoid.Health <= 0 then
            lockOnTarget = getNextTarget()
            if lockOnTarget then
                createVisualIndicator(lockOnTarget)
            else
                characterLockActive = false
                cameraRotateActive = false
                destroyVisualIndicator()
            end
        end
    end
end)

print("✅ JJK Shenanigans — Architect 03 Edition LOADED")
print("🎮 Volume Down = Hide/Show UI")
print("📱 Minimize button = − untuk kecilin UI")
print("🪄 Floating button muncul kalo diminimize")
