-- ==========================================
-- 🚢 EXPEDITION SYSTEM
-- ==========================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StarTrial")

local State = _G.HubState
if not State then
    warn("❌ HubState não encontrado!")
    return
end

-- ==========================================
-- 🔐 CONTROLE ANTI DUPLICAÇÃO
-- ==========================================

_G.ExpeditionSending = _G.ExpeditionSending or {}

-- ==========================================
-- 📦 CONFIG LOCAL
-- ==========================================

local ExpeditionNPC = {
    ["Marine 1"] = "1",
    ["Marine 2"] = "2",
    ["Marine 3"] = "3"
}

-- ==========================================
-- 🚀 ENVIAR EXPEDIÇÃO
-- ==========================================

local function SendExpedition(marineName, marineData)
    if _G.ExpeditionSending[marineName] then
        warn("⛔ Já enviando:", marineName)
        return
    end

    _G.ExpeditionSending[marineName] = true

    local npcId = ExpeditionNPC[marineName]
    local target = marineData.Target

    if not npcId or not target then
        warn("❌ Dados inválidos:", marineName, npcId, target)
        _G.ExpeditionSending[marineName] = nil
        return
    end

    print("🚀 Enviando Expedition:", marineName, "| NPC:", npcId, "| Target:", target)

    local args = {
        [1] = "SendExpedition",
        [2] = {
            ["NPC"] = npcId,
            ["Reward"] = target .. "-Rainbow",
            ["Category"] = "Pack"
        }
    }

    local success, err = pcall(function()
        Remote:FireServer(unpack(args))
    end)

    if success then
        print("✅ Enviado com sucesso:", marineName)
    else
        warn("❌ Erro ao enviar:", marineName, err)
    end

    task.wait(0.5) -- proteção leve contra spam
    _G.ExpeditionSending[marineName] = nil
end

-- ==========================================
-- 🎁 CLAIM EXPEDIÇÃO
-- ==========================================

local function ClaimExpedition(marineName)
    local npcId = ExpeditionNPC[marineName]

    if not npcId then
        warn("❌ NPC inválido para claim:", marineName)
        return
    end

    print("🎁 Claimando:", marineName, "| NPC:", npcId)

    local args = {
        [1] = "ClaimExpedition",
        [2] = npcId
    }

    local success, err = pcall(function()
        Remote:FireServer(unpack(args))
    end)

    if success then
        print("✅ Claim enviado:", marineName)
    else
        warn("❌ Erro no claim:", marineName, err)
    end
end

-- ==========================================
-- 🔁 LOOP PRINCIPAL
-- ==========================================

if not _G.ExpeditionRunner then
    _G.ExpeditionRunner = true

    task.spawn(function()
        print("🟢 Expedition.lua iniciado")

        while true do
            for marineName, marine in pairs(State.ExpeditionManager) do

                -- ==========================================
                -- 🚀 ENVIO (quando acabou de iniciar)
                -- ==========================================
                if marine.Active and not marine.Sent then
                    SendExpedition(marineName, marine)
                    marine.Sent = true
                end

                -- ==========================================
                -- 🎁 CLAIM (quando terminou)
                -- ==========================================
                if not marine.Active and marine.Sent then
                    ClaimExpedition(marineName)

                    -- reset completo
                    marine.Sent = false
                    marine.Target = "Pirate"

                    print("♻ Resetando:", marineName)
                end
            end

            task.wait(1)
        end
    end)
end
