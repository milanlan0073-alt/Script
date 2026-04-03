-- CENDOL HUB V2 - FULLY FIXED BY ARCHITECT 03
-- NO ERROR, NO BULLSHIT, LANGSUNG JALAN KONTOL!

loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Enabled = false,
    LockPlayer = true,
    LockNPC = true,
    CameraSmoothness = 0.25,
    BodyRotate = true,
    MaxDistance = 200,
    CameraOffset = Vector3.new(0, 2, 0),
    SideDashEnabled = false,
    RotateCamera = true,
    Minimized = false
}

local CurrentTarget = nil
local TargetPart = nil
local LockOnButton = nil
local DashButton = nil
local SpecialButton = nil
local MinimizeButton = nil
local ControlBar = nil
local MainGui = nil
local isMinimizing = false

local Hitboxes = {"Head", "UpperTorso", "HumanoidRootPart", "Torso"}

local NPCKeywords = {
    "Cursed", "Spirit", "Curse", "NPC", "Mob", "Enemy", "Boss",
    "Raid", "Demon", "Shadow", "Monster", "Dummy"
}

local function SafeTween(obj, props, duration, style, direction)
    if not obj or not TweenService then return end
    pcall(function()
        local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), props)
        tween:Play()
        return tween
    end)
end

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

    local players = {}
    local npcs = {}

    if Settings.LockPlayer then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local c = p.Character
                if c and IsAlive(c) then
                    local r = c:FindFirstChild("HumanoidRootPart")
                    if r then
                        table.insert(players, {char = c, dist = GetDistance(r, myPos)})
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
                    table.insert(npcs, {char = obj, dist = GetDistance(r, myPos)})
                end
            end
        end
    end

    table.sort(players, function(a,b) return a.dist < b.dist end)
    table.sort(npcs, function(a,b) return a.dist < b.dist end)

    if #players > 0 then
        closest = players[1].char
    elseif #npcs > 0 then
        closest = npcs[1].char
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

local function SideDash180()
    if not Settings.SideDashEnabled then return end
    if not CurrentTarget or not IsAlive(CurrentTarget) then return end
    local myChar = LocalPlayer.Character
    local humanoid = myChar and myChar:FindFirstChild("Humanoid")
    local rootPart = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = CurrentTarget and CurrentTarget:FindFirstChild("HumanoidRootPart")
    if not myChar or not humanoid or not rootPart or not targetRoot then return end
    local toTarget = (targetRoot.Position - rootPart.Position).Unit
    local dashDirection = -toTarget
    local dashPosition = rootPart.Position + (dashDirection * 15)
    SafeTween(rootPart, {CFrame = CFrame.new(dashPosition, dashPosition + toTarget)}, 0.15)
end

local function FindSpecialButton()
    for i = 1, 50 do
        task.wait(0.1)
        local playerGui = LocalPlayer.PlayerGui
        if playerGui then
            local function searchButtons(parent)
                if not parent then return nil end
                for _, child in ipairs(parent:GetChildren()) do
                    if child:IsA("ImageButton") or child:IsA("TextButton") then
                        local name = (child.Name or ""):lower()
                        local text = (child.Text or ""):lower()
                        if name:find("ult") or name:find("domain") or name:find("special") or name:find("skill") or
                           text:find("ult") or text:find("domain") or text:find("special") then
                            return child
                        end
                    end
                    local found = searchButtons(child)
                    if found then return found end
                end
                return nil
            end
            local found = searchButtons(playerGui)
            if found then return found end
        end
    end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "CendolSpecialDummy"
    sg.Parent = LocalPlayer.PlayerGui
    sg.ResetOnSpawn = false
    
    local dummy = Instance.new("ImageButton")
    dummy.Size = UDim2.new(0, 70, 0, 70)
    dummy.Position = UDim2.new(0.5, -35, 0.85, 0)
    dummy.BackgroundTransparency = 1
    dummy.Visible = false
    dummy.Parent = sg
    return dummy
end

local function MinimizeUI()
    if isMinimizing then return end
    isMinimizing = true
    Settings.Minimized = true
    
    if LockOnButton then
        SafeTween(LockOnButton, {BackgroundTransparency = 1, ImageTransparency = 1, TextTransparency = 1}, 0.2)
        SafeTween(LockOnButton, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        LockOnButton.Visible = false
    end
    if DashButton then
        SafeTween(DashButton, {BackgroundTransparency = 1, ImageTransparency = 1, TextTransparency = 1}, 0.2)
        SafeTween(DashButton, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        DashButton.Visible = false
    end
    
    if MinimizeButton then
        MinimizeButton.Text = "□"
        MinimizeButton.TextColor3 = Color3.fromRGB(0, 255, 0)
        local tooltip = MinimizeButton:FindFirstChild("Tooltip")
        if tooltip then tooltip.Text = "Maximize" end
    end
    
    task.wait(0.25)
    isMinimizing = false
end

local function MaximizeUI()
    if isMinimizing then return end
    isMinimizing = true
    Settings.Minimized = false
    
    if LockOnButton then 
        LockOnButton.Visible = true
        SafeTween(LockOnButton, {Size = UDim2.new(0, 60, 0, 60), BackgroundTransparency = 0.2, ImageTransparency = 0}, 0.2)
    end
    if DashButton then 
        DashButton.Visible = true
        SafeTween(DashButton, {Size = UDim2.new(0, 50, 0, 50), BackgroundTransparency = 0.2, ImageTransparency = 0}, 0.2)
    end
    
    if MinimizeButton then
        MinimizeButton.Text = "−"
        MinimizeButton.TextColor3 = Color3.fromRGB(255, 200, 100)
        local tooltip = MinimizeButton:FindFirstChild("Tooltip")
        if tooltip then tooltip.Text = "Minimize" end
    end
    
    if LockOnButton then
        local btnText = LockOnButton:FindFirstChild("TextLabel")
        if btnText then SafeTween(btnText, {TextTransparency = 0}, 0.15) end
    end
    if DashButton then
        local dashText = DashButton:FindFirstChild("TextLabel")
        if dashText then SafeTween(dashText, {TextTransparency = 0}, 0.15) end
    end
    
    task.wait(0.2)
    isMinimizing = false
end

local function CreateMinimizeButton(parentFrame)
    MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MinimizeButton.BackgroundTransparency = 0.3
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 200, 100)
    MinimizeButton.TextSize = 20
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.BorderSizePixel = 0
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = MinimizeButton
    
    local minStroke = Instance.new("UIStroke")
    minStroke.Color = Color3.fromRGB(255, 200, 100)
    minStroke.Thickness = 1.5
    minStroke.Transparency = 0.5
    minStroke.Parent = MinimizeButton
    
    local tooltip = Instance.new("TextLabel")
    tooltip.Size = UDim2.new(0, 60, 0, 20)
    tooltip.Position = UDim2.new(0.5, -30, 1, 5)
    tooltip.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    tooltip.BackgroundTransparency = 0.2
    tooltip.Text = "Minimize"
    tooltip.TextColor3 = Color3.fromRGB(0, 255, 0)
    tooltip.TextSize = 10
    tooltip.Font = Enum.Font.Gotham
    tooltip.Visible = false
    tooltip.Parent = MinimizeButton
    
    local tipCorner = Instance.new("UICorner")
    tipCorner.CornerRadius = UDim.new(0, 4)
    tipCorner.Parent = tooltip
    
    MinimizeButton.MouseEnter:Connect(function()
        tooltip.Visible = true
        MinimizeButton.BackgroundTransparency = 0.1
        MinimizeButton.TextColor3 = Color3.fromRGB(0, 255, 0)
    end)
    
    MinimizeButton.MouseLeave:Connect(function()
        tooltip.Visible = false
        MinimizeButton.BackgroundTransparency = 0.3
        if not Settings.Minimized then
            MinimizeButton.TextColor3 = Color3.fromRGB(255, 200, 100)
        else
            MinimizeButton.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        if Settings.Minimized then
            MaximizeUI()
        else
            MinimizeUI()
        end
    end)
    
    MinimizeButton.Parent = parentFrame
end

local function CreateLockOnButtonAboveSpecial()
    SpecialButton = FindSpecialButton()
    
    MainGui = Instance.new("ScreenGui")
    MainGui.Name = "LockOnSystem"
    MainGui.Parent = LocalPlayer.PlayerGui
    MainGui.ResetOnSpawn = false
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    ControlBar = Instance.new("Frame")
    ControlBar.Size = UDim2.new(0, 200, 0, 40)
    ControlBar.Position = UDim2.new(0.5, -100, 0.02, 0)
    ControlBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ControlBar.BackgroundTransparency = 0.7
    ControlBar.BorderSizePixel = 1
    ControlBar.BorderColor3 = Color3.fromRGB(0, 255, 0)
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 10)
    barCorner.Parent = ControlBar
    
    local barTitle = Instance.new("TextLabel")
    barTitle.Size = UDim2.new(0.7, 0, 1, 0)
    barTitle.Position = UDim2.new(0.05, 0, 0, 0)
    barTitle.BackgroundTransparency = 1
    barTitle.Text = "CENDOL HUB V2"
    barTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
    barTitle.TextXAlignment = Enum.TextXAlignment.Left
    barTitle.Font = Enum.Font.GothamBold
    barTitle.TextSize = 14
    barTitle.Parent = ControlBar
    
    CreateMinimizeButton(ControlBar)
    ControlBar.Parent = MainGui
    
    LockOnButton = Instance.new("ImageButton")
    LockOnButton.Size = UDim2.new(0, 60, 0, 60)
    LockOnButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    LockOnButton.BackgroundTransparency = 0.2
    LockOnButton.BorderSizePixel = 0
    LockOnButton.Image = "rbxassetid://3926305904"
    LockOnButton.ImageColor3 = Color3.fromRGB(200, 200, 255)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = LockOnButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 255)
    stroke.Thickness = 2.5
    stroke.Transparency = 0.3
    stroke.Parent = LockOnButton
    
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 14, 0, 14)
    statusDot.Position = UDim2.new(0, -4, 0, -4)
    statusDot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    statusDot.BorderSizePixel = 0
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = statusDot
    statusDot.Parent = LockOnButton
    
    local pulseTween = nil
    local function UpdateDotPulse(isLocked)
        if pulseTween then pcall(function() pulseTween:Cancel() end) end
        if isLocked then
            statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            pulseTween = TweenService:Create(statusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), 
                {BackgroundTransparency = 0.3})
            pulseTween:Play()
        else
            statusDot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            if pulseTween then pcall(function() pulseTween:Cancel() end) end
            statusDot.BackgroundTransparency = 0
        end
    end
    
    local btnText = Instance.new("TextLabel")
    btnText.Size = UDim2.new(1, 0, 0, 18)
    btnText.Position = UDim2.new(0, 0, 1, 5)
    btnText.BackgroundTransparency = 1
    btnText.Text = "LOCK"
    btnText.TextColor3 = Color3.fromRGB(200, 200, 255)
    btnText.TextScaled = true
    btnText.Font = Enum.Font.GothamBold
    btnText.TextSize = 12
    btnText.Parent = LockOnButton
    
    local function UpdateLockButtonPosition()
        if not LockOnButton then return end
        if SpecialButton and SpecialButton.Parent and SpecialButton.AbsoluteSize.X > 0 then
            local safeXOffset = SpecialButton.AbsolutePosition.X
            local safeYOffset = SpecialButton.AbsolutePosition.Y
            LockOnButton.Position = UDim2.new(0, safeXOffset + 5, 0, safeYOffset - 75)
            LockOnButton.Parent = SpecialButton.Parent
        else
            LockOnButton.Position = UDim2.new(0.5, -30, 0.75, 0)
            LockOnButton.Parent = MainGui
        end
    end
    
    UpdateLockButtonPosition()
    
    task.spawn(function()
        while LockOnButton and LockOnButton.Parent do
            task.wait(0.1)
            UpdateLockButtonPosition()
        end
    end)
    
    LockOnButton.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        if Settings.Enabled then
            local newTarget = GetClosestTarget()
            if newTarget then
                CurrentTarget = newTarget
                TargetPart = GetBestHitbox(CurrentTarget)
            end
            stroke.Color = Color3.fromRGB(0, 255, 0)
            stroke.Transparency = 0
            LockOnButton.ImageColor3 = Color3.fromRGB(0, 255, 0)
            btnText.Text = "LOCKED"
            btnText.TextColor3 = Color3.fromRGB(0, 255, 0)
            LockOnButton.BackgroundColor3 = Color3.fromRGB(0, 40, 0)
            UpdateDotPulse(true)
            
            local originalSize = LockOnButton.Size
            SafeTween(LockOnButton, {Size = UDim2.new(0, 65, 0, 65)}, 0.15, Enum.EasingStyle.Back)
            task.wait(0.15)
            SafeTween(LockOnButton, {Size = originalSize}, 0.1)
        else
            CurrentTarget = nil
            TargetPart = nil
            stroke.Color = Color3.fromRGB(100, 100, 255)
            stroke.Transparency = 0.3
            LockOnButton.ImageColor3 = Color3.fromRGB(200, 200, 255)
            btnText.Text = "LOCK"
            btnText.TextColor3 = Color3.fromRGB(200, 200, 255)
            LockOnButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            UpdateDotPulse(false)
        end
    end)
    
    LockOnButton.Parent = MainGui
    
    DashButton = Instance.new("ImageButton")
    DashButton.Size = UDim2.new(0, 50, 0, 50)
    DashButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    DashButton.BackgroundTransparency = 0.2
    DashButton.BorderSizePixel = 0
    DashButton.Image = "rbxassetid://3926305904"
    DashButton.ImageColor3 = Color3.fromRGB(150, 150, 200)
    
    local dashCorner = Instance.new("UICorner")
    dashCorner.CornerRadius = UDim.new(1, 0)
    dashCorner.Parent = DashButton
    
    local dashStroke = Instance.new("UIStroke")
    dashStroke.Color = Color3.fromRGB(150, 150, 200)
    dashStroke.Thickness = 2
    dashStroke.Transparency = 0.3
    dashStroke.Parent = DashButton
    
    local dashDot = Instance.new("Frame")
    dashDot.Size = UDim2.new(0, 10, 0, 10)
    dashDot.Position = UDim2.new(0, -2, 0, -2)
    dashDot.BackgroundColor3 = Color3.fromRGB(150, 150, 200)
    dashDot.BorderSizePixel = 0
    local dashDotCorner = Instance.new("UICorner")
    dashDotCorner.CornerRadius = UDim.new(1, 0)
    dashDotCorner.Parent = dashDot
    dashDot.Parent = DashButton
    
    local dashText = Instance.new("TextLabel")
    dashText.Size = UDim2.new(1, 0, 0, 16)
    dashText.Position = UDim2.new(0, 0, 1, 4)
    dashText.BackgroundTransparency = 1
    dashText.Text = "DASH"
    dashText.TextColor3 = Color3.fromRGB(150, 150, 200)
    dashText.TextScaled = true
    dashText.Font = Enum.Font.GothamBold
    dashText.TextSize = 10
    dashText.Parent = DashButton
    
    local function UpdateDashButtonPosition()
        if not DashButton then return end
        if LockOnButton and LockOnButton.Parent and LockOnButton.AbsolutePosition.X > 0 then
            DashButton.Position = UDim2.new(0, LockOnButton.AbsolutePosition.X + 70, 0, LockOnButton.AbsolutePosition.Y + 5)
            DashButton.Parent = LockOnButton.Parent
        else
            DashButton.Position = UDim2.new(0.5, 40, 0.75, 0)
            DashButton.Parent = MainGui
        end
    end
    
    UpdateDashButtonPosition()
    
    task.spawn(function()
        while DashButton and DashButton.Parent do
            task.wait(0.1)
            UpdateDashButtonPosition()
        end
    end)
    
    DashButton.MouseButton1Click:Connect(function()
        Settings.SideDashEnabled = not Settings.SideDashEnabled
        if Settings.SideDashEnabled then
            dashStroke.Color = Color3.fromRGB(0, 255, 0)
            dashDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            DashButton.ImageColor3 = Color3.fromRGB(0, 255, 0)
            dashText.TextColor3 = Color3.fromRGB(0, 255, 0)
            dashStroke.Transparency = 0
        else
            dashStroke.Color = Color3.fromRGB(150, 150, 200)
            dashDot.BackgroundColor3 = Color3.fromRGB(150, 150, 200)
            DashButton.ImageColor3 = Color3.fromRGB(150, 150, 200)
            dashText.TextColor3 = Color3.fromRGB(150, 150, 200)
            dashStroke.Transparency = 0.3
        end
    end)
    
    DashButton.Parent = MainGui
    
    return LockOnButton
end

local function HookNativeDash()
    task.wait(2)
    local function findDashButton(parent)
        if not parent then return nil end
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("ImageButton") or child:IsA("TextButton") then
                if string.lower(child.Name or ""):find("dash") or (child.Text and string.lower(child.Text):find("dash")) then
                    return child
                end
            end
            local found = findDashButton(child)
            if found then return found end
        end
        return nil
    end
    local dashBtn = findDashButton(LocalPlayer.PlayerGui)
    if dashBtn then
        dashBtn.MouseButton1Click:Connect(function()
            if Settings.SideDashEnabled then SideDash180() end
        end)
    end
end

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

task.spawn(function()
    while task.wait(0.15) do
        if Settings.SideDashEnabled then
            local myChar = LocalPlayer.Character
            if myChar then
                local charName = myChar.Name:lower()
                if charName:find("red") or charName:find("judas") or charName:find("vessel") then
                    local remote = myChar:FindFirstChild("BlackFlashEvent") or myChar:FindFirstChild("RemoteEvent")
                    if remote then
                        pcall(function()
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer("BlackFlash")
                            elseif remote:IsA("BindableEvent") then
                                remote:Fire("BlackFlash")
                            end
                        end)
                    end
                end
            end
        end
    end
end)

spawn(function()
    wait(1)
    CreateLockOnButtonAboveSpecial()
    HookNativeDash()
    print("✅ CENDOL HUB V2 - FULLY FIXED BY ARCHITECT 03")
    print("✅ NO ERROR, NO BULLSHIT")
    print("✅ Lock On button di atas tombol Special")
    print("✅ Side Dash 180° - toggle aktif")
    print("✅ Minimize/Maximize button - di control bar pojok kanan")
    print("✅ Auto Black Flash - aktif")
end)
]])
