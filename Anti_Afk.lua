-- [[ DYMCK HUB - ANTI-AFK (VERSÃO ESTÁVEL + FIX LOG ERROR) ]]

-- 1. TRAVA DE SEGURANÇA GLOBAL (IMPEDE MULTIPLICAÇÃO DO LOOP E EVENTOS)
if _G.AntiAFKRunning then 
    print("🛡️ ANTI-AFK: Já está rodando. Cancelando carga duplicada.")
    return 
end
_G.AntiAFKRunning = true

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

print("✅ DymckHUB: Anti-AFK iniciado (Timer: 600s).")

-- 2. LOOP PRINCIPAL (DENTRO DE UMA THREAD ÚNICA)
task.spawn(function()
    while true do
        -- Se o Hub for deletado ou o State sumir, encerra o script totalmente
        if not _G.HubState then
            _G.AntiAFKRunning = false -- Libera a trava para uma futura carga
            print("🛑 ANTI-AFK: HubState não encontrado. Parando script.")
            break
        end

        -- Só executa se o Toggle estiver ON
        if _G.HubState.AntiAFKActive then
            local success, err = pcall(function()
                print("🛡️ ANTI-AFK: Simulando movimento para manter conexão...")
                VirtualUser:CaptureController()
                VirtualUser:SetKeyDown("w")
                task.wait(0.5) 
                VirtualUser:SetKeyUp("w")
            end)

            if not success then
                print("🔥 ANTI-AFK: Erro ao simular movimento: " .. tostring(err))
            end

            -- Espera 10 minutos (600 segundos) antes de repetir
            task.wait(600)
        else
            -- Se estiver desligado, fica em standby checando a cada 2 segundos
            task.wait(2)
        end
    end
end)

-- 3. EVENTO DE IDLE (SEGURANÇA REDOBRADA - AGORA COM TRAVA)
-- Usamos uma conexão única para evitar que o Roblox crie várias ao carregar o script
if not _G.AntiAFKConnection then
    _G.AntiAFKConnection = lp.Idled:Connect(function()
        if _G.HubState and _G.HubState.AntiAFKActive then
            pcall(function()
                -- Simula um clique do botão direito do mouse na câmera
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(0.2)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                print("🛡️ ANTI-AFK: Idle detectado, sinal de vida enviado via Mouse2.")
            end)
        end
    end)
end
