-- Delta X Admin Panel (Fly Mode + Speed + Gravity + ESP)
-- Фиолетовая надпись + лаймовые контуры + улучшенное управление

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
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local Workspace = game:GetService("Workspace")
    local CoreGui = game:GetService("CoreGui")

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

    -- Очищаем старый ESP
    for _, obj in pairs(CoreGui:GetChildren()) do
        if obj.Name == "ESP_Boxes" then
            obj:Destroy()
        end
    end

    -- Цвета
    local LIME_COLOR = Color3.fromRGB(50, 255, 50)  -- Лаймовый для контуров
    local PURPLE_COLOR = Color3.fromRGB(170, 0, 255) -- Фиолетовый для надписи

    -- Создаем заставку с фиолетовой надписью
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
    splashText.TextColor3 = PURPLE_COLOR  -- ФИОЛЕТОВАЯ надпись
    splashText.TextSize = 28
    splashText.Font = Enum.Font.GothamBold
    splashText.BackgroundTransparency = 1
    splashText.Size = UDim2.new(1, 0, 0, 50)
    splashText.Position = UDim2.new(0, 0, 0.5, -25)

    -- Собираем заставку
    splashFrame.Parent = splashScreen
    splashText.Parent = splashFrame
    splashScreen.Parent = playerGui

    -- Функция для создания кнопок с лаймовыми контурами
    local function CreateButton(parent, name, position, size, text, color)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Position = position
        button.Size = size
        button.Text = text
        button.TextColor3 = Color3.new(1, 1, 1)
        button.BackgroundColor3 = color
        button.BorderColor3 = LIME_COLOR  -- Лаймовый контур
        button.BorderSizePixel = 2
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
                ),
                BorderColor3 = Color3.fromRGB(100, 255, 100)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = color,
                BorderColor3 = LIME_COLOR
            }):Play()
        end)
        
        return button
    end

    -- Функция для создания слайдеров с полем ввода
    local function CreateSliderWithInput(parent, name, position, width, text, minValue, maxValue, defaultValue)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = name
        sliderFrame.Position = position
        sliderFrame.Size = UDim2.new(0, width, 0, 30)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Text = text
        label.TextColor3 = LIME_COLOR  -- Лаймовый текст
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.Size = UDim2.new(0.3, 0, 1, 0)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame

        -- Поле для ввода значения
        local inputBox = Instance.new("TextBox")
        inputBox.Name = "InputBox"
        inputBox.Position = UDim2.new(0.3, 5, 0, 0)
        inputBox.Size = UDim2.new(0.3, -10, 1, 0)
        inputBox.Text = tostring(defaultValue)
        inputBox.TextColor3 = Color3.new(1, 1, 1)
        inputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        inputBox.BorderColor3 = LIME_COLOR  -- Лаймовый контур
        inputBox.BorderSizePixel = 2
        inputBox.Font = Enum.Font.Gotham
        inputBox.TextSize = 11
        inputBox.TextXAlignment = Enum.TextXAlignment.Center
        inputBox.ClearTextOnFocus = false
        inputBox.Parent = sliderFrame

        local minusButton = CreateButton(sliderFrame, "MinusButton", 
            UDim2.new(0.6, 5, 0, 0), 
            UDim2.new(0.2, -5, 1, 0), 
            "-", 
            Color3.fromRGB(100, 60, 60))

        local plusButton = CreateButton(sliderFrame, "PlusButton", 
            UDim2.new(0.8, 5, 0, 0), 
            UDim2.new(0.2, -5, 1, 0), 
            "+", 
            Color3.fromRGB(60, 100, 60))

        local currentValue = defaultValue

        local function updateValue(newValue)
            currentValue = math.clamp(newValue, minValue, maxValue)
            inputBox.Text = tostring(currentValue)
            return currentValue
        end

        -- Обработка ввода с клавиатуры
        inputBox.FocusLost:Connect(function(enterPressed)
            local newValue = tonumber(inputBox.Text)
            if newValue then
                updateValue(newValue)
            else
                inputBox.Text = tostring(currentValue)
            end
        end)

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

    -- Создаем основной GUI с лаймовыми контурами
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeltaXAdminGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size = UDim2.new(0, 350, 0, 310)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BorderColor3 = LIME_COLOR  -- Лаймовый контур
    mainFrame.BorderSizePixel = 2
    mainFrame.BackgroundTransparency = 0.1

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    titleBar.BorderColor3 = LIME_COLOR  -- Лаймовый контур
    titleBar.BorderSizePixel = 2

    -- Делаем titleBar активной для перемещения на всех устройствах
    titleBar.Active = true
    titleBar.Selectable = true

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "DELTA X ADMIN"
    title.TextColor3 = LIME_COLOR  -- Лаймовый текст
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local closeButton = CreateButton(titleBar, "CloseButton", 
        UDim2.new(1, -30, 0, 5), 
        UDim2.new(0, 20, 0, 20), 
        "X", 
        Color3.fromRGB(200, 60, 60))

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Position = UDim2.new(0, 10, 0, 40)
    scrollFrame.Size = UDim2.new(1, -20, 1, -50)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 380)
    scrollFrame.ScrollBarImageColor3 = LIME_COLOR  -- Лаймовый скроллбар

    local buttonsLayout = Instance.new("UIListLayout")
    buttonsLayout.Name = "ButtonsLayout"
    buttonsLayout.Padding = UDim.new(0, 5)
    buttonsLayout.Parent = scrollFrame

    -- Создаем кнопки управления
    local flyButton = CreateButton(scrollFrame, "FlyButton", 
        UDim2.new(0, 0, 0, 0), 
        UDim2.new(1, 0, 0, 35), 
        "FLY MODE: OFF", 
        Color3.fromRGB(80, 80, 90))

    local espButton = CreateButton(scrollFrame, "ESPButton", 
        UDim2.new(0, 0, 0, 0), 
        UDim2.new(1, 0, 0, 35), 
        "ESP: OFF", 
        Color3.fromRGB(80, 80, 90))

    -- Создаем слайдеры с полями ввода
    local flySpeedSlider, getFlySpeed, setFlySpeed = CreateSliderWithInput(scrollFrame, "FlySpeedSlider", 
        UDim2.new(0, 0, 0, 0), 300, "Fly Speed:", 10, 200, 50)

    local walkSpeedSlider, getWalkSpeed, setWalkSpeed = CreateSliderWithInput(scrollFrame, "WalkSpeedSlider", 
        UDim2.new(0, 0, 0, 0), 300, "Walk Speed:", 16, 100, 16)

    local jumpPowerSlider, getJumpPower, setJumpPower = CreateSliderWithInput(scrollFrame, "JumpPowerSlider", 
        UDim2.new(0, 0, 0, 0), 300, "Jump Power:", 50, 200, 50)

    local gravitySlider, getGravity, setGravity = CreateSliderWithInput(scrollFrame, "GravitySlider", 
        UDim2.new(0, 0, 0, 0), 300, "Gravity:", 0, 200, 196)

    local toggleGuiButton = CreateButton(scrollFrame, "ToggleGuiButton", 
        UDim2.new(0, 0, 0, 0), 
        UDim2.new(1, 0, 0, 35), 
        "HIDE GUI", 
        Color3.fromRGB(70, 70, 80))

    -- Собираем GUI
    titleBar.Parent = mainFrame
    title.Parent = titleBar
    scrollFrame.Parent = mainFrame
    mainFrame.Parent = screenGui
    screenGui.Parent = playerGui

    -- Логика работы
    local flyEnabled = false
    local espEnabled = false
    local guiVisible = true
    local bodyVelocity, bodyGyro
    local flyConnection
    local espConnection
    local isMobile = UserInputService.TouchEnabled
    local originalGravity = Workspace.Gravity

    -- Сохраняем оригинальные значения
    local originalWalkSpeed = 16
    local originalJumpPower = 50

    -- Улучшенная система перемещения окна для ПК и телефона
    local dragging = false
    local dragStart = Vector2.new()
    local startPosition = UDim2.new()

    -- Функция для начала перемещения
    local function StartDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = mainFrame.Position
        end
    end

    -- Функция для обновления позиции при перемещении
    local function UpdateDrag(input)
        if dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPosition.X.Scale, 
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, 
                startPosition.Y.Offset + delta.Y
            )
        end
    end

    -- Функция для завершения перемещения
    local function StopDrag(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
        end
    end

    -- Подключаем обработчики для перемещения (работает на всех устройствах)
    titleBar.InputBegan:Connect(StartDrag)
    title.InputBegan:Connect(StartDrag)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateDrag(input)
        end
    end)

    UserInputService.InputEnded:Connect(StopDrag)

    -- Создаем ESP GUI с лаймовыми контурами
    local espGui = Instance.new("ScreenGui")
    espGui.Name = "ESP_Boxes"
    espGui.ResetOnSpawn = false
    espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    espGui.Enabled = false
    espGui.Parent = CoreGui

    -- Переменные для ESP
    local espBoxes = {}
    local espNames = {}
    local espTracers = {}

    -- Функция создания ESP box с лаймовыми контурами
    local function CreateESPBox(player)
        if player == Players.LocalPlayer then return end
        
        local box = Instance.new("Frame")
        box.Name = player.Name .. "_ESP"
        box.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        box.BackgroundTransparency = 0.9
        box.BorderColor3 = LIME_COLOR  -- Лаймовый контур ESP
        box.BorderSizePixel = 2
        box.Size = UDim2.new(0, 50, 0, 80)
        box.Visible = false
        box.Parent = espGui
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = LIME_COLOR  -- Лаймовый текст
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 0, 15)
        nameLabel.Position = UDim2.new(0, 0, 0, -15)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 12
        nameLabel.Parent = box
        
        local tracer = Instance.new("Frame")
        tracer.Name = player.Name .. "_Tracer"
        tracer.BackgroundColor3 = LIME_COLOR  -- Лаймовый трейсер
        tracer.BackgroundTransparency = 0.7
        tracer.BorderSizePixel = 0
        tracer.Size = UDim2.new(0, 1, 0, 100)
        tracer.Visible = false
        tracer.Parent = espGui
        
        espBoxes[player] = box
        espNames[player] = nameLabel
        espTracers[player] = tracer
    end

    -- Функция обновления ESP
    local function UpdateESP()
        for player, box in pairs(espBoxes) do
            if player and player.Character and box then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                if humanoidRootPart and humanoid and humanoid.Health > 0 then
                    local position, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                    
                    if onScreen then
                        local distance = (humanoidRootPart.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude
                        local scale = 1000 / distance
                        
                        box.Size = UDim2.new(0, 20 * scale, 0, 40 * scale)
                        box.Position = UDim2.new(0, position.X - box.Size.X.Offset / 2, 0, position.Y - box.Size.Y.Offset / 2)
                        box.Visible = espEnabled
                        
                        -- Трейсер
                        local screenCenter = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y)
                        local footPosition = Workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(0, -3, 0))
                        
                        if footPosition.Z > 0 then
                            local angle = math.atan2(footPosition.Y - screenCenter.Y, footPosition.X - screenCenter.X)
                            local length = 100
                            
                            espTracers[player].Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
                            espTracers[player].Size = UDim2.new(0, length, 0, 2)
                            espTracers[player].Rotation = math.deg(angle)
                            espTracers[player].Visible = espEnabled
                        else
                            espTracers[player].Visible = false
                        end
                    else
                        box.Visible = false
                        espTracers[player].Visible = false
                    end
                else
                    box.Visible = false
                    if espTracers[player] then
                        espTracers[player].Visible = false
                    end
                end
            end
        end
    end

    -- Функция включения/выключения ESP
    local function ToggleESP(enable)
        espEnabled = enable
        espGui.Enabled = enable
        
        if enable then
            for _, player in pairs(Players:GetPlayers()) do
                CreateESPBox(player)
            end
            
            if espConnection then
                espConnection:Disconnect()
            end
            espConnection = RunService.RenderStepped:Connect(UpdateESP)
        else
            if espConnection then
                espConnection:Disconnect()
                espConnection = nil
            end
            
            for _, box in pairs(espBoxes) do
                if box then
                    box:Destroy()
                end
            end
            espBoxes = {}
            espNames = {}
            
            for _, tracer in pairs(espTracers) do
                if tracer then
                    tracer:Destroy()
                end
            end
            espTracers = {}
        end
    end

    -- Обработчик новых игроков
    Players.PlayerAdded:Connect(function(player)
        if espEnabled then
            CreateESPBox(player)
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        if espBoxes[player] then
            espBoxes[player]:Destroy()
            espBoxes[player] = nil
        end
        if espTracers[player] then
            espTracers[player]:Destroy()
            espTracers[player] = nil
        end
    end

    -- Создаем элементы управления для полета (универсальные для ПК и телефона)
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
    joyStick.BorderColor3 = LIME_COLOR  -- Лаймовый контур
    joyStick.BorderSizePixel = 2
    joyStick.Parent = flyControls

    local joyStickKnob = Instance.new("Frame")
    joyStickKnob.Name = "JoyStickKnob"
    joyStickKnob.Size = UDim2.new(0, 40, 0, 40)
    joyStickKnob.Position = UDim2.new(0.5, -20, 0.5, -20)
    joyStickKnob.BackgroundColor3 = LIME_COLOR  -- Лаймовый джойстик
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
    pcControls.TextColor3 = LIME_COLOR  -- Лаймовый текст
    pcControls.BackgroundTransparency = 1
    pcControls.Font = Enum.Font.Gotham
    pcControls.TextSize = 12
    pcControls.Size = UDim2.new(1, 0, 0, 20)
    pcControls.Position = UDim2.new(0, 0, 1, 10)
    pcControls.Parent = flyControls

    flyControls.Parent = playerGui

    -- Переменные для управления полетом
    local joyStickActive = false
    local joyStickStartPos = Vector2.new()
    local joyStickDirection = Vector2.new()
    local upPressed = false
    local downPressed = false

    -- Обработка мобильного управления полетом
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
    
    -- Кнопки высоты для мобильных
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

    -- Функция обновления интерфейса
    local function UpdateUI()
        flyButton.Text = "FLY MODE: " .. (flyEnabled and "ON" or "OFF")
        flyButton.BackgroundColor3 = flyEnabled and Color3.fromRGB(90, 90, 180) or Color3.fromRGB(80, 80, 90)
        
        espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
        espButton.BackgroundColor3 = espEnabled and Color3.fromRGB(180, 90, 90) or Color3.fromRGB(80, 80, 90)
        
        toggleGuiButton.Text = guiVisible and "HIDE GUI" or "SHOW GUI"
        
        -- Автоматическое определение устройств
        if UserInputService.TouchEnabled then
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
        
        humanoid.WalkSpeed = getWalkSpeed()
        humanoid.JumpPower = getJumpPower()
        Workspace.Gravity = getGravity()
    end

    -- Обработка изменений слайдеров
    local function onStatChange()
        ApplyStats()
    end

    -- Fly Mode логика (универсальная для ПК и телефона)
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
            
            -- Универсальное управление для ПК и телефона
            if UserInputService.TouchEnabled then
                -- Мобильное управление
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
                -- ПК управление
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

    -- ESP логика
    espButton.MouseButton1Click:Connect(function()
        ToggleESP(not espEnabled)
        UpdateUI()
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
        Workspace.Gravity = originalGravity
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = originalWalkSpeed
                humanoid.JumpPower = originalJumpPower
            end
        end
        
        ToggleESP(false)
        screenGui:Destroy()
        showGuiButton:Destroy()
        flyControls:Destroy()
        _G.DeltaXAdminLoaded = false
    end)

    -- Применяем настройки при появлении персонажа
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid")
       
сделай чтобы все контуры гуи были лаймовые а надпись "MADE BY SOJO" была фиолетовая, и чтобы двигать гуи и управлять полетом можно было и на пк и на телефоне
Вот обновлённый скрипт с фиолетовой надписью "MADE BY SOJO" и лаймовыми контурами GUI:

lua
-- Delta X Admin Panel (Fly Mode + Speed + Gravity + ESP)
-- Фиолетовая надпись "MADE BY SOJO" + лаймовые контуры

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
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local Workspace = game:GetService("Workspace")
    local CoreGui = game:GetService("CoreGui")

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

    -- Очищаем старый ESP
    for _, obj in pairs(CoreGui:GetChildren()) do
        if obj.Name == "ESP_Boxes" then
            obj:Destroy()
        end
    end

    -- Цвета
    local LIME_COLOR = Color3.fromRGB(50, 255, 50)  -- Лаймовый для контуров
    local PURPLE_COLOR = Color3.fromRGB(170, 0, 255) -- Фиолетовый для надписи

    -- Создаем заставку с ФИОЛЕТОВОЙ надписью
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
    splashText.TextColor3 = PURPLE_COLOR  -- ФИОЛЕТОВАЯ надпись
    splashText.TextSize = 28
    splashText.Font = Enum.Font.GothamBold
    splashText.BackgroundTransparency = 1
    splashText.Size = UDim2.new(1, 0, 0, 50)
    splashText.Position = UDim2.new(0, 0, 0.5, -25)

    -- Собираем заставку
    splashFrame.Parent = splashScreen
    splashText.Parent = splashFrame
    splashScreen.Parent = playerGui

    -- Функция для создания кнопок с ЛАЙМОВЫМИ контурами
    local function CreateButton(parent, name, position, size, text, color)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Position = position
        button.Size = size
        button.Text = text
        button.TextColor3 = Color3.new(1, 1, 1)
        button.BackgroundColor3 = color
        button.BorderColor3 = LIME_COLOR  -- ЛАЙМОВЫЙ контур
        button.BorderSizePixel = 2
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
                ),
                BorderColor3 = Color3.fromRGB(100, 255, 100)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = color,
                BorderColor3 = LIME_COLOR
            }):Play()
        end)
        
        return button
    end

    -- Функция для создания слайдеров с полем ввода
    local function CreateSliderWithInput(parent, name, position, width, text, minValue, maxValue, defaultValue)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = name
        sliderFrame.Position = position
        sliderFrame.Size = UDim2.new(0, width, 0, 30)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Text = text
        label.TextColor3 = LIME_COLOR  -- Лаймовый текст
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.Size = UDim2.new(0.3, 0, 1, 0)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame

        -- Поле для ввода значения
        local inputBox = Instance.new("TextBox")
        inputBox.Name = "InputBox"
        inputBox.Position = UDim2.new(0.3, 5, 0, 0)
        inputBox.Size = UDim2.new(0.3, -10, 1, 0)
        inputBox.Text = tostring(defaultValue)
        inputBox.TextColor3 = Color3.new(1, 1, 1)
        inputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        inputBox.BorderColor3 = LIME_COLOR  -- Лаймовый контур
        inputBox.BorderSizePixel = 2
        inputBox.Font = Enum.Font.Gotham
        inputBox.TextSize = 11
        inputBox.TextXAlignment = Enum.TextXAlignment.Center
        inputBox.ClearTextOnFocus = false
        inputBox.Parent = sliderFrame

        local minusButton = CreateButton(sliderFrame, "MinusButton", 
            UDim2.new(0.6, 5, 0, 0), 
            UDim2.new(0.2, -5, 1, 0), 
            "-", 
            Color3.fromRGB(100, 60, 60))

        local plusButton = CreateButton(sliderFrame, "PlusButton", 
            UDim2.new(0.8, 5, 0, 0), 
            UDim2.new(0.2, -5, 1, 0), 
            "+", 
            Color3.fromRGB(60, 100, 60))

        local currentValue = defaultValue

        local function updateValue(newValue)
            currentValue = math.clamp(newValue, minValue, maxValue)
            inputBox.Text = tostring(currentValue)
            return currentValue
        end

        -- Обработка ввода с клавиатуры
        inputBox.FocusLost:Connect(function(enterPressed)
            local newValue = tonumber(inputBox.Text)
            if newValue then
                updateValue(newValue)
            else
                inputBox.Text = tostring(currentValue)
            end
        end)

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

    -- Создаем основной GUI с ЛАЙМОВЫМИ контурами
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeltaXAdminGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size = UDim2.new(0, 350, 0, 310)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BorderColor3 = LIME_COLOR  -- ЛАЙМОВЫЙ контур
    mainFrame.BorderSizePixel = 2
    mainFrame.BackgroundTransparency = 0.1

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    titleBar.BorderColor3 = LIME_COLOR  -- ЛАЙМОВЫЙ контур
    titleBar.BorderSizePixel = 2

    -- Делаем titleBar активной для перемещения на всех устройствах
    titleBar.Active = true
    titleBar.Selectable = true

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "DELTA X ADMIN"
    title.TextColor3 = LIME_COLOR  -- Лаймовый текст
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local closeButton = CreateButton(titleBar, "CloseButton", 
        UDim2.new(1, -30, 0, 5), 
        UDim2.new(0, 20, 0, 20), 
        "X", 
        Color3.fromRGB(200, 60, 60))

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Position = UDim2.new(0, 10, 0, 40)
    scrollFrame.Size = UDim2.new(1, -20, 1, -50)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 380)
    scrollFrame.ScrollBarImageColor3 = LIME_COLOR  -- Лаймовый скроллбар

    local buttonsLayout = Instance.new("UIListLayout")
    buttonsLayout.Name = "ButtonsLayout"
    buttonsLayout.Padding = UDim.new(0, 5)
    buttonsLayout.Parent = scrollFrame

    -- Создаем кнопки управления
    local flyButton = CreateButton(scrollFrame, "FlyButton", 
        UDim2.new(0, 0, 0, 0), 
        UDim2.new(1, 0, 0, 35), 
        "FLY MODE: OFF", 
        Color3.fromRGB(80, 80, 90))

    local espButton = CreateButton(scrollFrame, "ESPButton", 
        UDim2.new(0, 0, 0, 0), 
        UDim2.new(1, 0, 0, 35), 
        "ESP: OFF", 
        Color3.fromRGB(80, 80, 90))

    -- Создаем слайдеры с полями ввода
    local flySpeedSlider, getFlySpeed, setFlySpeed = CreateSliderWithInput(scrollFrame, "FlySpeedSlider", 
        UDim2.new(0, 0, 0, 0), 300, "Fly Speed:", 10, 200, 50)

    local walkSpeedSlider, getWalkSpeed, setWalkSpeed = CreateSliderWithInput(scrollFrame, "WalkSpeedSlider", 
        UDim2.new(0, 0, 0, 0), 300, "Walk Speed:", 16, 100, 16)

    local jumpPowerSlider, getJumpPower, setJumpPower = CreateSliderWithInput(scrollFrame, "JumpPowerSlider", 
        UDim2.new(0, 0, 0, 0), 300, "Jump Power:", 50, 200, 50)

    local gravitySlider, getGravity, setGravity = CreateSliderWithInput(scrollFrame, "GravitySlider", 
        UDim2.new(0, 0, 0, 0), 300, "Gravity:", 0, 200, 196)

    local toggleGuiButton = CreateButton(scrollFrame, "ToggleGuiButton", 
        UDim2.new(0, 0, 0, 0), 
        UDim2.new(1, 0, 0, 35), 
        "HIDE GUI", 
        Color3.fromRGB(70, 70, 80))

    -- Собираем GUI
    titleBar.Parent = mainFrame
    title.Parent = titleBar
    scrollFrame.Parent = mainFrame
    mainFrame.Parent = screenGui
    screenGui.Parent = playerGui

    -- Логика работы
    local flyEnabled = false
    local espEnabled = false
    local guiVisible = true
    local bodyVelocity, bodyGyro
    local flyConnection
    local espConnection
    local originalGravity = Workspace.Gravity

    -- Сохраняем оригинальные значения
    local originalWalkSpeed = 16
    local originalJumpPower = 50

    -- Улучшенная система перемещения окна для ПК и телефона
    local dragging = false
    local dragStart = Vector2.new()
    local startPosition = UDim2.new()

    -- Функция для начала перемещения
    local function StartDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = mainFrame.Position
        end
    end

    -- Функция для обновления позиции при перемещении
    local function UpdateDrag(input)
        if dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPosition.X.Scale, 
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, 
                startPosition.Y.Offset + delta.Y
            )
        end
    end

    -- Функция для завершения перемещения
    local function StopDrag(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
        end
    end

    -- Подключаем обработчики для перемещения (работает на всех устройствах)
    titleBar.InputBegan:Connect(StartDrag)
    title.InputBegan:Connect(StartDrag)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateDrag(input)
        end
    end)

    UserInputService.InputEnded:Connect(StopDrag)

    -- Создаем ESP GUI с лаймовыми контурами
    local espGui = Instance.new("ScreenGui")
    espGui.Name = "ESP_Boxes"
    espGui.ResetOnSpawn = false
    espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    espGui.Enabled = false
    espGui.Parent = CoreGui

    -- Переменные для ESP
    local espBoxes = {}
    local espNames = {}
    local espTracers = {}

    -- Функция создания ESP box с лаймовыми контурами
    local function CreateESPBox(player)
        if player == Players.LocalPlayer then return end
        
        local box = Instance.new("Frame")
        box.Name = player.Name .. "_ESP"
        box.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        box.BackgroundTransparency = 0.9
        box.BorderColor3 = LIME_COLOR  -- Лаймовый контур ESP
        box.BorderSizePixel = 2
        box.Size = UDim2.new(0, 50, 0, 80)
        box.Visible = false
        box.Parent = espGui
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = LIME_COLOR  -- Лаймовый текст
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 0, 15)
        nameLabel.Position = UDim2.new(0, 0, 0, -15)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 12
        nameLabel.Parent = box
        
        local tracer = Instance.new("Frame")
        tracer.Name = player.Name .. "_Tracer"
        tracer.BackgroundColor3 = LIME_COLOR  -- Лаймовый трейсер
        tracer.BackgroundTransparency = 0.7
        tracer.BorderSizePixel = 0
        tracer.Size = UDim2.new(0, 1, 0, 100)
        tracer.Visible = false
        tracer.Parent = espGui
        
        espBoxes[player] = box
        espNames[player] = nameLabel
        espTracers[player] = tracer
    end

    -- Функция обновления ESP
    local function UpdateESP()
        for player, box in pairs(espBoxes) do
            if player and player.Character and box then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                if humanoidRootPart and humanoid and humanoid.Health > 0 then
                    local position, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                    
                    if onScreen then
                        local distance = (humanoidRootPart.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude
                        local scale = 1000 / distance
                        
                        box.Size = UDim2.new(0, 20 * scale, 0, 40 * scale)
                        box.Position = UDim2.new(0, position.X - box.Size.X.Offset / 2, 0, position.Y - box.Size.Y.Offset / 2)
                        box.Visible = espEnabled
                        
                        -- Трейсер
                        local screenCenter = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y)
                        local footPosition = Workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(0, -3, 0))
                        
                        if footPosition.Z > 0 then
                            local angle = math.atan2(footPosition.Y - screenCenter.Y, footPosition.X - screenCenter.X)
                            local length = 100
                            
                            espTracers[player].Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
                            espTracers[player].Size = UDim2.new(0, length, 0, 2)
                            espTracers[player].Rotation = math.deg(angle)
                            espTracers[player].Visible = espEnabled
                        else
                            espTracers[player].Visible = false
                        end
                    else
                        box.Visible = false
                        espTracers[player].Visible = false
                    end
                else
                    box.Visible = false
                    if espTracers[player] then
                        espTracers[player].Visible = false
                    end
                end
            end
        end
    end

    -- Функция включения/выключения ESP
    local function ToggleESP(enable)
        espEnabled = enable
        espGui.Enabled = enable
        
        if enable then
            for _, player in pairs(Players:GetPlayers()) do
                CreateESPBox(player)
            end
            
            if espConnection then
                espConnection:Disconnect()
            end
            espConnection = RunService.RenderStepped:Connect(UpdateESP)
        else
            if espConnection then
                espConnection:Disconnect()
                espConnection = nil
            end
            
            for _, box in pairs(espBoxes) do
                if box then
                    box:Destroy()
                end
            end
            espBoxes = {}
            espNames = {}
            
            for _, tracer in pairs(espTracers) do
                if tracer then
                    tracer:Destroy()
                end
            end
            espTracers = {}
        end
    end

    -- Обработчик новых игроков
    Players.PlayerAdded:Connect(function(player)
        if espEnabled then
            CreateESPBox(player)
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        if espBoxes[player] then
            espBoxes[player]:Destroy()
            espBoxes[player] = nil
        end
        if espTracers[player] then
            espTracers[player]:Destroy()
            espTracers[player] = nil
        end
    end

    -- Создаем элементы управления для полета (универсальные для ПК и телефона)
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
    joyStick.BorderColor3 = LIME_COLOR  -- Лаймовый контур
    joyStick.BorderSizePixel = 2
    joyStick.Parent = flyControls

    local joyStickKnob = Instance.new("Frame")
    joyStickKnob.Name = "JoyStickKnob"
    joyStickKnob.Size = UDim2.new(0, 40, 0, 40)
    joyStickKnob.Position = UDim2.new(0.5, -20, 0.5, -20)
    joyStickKnob.BackgroundColor3 = LIME_COLOR  -- Лаймовый джойстик
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
    pcControls.TextColor3 = LIME_COLOR  -- Лаймовый текст
    pcControls.BackgroundTransparency = 1
    pcControls.Font = Enum.Font.Gotham
    pcControls.TextSize = 12
    pcControls.Size = UDim2.new(1, 0, 0, 20)
    pcControls.Position = UDim2.new(0, 0, 1, 10)
    pcControls.Parent = flyControls

    flyControls.Parent = playerGui

    -- Переменные для управления полетом
    local joyStickActive = false
    local joyStickStartPos = Vector2.new()
    local joyStickDirection = Vector2.new()
    local upPressed = false
    local downPressed = false

    -- Обработка мобильного управления полетом
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
    
    -- Кнопки высоты для мобильных
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

    -- Функция обновления интерфейса
    local function UpdateUI()
        flyButton.Text = "FLY MODE: " .. (flyEnabled and "ON" or "OFF")
        flyButton.BackgroundColor3 = flyEnabled and Color3.fromRGB(90, 90, 180) or Color3.fromRGB(80, 80, 90)
        
        espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
        espButton.BackgroundColor3 = espEnabled and Color3.fromRGB(180, 90, 90) or Color3.fromRGB(80, 80, 90)
        
        toggleGuiButton.Text = guiVisible and "HIDE GUI" or "SHOW GUI"
        
        -- Автоматическое определение устройств
        if UserInputService.TouchEnabled then
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
        
        humanoid.WalkSpeed = getWalkSpeed()
        humanoid.JumpPower = getJumpPower()
        Workspace.Gravity = getGravity()
    end

    -- Обработка изменений слайдеров
    local function onStatChange()
        ApplyStats()
    end

    -- Fly Mode логика (универсальная для ПК и телефона)
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
            
            -- Универсальное управление для ПК и телефона
            if UserInputService.TouchEnabled then
                -- Мобильное управление
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
                -- ПК управление
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

    -- ESP логика
    espButton.MouseButton1Click:Connect(function()
        ToggleESP(not espEnabled)
        UpdateUI()
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
        Workspace.Gravity = originalGravity
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = originalWalkSpeed
                humanoid.JumpPower = originalJumpPower
            end
        end
        
        ToggleESP(false)
        screenGui:Destroy()
        showGuiButton:Destroy()
        flyControls:Destroy()
        _G.DeltaXAdminLoaded = false
    end)

    -- Применяем настройки при появлении персонажа
    player.CharacterAdded:Connect(function(character)
