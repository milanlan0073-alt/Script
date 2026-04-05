-- ARCHITECT 03 - JUJUTSU SHENANIGANS DARK UI (ANDROID EDITION)
-- Optimized for: Arceus X, Hydrogen, Fluxus Android, Codex
-- Touch-friendly UI, no mouse dependencies

local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local tweenService = game:GetService("TweenService")

-- =========== ANDROID-OPTIMIZED LIBRARY ===========
local Library = {}
local mainGui, mainFrame, currentTab

function Library:CreateWindow(title)
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "JJK_Android_UI"
    mainGui.Parent = game:GetService("CoreGui")
    mainGui.Enabled = true
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- MAIN FRAME (Responsive buat layar kecil)
    local screenSize = workspace.CurrentCamera.ViewportSize
    local frameWidth = math.min(650, screenSize.X - 40)
    local frameHeight = math.min(450, screenSize.Y - 60)
    
    mainFrame = Instance.new("Frame")
    mainFrame.Parent = mainGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderColor3 = Color3.fromRGB(80, 60, 140)
    mainFrame.BorderSizePixel = 1
    mainFrame.ClipsDescendants = true
    mainFrame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
    mainFrame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
    mainFrame.Active = true

    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Parent = mainFrame
    shadow.Image = "rbxassetid://1316044356"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.65
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.ZIndex = 0
    shadow.BackgroundTransparency = 1

    -- Background
    local bgFrame = Instance.new("Frame")
    bgFrame.Parent = mainFrame
    bgFrame.Size = UDim2.new(1, 0, 1, 0)
    bgFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    bgFrame.BackgroundTransparency = 0
    bgFrame.ZIndex = 1

    -- Header (lebih besar buat touch)
    local header = Instance.new("Frame")
    header.Parent = mainFrame
    header.BackgroundColor3 = Color3.fromRGB(30, 25, 50)
    header.BackgroundTransparency = 0
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, 55)
    header.Position = UDim2.new(0, 0, 0, 0)

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = header
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title .. " — Architect 03 [Android]"
    titleLabel.TextColor3 = Color3.fromRGB(200, 170, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Position = UDim2.new(0, 12, 0.5, -12)
    titleLabel.Size = UDim2.new(0, 280, 0, 28)

    -- Glow line
    local glow = Instance.new("Frame")
    glow.Parent = header
    glow.BackgroundColor3 = Color3.fromRGB(140, 100, 230)
    glow.BorderSizePixel = 0
    glow.Size = UDim2.new(0.8, 0, 0, 2)
    glow.Position = UDim2.new(0.1, 0, 1, -2)
    glow.BackgroundTransparency = 0.3

    -- Close button (lebih besar buat touch)
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
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = closeBtn
    closeBtn.MouseButton1Click:Connect(function()
        mainGui.Enabled = false
    end)

    -- Tab Container (scrollable untuk touch)
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Parent = mainFrame
    tabContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    tabContainer.BackgroundTransparency = 0
    tabContainer.Size = UDim2.new(0, 130, 1, -55)
    tabContainer.Position = UDim2.new(0, 0, 0, 55)
    tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContainer.ScrollBarThickness = 3
    tabContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 70, 180)

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 0)
    tabCorner.Parent = tabContainer

    local tabList = Instance.new("UIListLayout")
    tabList.Parent = tabContainer
    tabList.Padding = UDim.new(0, 8)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    
    tabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, tabList.AbsoluteContentSize.Y + 10)
    end)

    local contentContainer = Instance.new("Frame")
    contentContainer.Parent = mainFrame
    contentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    contentContainer.BackgroundTransparency = 0
    contentContainer.Size = UDim2.new(1, -145, 1, -65)
    contentContainer.Position = UDim2.new(0, 135, 0, 60)

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentContainer

    self.Tabs = {}
    self.Frames = {}
    self.TabButtons = {}

    function Library:CreateTab(tabName)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Parent = tabContainer
        tabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        tabBtn.BackgroundTransparency = 0
        tabBtn.Text = tabName
        tabBtn.TextColor3 = Color3.fromRGB(190, 190, 210)
        tabBtn.TextSize = 13
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.Size = UDim2.new(1, -10, 0, 42)
        local tabBtnCorner = Instance.new("UICorner")
        tabBtnCorner.CornerRadius = UDim.new(0, 8)
        tabBtnCorner.Parent = tabBtn

        local contentFrame = Instance.new("ScrollingFrame")
        contentFrame.Parent = contentContainer
        contentFrame.BackgroundTransparency = 1
        contentFrame.Size = UDim2.new(1, -15, 1, -15)
        contentFrame.Position = UDim2.new(0, 8, 0, 8)
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        contentFrame.ScrollBarThickness = 4
        contentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 70, 180)
        contentFrame.Visible = (#self.Tabs == 0)

        local list = Instance.new("UIListLayout")
        list.Parent = contentFrame
        list.Padding = UDim.new(0, 10)
        list.SortOrder = Enum.SortOrder.LayoutOrder

        local function updateCanvas()
            task.wait()
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 20)
        end
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        task.wait()

        table.insert(self.Tabs, {btn = tabBtn, content = contentFrame})

        tabBtn.MouseButton1Click:Connect(function()
            for i, v in pairs(self.Tabs) do
                v.content.Visible = false
                v.btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                v.btn.TextColor3 = Color3.fromRGB(190, 190, 210)
            end
            contentFrame.Visible = true
            tabBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 180)
            tabBtn.TextColor3 = Color3.fromRGB(255, 230, 255)
        end)

        if #self.Tabs == 1 then
            tabBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 180)
            tabBtn.TextColor3 = Color3.fromRGB(255, 230, 255)
        end

        local Section = {}
        function Section:CreateSection(sectionName)
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Parent = contentFrame
            sectionFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
            sectionFrame.BackgroundTransparency = 0
            sectionFrame.Size = UDim2.new(1, -10, 0, 50)
            sectionFrame.BorderSizePixel = 0
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 8)
            sectionCorner.Parent = sectionFrame

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Parent = sectionFrame
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = sectionName
            titleLabel.TextColor3 = Color3.fromRGB(200, 170, 240)
            titleLabel.TextSize = 15
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.Position = UDim2.new(0, 12, 0, 5)
            titleLabel.Size = UDim2.new(1, -30, 0, 22)

            local elementContainer = Instance.new("Frame")
            elementContainer.Parent = sectionFrame
            elementContainer.BackgroundTransparency = 1
            elementContainer.Size = UDim2.new(1, -20, 0, 30)
            elementContainer.Position = UDim2.new(0, 10, 0, 32)

            local Elements = {}
            
            function Elements:CreateButton(text, callback)
                local btn = Instance.new("TextButton")
                btn.Parent = elementContainer
                btn.BackgroundColor3 = Color3.fromRGB(55, 45, 85)
                btn.Text = text
                btn.TextColor3 = Color3.fromRGB(240, 235, 255)
                btn.TextSize = 14
                btn.Font = Enum.Font.Gotham
                btn.Size = UDim2.new(1, 0, 0, 40) -- Lebih besar buat touch
                btn.BackgroundTransparency = 0
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 8)
                btnCorner.Parent = btn

                btn.MouseButton1Click:Connect(function()
                    callback()
                    local originalColor = btn.BackgroundColor3
                    btn.BackgroundColor3 = Color3.fromRGB(150, 100, 250)
                    task.wait(0.08)
                    btn.BackgroundColor3 = originalColor
                end)

                elementContainer.Size = UDim2.new(1, -20, 0, 40 + (#elementContainer:GetChildren() - 1) * 48)
                sectionFrame.Size = UDim2.new(1, -10, 0, 45 + (#elementContainer:GetChildren()) * 50)
            end

            function Elements:CreateToggle(text, callback)
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Parent = elementContainer
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Size = UDim2.new(1, 0, 0, 40)

                local label = Instance.new("TextLabel")
                label.Parent = toggleFrame
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextColor3 = Color3.fromRGB(200, 195, 230)
                label.TextSize = 13
                label.Font = Enum.Font.Gotham
                label.Position = UDim2.new(0, 0, 0, 8)
                label.Size = UDim2.new(0, 220, 0, 24)
                label.TextXAlignment = Enum.TextXAlignment.Left

                local toggleBtn = Instance.new("TextButton")
                toggleBtn.Parent = toggleFrame
                toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 60, 100)
                toggleBtn.Text = ""
                toggleBtn.Size = UDim2.new(0, 50, 0, 30)
                toggleBtn.Position = UDim2.new(1, -55, 0, 5)
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(1, 0)
                toggleCorner.Parent = toggleBtn

                local indicator = Instance.new("Frame")
                indicator.Parent = toggleBtn
                indicator.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
                indicator.Size = UDim2.new(0, 22, 0, 22)
                indicator.Position = UDim2.new(0, 3, 0.5, -11)
                local indCorner = Instance.new("UICorner")
                indCorner.CornerRadius = UDim.new(1, 0)
                indCorner.Parent = indicator

                local toggled = false
                toggleBtn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    if toggled then
                        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 80, 210)
                        indicator.Position = UDim2.new(1, -25, 0.5, -11)
                    else
                        toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 60, 100)
                        indicator.Position = UDim2.new(0, 3, 0.5, -11)
                    end
                    callback(toggled)
                end)

                elementContainer.Size = UDim2.new(1, -20, 0, 40 + (#elementContainer:GetChildren() - 1) * 48)
                sectionFrame.Size = UDim2.new(1, -10, 0, 45 + (#elementContainer:GetChildren()) * 50)
            end

            function Elements:CreateSlider(text, minVal, maxVal, defaultVal, callback)
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Parent = elementContainer
                sliderFrame.BackgroundTransparency = 1
                sliderFrame.Size = UDim2.new(1, 0, 0, 70)

                local label = Instance.new("TextLabel")
                label.Parent = sliderFrame
                label.BackgroundTransparency = 1
                label.Text = text .. " : " .. defaultVal
                label.TextColor3 = Color3.fromRGB(200, 195, 230)
                label.TextSize = 13
                label.Font = Enum.Font.Gotham
                label.Position = UDim2.new(0, 0, 0, 0)
                label.Size = UDim2.new(1, 0, 0, 25)

                local sliderBar = Instance.new("Frame")
                sliderBar.Parent = sliderFrame
                sliderBar.BackgroundColor3 = Color3.fromRGB(55, 45, 80)
                sliderBar.Size = UDim2.new(1, -10, 0, 12)
                sliderBar.Position = UDim2.new(0, 5, 0, 40)
                local barCorner = Instance.new("UICorner")
                barCorner.CornerRadius = UDim.new(1, 0)
                barCorner.Parent = sliderBar

                local fill = Instance.new("Frame")
                fill.Parent = sliderBar
                fill.BackgroundColor3 = Color3.fromRGB(140, 90, 230)
                fill.Size = UDim2.new((defaultVal - minVal)/(maxVal - minVal), 0, 1, 0)
                fill.BorderSizePixel = 0
                local fillCorner = Instance.new("UICorner")
                fillCorner.CornerRadius = UDim.new(1, 0)
                fillCorner.Parent = fill

                local value = defaultVal
                local draggingSlider = false
                
                -- Touch support untuk Android
                sliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                        local x = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                        value = math.floor(minVal + (maxVal - minVal) * x)
                        fill.Size = UDim2.new(x, 0, 1, 0)
                        label.Text = text .. " : " .. value
                        callback(value)
                    end
                end)
                
                userInput.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)
                
                userInput.InputChanged:Connect(function(input)
                    if draggingSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                        local x = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                        value = math.floor(minVal + (maxVal - minVal) * x)
                        fill.Size = UDim2.new(x, 0, 1, 0)
                        label.Text = text .. " : " .. value
                        callback(value)
                    end
                end)

                elementContainer.Size = UDim2.new(1, -20, 0, 40 + (#elementContainer:GetChildren() - 1) * 75)
                sectionFrame.Size = UDim2.new(1, -10, 0, 45 + (#elementContainer:GetChildren()) * 75)
            end

            return Elements
        end
        return Section
    end

    -- Touch drag untuk move UI
    local draggingEnabled = false
    local dragStartPos = nil
    local dragFramePos = nil
    local touchStarted = false

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingEnabled = true
            dragStartPos = input.Position
            dragFramePos = mainFrame.Position
            touchStarted = true
        end
    end)
    
    userInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingEnabled = false
            touchStarted = false
        end
    end)
    
    userInput.InputChanged:Connect(function(input)
        if draggingEnabled and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStartPos
            mainFrame.Position = UDim2.new(dragFramePos.X.Scale, dragFramePos.X.Offset + delta.X, dragFramePos.Y.Scale, dragFramePos.Y.Offset + delta.Y)
        end
    end)

    return Library
end

-- =========== MAIN FUNCTIONS (SAME) ===========
local window = Library:CreateWindow("Jujutsu Shenanigans")

-- Combat Tab
local combatTab = window:CreateTab("⚔️ Combat")
local combatSection = combatTab:CreateSection("Combat Modifiers")

combatSection:CreateButton("💀 Kill All Players", function()
    local players = game:GetService("Players"):GetPlayers()
    for _, target in ipairs(players) do
        if target ~= player and target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Health = 0
        end
    end
end)

combatSection:CreateButton("🔪 Kill Nearest", function()
    local closest = nil
    local closestDist = math.huge
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, target in pairs(game:GetService("Players"):GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (target.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = target
            end
        end
    end
    
    if closest and closest.Character and closest.Character:FindFirstChild("Humanoid") then
        closest.Character.Humanoid.Health = 0
    end
end)

combatSection:CreateSlider("⚡ Walk Speed", 16, 120, 16, function(value)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = value
    end
end)

combatSection:CreateSlider("🦘 Jump Power", 50, 200, 50, function(value)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = value
    end
end)

-- Teleport Tab
local tpTab = window:CreateTab("🌀 Teleport")
local tpSection = tpTab:CreateSection("Teleportation")

tpSection:CreateButton("📍 Teleport Forward", function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local move = camera.CFrame.LookVector * 20
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + move
    end
end)

tpSection:CreateButton("👥 Bring All Players", function()
    local myPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if myPos then
        for _, v in pairs(game:GetService("Players"):GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.CFrame = myPos.CFrame
            end
        end
    end
end)

-- Visuals Tab
local visTab = window:CreateTab("👁️ Visuals")
local visSection = visTab:CreateSection("ESP")

local espActive = false
visSection:CreateToggle("📦 ESP Box + Name", function(state)
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

-- Misc Tab
local miscTab = window:CreateTab("✨ Misc")
local miscSection = miscTab:CreateSection("Miscellaneous")

miscSection:CreateButton("📜 Load Infinite Yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

miscSection:CreateButton("🔄 Rejoin Game", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end)

local flyState = false
miscSection:CreateToggle("🕊️ Fly Mode", function(state)
    flyState = state
    if state then
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp
            
            local con = runService.RenderStepped:Connect(function()
                if not flyState or not player.Character then return end
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp or not bv.Parent then return end
                
                local moveDir = Vector3.new()
                if userInput:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
                if userInput:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
                if userInput:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
                if userInput:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
                if userInput:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if userInput:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                
                if moveDir.Magnitude > 0 then
                    bv.Velocity = moveDir.Unit * 60
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
                
                hrp.CanCollide = false
            end)
            
            getgenv()._flyBV = bv
            getgenv()._flyCon = con
        end
    else
        if getgenv()._flyBV then getgenv()._flyBV:Destroy() end
        if getgenv()._flyCon then getgenv()._flyCon:Disconnect() end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CanCollide = true
        end
    end
end)

-- Toggle UI dengan tombol Volume Down (Android)
userInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.VolumeDown then
        mainGui.Enabled = not mainGui.Enabled
    end
    -- Alternative: tiga jari tap (kalo executor support)
end)

print("✅ Architect 03 — Android Edition Loaded!")
print("📱 Tekan Tombol Volume Bawah untuk toggle GUI")
print("🎮 Support Touch Screen - Tap tombol langsung")
