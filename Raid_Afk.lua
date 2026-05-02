-- [[ GEMINI MASTER HUB - MOTOR DE INVASÃO AFK ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

-- 1. Puxa os dados globais (Main e Motor agora usam a MESMA lista)
local State = _G.HubState and _G.HubState.RaidAFK
local Database = _G.HubDatabase -- ⬅️ Puxando a sua tabela Database do Main

-- Validação de Segurança: Se o Main não foi carregado, o motor espera
if not State or not Database then
    warn("GeminiHUB [Aviso]: Aguardando inicialização do HubDatabase...")
    return
end

local function EntrarNaRaid(raidNome)
    if not State.Active then return end
    
    local data = State.Decks[raidNome]
    if not data then return end

    -- Verifica se os slots não estão vazios
    if data.char1 == "" and data.char2 == "" and data.char3 == "" then
        return
    end

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local starRem = remotes:FindFirstChild("StarTrial")
        if starRem then pcall(function() starRem:FireServer("AFK", false) end) end
        
        task.wait(0.5)

        local raidRem = remotes:FindFirstChild("Raid")
        if raidRem then
            pcall(function()
                raidRem:FireServer("Join", {
                    [1] = (data.char1 ~= "") and data.char1 or "Empty",
                    [2] = (data.char2 ~= "") and data.char2 or "Empty",
                    [3] = (data.char3 ~= "") and data.char3 or "Empty"
                })
            end)
            print("GeminiHUB: Auto-Join para " .. raidNome)
        end
    end
end

local function OnRaidMessageFound(fullText)
    local lowMsg = fullText:lower()
    
    if string.find(lowMsg, "raid is starting now") then
        -- 🧠 A MÁGICA AQUI: Ele percorre a sua Database.Decks original do Main
        for _, nome in pairs(Database.Decks) do
            if string.find(lowMsg, nome:lower()) then
                EntrarNaRaid(nome)
                break
            end
        end
    end
end

-- ==========================================
-- MONITORES DE CHAT
-- ==========================================

if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.MessageReceived:Connect(function(m)
        if m.Text then OnRaidMessageFound(m.Text) end
    end)
end

task.spawn(function()
    local lp = Players.LocalPlayer
    local chatScroller = lp:WaitForChild("PlayerGui"):FindFirstChild("Scroller", true)
    
    if chatScroller then
        chatScroller.ChildAdded:Connect(function(newMsg)
            task.wait(0.1)
            local label = newMsg:FindFirstChildOfClass("TextLabel")
            if label then OnRaidMessageFound(label.Text) end
        end)
    end
end)

print("GeminiHUB: Motor AFK sincronizado com a Database principal!")
