-- CENDOL HUB V2 - Lock Button LEFT BOTTOM (Above Left Special Skill)
-- By: milanlan0073-alt + Architect 03

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
    CameraFollow = true,
    BodyRotate = true,
    MaxDistance = 200,
    SideDashEnabled = true,
}

local CurrentTarget = nil
local LockButton = nil

-- ========== CREATE LOCK BUTTON (KIRI BAWAH) ==========
local function CreateLockButton()
    for i = 1, 20 do
        if LocalPlayer:FindFirstChild("PlayerGui") then break end
        task.wait(0.5)
    end
    
    local playerGui = LocalPlayer.PlayerGui
    
    -- Buat ScreenGui
    local lockGui = Instance.new("ScreenGui")
    lockGui.Name = "LockOnButtonGui"
    lockGui.Parent = playerGui
    lockGui.ResetOnSpawn = false
    lockGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Tombol Lock On (BENTUK BULAT, BUKAN BINTANG)
    local lockBtn = Instance.new("ImageButton")
    lockBtn.Name = "LockOnButton"
    lockBtn.Size = UDim2.new(0, 65, 0, 65)
    lockBtn.Position = UDim2.new(0.05, 0, 0.75, 0) -- KIRI BAWAH (5% dari kiri, 75% dari atas)
    lockBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    lockBtn.BackgroundTransparency = 0.4
    lockBtn.Image = "rbxassetid://6031091207" -- Icon target/lock
    lockBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    lockBtn.ScaleType = Enum.ScaleType.Fit
    lockBtn.AutoButtonColor = true
    lockBtn.ZIndex = 20
    
    -- Efek rounded (bulat)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = lockBtn
    
    -- Border glow
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 80, 80)
    stroke.Thickness = 2
    stroke.Transparency = 0.4
    stroke.Parent = lockBtn
    
    -- Teks status di dalam tombol
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 0, 20)
    statusText.Position = UDim2.new(0, 0, 0.7, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "OFF"
    statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusText.TextSize = 14
    statusText.Font = Enum.Font.GothamBold
    statusText.ZIndex = 21
    statusText.Parent = lockBtn
    
    -- Efek bayangan
    local shadow = Instance.new("UIShadow")
    shadow.Parent = lockBtn
    
    -- Fungsi toggle lock
    local function ToggleLock()
        Settings.Enabled = not Settings.Enabled
        
        if Settings.Enabled then
            statusText.Text = "ON"
            statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
            lockBtn.ImageColor3 = Color3.fromRGB(100, 255, 100)
            stroke.Color = Color3.fromRGB(100, 255, 100)
            stroke.Transparency = 0.2
            
            -- Cari target terdekat
            local function GetClosestTarget()
                local closest = nil
                local closestDist = Settings.MaxDistance
                local myChar = LocalPlayer.Character
                if not myChar then return nil end
                local myPos = myChar:FindFirstChild("HumanoidRootPart")
                if not myPos then return nil end
                
                -- Cari player
                if Settings.LockPlayer then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer then
                            local c = p.Character
                            if c and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0 then
                                local r = c:FindFirstChild("HumanoidRootPart")
                                if r then
                                    local d = (r.Position - myPos.Position).Magnitude
                                    if d < closestDist then
                                        closestDist = d
                                        closest = c
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Cari NPC
                if Settings.LockNPC then
                    local NPCKeywords = {"Cursed", "Spirit", "Curse", "NPC", "Mob", "Enemy", "Boss", "Raid", "Demon", "Shadow", "Monster", "Training", "Dummy", "Zombie", "Skeleton"}
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj ~= myChar then
                            local h = obj:FindFirstChild("Humanoid")
                            local r = obj:FindFirstChild("HumanoidRootPart")
                            if h and r and h.Health > 0 then
                                local isNPC = true
                                if Players:GetPlayerFromCharacter(obj) then isNPC = false end
                                if isNPC then
                                    local d = (r.Position - myPos.Position).Magnitude
                                    if d < closestDist then
                                        closestDist = d
                                        closest = obj
                                    end
                                end
                            end
                        end
                    end
                end
                
                return closest
            end
            
            CurrentTarget = GetClosestTarget()
            
            -- Animasi keren pas nyala
            TweenService:Create(lockBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic), {
                Size = UDim2.new(0, 70, 0, 70)
            }):Play()
        else
            statusText.Text = "OFF"
            statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            lockBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
            stroke.Color = Color3.fromRGB(255, 80, 80)
            stroke.Transparency = 0.4
            CurrentTarget = nil
            
            TweenService:Create(lockBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic), {
                Size = UDim2.new(0, 65, 0, 65)
            }):Play()
        end
    end
    
    lockBtn.MouseButton1Click:Connect(ToggleLock)
    lockBtn.Parent = lockGui
    
    -- Animasi hover
    lockBtn.MouseEnter:Connect(function()
        TweenService:Create(lockBtn, TweenInfo.new(0.15), {
            Size = UDim2.new(0, 72, 0, 72)
        }):Play()
    end)
    
    lockBtn.MouseLeave:Connect(function()
        TweenService:Create(lockBtn, TweenInfo.new(0.15), {
            Size = UDim2.new(0, 65, 0, 65)
        }):Play()
    end)
    
    return lockBtn
end

-- ========== CAMERA FOLLOW ==========
local function UpdateCameraFollow()
    if not Settings.CameraFollow then return end
    if not Settings.Enabled or not CurrentTarget then return end
    
    local targetPart = CurrentTarget:FindFirstChild("Head") or CurrentTarget:FindFirstChild("HumanoidRootPart")
    if not targetPart then return end
    
    local targetPos = targetPart.Position + Vector3.new(0, 2, 0)
    local currentCFrame = Camera.CFrame
    local desiredCFrame = CFrame.new(currentCFrame.Position, targetPos)
    Camera.CFrame = currentCFrame:Lerp(desiredCFrame, 0.25)
end

-- ========== BODY ROTATE ==========
local function RotateToTarget()
    if not Settings.BodyRotate then return end
    if not Settings.Enabled or not CurrentTarget then return end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = CurrentTarget:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return end
    
    local direction = (targetRoot.Position - myRoot.Position).Unit
    myChar:SetPrimaryPartCFrame(CFrame.new(myRoot.Position, myRoot.Position + direction))
end

-- ========== SIDE DASH 180° ==========
local function PerformSideDash()
    if not Settings.SideDashEnabled then return end
    if not Settings.Enabled or not CurrentTarget then return end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = CurrentTarget:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return end
    
    local toTarget = (targetRoot.Position - myRoot.Position).Unit
    local dashDirection = -toTarget
    myRoot.AssemblyLinearVelocity = dashDirection * 80
    
    local humanoid = myChar:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
        task.delay(0.3, function()
            if humanoid and humanoid.Parent then
                humanoid.PlatformStand = false
            end
        end)
    end
end

-- Deteksi tombol dash (F, Q, LeftShift)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode
        if key == Enum.KeyCode.F or key == Enum.KeyCode.Q or key == Enum.KeyCode.LeftShift then
            if Settings.Enabled and CurrentTarget then
                task.spawn(PerformSideDash)
            end
        end
    end
end)

-- ========== MAIN LOOP ==========
RunService.RenderStepped:Connect(function()
    if Settings.Enabled and CurrentTarget then
        -- Cek target masih hidup
        if CurrentTarget:FindFirstChild("Humanoid") and CurrentTarget.Humanoid.Health > 0 then
            UpdateCameraFollow()
            RotateToTarget()
        else
            CurrentTarget = nil
            if Settings.Enabled then
                -- Cari target baru
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
                                if c and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0 then
                                    local r = c:FindFirstChild("HumanoidRootPart")
                                    if r then
                                        local d = (r.Position - myPos.Position).Magnitude
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
                        local NPCKeywords = {"Cursed", "Spirit", "Curse", "NPC", "Mob", "Enemy", "Boss", "Raid", "Demon", "Shadow", "Monster"}
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj:IsA("Model") and obj ~= myChar then
                                local h = obj:FindFirstChild("Humanoid")
                                local r = obj:FindFirstChild("HumanoidRootPart")
                                if h and r and h.Health > 0 then
                                    local isNPC = true
                                    if Players:GetPlayerFromCharacter(obj) then isNPC = false end
                                    if isNPC then
                                        local d = (r.Position - myPos.Position).Magnitude
                                        if d < closestDist then
                                            closestDist = d
                                            closest = obj
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    return closest
                end
                CurrentTarget = GetClosestTarget()
            end
        end
    end
end)

-- INIT
spawn(function()
    task.wait(1)
    LockButton = CreateLockButton()
    print("=== CENDOL HUB V2 LOADED ===")
    print("=== Lock Button di KIRI BAWAH ===")
    print("=== Tekan tombol lock buat aktifin ===")
end)
]])()
