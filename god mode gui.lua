-- Версия с God Mode и Flight Mode
local function initializeAdminSystem()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local StarterPlayer = game:GetService("StarterPlayer")
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local REMOTE_NAME = "AdminSystemEvents_v2_Loadstring"

    -- Создаём RemoteEvent
    local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = REMOTE_NAME
        remote.Parent = ReplicatedStorage
    end

    -- Клиентский код
    local clientCode = [[
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")

        local player = Players.LocalPlayer
        local REMOTE_NAME = "]] .. REMOTE_NAME .. [["
        local remote = ReplicatedStorage:WaitForChild(REMOTE_NAME)

        local function make(className, props)
            local obj = Instance.new(className)
            if props then
                for k, v in pairs(props) do
                    pcall(function() obj[k] = v end)
                end
            end
            return obj
        end

        -- Удаляем старое GUI
        if player:FindFirstChild("PlayerGui") then
            local existing = player.PlayerGui:FindFirstChild("AdminSystemGUI_Loadstring")
            if existing then existing:Destroy() end
        end

        -- Создаём GUI
        local screenGui = make("ScreenGui", {
            Name = "AdminSystemGUI_Loadstring",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        })

        local frame = make("Frame", {
            Name = "MainFrame",
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.new(0.02, 0, 0.02, 0),
            Size = UDim2.new(0, 300, 0, 180),
            BackgroundColor3 = Color3.fromRGB(30, 30, 35),
            BorderSizePixel = 0,
            BackgroundTransparency = 0.05
        })

        local title = make("TextLabel", {
            Name = "Title",
            Position = UDim2.new(0, 10, 0, 6),
            Size = UDim2.new(1, -20, 0, 24),
            Text = "ADMIN PANEL",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local godStatus = make("TextLabel", {
            Name = "GodStatus",
            Position = UDim2.new(0, 10, 0, 34),
            Size = UDim2.new(1, -20, 0, 18),
            Text = "God Mode: OFF",
            TextColor3 = Color3.fromRGB(200, 200, 200),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local flyStatus = make("TextLabel", {
            Name = "FlyStatus",
            Position = UDim2.new(0, 10, 0, 56),
            Size = UDim2.new(1, -20, 0, 18),
            Text = "Fly Mode: OFF (WASD + Space/Shift)",
            TextColor3 = Color3.fromRGB(200, 200, 200),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local godButton = make("TextButton", {
            Name = "GodButton",
            Position = UDim2.new(0, 10, 0, 80),
            Size = UDim2.new(0.48, -15, 0, 40),
            Text = "TOGGLE GOD",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundColor3 = Color3.fromRGB(70, 130, 180),
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            TextSize = 14
        })

        local flyButton = make("TextButton", {
            Name = "FlyButton",
            Position = UDim2.new(0.52, 5, 0, 80),
            Size = UDim2.new(0.48, -15, 0, 40),
            Text = "TOGGLE FLY",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundColor3 = Color3.fromRGB(120, 80, 160),
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            TextSize = 14
        })

        local toggleGuiButton = make("TextButton", {
            Name = "ToggleGUIButton",
            Position = UDim2.new(0, 10, 0, 130),
            Size = UDim2.new(1, -20, 0, 40),
            Text = "HIDE GUI (RightShift)",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundColor3 = Color3.fromRGB(90, 90, 95),
            BorderSizePixel = 0,
            Font = Enum.Font.Gotham,
            TextSize = 14
        })

        -- Собираем GUI
        frame.Parent = screenGui
        title.Parent = frame
        godStatus.Parent = frame
        flyStatus.Parent = frame
        godButton.Parent = frame
        flyButton.Parent = frame
        toggleGuiButton.Parent = frame
        screenGui.Parent = player:WaitForChild("PlayerGui")

        -- Логика
        local godEnabled = false
        local flyEnabled = false
        local guiVisible = true

        local function updateUI()
            godButton.Text = godEnabled and "GOD: ON" or "GOD: OFF"
            godStatus.Text = "God Mode: " .. (godEnabled and "ON" or "OFF")
            flyButton.Text = flyEnabled and "FLY: ON" or "FLY: OFF"
            flyStatus.Text = flyEnabled and "Fly Mode: ON (WASD + Space/Shift)" or "Fly Mode: OFF"
            godButton.BackgroundColor3 = godEnabled and Color3.fromRGB(180, 70, 70) or Color3.fromRGB(70, 130, 180)
            flyButton.BackgroundColor3 = flyEnabled and Color3.fromRGB(160, 60, 160) or Color3.fromRGB(120, 80, 160)
            toggleGuiButton.Text = guiVisible and "HIDE GUI (RightShift)" or "SHOW GUI (RightShift)"
        end

        -- God Mode логика
        godButton.MouseButton1Click:Connect(function()
            godEnabled = not godEnabled
            updateUI()
            remote:FireServer("ToggleGod", godEnabled)
        end)

        -- Fly Mode логика
        local flySpeed = 50
        local bodyVelocity
        local bodyGyro

        local function startFlying()
            if not player.Character then return end
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end

            humanoid.PlatformStand = true

            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart

            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)
            bodyGyro.P = 1000
            bodyGyro.D = 50
            bodyGyro.CFrame = (player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart).CFrame
            bodyGyro.Parent = bodyVelocity.Parent

            local flyConnection
            flyConnection = RunService.Heartbeat:Connect(function()
                if not flyEnabled or not player.Character then
                    flyConnection:Disconnect()
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

        local function stopFlying()
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
        end

        flyButton.MouseButton1Click:Connect(function()
            flyEnabled = not flyEnabled
            updateUI()

            if flyEnabled then
                startFlying()
            else
                stopFlying()
            end
        end)

        -- Переключение GUI
        toggleGuiButton.MouseButton1Click:Connect(function()
            guiVisible = not guiVisible
            screenGui.Enabled = guiVisible
            updateUI()
        end)

        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.RightShift then
                guiVisible = not guiVisible
                screenGui.Enabled = guiVisible
                updateUI()
            end
        end)

        updateUI()
    ]]

    -- Вставляем LocalScript в StarterPlayerScripts
    local function injectClientScript()
        local starterScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")
        if not starterScripts then
            starterScripts = Instance.new("StarterPlayerScripts")
            starterScripts.Parent = StarterPlayer
        end

        -- Удаляем старые версии
        for _, child in ipairs(starterScripts:GetChildren()) do
            if child:IsA("LocalScript") and child.Name == "AdminSystemClient_Loadstring" then
                child:Destroy()
            end
        end

        local ls = Instance.new("LocalScript")
        ls.Name = "AdminSystemClient_Loadstring"
        ls.Source = clientCode
        ls.Parent = starterScripts
    end

    -- Серверная логика God Mode
    local godStates = {}

    local function enableGodForPlayer(player)
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
                    
                    local holder = Instance.new("ObjectValue")
                    holder.Name = "GodRestoreConn"
                    holder.Value = conn
                    holder.Parent = humanoid
                end
            end
        end
    end

    local function disableGodForPlayer(player)
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

    -- Обработчики игроков
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            if godStates[player.UserId] then
                local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
                if humanoid then
                    enableGodForPlayer(player)
                end
            end
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        godStates[player.UserId] = nil
    end)

    -- Обработка RemoteEvent
    remote.OnServerEvent:Connect(function(player, action, value)
        if action == "ToggleGod" then
            if value then
                enableGodForPlayer(player)
            else
                disableGodForPlayer(player)
            end
        end
    end)

    -- Внедряем клиентский скрипт
    injectClientScript()

    print("Admin System активирован (God Mode + Fly Mode) | RemoteEvent: "..REMOTE_NAME)
end

-- Запускаем систему
pcall(initializeAdminSystem)
