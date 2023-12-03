-- screen shake when taking damage

local ShakeIntensity = 0.2
local shakeWait = 50
local isHeartbeatPlaying = false


function TakeDamage()
    local playerPed = GetPlayerPed(-1)

    if not IsEntityDead(playerPed) then
        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", ShakeIntensity)
        Citizen.Wait(shakeWait)
        StopGameplayCamShaking(false)
    end
end

RegisterNetEvent("client:TakeDamage")
AddEventHandler("client:TakeDamage", function()
    TakeDamage()
end)

Citizen.CreateThread(function()
    local prevHealth = GetEntityHealth(GetPlayerPed(-1))
    while true do
        Citizen.Wait(0)

        local playerPed = GetPlayerPed(-1)
        local currentHealth = GetEntityHealth(playerPed)

        if prevHealth > currentHealth then
            prevHealth = currentHealth
            TriggerEvent('client:TakeDamage')
        else
            prevHealth = currentHealth
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)  -- Adjust the interval based on your preference

        local playerPed = GetPlayerPed(-1)

        if DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then
            local health = GetEntityHealth(playerPed)

            print("Current Health: " .. health)

            if health < 120.0 then
                if not isHeartbeatPlaying then
                    PlaySoundFrontend(-1, "Short_Transition_In", "PLAYER_SWITCH_CUSTOM_SOUNDSET", 1)
                    print("Playing heartbeat sound")
                    TriggerEvent("playHeartbeat")
                    isHeartbeatPlaying = true
                end

                SetTimecycleModifier("hud_def_blur")
                SetTimecycleModifierStrength(0.5) -- Adjust the strength based on your preference
            else
                if isHeartbeatPlaying then
                    print("Stopping heartbeat sound")
                    TriggerEvent("stopHeartbeat")
                    isHeartbeatPlaying = false
                end

                ClearTimecycleModifier()
            end
        else
            print("Player entity doesn't exist or is dead.")
        end
    end
    DoEffect()
end)


