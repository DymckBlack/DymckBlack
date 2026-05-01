-- [[ DYMCK HUB - CASH SCRIPT (DIAGNÓSTICO) ]]
-- Este script imprimirá informações no console (F9) para descobrirmos o erro.

if _G.CashLoaded then 
    print("⚠️ CASH: O script já estava carregado. Verifique se as alterações no GitHub foram salvas.")
end 
_G.CashLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Pega a referência do Estado Central
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
    if not root then 
        print("❌ CASH: RootPart não encontrado. O personagem está vivo?")
        return nil 
    end
    
    local closestNum = nil
    local shortestDist = math.huge
    for num, pos in pairs(PlotPositions) do
        local dist = (root.Position - pos).Magnitude
        if dist < shortestDist then
            shortestDist = dist
            closestNum = num
        end
    end
    
    -- Se a distância for muito grande (ex: > 50 studs), talvez as coordenadas mudaram
    if shortestDist > 50 then
        print("⚠️ CASH: Plot mais próximo está muito longe (" .. math.floor(shortestDist) .. " studs).")
    end
    
    return closestNum
end

task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local CardRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Card")
    local Plots = workspace:WaitForChild("Plots")
    
    print("✅ DymckHUB: Loop de CASH iniciado.")

    while true do
        -- Verifica se o State existe e se o CashActive está ON
        if State and State.CashActive then
            
            if not SavedPlotNumber then 
                print("🔍 CASH: Tentando identificar seu Plot...")
                SavedPlotNumber = GetMyPlotByPos() 
                if SavedPlotNumber then
                    print("🎯 CASH: Plot identificado com sucesso: " .. SavedPlotNumber)
                else
                    print("❌ CASH: Não foi possível identificar seu Plot pela posição.")
                end
            end

            if SavedPlotNumber then
                local sucesso, erro = pcall(function()
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
                    else
                        print("❌ CASH: Objeto do Plot " .. SavedPlotNumber .. " não encontrado no Workspace.")
                    end
                end)
                
                if not sucesso then
                    print("🔥 CASH: Erro interno na coleta: " .. tostring(erro))
                end

                task.wait(1.8) 

                pcall(function()
                    CardRemote:FireServer("Page", "RightArrow")
                end)

                task.wait(1.8) 
            else
                task.wait(5) -- Espera mais tempo se não achar o plot
            end
        else
            -- Se o State não existir ou CashActive for false
            if not State then
                print("⚠️ CASH: HubState é nulo (nil). O Main carregou?")
                State = _G.HubState
            end
            SavedPlotNumber = nil
            task.wait(2) 
        end
    end
end)
