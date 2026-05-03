-- ==========================================
-- 🌀 SCRIPT: EXPEDITION.LUA (ANTI-MULTIPLICAÇÃO)
-- ==========================================
local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StarTrial")
local State = _G.HubState.ExpeditionManager
local DB = _G.HubDatabase.Expedition

-- 🛡️ TRAVA GLOBAL: Garante que só exista um loop por Marine
_G.ExpeditionRunning = _G.ExpeditionRunning or {
    ["Marine 1"] = false,
    ["Marine 2"] = false,
    ["Marine 3"] = false
}

-- Função para converter formato "HH:MM:SS" ou "HH:MM" para segundos
local function TimeToSeconds(timeStr)
    local h, m, s = 0, 0, 0
    local parts = string.split(timeStr, ":")
    if #parts == 3 then
        h, m, s = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
    elseif #parts == 2 then
        h, m = tonumber(parts[1]), tonumber(parts[2])
    end
    return (h * 3600) + (m * 60) + s
end

-- Função que gerencia o ciclo de vida de cada Marine
local function ManageMarine(marineName)
    -- Se já estiver rodando este Marine, cancela a nova tentativa
    if _G.ExpeditionRunning[marineName] then return end
    
    _G.ExpeditionRunning[marineName] = true
    local marineID = marineName:match("%d+") 
    
    print("🚀 Gerenciador iniciado para: " .. marineName)

    while State[marineName].Active do
        local target = State[marineName].Target
        local data = DB[target]
        
        if not data then break end

        -- 1. ENVIAR
        Remote:FireServer("SendExpedition", {
            ["NPC"] = marineID,
            ["Reward"] = target .. "-Rainbow",
            ["Category"] = "Pack"
        })

        -- 2. ESPERAR
        local waitTime = TimeToSeconds(data.Time)
        task.wait(waitTime)

        -- 3. DELAY SEGURANÇA
        task.wait(3)

        -- 4. COLETAR
        Remote:FireServer("ClaimExpedition", marineID)

        task.wait(2) 
    end

    -- Ao sair do loop (quando desativado no menu), libera a trava
    _G.ExpeditionRunning[marineName] = false
    print("🛑 Gerenciador encerrado para: " .. marineName)
end

-- Inicia o gerenciamento para os 3 Marines
for i = 1, 3 do
    local mName = "Marine " .. i
    task.spawn(function()
        ManageMarine(mName)
    end)
end
