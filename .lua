local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")

-- Параметры для экономии батареи твоего смартфона 📱
local RADIUS = 15 
local ATTACK_SPEED = 0.25 

-- ВНИМАНИЕ: Сюда нужно вписать РЕАЛЬНОЕ имя ивента урона из твоей игры!
-- Без него это всё ещё просто дискотека. Ищи слова "Damage", "Hit", "Melee", "Attack"
local DAMAGE_EVENT_NAME = "ТутВпишиИмяИвента" 

-- [[ ВИЗУАЛ: Пузырь пафоса ]] --
local function CreateAura()
    local sphere = Instance.new("Part")
    sphere.Shape = Enum.PartType.Ball
    sphere.Material = Enum.Material.ForceField -- Стильно, модно, не слепит глаза
    sphere.Size = Vector3.new(RADIUS * 2, RADIUS * 2, RADIUS * 2)
    sphere.Color = Color3.fromRGB(255, 0, 0)
    sphere.CanCollide = false
    sphere.Transparency = 0.7
    sphere.Massless = true -- Чтобы не таскать лишний вес на горбу
    sphere.Parent = char
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = rootPart
    weld.Part1 = sphere
    weld.Parent = sphere
end

-- [[ ЛОГИКА: Поиск живой жертвы ]] --
local function GetClosestEnemy()
    local target = nil
    local dist = RADIUS
    
    for _, p in pairs(Players:GetPlayers()) do
        -- Проверяем, что это не мы, что у врага есть туловище и ОН ЖИВ
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local magnitude = (rootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if magnitude < dist then
                    dist = magnitude
                    target = p.Character
                end
            end
        end
    end
    return target
end

CreateAura()

-- Главный цикл мясорубки 🔪
task.spawn(function()
    while task.wait(ATTACK_SPEED) do
        local target = GetClosestEnemy()
        if target then
            print("💥 Пытаемся стукнуть: " .. target.Name)
            
            -- ПОПЫТКА УДАРА 
            -- Ищем ивент в ReplicatedStorage (там они прячутся чаще всего)
            local hitEvent = game:GetService("ReplicatedStorage"):FindFirstChild(DAMAGE_EVENT_NAME, true)
            
            if hitEvent and hitEvent:IsA("RemoteEvent") then
                -- ВНИМАНИЕ: В некоторых играх сюда нужно передавать не перса (target), 
                -- а его Humanoid, конкретную часть тела или даже твое оружие!
                hitEvent:FireServer(target) 
            else
                warn("Шеф, всё пропало! RemoteEvent с именем '" .. DAMAGE_EVENT_NAME .. "' не найден. Ищи через чит-меню (Dex)!")
            end
        end
    end
end)
