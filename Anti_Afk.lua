-- [[ DYMCK HUB - ANTI-AFK (VERSÃO ESTÁVEL) ]]

-- 1. TRAVA DE SEGURANÇA (IMPEDE MULTIPLICAÇÃO)
if _G.AntiAFKRunning then 
    print("🛡️ ANTI-AFK: Já está rodando. Cancelando carga duplicada.")
    return 
end
_G.AntiAFKRunning = true

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

print("✅ DymckHUB: Anti-AFK iniciado (Timer: 600s).")

-- 2. LOOP PRINCIPAL
task.spawn(function()
    while true do
        -- Se o Hub for deletado ou o State sumir, encerra o script
        if not _G.HubState then
            _G.AntiAFKRunning = false
            print("🛑 ANTI-AFK: HubState não encontrado. Parando script.")
            break
        end

        -- Só executa se o Toggle estiver ON
        if _G.HubState.AntiAFKActive then
            local success, err = pcall(function()
                print("🛡️ ANTI-AFK: Simulando movimento para manter conexão...")
                
                -- Simula o pressionar da tecla "W" por um curto tempo
                VirtualUser:CaptureController()
                VirtualUser:SetKeyDown(Enum.KeyCode.W)
                task.wait(0.5) -- Um passinho de meio segundo
                VirtualUser:SetKeyUp(Enum.KeyCode.W)
            end)

            if not success then
                print("🔥 ANTI-AFK: Erro ao simular movimento: " .. tostring(err))
            end

            -- Espera 10 minutos (600 segundos) antes de repetir
            task.wait(600)
        else
            -- Se estiver desligado, espera um pouco e checa de novo
            task.wait(2)
        end
    end
end)

-- 3. EVENTO EXTRA (SEGURANÇA REDOBRADA)
-- Caso o Roblox tente te desconectar por inatividade antes dos 10 min
lp.Idled:Connect(function()
    if _G.HubState and _G.HubState.AntiAFKActive then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(0.2)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        print("🛡️ ANTI-AFK: Idle detectado, sinal de vida enviado.")
    end
end)
