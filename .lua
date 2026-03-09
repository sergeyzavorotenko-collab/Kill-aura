local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")

-- Настройки
local AURA_RADIUS = 15
local DAMAGE_PER_TICK = 999 -- Огромный урон
local TICK_SPEED = 0.05 -- Часто наносим
local AURA_COLOR = Color3.fromRGB(255, 0, 0)

-- [[ СОЗДАНИЕ АУРЫ ]] --
local function CreateAura()
    local p = Instance.new("Part")
    p.Name = "VisualAura"
    p.Shape = Enum.PartType.Ball
    p.Material = Enum.Material.ForceField
    p.Size = Vector3.new(AURA_RADIUS*2, AURA_RADIUS*2, AURA_RADIUS*2)
    p.Color = AURA_COLOR
    p.CanCollide = false
    p.Massless = true
    p.Parent = char
    
    local weld = Instance.new("Weld", p)
    weld.Part0 = rootPart
    weld.Part1 = p
    return p
end

local auraPart = CreateAura()

-- [[ ЛОГИКА АТАКИ - УБИВАЕТ ДО СМЕРТИ ]] --
local function AttackEnemies()
    for _, target in pairs(Players:GetPlayers()) do
        if target == player then continue end
        
        local tChar = target.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        local tHum = tChar and tChar:FindFirstChild("Humanoid")
        
        if tRoot and tHum and tHum.Health > 0 then
            local dist = (rootPart.Position - tRoot.Position).Magnitude
            if dist <= AURA_RADIUS then
                -- Наносим урон
                tHum:TakeDamage(DAMAGE_PER_TICK)
                
                -- Вспышка при попадании
                auraPart.Color = Color3.fromRGB(255, 255, 255)
                task.delay(0.1, function() 
                    auraPart.Color = AURA_COLOR 
                end)
                
                print("💀 Урон нанесён " .. target.Name .. " | HP: " .. tHum.Health)
            end
        end
    end
end

-- [[ ЗАПУСК АУРЫ ]] --
print("💀 Килл аура МАКСИМУМ ЗАПУЩЕНА. Противники будут убиты до смерти!")

task.spawn(function()
    while char and char:Parent do
        AttackEnemies()
        task.wait(TICK_SPEED)
    end
end)
