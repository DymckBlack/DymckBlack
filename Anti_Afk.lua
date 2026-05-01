-- [[ GEMINI HUB - AUTO RAID AFK BACKEND ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

-- Referência direta ao novo State
local State = _G.HubState.RaidAFK
local RaidDatabase = _G.HubDatabase and _G.HubDatabase.Decks or {"Pirate","Ninja","Soul","Slayer","Sorcerer","Dragon","Fire","Hero","Hunter","Solo","Titan","Chainsaw","Flight","Ego","Clover","Ghoul","Geass","Bizarre","Fairy","Sins","Note","Slime","Mage","Zero","Vagrant","Rebellion","Viking","Mercenary"}

local function EntrarNaRaid(raidNomeEncontrada)
    -- Verifica se o Auto Join ainda está ligado no State
    if not State.Active then return end
    
    -- Busca o deck dentro da nova estrutura: State.RaidAFK.Decks
    local data = State.Decks[raidNomeEncontrada]
    
    if data then
        -- Validação: Se o deck estiver vazio, ignora para não entrar com time errado
        if data.char1 == "" and data.char2 == "" and data.char3 == "" then
            print("GeminiHUB: Raid " .. raidNomeEncontrada .. " detectada, mas o deck está vazio no State!")
            return
        end

        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            -- 1. Anti-Stuck: Sai do modo AFK do Star Trial antes de tentar entrar na Raid
            local starRem = remotes:FindFirstChild("StarTrial")
            if starRem then starRem:FireServer("AFK", false) end
            
            task.wait(0.5)

            -- 2. Disparo do Remote de Join
            local raidRem = remotes:FindFirstChild("Raid")
            if raidRem then
                raidRem:FireServer("Join", {
                    [1] = (data.char1 ~= "") and data.char1 or "Empty",
                    [2] = (data.char2 ~= "") and data.char2 or "Empty",
                    [3] = (data.char3 ~= "") and data.char3 or "Empty"
                })
                print("GeminiHUB: Auto-Join executado com sucesso para -> " .. raidNomeEncontrada)
            end
        end
    end
end

local function OnRaidMessageFound(fullText)
    local lowMsg = fullText:lower()
    
    -- Filtro principal da mensagem do sistema
    if string.find(lowMsg, "raid is starting now") then
        -- Percorre a database para identificar qual raid iniciou
        for _, nome in pairs(RaidDatabase) do
            if string.find(lowMsg, nome:lower()) then
                EntrarNaRaid(nome)
                break
            end
        end
    end
end

-- ==========================================
-- SISTEMA DE MONITORAMENTO (CHATS)
-- ==========================================

-- 1. Monitor via TextChatService (Versão Moderna)
if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.MessageReceived:Connect(function(m)
        if m.Text then OnRaidMessageFound(m.Text) end
    end)
end

-- 2. Monitor via PlayerGui (Backup para Legacy Chat)
task.spawn(function()
    local player = Players.LocalPlayer
    local chatFrame = player.PlayerGui:FindFirstChild("Chat") and player.PlayerGui.Chat:FindFirstChild("Scroller", true)
    
    if chatFrame then
        chatFrame.ChildAdded:Connect(function(newMsg)
            task.wait(0.1) -- Delay para garantir que o TextLabel foi instanciado
            local label = newMsg:FindFirstChildOfClass("TextLabel")
            if label then
                OnRaidMessageFound(label.Text)
            end
        end)
    end
end)

print("GeminiHUB: Motor de Invasão AFK sincronizado com o State!")
