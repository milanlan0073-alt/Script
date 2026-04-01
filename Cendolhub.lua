-- CENDOL HUB - FIXED FOR ANDROID
-- By: milanlan0073-alt

loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local Settings = {
    Enabled = true,
    Keybind = "Q",
    MaxDistance = 150,
    SmoothCamera = true,
    Smoothness = 0.35,
    ShowESP = true
}

local CurrentTarget = nil
local TargetPart = nil
local ESPObjects = {}

-- HITBOXES
local Hitboxes = {"Head", "UpperTorso", "HumanoidRootPart", "Torso"}

-- UTILITIES
local function IsAlive(c)
    if not c then return false end
    local h = c:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function GetDistance(a, b)
    return (a.Position - b.Position).Magnitude
end

-- GET TARGETS
local function GetAllTargets()
    local targets = {}
    local myChar = LocalPlayer.Character
    if not myChar then return targets end
    local myPos = myChar:FindFirstChild("HumanoidRootPart")
    if not myPos then return targets end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local c = p.Character
            if c and IsAlive(c) then
                local r = c:FindFirstChild("HumanoidRootPart")
                if r then
                    local d = GetDistance(r, myPos)
                    if d <= Settings.MaxDistance then
                        table.insert(targets, {
                            Character = c,
                            Root = r,
                            Distance = d,
                            Name = p.Name
                        })
                    end
                end
            end
        end
    end
    
    table.sort(targets, function(a,b) return a.Distance < b.Distance end)
    return targets
end

local function GetBestHitbox(char)
    for _, h in ipairs(Hitboxes) do
        local part = char:FindFirstChild(h)
        if part and part:IsA("BasePart") then return part end
    end
    return char:FindFirstChild("HumanoidRootPart")
end

-- SIMPLE ESP (PASTI MUNCUL)
local function CreateESP(target)
    if not Settings.ShowESP then return end
    if ESPObjects[target] then 
        pcall(function() ESPObjects[target]:Destroy() end) 
    end
    
    local root = target:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CendolESP"
    billboard.Size = UDim2.new(0, 80, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = root
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    frame.BackgroundTransparency = 0.5
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = target.Name or "?"
    
    label.Parent = frame
    frame.Parent = billboard
    billboard.Parent = root
    ESPObjects[target] = billboard
end

-- MAIN FUNCTIONS
local function FindBestTarget()
    local targets = GetAllTargets()
    if #targets > 0 then
        local best = targets[1]
        return best.Character, GetBestHitbox(best.Character)
    end
    return nil, nil
end

local function UpdateLockOn()
    if not Settings.Enabled then return end
    if not CurrentTarget or not IsAlive(CurrentTarget) then
        CurrentTarget, TargetPart = FindBestTarget()
        if CurrentTarget then 
            CreateESP(CurrentTarget) 
        end
    end
end

local function SmoothLock()
    if not Settings.Enabled or not TargetPart or not TargetPart.Parent then return end
    local targetPos = TargetPart.Position
    local currentPos = Camera.CFrame.Position
    if Settings.SmoothCamera then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(currentPos, targetPos), Settings.Smoothness)
    else
        Camera.CFrame = CFrame.new(currentPos, targetPos)
    end
end

-- KEYBIND
UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.Q then
        Settings.Enabled = not Settings.Enabled
        if not Settings.Enabled then
            CurrentTarget = nil
            TargetPart = nil
            for _, esp in pairs(ESPObjects) do
                pcall(function() esp:Destroy() end)
            end
            ESPObjects = {}
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "CENDOL HUB",
            Text = Settings.Enabled and "🔴 ACTIVE" or "⚫ OFF",
            Duration = 1
        })
    end
end)

-- SIMPLE UI (PASTI MUNCUL)
local function CreateSimpleUI()
    -- Tunggu sampe PlayerGui ada
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
    frame.Size = UDim2.new(0, 200, 0, 80)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.4, 0)
    title.Text = "⚡ CENDOL HUB"
    title.TextColor3 = Color3.fromRGB(255, 50, 50)
    title.BackgroundTransparency = 1
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0.3, 0)
    status.Position = UDim2.new(0, 0, 0.4, 0)
    status.Text = Settings.Enabled and "▶ ACTIVE" or "⏸ OFF"
    status.TextColor3 = Settings.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    status.BackgroundTransparency = 1
    status.TextScaled = true
    status.Font = Enum.Font.Gotham
    status.Parent = frame
    
    local key = Instance.new("TextLabel")
    key.Size = UDim2.new(1, 0, 0.3, 0)
    key.Position = UDim2.new(0, 0, 0.7, 0)
    key.Text = "🔘 PRESS Q"
    key.TextColor3 = Color3.fromRGB(200, 200, 200)
    key.BackgroundTransparency = 1
    key.TextScaled = true
    key.Font = Enum.Font.Gotham
    key.Parent = frame
    
    -- Update status live
    spawn(function()
        while frame and frame.Parent do
            status.Text = Settings.Enabled and "▶ ACTIVE" or "⏸ OFF"
            status.TextColor3 = Settings.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            if CurrentTarget and IsAlive(CurrentTarget) then
                local dist = TargetPart and math.floor((TargetPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
                key.Text = "🎯 " .. (CurrentTarget.Name or "?") .. " (" .. dist .. "m)"
            else
                key.Text = "🔘 PRESS Q"
            end
            task.wait(0.3)
        end
    end)
    
    frame.Parent = sg
    
    -- Draggable
    local dragging = false
    local dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return frame
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    UpdateLockOn()
    if Settings.Enabled and TargetPart then
        SmoothLock()
    end
end)

-- INIT
spawn(function()
    -- Tunggu game siap
    wait(2)
    local success, err = pcall(CreateSimpleUI)
    if not success then
        warn("UI Error: " .. tostring(err))
        -- Fallback: coba lagi nanti
        wait(3)
        pcall(CreateSimpleUI)
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "CENDOL HUB",
        Text = "Loaded! Press Q to toggle",
        Duration = 3
    })
    print("=== CENDOL HUB LOADED ===")
end)
]])()
