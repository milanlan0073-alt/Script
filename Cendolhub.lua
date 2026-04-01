-- CENDOL HUB - ARCHITECT 03 EDITION
-- Lock-On System for Jujutsu Kaisen Shinenanigan
-- By: milanlan0073-alt

loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ========== CENDOL HUB CONFIG ==========
local Settings = {
    Enabled = true,
    Keybind = "Q",
    AutoLock = true,
    MaxDistance = 150,
    TargetPriority = "Closest",
    AutoAttack = false,
    SmoothCamera = true,
    Smoothness = 0.3,
    ShowESP = true,
    ESPColor = Color3.fromRGB(255, 0, 0),
    HubName = "CENDOL HUB"
}

local CurrentTarget = nil
local TargetPart = nil
local ESPObjects = {}

local Hitboxes = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "Torso"}

local function IsAlive(c)
    if not c then return false end
    local h = c:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function GetDistance(a, b)
    if not a or not b then return math.huge end
    return (a.Position - b.Position).Magnitude
end

local function GetAllTargets()
    local targets = {}
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return targets end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local c = p.Character
            if c and IsAlive(c) then
                local r = c:FindFirstChild("HumanoidRootPart")
                if r then
                    local d = GetDistance(r, myPos)
                    if d <= Settings.MaxDistance then
                        table.insert(targets, {Type="Player", Name=p.Name, Character=c, Root=r, Distance=d, Health=c.Humanoid.Health, MaxHealth=c.Humanoid.MaxHealth})
                    end
                end
            end
        end
    end
    
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("Model") and o ~= LocalPlayer.Character then
            local h = o:FindFirstChild("Humanoid")
            local r = o:FindFirstChild("HumanoidRootPart")
            if h and r and h.Health > 0 and not Players:GetPlayerFromCharacter(o) then
                local d = GetDistance(r, myPos)
                if d <= Settings.MaxDistance then
                    table.insert(targets, {Type="NPC", Name=o.Name, Character=o, Root=r, Distance=d, Health=h.Health, MaxHealth=h.MaxHealth})
                end
            end
        end
    end
    
    if Settings.TargetPriority == "Closest" then
        table.sort(targets, function(a,b) return a.Distance < b.Distance end)
    elseif Settings.TargetPriority == "LowestHP" then
        table.sort(targets, function(a,b) return (a.Health/a.MaxHealth) < (b.Health/b.MaxHealth) end)
    end
    
    return targets
end

local function GetBestHitbox(c)
    for _, h in ipairs(Hitboxes) do
        local p = c:FindFirstChild(h)
        if p and p:IsA("BasePart") then return p end
    end
    return c:FindFirstChild("HumanoidRootPart")
end

local function CreateESP(t)
    if not Settings.ShowESP then return end
    if ESPObjects[t] then pcall(function() ESPObjects[t]:Destroy() end) end
    local r = t:FindFirstChild("HumanoidRootPart")
    if not r then return end
    local b = Instance.new("BillboardGui")
    b.Name = "CendolHub_ESP"
    b.Size = UDim2.new(0, 80, 0, 30)
    b.StudsOffset = Vector3.new(0, 2.5, 0)
    b.AlwaysOnTop = true
    b.Adornee = r
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = Settings.ESPColor
    f.BackgroundTransparency = 0.6
    local hb = Instance.new("Frame")
    hb.Size = UDim2.new(1,0,0.2,0)
    hb.Position = UDim2.new(0,0,0.8,0)
    hb.BackgroundColor3 = Color3.fromRGB(0,255,0)
    hb.BackgroundTransparency = 0.3
    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1,0,0.6,0)
    nl.Position = UDim2.new(0,0,0.2,0)
    nl.BackgroundTransparency = 1
    nl.TextColor3 = Color3.fromRGB(255,255,255)
    nl.TextScaled = true
    nl.Font = Enum.Font.GothamBold
    nl.Text = t.Name or "?"
    nl.Parent = f
    hb.Parent = f
    f.Parent = b
    b.Parent = r
    ESPObjects[t] = b
end

local function UpdateESP()
    for t, e in pairs(ESPObjects) do
        if not t or not t.Parent or not IsAlive(t) then
            pcall(function() e:Destroy() end)
            ESPObjects[t] = nil
        elseif IsAlive(t) and e then
            local f = e:FindFirstChild("Frame")
            if f then
                local hb = f:FindFirstChild("Frame")
                if hb then
                    local hp = t.Humanoid.Health / t.Humanoid.MaxHealth
                    hb.Size = UDim2.new(hp, 0, 0.2, 0)
                    hb.BackgroundColor3 = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
                end
            end
        end
    end
end

local function FindBestTarget()
    local t = GetAllTargets()
    if #t > 0 then
        local b = t[1]
        return b.Character, GetBestHitbox(b.Character)
    end
    return nil, nil
end

local function UpdateLockOn()
    if not Settings.Enabled then return end
    if not CurrentTarget or not IsAlive(CurrentTarget) then
        if Settings.AutoLock then
            CurrentTarget, TargetPart = FindBestTarget()
            if CurrentTarget then CreateESP(CurrentTarget) end
        else
            CurrentTarget, TargetPart = nil, nil
        end
    end
end

local function SmoothLock(dt)
    if not Settings.Enabled or not TargetPart or not TargetPart.Parent then
        if not TargetPart then CurrentTarget = nil end
        return
    end
    local tp = TargetPart.Position
    local cp = Camera.CFrame.Position
    if Settings.SmoothCamera then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(cp, tp), Settings.Smoothness)
    else
        Camera.CFrame = CFrame.new(cp, tp)
    end
end

local KeyMap = {Q=Enum.KeyCode.Q, E=Enum.KeyCode.E, R=Enum.KeyCode.R, F=Enum.KeyCode.F, G=Enum.KeyCode.G}
UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    local k = KeyMap[Settings.Keybind]
    if i.KeyCode == k then
        Settings.Enabled = not Settings.Enabled
        if not Settings.Enabled then
            CurrentTarget = nil
            TargetPart = nil
            for _, e in pairs(ESPObjects) do pcall(function() e:Destroy() end) end
            ESPObjects = {}
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="CENDOL HUB", Text=Settings.Enabled and "LOCK-ON ACTIVE" or "LOCK-ON OFF", Duration=1})
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    UpdateLockOn()
    UpdateESP()
    if Settings.Enabled and TargetPart then
        SmoothLock(dt)
    end
end)

local function CreateGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "CendolHub"
    sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0,220,0,120)
    f.Position = UDim2.new(0,10,0,10)
    f.BackgroundColor3 = Color3.fromRGB(0,0,0)
    f.BackgroundTransparency = 0.5
    f.BorderSizePixel = 0
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,0,1,0)
    t.Text = "CENDOL HUB\n" .. (Settings.Enabled and "ACTIVE" or "INACTIVE") .. "\nKey: " .. Settings.Keybind
    t.TextColor3 = Settings.Enabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    t.BackgroundTransparency = 1
    t.TextScaled = true
    t.Font = Enum.Font.GothamBold
    t.Parent = f
    f.Parent = sg
    while f and f.Parent do
        task.wait(0.5)
        t.Text = "CENDOL HUB\n" .. (Settings.Enabled and "ACTIVE" or "INACTIVE") .. "\nKey: " .. Settings.Keybind
        t.TextColor3 = Settings.Enabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    end
end

spawn(function() wait(1) pcall(CreateGUI) end)
game:GetService("StarterGui"):SetCore("SendNotification", {Title="CENDOL HUB", Text="Lock-On Loaded | Press " .. Settings.Keybind .. " to toggle", Duration=3})
print("=== CENDOL HUB LOADED ===")
]])()
