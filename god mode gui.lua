-- Delta X Admin Panel (God Mode + Fly Mode)
-- Полностью автономный скрипт с автоматическим созданием GUI

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

    -- Получаем локального игрока
    local player = Players.LocalPlayer
    repeat task.wait() until player:FindFirstChild("PlayerGui")
    local playerGui = player.PlayerGui

    -- Удаляем старое GUI если есть
    local existingGui = playerGui:FindFirstChild("DeltaXAdminGUI")
    if existingGui then existingGui:Destroy() end

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
    splashText.TextColor3 = Color3.fromRGB(170, 0, 255) -- Фиолетовый цвет
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
        button.TextSize = 14
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

    -- Создаем основной GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeltaXAdminGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
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

    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsFrame"
    buttonsFrame.Position = UDim2.new(0, 10, 0, 40)
    buttonsFrame.Size = UDim2.new(1, -20, 1, -50)
    buttonsFrame.BackgroundTransparency = 1

    -- Создаем кнопки управления
    local godButton = CreateButton(buttonsFrame, "GodButton", 
        UDim2.new(0, 0, 0, 0), 
        UDim2.new(1, 0, 0, 40), 
        "GOD MODE: OFF", 
        Color3.fromRGB(80, 80, 90))

    local flyButton = CreateButton(buttonsFrame, "FlyButton", 
        UDim2.new(0, 0, 0, 45), 
        UDim2.new(1, 0, 0, 40), 
        "FLY MODE: OFF", 
        Color3.fromRGB(80, 80, 90))

    local toggleGuiButton = CreateButton(buttonsFrame, "ToggleGuiButton", 
        UDim2.new(0, 0, 0, 90), 
        UDim2.new(1, 0, 0, 40), 
        "HIDE GUI", 
        Color3.fromRGB(70, 70, 80))

    -- Собираем GUI
    titleBar.Parent = mainFrame
    title.Parent = titleBar
    closeButton.Parent = titleBar
    buttonsFrame.Parent = mainFrame
    godButton.Parent = buttonsFrame
    flyButton.Parent = buttonsFrame
    toggleGuiButton.Parent = buttonsFrame
    mainFrame.Parent = screenGui
    screenGui.Parent = playerGui

    -- Логика работы
    local godEnabled = false
    local flyEnabled = false
    local guiVisible = true
    local bodyVelocity, bodyGyro

    -- Функция обновления интерфейса
    local function UpdateUI()
        godButton.Text = "GOD MODE: " .. (godEnabled and "ON" or "OFF")
        godButton.BackgroundColor3 = godEnabled and Color3.fromRGB(90, 180, 90) or Color3.fromRGB(80, 80, 90)
        
        flyButton.Text = "FLY MODE: " .. (flyEnabled and "ON" or "OFF")
        flyButton.BackgroundColor3 = flyEnabled and Color3.fromRGB(90, 90, 180) or Color3.fromRGB(80, 80, 90)
        
        toggleGuiButton.Text = guiVisible and "HIDE GUI" or "SHOW GUI"
    end

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
        
        RunService.Heartbeat:Connect(function()
            if not flyEnabled or not player.Character or not bodyVelocity or not bodyGyro then
                return
            end
            
            local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart
            if not root then return end
            
            local cam = workspace.CurrentCamera
            local direction = Vector3.new()
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + (cam.CFrame.LookVector * 50)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - (cam.CFrame.LookVector * 50)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - (cam.CFrame.RightVector * 50)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + (cam.CFrame.RightVector * 50)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 50, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 50, 0)
            end
            
            bodyVelocity.Velocity = direction
            bodyGyro.CFrame = cam.CFrame
        end)
    end

    local function StopFlying()
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
        UpdateUI()
    end)

    -- Закрытие GUI
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        _G.DeltaXAdminLoaded = false
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
end

-- Запускаем скрипт
DeltaXAdmin()
