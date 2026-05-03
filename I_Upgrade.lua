-- [[ DYMCK HUB - I_UPGRADE.LUA (EQUIPMENT) ]]

-- 1. TRAVA DE SEGURANÇA (DEBOUNCE)
-- Evita spam de cliques no botão de Upgrade
if _G.UpgradeSpamProtection then 
    return 
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local towerRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tower")
local State = _G.HubState.Tower

-- Proteção silenciosa contra item vazio
local itemParaUpgrade = State.ItemTarget

if itemParaUpgrade and itemParaUpgrade ~= "" then
    _G.UpgradeSpamProtection = true -- Ativa a trava temporária

    pcall(function()
        local args = {
            [1] = "UpgradeArmor",
            [2] = itemParaUpgrade
        }
        towerRemote:FireServer(unpack(args))
    end)

    -- Aguarda 0.5 segundos antes de permitir outro clique de upgrade
    task.delay(0.5, function()
        _G.UpgradeSpamProtection = false
    end)
end
