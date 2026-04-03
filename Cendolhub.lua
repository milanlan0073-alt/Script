-- CENDOL HUB V2 - BLACK FLASH AFTER DASH
-- JUJUTSU SHENANIGANS OPTIMIZED
-- BY ARCHITECT 03

loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local CoreGui = game:GetService("CoreGui")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Settings = {
    Enabled = false,
    LockPlayer = true,
    LockNPC = true,
    CameraSmoothness = 0.3,
    BodyRotate = true,
    MaxDistance = 250,
    CameraOffset = Vector3.new(0, 1.5, 0),
    SideDashEnabled = false,
    RotateCamera = true,
    Minimized = false,
    BlackFlashAfterDash = true  -- <-- FITUR BARU KONTOL!
}

local CurrentTarget = nil
local TargetPart = nil
local LockOnButton = nil
local DashButton = nil
local BlackFlashButton = nil
local MinimizeButton = nil
local MainFrame = nil
local isMinimizing = false
local lastDashTime = 0
local dashCooldown = 0.5

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
                        table.insert(targets, {char = c, dist = GetDistance(r, myPos), isPlayer = true})
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
                    table.insert(targets, {char = obj, dist = GetDistance(r, myPos), isPlayer = false})
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
    local targetRoot = CurrentTarget:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return end
    local direction = (targetRoot.Position - myRoot.Position).Unit
    local lookAt = CFrame.new(myRoot.Position, myRoot.Position + direction)
    pcall(function()
        myChar:SetPrimaryPartCFrame(lookAt)
    end)
end

-- TRIGGER BLACK FLASH - MULTI METHOD
local function TriggerBlackFlash()
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    
    local success = false
    
    -- METHOD 1: Cari remote event di karakter
    local remotesToTry = {
        "BlackFlash", "BlackFlashEvent", "CriticalHit", "SpecialMove",
        "M1", "Attack", "Punch", "HeavyAttack", "Skill", "Domain"
    }
    
    for _, rName in ipairs(remotesToTry) do
        -- Cek di karakter
        local remote = myChar:FindFirstChild(rName)
        if remote and remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer("BlackFlash")
                success = true
            end)
            if success then break end
        end
        
        -- Cek di ReplicatedStorage
        local remote2 = game:GetService("ReplicatedStorage"):FindFirstChild(rName)
        if remote2 and remote2:IsA("RemoteEvent") then
            pcall(function()
                remote2:FireServer("BlackFlash")
                success = true
            end)
            if success then break end
        end
        
        -- Cek di Players
        local remote3 = game:GetService("Players"):FindFirstChild(rName)
        if remote3 and remote3:IsA("RemoteEvent") then
            pcall(function()
                remote3:FireServer("BlackFlash")
                success = true
            end)
            if success then break end
        end
    end
    
    -- METHOD 2: Simulate M1 click (buat game tertentu)
    if not success then
        pcall(function()
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(0,0))
            success = true
        end)
    end
    
    -- METHOD 3: Pake BindableEvent
    if not success then
        for _, rName in ipairs(remotesToTry) do
            local remote = myChar:FindFirstChild(rName)
            if remote and remote:IsA("BindableEvent") then
                pcall(function()
                    remote:Fire("BlackFlash")
                    success = true
                end)
                if success then break end
            end
        end
    end
    
    return success
end

-- BLACK FLASH EFFECT VISUAL (simulasi)
local function ShowBlackFlashEffect()
    pcall(function()
        local effect = Instance.new("Part")
        effect.Size = Vector3.new(5, 5, 5)
        effect.Shape = Enum.PartType.Ball
        effect.BrickColor = BrickColor.new("Bright red")
        effect.Material = Enum.Material.Neon
        effect.CanCollide = false
        effect.Anchored = true
        effect.Position = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position) or Vector3.new(0,0,0)
        effect.Parent = workspace
        
        local tween = TweenService:Create(effect, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {Size = Vector3.new(15, 15, 15), Transparency = 1})
        tween:Play()
        tween.Completed:Connect(function()
            effect:Destroy()
        end)
    end)
end

-- DASH 180° + BLACK FLASH
local function SideDash180WithBlackFlash()
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
    
    -- EFEK DASH
    pcall(function()
        local dashEffect = Instance.new("Part")
        dashEffect.Size = Vector3.new(2, 2, 2)
        dashEffect.BrickColor = BrickColor.new("White")
        dashEffect.Material = Enum.Material.Neon
        dashEffect.CanCollide = false
        dashEffect.Anchored = true
        dashEffect.Position = rootPart.Position
        dashEffect.Parent = workspace
        TweenService:Create(dashEffect, TweenInfo.new(0.2), {Transparency = 1, Size = Vector3.new(8, 8, 8)}):Play()
        game:GetService("Debris"):AddItem(dashEffect, 0.3)
    end)
    
    -- GERAK DASH
    pcall(function()
        local tween = TweenService:Create(rootPart, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {CFrame = CFrame.new(dashPosition, dashPosition + toTarget)})
        tween:Play()
        
        -- BLACK FLASH SETELAH DASH SELESAI
        tween.Completed:Connect(function()
            -- Efek visual dulu
            ShowBlackFlashEffect()
            
            -- Trigger black flash MULTIPLE TIMES biar pasti kena
            for i = 1, 3 do
                task.wait(0.05)
                TriggerBlackFlash()
            end
            
            -- Tambah efek suara visual
            pcall(function()
                local flashPart = Instance.new("Part")
                flashPart.Size = Vector3.new(10, 10, 10)
                flashPart.BrickColor = BrickColor.new("Really red")
                flashPart.Material = Enum.Material.Neon
                flashPart.CanCollide = false
                flashPart.Anchored = true
                flashPart.Position = targetRoot.Position
                flashPart.Parent = workspace
                TweenService:Create(flashPart, TweenInfo.new(0.2), {Transparency = 1}):Play()
                game:GetService("Debris"):AddItem(flashPart, 0.3)
            end)
        end)
    end)
end

-- BUAT UI
local function CreateUI()
    local container = pcall(function() return CoreGui end) and CoreGui or PlayerGui
    
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "CendolHubV2"
    MainFrame.Size = UDim2.new(0, 260, 0, 45)
    MainFrame.Position = UDim2.new(0.5, -130, 0.02, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    MainFrame.BackgroundTransparency = 0.85
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    MainFrame.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = MainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.05, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ CENDOL HUB V2 | BLACK FLASH ⚡"
    title.TextColor3 = Color3.fromRGB(255, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.ZIndex = 10
    title.Parent = MainFrame
    
    -- Minimize button
    MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 28, 0, 28)
    MinimizeButton.Position = UDim2.new(1, -32, 0, 8)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MinimizeButton.BackgroundTransparency = 0.3
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 0, 0)
    MinimizeButton.TextSize = 18
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.ZIndex = 10
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = MinimizeButton
    
    MinimizeButton.MouseButton1Click:Connect(function()
        if Settings.Minimized then
            Settings.Minimized = false
            LockOnButton.Visible = true
            DashButton.Visible = true
            MinimizeButton.Text = "−"
            MainFrame.Size = UDim2.new(0, 260, 0, 45)
        else
            Settings.Minimized = true
            LockOnButton.Visible = false
            DashButton.Visible = false
            MinimizeButton.Text = "□"
            MainFrame.Size = UDim2.new(0, 260, 0, 45)
        end
    end)
    
    MinimizeButton.Parent = MainFrame
    
    -- DRAG MOVE
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    MainFrame.InputEnded:Connect(function(input)
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
    
    -- LOCK ON BUTTON
    LockOnButton = Instance.new("TextButton")
    LockOnButton.Size = UDim2.new(0, 75, 0, 35)
    LockOnButton.Position = UDim2.new(0.5, -80, 0.15, 0)
    LockOnButton.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    LockOnButton.BackgroundTransparency = 0.2
    LockOnButton.Text = "🔒 OFF"
    LockOnButton.TextColor3 = Color3.fromRGB(200, 200, 255)
    LockOnButton.TextSize = 13
    LockOnButton.Font = Enum.Font.GothamBold
    LockOnButton.BorderSizePixel = 0
    LockOnButton.ZIndex = 10
    
    local lockCorner = Instance.new("UICorner")
    lockCorner.CornerRadius = UDim.new(0, 8)
    lockCorner.Parent = LockOnButton
    
    local lockStroke = Instance.new("UIStroke")
    lockStroke.Color = Color3.fromRGB(100, 100, 255)
    lockStroke.Thickness = 2
    lockStroke.Transparency = 0.3
    lockStroke.Parent = LockOnButton
    
    LockOnButton.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        if Settings.Enabled then
            local newTarget = GetClosestTarget()
            if newTarget then
                CurrentTarget = newTarget
                TargetPart = GetBestHitbox(CurrentTarget)
            end
            LockOnButton.Text = "🔒 ON"
            LockOnButton.TextColor3 = Color3.fromRGB(255, 0, 0)
            lockStroke.Color = Color3.fromRGB(255, 0, 0)
            lockStroke.Transparency = 0
            LockOnButton.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
        else
            CurrentTarget = nil
            TargetPart = nil
            LockOnButton.Text = "🔒 OFF"
            LockOnButton.TextColor3 = Color3.fromRGB(200, 200, 255)
            lockStroke.Color = Color3.fromRGB(100, 100, 255)
            lockStroke.Transparency = 0.3
            LockOnButton.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        end
    end)
    
    LockOnButton.Parent = MainFrame
    
    -- DASH + BLACK FLASH BUTTON (TOGGLE)
    DashButton = Instance.new("TextButton")
    DashButton.Size = UDim2.new(0, 85, 0, 35)
    DashButton.Position = UDim2.new(0.5, 0, 0.15, 0)
    DashButton.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    DashButton.BackgroundTransparency = 0.2
    DashButton.Text = "⚡ DASH+BF OFF"
    DashButton.TextColor3 = Color3.fromRGB(200, 200, 255)
    DashButton.TextSize = 11
    DashButton.Font = Enum.Font.GothamBold
    DashButton.BorderSizePixel = 0
    DashButton.ZIndex = 10
    
    local dashCorner = Instance.new("UICorner")
    dashCorner.CornerRadius = UDim.new(0, 8)
    dashCorner.Parent = DashButton
    
    local dashStroke = Instance.new("UIStroke")
    dashStroke.Color = Color3.fromRGB(150, 150, 200)
    dashStroke.Thickness = 2
    dashStroke.Transparency = 0.3
    dashStroke.Parent = DashButton
    
    DashButton.MouseButton1Click:Connect(function()
        Settings.SideDashEnabled = not Settings.SideDashEnabled
        if Settings.SideDashEnabled then
            DashButton.Text = "⚡ DASH+BF ON"
            DashButton.TextColor3 = Color3.fromRGB(255, 0, 0)
            dashStroke.Color = Color3.fromRGB(255, 0, 0)
            dashStroke.Transparency = 0
            DashButton.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
        else
            DashButton.Text = "⚡ DASH+BF OFF"
            DashButton.TextColor3 = Color3.fromRGB(200, 200, 255)
            dashStroke.Color = Color3.fromRGB(150, 150, 200)
            dashStroke.Transparency = 0.3
            DashButton.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        end
    end)
    
    DashButton.Parent = MainFrame
    
    MainFrame.Parent = container
    
    -- INDICATOR CIRCLE (merah buat target)
    local indicator = Instance.new("Frame")
    indicator.Name = "LockIndicator"
    indicator.Size = UDim2.new(0, 60, 0, 60)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    indicator.BackgroundTransparency = 0.7
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.ZIndex = 20
    
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator
    
    local indStroke = Instance.new("UIStroke")
    indStroke.Color = Color3.fromRGB(255, 0, 0)
    indStroke.Thickness = 3
    indStroke.Transparency = 0.3
    indStroke.Parent = indicator
    
    indicator.Parent = container
    
    -- UPDATE INDICATOR
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
    
    return LockOnButton
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
            local oldClick = dashBtn.MouseButton1Click
            dashBtn.MouseButton1Click:Connect(function()
                if Settings.SideDashEnabled then
                    task.spawn(function() SideDash180WithBlackFlash() end)
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
    print("✅ CENDOL HUB V2 - BLACK FLASH AFTER DASH READY!")
    print("✅ DASH 180° + BLACK FLASH OTOMATIS!")
    print("✅ Efek visual merah + partikel neon")
    print("✅ Lock On + Indicator Circle")
    print("✅ Bisa di drag pake mouse")
    print("✅ COMBO: LOCK ON -> ENABLE DASH+BF -> DASH -> BLACK FLASH EXPLOSION!")
end)
]])
