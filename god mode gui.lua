local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local userInputService = game:GetService("UserInputService")

local kotirScreen = Instance.new("ScreenGui")
kotirScreen.Name = "KotirScreen"
kotirScreen.IgnoreGuiInset = true
kotirScreen.ResetOnSpawn = false

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
textLabel.Text = "MADE BY SOJO"
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.TextScaled = true
textLabel.Font = Enum.Font.SciFi
textLabel.Parent = kotirScreen

kotirScreen.Parent = playerGui

wait(3)
kotirScreen:Destroy()
```

-- Delta X Admin Panel (God Mode + Fly Mode)
-- Автономный скрипт, не требует внешних зависимостей

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

    -- Создаем RemoteEvent для God Mode
    local REMOTE_NAME = "DeltaXAdminSystem_v6"
    local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME) or Instance.new("RemoteEvent")
    remote.Name = REMOTE_NAME
    remote.Parent = ReplicatedStorage

    -- Получаем локального игрока
    local player = Players.LocalPlayer
    repeat task.wait() until player:FindFirstChild("PlayerGui")
    local playerGui = player.PlayerGui

    -- Удаляем старое GUI если есть
    local existingGui = playerGui:FindFirstChild("DeltaXAdminGUI")
    if existingGui then
        existingGui:Destroy()
        task.wait()
    end

    -- Функция для создания элементов с защитой от ошибок
    local function CreateElement(className, props)
        local element = Instance.new(className)
        for prop, value in pairs(props) do
            pcall(function() element[prop] = value end)
        end
        return element
    end

    -- Создаем GUI
    local screenGui = CreateElement("ScreenGui", {
        Name = "DeltaXAdminGUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local mainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 350, 0, 250),
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BorderColor3 = Color3.fromRGB(50, 50, 60),
        BorderSizePixel = 1,
        BackgroundTransparency = 0.1
    })

    local titleBar = CreateElement("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        BorderSizePixel = 0
    })

    local title = CreateElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = "DELTA X ADMIN",
        TextColor3 = Color3.fromRGB(220, 220, 220),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local closeButton = CreateElement("TextButton", {
        Name = "CloseButton",
        Position = UDim2.new(1, -30, 0, 5),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "×",
        TextColor3 = Color3.fromRGB(220, 220, 220),
        BackgroundColor3 = Color3.fromRGB(200, 60, 60),
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        TextSize = 18
    })

    local buttonsFrame = CreateElement("Frame", {
        Name = "ButtonsFrame",
        Position = UDim2.new(0, 10, 0, 40),
        Size = UDim2.new(1, -20, 1, -50),
        BackgroundTransparency = 1
    })

    -- Собираем GUI
    titleBar.Parent = mainFrame
    title.Parent = titleBar
    closeButton.Parent = titleBar
    buttonsFrame.Parent = mainFrame
    mainFrame.Parent = screenGui
    screenGui.Parent = playerGui

    -- Функция создания кнопок с анимацией
    local function CreateButton(name, yPos, text, defaultColor)
        local button = CreateElement("TextButton", {
            Name = name,
            Position = UDim2.new(0, 0, 0, yPos),
            Size = UDim2.new(1, 0, 0, 40),
            Text = text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundColor3 = defaultColor,
            BorderSizePixel = 0,
            Font = Enum.Font.Gotham,
            TextSize = 14
        })

        -- Анимация при наведении
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.new(
                    math.min(defaultColor.R * 1.3, 1),
                    math.min(defaultColor.G * 1.3, 1),
                    math.min(defaultColor.B * 1.3, 1)
                )
            }:Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = defaultColor
            }:Play()
        end)

        button.Parent = buttonsFrame
        return button
    end

    -- Создаем кнопки управления
    local godToggle = CreateButton("GodToggle", 0, "GOD MODE: OFF", Color3.fromRGB(80, 80, 90))
    local flyToggle = CreateButton("FlyToggle", 45, "FLY MODE: OFF (WASD+Space/Shift)", Color3.fromRGB(80, 80, 90))
    local speedLabel = CreateButton("SpeedLabel", 90, "FLY SPEED: 50", Color3.fromRGB(60, 60, 70))
    speedLabel.AutoButtonColor = false

    -- Кнопки регулировки скорости
    local speedMinus = CreateElement("TextButton", {
        Name = "SpeedMinus",
        Position = UDim2.new(0, 0, 0, 135),
        Size = UDim2.new(0.5, -5, 0, 30),
        Text = "-",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(100, 60, 60),
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        TextSize = 16
    })

    local speedPlus = CreateElement("TextButton", {
        Name = "SpeedPlus",
        Position = UDim2.new(0.5, 5, 0, 135),
        Size = UDim2.new(0.5, -5, 0, 30),
        Text = "+",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(60, 100, 60),
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        TextSize = 16
    })

    speedMinus.Parent = buttonsFrame
    speedPlus.Parent = buttonsFrame

    -- Логика работы
    local godEnabled = false
    local flyEnabled = false
    local flySpeed = 50
    local bodyVelocity, bodyGyro

    -- Функция обновления интерфейса
    local function UpdateUI()
        godToggle.Text = "GOD MODE: " .. (godEnabled and "ON" or "OFF")
        godToggle.BackgroundColor3 = godEnabled and Color3.fromRGB(90, 180, 90) or Color3.fromRGB(80, 80, 90)
        
        flyToggle.Text = "FLY MODE: " .. (flyEnabled and "ON" or "OFF") .. " (WASD+Space/Shift)"
        flyToggle.BackgroundColor3 = flyEnabled and Color3.fromRGB(90, 90, 180) or Color3.fromRGB(80, 80, 90)
        
        speedLabel.Text = "FLY SPEED: " .. flySpeed
    end

    -- God Mode логика
    godToggle.MouseButton1Click:Connect(function()
        godEnabled = not godEnabled
        UpdateUI()
        remote:FireServer("ToggleGod", godEnabled)
    end)

    -- Fly Mode логика
    local function StartFlying()
        if not player.Character then return end
        
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        humanoid.PlatformStand = true
        
        local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart
        if not root then return end
        
        -- Очищаем старые объекты
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        
        bodyVelocity = CreateElement("BodyVelocity", {
            MaxForce = Vector3.new(10000, 10000, 10000),
            Velocity = Vector3.new(0, 0, 0),
            Parent = root
        })
        
        bodyGyro = CreateElement("BodyGyro", {
            MaxTorque = Vector3.new(10000, 10000, 10000),
            P = 1000,
            D = 50,
            CFrame = root.CFrame,
            Parent = root
        })
        
        local flyConnection
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled or not player.Character or not bodyVelocity or not bodyGyro then
                if flyConnection then flyConnection:Disconnect() end
                return
            end
            
            local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart
            if not root then return end
            
            local cam = workspace.CurrentCamera
            local direction = Vector3.new()
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + (cam.CFrame.LookVector * flySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - (cam.CFrame.LookVector * flySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - (cam.CFrame.RightVector * flySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + (cam.CFrame.RightVector * flySpeed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, flySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, flySpeed, 0)
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

    flyToggle.MouseButton1Click:Connect(function()
        flyEnabled = not flyEnabled
        UpdateUI()
        
        if flyEnabled then
            StartFlying()
        else
            StopFlying()
        end
    end)

    -- Управление скоростью полета
    speedPlus.MouseButton1Click:Connect(function()
        flySpeed = math.min(flySpeed + 10, 200)
        UpdateUI()
    end)

    speedMinus.MouseButton1Click:Connect(function()
        flySpeed = math.max(flySpeed - 10, 20)
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

    -- Серверная часть God Mode
    local function InitializeGodModeSystem()
        local godStates = {}

        local function EnableGodForPlayer(player)
            godStates[player.UserId] = true
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
                if humanoid then
                    humanoid.MaxHealth = math.huge
                    humanoid.Health = humanoid.MaxHealth
                    
                    if not humanoid:FindFirstChild("GodRestoreConn") then
                        local conn = humanoid.HealthChanged:Connect(function()
                            if godStates[player.UserId] and humanoid and humanoid.Parent then
                                humanoid.Health = humanoid.MaxHealth
                            end
                        end)
                        
                        local holder = CreateElement("ObjectValue", {
                            Name = "GodRestoreConn",
                            Value = conn,
                            Parent = humanoid
                        })
                    end
                end
            end
        end

        local function DisableGodForPlayer(player)
            godStates[player.UserId] = nil
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = 100
                    if humanoid.Health > humanoid.MaxHealth then
                        humanoid.Health = humanoid.MaxHealth
                    end
                    
                    local holder = humanoid:FindFirstChild("GodRestoreConn")
                    if holder then
                        if holder.Value then pcall(function() holder.Value:Disconnect() end) end
                        holder:Destroy()
                    end
                end
            end
        end

        -- Обработка RemoteEvent
        remote.OnServerEvent:Connect(function(player, action, value)
            if action == "ToggleGod" then
                if value then
                    EnableGodForPlayer(player)
                else
                    DisableGodForPlayer(player)
                end
            end
        end)

        -- Обработчики игроков
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(char)
                if godStates[player.UserId] then
                    local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
                    if humanoid then
                        EnableGodForPlayer(player)
                    end
                end
            end)
        end)
    end

    -- Инициализация систем
    InitializeGodModeSystem()
    UpdateUI()
end

-- Запускаем скрипт
DeltaXAdmin()
