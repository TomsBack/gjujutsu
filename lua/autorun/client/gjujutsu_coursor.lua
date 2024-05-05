lastPressTime = 0

hook.Add("PlayerButtonDown", "gJujutsu.lock_on", function(ply, key)
    if not ply:Alive() then return end
    local currentTime = CurTime()
    if key == MOUSE_MIDDLE then
        if currentTime - lastPressTime >= 0.2 then
            lastPressTime = currentTime
            if not IsValid(ply.targetPlayer) then 
                local trace = ply:GetEyeTrace()
                if trace.Hit then print(trace.Entity) end
                if trace.Hit and IsValid(trace.Entity) and (trace.Entity:IsPlayer() or trace.Entity:IsNPC()) and trace.Entity != ply then
                    ply.targetPlayer = trace.Entity
                end
            else
                ply.targetPlayer = nil
                local ang = ply:EyeAngles()
                ply:SetEyeAngles(Angle(ang.x,ang.y, 0))
            end
        end 
    end
end)

hook.Add("Think", "gJujutsu.TargetLockingSystem", function()
    if IsValid(LocalPlayer().targetPlayer) then
        if LocalPlayer().targetPlayer:Health() > 0 and LocalPlayer():Alive() then
            local currentAngles = LocalPlayer():EyeAngles()
            local targetPos = LocalPlayer().targetPlayer:GetPos()
            local targetAngles = (targetPos - LocalPlayer():GetPos()):Angle()
            local newAngles = LerpAngle(FrameTime() * 20, currentAngles, targetAngles)
            LocalPlayer():SetEyeAngles(newAngles)
        else
            LocalPlayer().targetPlayer = nil
            local ang = LocalPlayer():EyeAngles()
            LocalPlayer():SetEyeAngles(Angle(ang.x,ang.y, 0)) 
        end
    end
end)

hook.Add("HUDPaint", "gJujutsu.lockOnMark", function()
    if IsValid(LocalPlayer().targetPlayer) then
        local targetPos = LocalPlayer().targetPlayer:GetPos() + Vector(0,0,50)
        local targetScreenPos = targetPos:ToScreen()

        surface.SetMaterial(Material('hud/targetCursor.png'))
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(targetScreenPos.x - 30, targetScreenPos.y - 20, 64, 64)
    end
end)