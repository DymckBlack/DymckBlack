-- [[ DYMCKHUB - VOTE ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

-- 1. 🛡️ SISTEMA ANTI-DUPLICAÇÃO
if _G.VoteListenerRunning then 
    return 
end
_G.VoteListenerRunning = true

-- Referência ao estado central
local State = _G.HubState.Vote

-- Função para gerenciar a suspensão dos outros loops (Trial / Trial Fast)
local function IniciarPausaRaid()
    _G.RaidPauseActive = true
    
    -- Timer de 560 segundos (9 minutos e 20 segundos)
    task.delay(560, function()
        _G.RaidPauseActive = false
    end)
end

local function RealizarVoto()
    -- Verifica se o State ainda existe e se a opção Auto está ligada
    if not _G.HubState or not State.Auto then return end
    
    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Raid")
    if remote then
        pcall(function()
            remote:FireServer("Vote", State.Selected)
            -- Ativa a pausa global assim que o voto é realizado
            IniciarPausaRaid()
        end)
    end
end

-- Listener de Chat (Execução Única)
local function setupChatListener()
    -- Se o HubState sumir, encerramos a trava para permitir novo setup no futuro
    task.spawn(function()
        while true do
            if not _G.HubState then
                _G.VoteListenerRunning = false
                _G.RaidPauseActive = false -- Reseta a pausa caso o Hub feche
                break
            end
            task.wait(2)
        end
    end)

    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.OnIncomingMessage = function(message)
            if message.Text and string.find(message.Text:lower(), "raid voting has opened") then
                task.wait(math.random(2, 4)) -- Delay humano para não parecer bot
                RealizarVoto()
            end
        end
    end
end

task.spawn(setupChatListener)
