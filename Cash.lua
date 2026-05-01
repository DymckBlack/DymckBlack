-- [[ DYMCK HUB - CASH SCRIPT (VERSÃO ESTÁVEL) ]]

-- 1. TRAVA DE CARREGAMENTO (IMPEDE MULTIPLICAÇÃO)
if _G.CashLoopRunning then 
    print("⚠️ CASH: O script já está rodando em segundo plano. Ignorando carga duplicada.")
    return 
end
_G.CashLoopRunning = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local State = _G.HubState

-- Memória de Sessão
local SavedPlotNumber = nil 

-- Coordenadas Fixas para Identificação
local PlotPositions = {
    [1] = Vector3.new(-600.56, 7.15, -131.69),
    [2] = Vector3.new(-588.79, 7.15, -228.43),
    [3] = Vector3.new(-592.89, 7.15, -321.67),
    [4] = Vector3.new(-476.58, 7.15, -326.79),
    [5] = Vector3.new(-480.35, 7.15, -228.60),
    [6] = Vector3.new(-480.89, 7.15, -131.18)
}

local function GetMyPlotByPos()
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local closestNum = nil
    local shortestDist = math.huge
    for num, pos in pairs(PlotPositions) do
        local dist = (root.Position - pos).Magnitude
        if dist < shortestDist then
            shortestDist = dist
            closestNum = num
        end
    end
    return (shortestDist < 50) and closestNum or nil
end

-- Inicia o processo único
print("✅ DymckHUB: Loop de CASH iniciado com proteção de duplicata.")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CardRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Card")
local Plots = workspace:WaitForChild("Plots")

-- O LOOP PRINCIPAL
while true do
    -- Se o Hub for fechado ou o estado for perdido, limpamos a trava e paramos tudo
    if not _G.HubState then
        _G.CashLoopRunning = false
        print("🛑 CASH: HubState não encontrado. Parando script.")
        break
    end

    if State.CashActive then
        -- Identifica o Plot apenas uma vez por ativação
        if not SavedPlotNumber then 
            SavedPlotNumber = GetMyPlotByPos() 
            if SavedPlotNumber then
                print("🎯 CASH: Plot identificado: " .. SavedPlotNumber)
            end
        end

        if SavedPlotNumber then
            pcall(function()
                local plot = Plots:FindFirstChild(tostring(SavedPlotNumber))
                if plot then
                    local display = plot.Map:FindFirstChild("Display")
                    if display then
                        local sides = {display:FindFirstChild("Left"), display:FindFirstChild("Right")}
                        for _, side in pairs(sides) do
                            if side then
                                for slotIdx = 1, 9 do
                                    local card = side:FindFirstChild(tostring(slotIdx))
                                    if card then 
                                        CardRemote:FireServer("Collect", card) 
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            
            task.wait(1.5) -- Tempo entre coletas

            pcall(function()
                CardRemote:FireServer("Page", "RightArrow")
            end)

            task.wait(1.5) -- Tempo após mudar página
        else
            -- Se não achou plot, espera e tenta identificar de novo no próximo ciclo
            task.wait(5)
        end
    else
        -- Se o botão estiver OFF, o script fica em "standby" sem gastar CPU
        SavedPlotNumber = nil
        task.wait(1) 
    end
end
