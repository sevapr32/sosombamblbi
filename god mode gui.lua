-- Delta X Admin Panel (God Mode + Fly Mode + Speed + Gravity)
-- Полная поддержка ПК и мобильных устройств

local function DeltaXAdmin()
    -- Проверка на повторный запуск
    if _G.DeltaXAdminLoaded then return end
    _G.DeltaXAdminLoaded = true

    -- Ожидаем загрузку игры
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    -- Получаем сервисы
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local Workspace = game:GetService("Workspace")

    -- Получаем локального игрока
    local player = Players.LocalPlayer
    repeat task.wait() until player:FindFirstChild("PlayerGui")
    local playerGui = player.PlayerGui

    -- Удаляем старое GUI если есть
    local existingGui = playerGui:FindFirstChild("DeltaXAdminGUI")
    if existingGui then existingGui:Destroy() end
    local existingToggle = playerGui:FindFirstChild("ShowGUIButton")
    if existingToggle then existingToggle:Destroy() end
    local existingControls = playerGui:FindFirstChild("FlyControls")
    if existingControls then existingControls:Destroy() end

    -- Создаем заставку
    local splashScreen = Instance.new("ScreenGui")
    splashScreen.Name = "SplashScreen"
    splashScreen.ResetOnSpawn = false
    splashScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local splashFrame = Instance.new("Frame")
    splashFrame.Size = UDim2.new(1, 0, 1, 0)
    splashFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    splashFrame.BackgroundTransparency = 0.7
    splashFrame.BorderSizePixel = 0

    local splashText = Instance.new("TextLabel")
    splashText.Text = "MADE BY SOJO"
    splashText.TextColor3 = Color3.fromRGB(170, 0, 255)
    splashText.TextSize = 28
    splashText.Font = Enum.Font.GothamBold
    splashText.BackgroundTransparency = 1
    splashText.Size = UDim2.new(1, 0, 0, 50)
    splashText.Position = UDim2.new(0, 0, 0.5, -25)

    -- Собираем заставку
    splashFrame.Parent = splashScreen
    splashText.Parent = splashFrame
    splashScreen.Parent = playerGui

    -- Функция для создания кнопок с анимацией
    local function CreateButton(parent, name, position, size, text, color)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Position = position
        button.Size = size
        button.Text = text
        button.TextColor3 = Color3.new(1, 1, 1)
        button.BackgroundColor3 = color
        button.BorderSizePixel = 0
        button.Font = Enum.Font.Gotham
        button.TextSize = 12
        button.Parent = parent
        
        -- Анимация при наведении
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.new(
                    math.min(color.R * 1.3, 1),
                    math.min(color.G * 1.3, 1),
                    math.min(color.B * 1.3, 1)
                )
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = color
            }):Play()
        end)
        
        return button
    end

    -- Функция для создания слайдеров
    local function CreateSlider(parent, name, position, width, text, minValue, maxValue, defaultValue)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = name
        sliderFrame.Position = position
        sliderFrame.Size = UDim2.new(0, width, 0, 30)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Name = "ValueLabel"
        valueLabel.Text = tostring(defaultValue)
        valueLabel.TextColor3 = Color3.new(1, 1, 1)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 11
        valueLabel.Size = UDim2.new(0.2, 0, 1, 0)
        valueLabel.Position = UDim2.new(0.4, 0, 0, 0)
        valueLabel.Parent = sliderFrame

        local minusButton = CreateButton(sliderFrame, "MinusButton", 
            UDim2.new(0.6, 0, 0, 0), 
            UDim2.new(0.1, 0, 1, 0), 
            "-", 
            Color3.fromRGB(100, 60, 60))

        local plusButton = CreateButton(sliderFrame, "PlusButton", 
            UDim2.new(0.9, 0, 0, 0), 
            UDim2.new(0.1, 0, 1, 0), 
            "+", 
            Color3.fromRGB(60, 100, 60))

        local currentValue = defaultValue

        local function updateValue(newValue)
            currentValue = math.clamp(newValue, minValue, maxValue)
            valueLabel.Text = tostring(currentValue)
            return currentValue
        end

        minusButton.MouseButton1Click:Connect(function()
            updateValue(currentValue - 1)
        end)

        plusButton.MouseButton1Click:Connect(function()
            updateValue(currentValue + 1)
        end)

        return sliderFrame, function() return currentValue end, updateValue
    end

    -- Показываем заставку
    splashText.TextTransparency = 1
    splashFrame.BackgroundTransparency = 1
    
    TweenService:Create(splashText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(splashFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.7}):Play()
    
    wait(1.5)
    
    TweenService:Create(splashText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(splashFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    
    wait(0.5)
    splashScreen:Destroy()

    -- Создаем кнопку для показа GUI
    local showGuiButton = Instance.new("ScreenGui")
    showGuiButton.Name = "ShowGUIButton"
    showGuiButton.ResetOnSpawn = false
    showGuiButton.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    showGuiButton.Enabled = false

    local showButton = CreateButton(showGuiButton, "ShowButton", 
        UDim2.new(0, 20, 0, 20), 
        UDim2.new(0, 100, 0, 40), 
        "SHOW GUI", 
        Color3.fromRGB(70, 70, 80))

    showGuiButton.Parent = playerGui

    -- Создаем основной GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeltaXAdminGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size = UDim2.new(0, 350, 0, 320)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.BackgroundTransparency = 0.1

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    titleBar.BorderSizePixel = 0

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "DELTA X ADMIN"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Position = UDim2.new(1, -30, 0, 5)
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Position = UDim2.new(0, 10, 0, 40)
    scrollFrame.Size = UDim2.new(1, -20, 1, -50)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 400)

    local buttonsLayout = Instance.new("UIListLayout")
    buttonsLayout.Name = "ButtonsLayout"
    buttonsLayout.Padding = UDim.new(0, 5)
    buttonsLayout.Parent = scrollFrame

    -- Создаем кнопки управления
    local godButton = CreateButton(scrollFrame, "GodButton", 
        UDim2.new(0, 0, 0, 0), 
        UDim2.new(1, 0, 0, 35), 
        "GOD MODE: OFF", 
        Color3.fromRGB(80, 80, 90))

    local flyButton = CreateButton(scrollFrame, "FlyButton", 
        UDim2.new(0, 0, 0, 0), 
        UDim2.new(1, 0, 0, 35), 
        "FLY MODE: OFF", 
        Color3.fromRGB(80, 80, 90))

    -- Создаем слайдеры
    local flySpeedSlider, getFlySpeed, setFlySpeed = CreateSlider(scrollFrame, "FlySpeedSlider", 
        UDim2.new(0, 0, 0, 0), 300, "Fly Speed:", 10, 200, 50)

    local walkSpeedSlider, getWalkSpeed, setWalkSpeed = CreateSlider(scrollFrame, "WalkSpeedSlider", 
        UDim2.new(0, 0, 0, 0), 300, "Walk Speed:", 16, 100, 16)

    local jumpPowerSlider, getJumpPower, setJumpPower = CreateSlider(scrollFrame, "JumpPowerSlider", 
        UDim2.new(0, 0, 0, 0), 300, "Jump Power:", 50, 200, 50)

    local gravitySlider, getGravity, setGravity = CreateSlider(scrollFrame, "GravitySlider", 
        UDim2.new(0, 0, 0, 0), 300, "Gravity:", 0, 200, 196)

    local toggleGuiButton = CreateButton(scrollFrame, "ToggleGuiButton", 
        UDim2.new(0, 0, 0, 0), 
        UDim2.new(1, 0, 0, 35), 
        "HIDE GUI", 
        Color3.fromRGB(70, 70, 80))

    -- Собираем GUI
    titleBar.Parent = mainFrame
    title.Parent = titleBar
    closeButton.Parent = titleBar
    scrollFrame.Parent = mainFrame
    mainFrame.Parent = screenGui
    screenGui.Parent = playerGui

    -- Логика работы
    local godEnabled = false
    local flyEnabled = false
    local guiVisible = true
    local bodyVelocity, bodyGyro
    local flyConnection
    local isMobile = UserInputService.TouchEnabled
    local originalGravity = Workspace.Gravity

    -- Сохраняем оригинальные значения
    local originalWalkSpeed = 16
    local originalJumpPower = 50

    -- Создаем элементы управления для полета
    local flyControls = Instance.new("ScreenGui")
    flyControls.Name = "FlyControls"
    flyControls.ResetOnSpawn = false
    flyControls.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    flyControls.Enabled = false

    local joyStick = Instance.new("Frame")
    joyStick.Name = "JoyStick"
    joyStick.Size = UDim2.new(0, 120, 0, 120)
    joyStick.Position = UDim2.new(0, 30, 1, -160)
    joyStick.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    joyStick.BackgroundTransparency = 0.8
    joyStick.BorderSizePixel = 0
    joyStick.Parent = flyControls

    local joyStickKnob = Instance.new("Frame")
    joyStickKnob.Name = "JoyStickKnob"
    joyStickKnob.Size = UDim2.new(0, 40, 0, 40)
    joyStickKnob.Position = UDim2.new(0.5, -20, 0.5, -20)
    joyStickKnob.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    joyStickKnob.BackgroundTransparency = 0.6
    joyStickKnob.BorderSizePixel = 0
    joyStickKnob.Parent = joyStick

    local upButton = CreateButton(flyControls, "UpButton", 
        UDim2.new(1, -80, 1, -180), 
        UDim2.new(0, 60, 0, 60), 
        "↑", 
        Color3.fromRGB(80, 80, 90))
        
    local downButton = CreateButton(flyControls, "DownButton", 
        UDim2.new(1, -80, 1, -110), 
        UDim2.new(0, 60, 0, 60), 
        "↓", 
        Color3.fromRGB(80, 80, 90))

    local pcControls = Instance.new("TextLabel")
    pcControls.Name = "PCControls"
    pcControls.Text = "PC: WASD + Space/Shift"
    pcControls.TextColor3 = Color3.new(1, 1, 1)
    pcControls.BackgroundTransparency = 1
    pcControls.Font = Enum.Font.Gotham
    pcControls.TextSize = 12
    pcControls.Size = UDim2.new(1, 0, 0, 20)
    pcControls.Position = UDim2.new(0, 0, 1, 10)
    pcControls.Parent = flyControls

    flyControls.Parent = playerGui

    -- Переменные для управления
    local joyStickActive = false
    local joyStickStartPos = Vector2.new()
    local joyStickDirection = Vector2.new()
    local upPressed = false
    local downPressed = false

    -- Функция обновления интерфейса
    local function UpdateUI()
        godButton.Text = "GOD MODE: " .. (godEnabled and "ON" or "OFF")
        godButton.BackgroundColor3 = godEnabled and Color3.fromRGB(90, 180, 90) or Color3.fromRGB(80, 80, 90)
        
        flyButton.Text = "FLY MODE: " .. (flyEnabled and "ON" or "OFF")
        flyButton.BackgroundColor3 = flyEnabled and Color3.fromRGB(90, 90, 180) or Color3.fromRGB(80, 80, 90)
        
        toggleGuiButton.Text = guiVisible and "HIDE GUI" or "SHOW GUI"
        
        if isMobile then
            joyStick.Visible = true
            upButton.Visible = true
            downButton.Visible = true
            pcControls.Visible = false
        else
            joyStick.Visible = false
            upButton.Visible = false
            downButton.Visible = false
            pcControls.Visible = true
        end
    end

    -- Функция применения скорости и гравитации
    local function ApplyStats()
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        -- Применяем скорость ходьбы
        humanoid.WalkSpeed = getWalkSpeed()
        
        -- Применяем силу прыжка
        humanoid.JumpPower = getJumpPower()
        
        -- Применяем гравитацию
        Workspace.Gravity = getGravity()
    end

    -- Обработка изменений слайдеров
    local function onStatChange()
        ApplyStats()
    end

    flySpeedSlider.Changed:Connect(onStatChange)
    walkSpeedSlider.Changed:Connect(onStatChange)
    jumpPowerSlider.Changed:Connect(onStatChange)
    gravitySlider.Changed:Connect(onStatChange)

    -- Обработка мобильного управления
    joyStick.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            joyStickActive = true
            joyStickStartPos = input.Position
        end
    end)
    
    joyStick.InputChanged:Connect(function(input)
        if joyStickActive and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - joyStickStartPos
            local maxDistance = 40
            local distance = math.min(delta.Magnitude, maxDistance)
            local direction = delta.Unit
            
            joyStickDirection = direction * (distance / maxDistance)
            joyStickKnob.Position = UDim2.new(0.5, -20 + direction.X * distance, 0.5, -20 + direction.Y * distance)
        end
    end)
    
    joyStick.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            joyStickActive = false
            joyStickDirection = Vector2.new()
            joyStickKnob.Position = UDim2.new(0.5, -20, 0.5, -20)
        end
    end)
    
    upButton.MouseButton1Down:Connect(function()
        upPressed = true
    end)
    
    upButton.MouseButton1Up:Connect(function()
        upPressed = false
    end)
    
    downButton.MouseButton1Down:Connect(function()
        downPressed = true
    end)
    
    downButton.MouseButton1Up:Connect(function()
        downPressed = false
    end)

    -- God Mode логика
    godButton.MouseButton1Click:Connect(function()
        godEnabled = not godEnabled
        UpdateUI()
    end)

    -- Fly Mode логика
    local function StartFlying()
        if not player.Character then return end
        
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        humanoid.PlatformStand = true
        flyControls.Enabled = true
        
        local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart
        if not root then return end
        
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = root
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)
        bodyGyro.P = 1000
        bodyGyro.D = 50
        bodyGyro.CFrame = root.CFrame
        bodyGyro.Parent = root
        
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled or not player.Character or not bodyVelocity or not bodyGyro then
                return
            end
            
            local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart
            if not root then return end
            
            local cam = workspace.CurrentCamera
            local direction = Vector3.new()
            local currentFlySpeed = getFlySpeed()
            
            if isMobile then
                if joyStickActive then
                    direction = direction + (cam.CFrame.RightVector * joyStickDirection.X * currentFlySpeed)
                    direction = direction - (cam.CFrame.LookVector * joyStickDirection.Y * currentFlySpeed)
                end
                if upPressed then
                    direction = direction + Vector3.new(0, currentFlySpeed, 0)
                end
                if downPressed then
                    direction = direction - Vector3.new(0, currentFlySpeed, 0)
                end
            else
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    direction = direction + (cam.CFrame.LookVector * currentFlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    direction = direction - (cam.CFrame.LookVector * currentFlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    direction = direction - (cam.CFrame.RightVector * currentFlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    direction = direction + (cam.CFrame.RightVector * currentFlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    direction = direction + Vector3.new(0, currentFlySpeed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    direction = direction - Vector3.new(0, currentFlySpeed, 0)
                end
            end
            
            bodyVelocity.Velocity = direction
            bodyGyro.CFrame = cam.CFrame
        end)
    end

    local function StopFlying()
        flyControls.Enabled = false
        
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
            
            local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart
            if root then
                for _, obj in ipairs(root:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then
                        obj:Destroy()
                    end
                end
            end
        end
        bodyVelocity = nil
        bodyGyro = nil
        
        joyStickActive = false
        joyStickDirection = Vector2.new()
        joyStickKnob.Position = UDim2.new(0.5, -20, 0.5, -20)
        upPressed = false
        downPressed = false
    end

    flyButton.MouseButton1Click:Connect(function()
        flyEnabled = not flyEnabled
        UpdateUI()
        
        if flyEnabled then
            StartFlying()
        else
            StopFlying()
        end
    end)

    -- Управление видимостью GUI
    toggleGuiButton.MouseButton1Click:Connect(function()
        guiVisible = not guiVisible
        screenGui.Enabled = guiVisible
        showGuiButton.Enabled = not guiVisible
        UpdateUI()
    end)

    -- Кнопка показа GUI
    showButton.MouseButton1Click:Connect(function()
        screenGui.Enabled = true
        showGuiButton.Enabled = false
        guiVisible = true
        UpdateUI()
    end)

    -- Закрытие GUI
    closeButton.MouseButton1Click:Connect(function()
        -- Восстанавливаем оригинальные значения
        Workspace.Gravity = originalGravity
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = originalWalkSpeed
                humanoid.JumpPower = originalJumpPower
            end
        end
        
        screenGui:Destroy()
        showGuiButton:Destroy()
        flyControls:Destroy()
        _G.DeltaXAdminLoaded = false
    end)

    -- Применяем настройки при появлении персонажа
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid")
        ApplyStats()
    end)

    -- Перемещение GUI
    local dragging = false
    local dragInput, dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Первоначальное обновление UI
    UpdateUI()
    ApplyStats()
end

-- Запускаем скрипт
DeltaXAdmin()
