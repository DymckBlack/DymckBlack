-- [[ DYMCK HUB - I_UPGRADE.LUA (EQUIPMENT) ]]

local towerRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Tower")
local State = _G.HubState.Tower

-- Proteção contra upgrade em item vazio
local itemParaUpgrade = State.ItemTarget

if not itemParaUpgrade or itemParaUpgrade == "" then
    warn("⚠️ [ERRO]: Nenhum item selecionado para Upgrade!")
    return 
end

local success, err = pcall(function()
    local args = {
        [1] = "UpgradeArmor",
        [2] = itemParaUpgrade
    }
    towerRemote:FireServer(unpack(args))
end)

if success then
    print("🔨 [TOWER]: Upgrade enviado com sucesso para: " .. itemParaUpgrade)
else
    warn("❌ [TOWER]: Erro ao enviar Upgrade: " .. tostring(err))
end
