-- Delta X Admin Panel (God Mode + Fly Mode)
-- Автономный скрипт с заставкой

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
    local TextService = game:GetService("TextService")

    -- Получаем локального игрока
    local player = Players.LocalPlayer
    repeat task.wait() until player:FindFirstChild("PlayerGui")
    local playerGui = player.PlayerGui

    -- Удаляем старое GUI если есть
    local existingGui = playerGui:FindFirstChild("DeltaXAdminGUI")
    if existingGui then existingGui:Destroy() end

    -- Функция для создания элементов с защитой от ошибок
    local function CreateElement(className, props)
        local element = Instance.new(className)
        for prop, value in pairs(props) do
            pcall(function() element[prop] = value end)
        end
        return element
    end

    -- Создаем заставку
    local splashScreen = CreateElement("ScreenGui", {
        Name = "SplashScreen",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local splashFrame = CreateElement("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0
    })

    local splashText = CreateElement("TextLabel", {
        Text = "MADE BY SOJO",
        TextColor3 = Color3.fromRGB(170, 0, 255),  -- Фиолетовый цвет
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0.5, -25)
    })

    -- Собираем заставку
    splashFrame.Parent = splashScreen
    splashText.Parent = splashFrame
    splashScreen.Parent = playerGui

    -- Анимация появления и исчезания заставки
    local function ShowSplash()
        splashText.TextTransparency = 1
        splashFrame.BackgroundTransparency = 1
        
        -- Появление
        TweenService:Create(splashText, TweenInfo.new(0.5), {
            TextTransparency = 0
        }):Play()
        
        TweenService:Create(splashFrame, TweenInfo.new(0.5), {
            BackgroundTransparency = 0.3
        }):Play()
        
        wait(2)  -- Показываем 2 секунды
        
        -- Исчезание
        TweenService:Create(splashText, TweenInfo.new(0.5), {
            TextTransparency = 1
        }):Play()
        
        TweenService:Create(splashFrame, TweenInfo.new(0.5), {
            BackgroundTransparency = 1
        }):Play()
        
        wait(0.5)
        splashScreen:Destroy()
    end

    -- Запускаем заставку
    coroutine.wrap(ShowSplash)()

    -- Ждем завершения заставки перед созданием основного GUI
    wait(3)

    -- Создаем основной GUI (остальной код остается таким же, как в предыдущем скрипте)
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

    -- ... (остальной код создания GUI остается без изменений)

    -- Собираем основной GUI
    mainFrame.Parent = screenGui
    screenGui.Parent = playerGui

    -- Анимация появления основного GUI
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Visible = true
    
    TweenService:Create(mainFrame, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 350, 0, 250)
    }):Play()

    -- ... (остальная логика работы скрипта остается без изменений)
end

-- Запускаем скрипт
DeltaXAdmin()
