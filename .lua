local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")

-- ТВОИ ЭКСТРЕМАЛЬНЫЕ НАСТРОЙКИ
local RADIUS = 30 
local ATTACK_SPEED = 0.08 
local FoundEvents = {}

print("🌑 СИСТЕМА УНИЧТОЖЕНИЯ: ЗАГРУЗКА БАЗ ДАННЫХ...")

-- Сбор всех боевых каналов
for _, v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        local n = v.Name:lower()
        if n:find("hit") or n:find("attack") or n:find("punch") or n:find("swing") or n:find("damage") or n:find("kill") or n:find("combat") or n:find("sword") or n:find("skill") or n:find("ability") or n:find("cast") or n:find("fire") then
            table.insert(FoundEvents, v)
        end
    end
end

-- [[ ВИЗУАЛ: Тёмная материя ]] --
local function CreateAura()
    local sphere = Instance.new("Part")
    sphere.Shape = Enum.PartType.Ball
    sphere.Material = Enum.Material.ForceField
    sphere.Size = Vector3.new(RADIUS * 2, RADIUS * 2, RADIUS * 2)
    sphere.Color = Color3.fromRGB(150, 0, 255) -- Глубокий фиолетовый
    sphere.CanCollide = false
    sphere.Transparency = 0.9
    sphere.Massless = true
    sphere.Parent = char
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = rootPart
    weld.Part1 = sphere
    weld.Parent = sphere
end

-- [[ ПОИСК ЦЕЛИ ]] --
local function GetClosestEnemy()
    local target = nil
    local dist = RADIUS
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            -- Проверка: жив ли враг и нет ли на нем щита новичка
            if hum and hrp and hum.Health > 0 and not p.Character:FindFirstChildOfClass("ForceField") then
                local magnitude = (rootPart.Position - hrp.Position).Magnitude
                if magnitude < dist then
                    dist = magnitude
                    target = p.Character
                end
            end
        end
    end
    return target
end

-- [[ АТАКУЮЩИЙ ПРОТОКОЛ ]] --
local function Attack(target)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    local t_hrp = target.HumanoidRootPart
    local t_hum = target.Humanoid
    
    -- Мягкий поворот к цели (только по горизонтали)
    local targetPos = Vector3.new(t_hrp.Position.X, rootPart.Position.Y, t_hrp.Position.Z)
    rootPart.CFrame = CFrame.new(rootPart.Position, targetPos)
    
    for _, event in pairs(FoundEvents) do
        pcall(function()
            -- Шквал аргументов для обхода разных типов защит
            local pos = t_hrp.Position
            event:FireServer(target)
            event:FireServer(t_hum)
            if tool then
                event:FireServer(target, tool)
                event:FireServer(t_hum, tool, pos)
            end
            -- Некоторые игры требуют ID части тела
            event:FireServer(t_hrp)
            -- Некоторые игры требуют вектор направления
            event:FireServer(target, (pos - rootPart.Position).Unit)
        end)
    end
end

CreateAura()

-- ГЛАВНЫЙ ЦИКЛ УНИЧТОЖЕНИЯ
task.spawn(function()
    print("💀 РЕЖИМ АПОКАЛИПСИС АКТИВИРОВАН")
    local count = 0
    while task.wait(ATTACK_SPEED) do
        local target = GetClosestEnemy()
        if target then
            Attack(target)
            count = count + 1
            if count % 20 == 0 then
                print("📊 Статистика: " .. count .. " залпов произведено.")
            end
        end
    end
end)
