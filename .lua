local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

-- Настройки
local AURA_RADIUS = 20 -- Радиус ауры в studs
local DAMAGE_PER_TICK = 10 -- Урон за один тик
local TICK_SPEED = 0.1 -- Частота урона (в секундах)
local AURA_COLOR = Color3.fromRGB(255, 0, 0) -- Красный цвет ауры

-- Функция для создания визуальной ауры
local function CreateAuraVisual()
    local aura = Instance.new("Part")
    aura.Shape = Enum.PartType.Ball
    aura.Material = Enum.Material.Neon
    aura.Size = Vector3.new(AURA_RADIUS * 2, AURA_RADIUS * 2, AURA_RADIUS * 2)
    aura.Color = AURA_COLOR
    aura.Transparency = 0.5
    aura.CanCollide = false
    aura.CFrame = rootPart.CFrame
    aura.TopSurface = Enum.SurfaceType.Smooth
    aura.BottomSurface = Enum.SurfaceType.Smooth
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = rootPart
    weld.Part1 = aura
    weld.Parent = aura
    
    aura.Parent = char
    return aura
end

-- Функция для нанесения урона врагам
local function DamageNearbyEnemies()
    local players = game.Players:GetPlayers()
    
    for _, otherPlayer in pairs(players) do
        if otherPlayer == player then continue end
        
        local otherChar = otherPlayer.Character
        if not otherChar then continue end
        
        local otherHumanoid = otherChar:FindFirstChild("Humanoid")
        local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
        
        if not otherHumanoid or not otherRoot then continue end
        
        -- Проверяем расстояние
        local distance = (rootPart.Position - otherRoot.Position).Magnitude
        
        if distance <= AURA_RADIUS then
            otherHumanoid:TakeDamage(DAMAGE_PER_TICK)
            print("Урон нанесён " .. otherPlayer.Name)
        end
    end
end

-- Создаём ауру
local aura = CreateAuraVisual()
print("✨ Килл аура активирована!")

-- Бесконечный цикл урона
while humanoid.Health > 0 do
    DamageNearbyEnemies()
    wait(TICK_SPEED)
end

print("❌ Килл аура деактивирована (персонаж мёртв)")
