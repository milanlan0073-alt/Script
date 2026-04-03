-- CENDOL HUB V2 - JUJUTSU SHENANIGANS EDITION
-- Lock On Button + Side Dash 180°
-- Tampilan tombul kaya di foto: bulat, border, status dot, teks di bawah

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
    SideDashEnabled = false
}

local CurrentTarget = nil
local TargetPart = nil
local LockOnButton = nil
local DashButton = nil

local Hitboxes = {"Head", "UpperTorso", "HumanoidRootPart", "Torso"}

local NPCKeywords = {
    "Cursed", "Spirit", "Curse", "NPC", "Mob", "Enemy", "Boss",
    "Raid", "Demon", "Shadow", "Monster","Dummy"
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
    myChar:SetPrimaryPartCFrame(lookAt)
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
    local tween = TweenService:Create(rootPart, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = CFrame.new(dashPosition, dashPosition + toTarget)})
    tween:Play()
end

-- MEMBUAT TOMBOL BULAT KAYA DI FOTO
local function CreateGameButtons()
    for i = 1, 10 do
        if LocalPlayer:FindFirstChild("PlayerGui") then break end
        wait(0.5)
    end
    local sg = Instance.new("ScreenGui")
    sg.Name = "JujutsuLockOn"
    sg.Parent = LocalPlayer.PlayerGui
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- TOMBOL LOCK ON
    LockOnButton = Instance.new("ImageButton")
    LockOnButton.Size = UDim2.new(0, 70, 0, 70)
    LockOnButton.Position = UDim2.new(1, -85, 1, -85)
    LockOnButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    LockOnButton.BackgroundTransparency = 0.3
    LockOnButton.BorderSizePixel = 0
    LockOnButton.Image = "rbxassetid://3926305904"

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = LockOnButton

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 80, 80)
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = LockOnButton

    local btnText = Instance.new("TextLabel")
    btnText.Size = UDim2.new(1, 0, 0, 20)
    btnText.Position = UDim2.new(0, 0, 1, -25)
    btnText.BackgroundTransparency = 1
    btnText.Text = "LOCK"
    btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnText.TextScaled = true
    btnText.Font = Enum.Font.GothamBold
    btnText.Parent = LockOnButton

    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 12, 0, 12)
    statusDot.Position = UDim2.new(0, 5, 0, 5)
    statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    statusDot.BorderSizePixel = 0
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = statusDot
    statusDot.Parent = LockOnButton

    LockOnButton.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        if Settings.Enabled then
            local newTarget = GetClosestTarget()
            if newTarget then
                CurrentTarget = newTarget
                TargetPart = GetBestHitbox(CurrentTarget)
            end
            statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            stroke.Color = Color3.fromRGB(0, 255, 0)
            LockOnButton.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
            LockOnButton.BackgroundTransparency = 0.2
            btnText.Text = "LOCKED"
        else
            CurrentTarget = nil
            TargetPart = nil
            statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            stroke.Color = Color3.fromRGB(255, 80, 80)
            LockOnButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            LockOnButton.BackgroundTransparency = 0.3
            btnText.Text = "LOCK"
        end
    end)

    LockOnButton.Parent = sg

    -- TOMBOL DASH (Side Dash toggle)
    DashButton = Instance.new("ImageButton")
    DashButton.Size = UDim2.new(0, 60, 0, 60)
    DashButton.Position = UDim2.new(1, -85, 1, -170)
    DashButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DashButton.BackgroundTransparency = 0.3
    DashButton.BorderSizePixel = 0
    DashButton.Image = "rbxassetid://3926305904"

    local dashCorner = Instance.new("UICorner")
    dashCorner.CornerRadius = UDim.new(1, 0)
    dashCorner.Parent = DashButton

    local dashStroke = Instance.new("UIStroke")
    dashStroke.Color = Color3.fromRGB(150, 150, 150)
    dashStroke.Thickness = 2
    dashStroke.Transparency = 0.5
    dashStroke.Parent = DashButton

    local dashText = Instance.new("TextLabel")
    dashText.Size = UDim2.new(1, 0, 0, 18)
    dashText.Position = UDim2.new(0, 0, 1, -22)
    dashText.BackgroundTransparency = 1
    dashText.Text = "DASH"
    dashText.TextColor3 = Color3.fromRGB(255, 255, 255)
    dashText.TextScaled = true
    dashText.Font = Enum.Font.GothamBold
    dashText.Parent = DashButton

    local dashDot = Instance.new("Frame")
    dashDot.Size = UDim2.new(0, 10, 0, 10)
    dashDot.Position = UDim2.new(0, 4, 0, 4)
    dashDot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    dashDot.BorderSizePixel = 0
    local dashDotCorner = Instance.new("UICorner")
    dashDotCorner.CornerRadius = UDim.new(1, 0)
    dashDotCorner.Parent = dashDot
    dashDot.Parent = DashButton

    DashButton.MouseButton1Click:Connect(function()
        Settings.SideDashEnabled = not Settings.SideDashEnabled
        if Settings.SideDashEnabled then
            dashStroke.Color = Color3.fromRGB(0, 255, 0)
            dashDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            DashButton.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
            DashButton.BackgroundTransparency = 0.2
        else
            dashStroke.Color = Color3.fromRGB(150, 150, 150)
            dashDot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
            DashButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            DashButton.BackgroundTransparency = 0.3
        end
    end)

    DashButton.Parent = sg
end

-- HOOK DASH ASLI (JIKA ADA)
local function HookNativeDash()
    task.wait(2)
    local function findButton(parent)
        if not parent then return nil end
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("ImageButton") or child:IsA("TextButton") then
                if string.lower(child.Name or ""):find("dash") or (child.Text and string.lower(child.Text):find("dash")) then
                    return child
                end
            end
            local found = findButton(child)
            if found then return found end
        end
        return nil
    end
    local dashBtn = findButton(LocalPlayer.PlayerGui)
    if dashBtn then
        dashBtn.MouseButton1Click:Connect(function()
            if Settings.SideDashEnabled then SideDash180() end
        end)
    else
        if DashButton then
            DashButton.MouseButton1Click:Connect(function()
                if Settings.SideDashEnabled then SideDash180() end
            end)
        end
    end
end

-- MAIN LOOP CAMERA & ROTASI
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
            local targetPos = TargetPart.Position + Settings.CameraOffset
            local currentCFrame = Camera.CFrame
            local desiredCFrame = CFrame.new(currentCFrame.Position, targetPos)
            Camera.CFrame = currentCFrame:Lerp(desiredCFrame, Settings.CameraSmoothness)
        end
        RotateToTarget()
    end
end)

spawn(function()
    wait(1)
    CreateGameButtons()
    HookNativeDash()
    print("✅ Lock On + Side Dash 180° siap dipake")
end)
]])()
