-- Manga.lua (Otimizado para Gemini Master Hub)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaidRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Raid")

-- Referência ao estado do Hub
local State = _G.HubState.Manga

if RaidRemote then
    local charName = tostring(State.Name)

    -- Validação: Só dispara se houver um nome escrito
    if charName ~= "" then
        local args = {
            [1] = "Manga",
            [2] = charName
        }

        local success, err = pcall(function()
            RaidRemote:FireServer(unpack(args))
        end)

        if success then
            print("GeminiHub: Upgrade de Manga enviado para -> " .. charName)
        else
            warn("GeminiHub: Erro no upgrade de Manga -> " .. err)
        end
    else
        warn("GeminiHub: Digite o nome do personagem antes de evoluir!")
    end
end
