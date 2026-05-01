-- Vote.lua (Otimizado para Gemini Master Hub)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

-- Referência ao estado central
local State = _G.HubState.Vote

local function RealizarVoto()
    if not State.Auto then return end
    
    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Raid")
    if remote then
        remote:FireServer("Vote", State.Selected)
        print("GeminiHub: Voto automático -> " .. State.Selected)
    end
end

-- Listener de Chat
local function setupChatListener()
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.OnIncomingMessage = function(message)
            if string.find(message.Text:lower(), "raid voting has opened") then
                task.wait(math.random(2, 4))
                RealizarVoto()
            end
        end
    end
end

task.spawn(setupChatListener)
