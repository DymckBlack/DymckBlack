-- [[ DYMCK HUB - EXPEDITION SYSTEM ]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StarTrial")

local State = _G.HubState
if not State then
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
        return
    end

    _G.ExpeditionSending[marineName] = true

    local npcId = ExpeditionNPC[marineName]
    local target = marineData.Target

    if not npcId or not target then
        _G.ExpeditionSending[marineName] = nil
        return
    end

    local args = {
        [1] = "SendExpedition",
        [2] = {
            ["NPC"] = npcId,
            ["Reward"] = target .. "-Rainbow",
            ["Category"] = "Pack"
        }
    }

    pcall(function()
        Remote:FireServer(unpack(args))
    end)

    task.wait(0.5) -- Proteção contra spam
    _G.ExpeditionSending[marineName] = nil
end

-- ==========================================
-- 🎁 CLAIM EXPEDIÇÃO
-- ==========================================
local function ClaimExpedition(marineName)
    local npcId = ExpeditionNPC[marineName]

    if not npcId then
        return
    end

    local args = {
        [1] = "ClaimExpedition",
        [2] = npcId
    }

    pcall(function()
        Remote:FireServer(unpack(args))
    end)
end

-- ==========================================
-- 🔁 LOOP PRINCIPAL (THREAD ÚNICA)
-- ==========================================
if not _G.ExpeditionRunner then
    _G.ExpeditionRunner = true

    task.spawn(function()
        while true do
            -- Se o State sumir, encerra e libera a trava
            if not _G.HubState then
                _G.ExpeditionRunner = false
                break
            end

            for marineName, marine in pairs(State.ExpeditionManager) do

                -- 🚀 ENVIO
                if marine.Active and not marine.Sent then
                    SendExpedition(marineName, marine)
                    marine.Sent = true
                end

                -- 🎁 CLAIM
                if not marine.Active and marine.Sent then
                    ClaimExpedition(marineName)

                    -- Reset silencioso
                    marine.Sent = false
                    marine.Target = nil
                end
            end

            task.wait(1)
        end
    end)
end
