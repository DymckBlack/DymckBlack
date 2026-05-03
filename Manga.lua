-- [[ DYMCK HUB - MANGA.LUA (EQUIPMENT) ]]

-- 1. TRAVA DE SEGURANÇA (DEBOUNCE)
-- Impede spam de cliques no botão de evolução
if _G.MangaSpamProtection then 
    return 
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaidRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Raid")

-- Referência ao estado do Hub
local State = _G.HubState.Manga

if RaidRemote and State then
    local charName = tostring(State.Name)

    -- Validação silenciosa: Só dispara se houver um nome escrito
    if charName ~= "" then
        _G.MangaSpamProtection = true -- Ativa a trava

        local args = {
            [1] = "Manga",
            [2] = charName
        }

        pcall(function()
            RaidRemote:FireServer(unpack(args))
        end)

        -- Aguarda 1 segundo antes de liberar o próximo clique
        task.delay(1, function()
            _G.MangaSpamProtection = false
        end)
    end
end
