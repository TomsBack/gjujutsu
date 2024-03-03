AddCSLuaFile()

function SUKUNA_DomainExpansionCinematic(ply)
	local owner = ply
    local localPlayer = LocalPlayer()
    local cinematicPos = ply:GetPos()
    local steamID = ply:SteamID()

    if localPlayer == ply then
        local screenWidth = ScrW()
        local screenHeight = ScrH()
        local blackBarSize = screenHeight * 0.09
        local bottomPos = screenHeight - blackBarSize + 1
        local color_black = color_black --Localize the global var

        local start = SysTime()
        local animDuration = 1 

        hook.Add("DrawOverlay", "SUKUNA_CinematicBars" .. steamID, function()
            local lerpedSize = Lerp((SysTime() - start) / animDuration, 0, blackBarSize)
            local lerpedBottom = Lerp((SysTime() - start) / animDuration, screenHeight + 1, bottomPos) --Need to lerp the bottom pos, so it goes from down to up

            surface.SetDrawColor(color_black)
            surface.DrawRect(0, 0, screenWidth, lerpedSize)
            surface.DrawRect(0, lerpedBottom, screenWidth, lerpedSize)
        end)
        
        hook.Add("HUDShouldDraw", "SUKUNA_NoHudCinematic" .. steamID, function()
            return false
        end)
    end

    local oldLook = ply:EyeAngles()
    oldLook.x = 0

    --Experimental
    local angles = ply:GetAimVector():Angle()
    angles:Normalize()
    angles.x = 0

	local copy = ClientsideModel(ply:GetModel())
    copy:SetPos(cinematicPos)
    copy:SetAngles(angles)
    copy:SetNoDraw(false)
    copy:SetSkin(ply:GetSkin())
    copy:SetPlaybackRate(1)
    copy:SetSequence(copy:LookupSequence( "sukuna_domain_anim" ))
    copy:SetBodygroup(0, 1)
    copy:SetBodygroup(1, 1)
    copy:SetBodygroup(2, 1)
    copy:SetBodygroup(3, 1)
    copy:SetBodygroup(4, 1)
	ply.gJujutsu_Copy = copy
    
    local head = copy:LookupBone("ValveBiped.Bip01_Head1")
    local rightHand = copy:LookupBone("ValveBiped.Bip01_R_Hand")

    local headPos = copy:GetPos() + copy:GetUp() * 60
    
    copy.RenderOverride = function(self)
        if IsValid(ply) and IsValid(copy) then
            copy:DrawModel()
            copy:FrameAdvance()
        end
    end

	local camera = gebLib_Camera.New("Sukuna_Domain", ply, 60, 850)
	owner.gJujutsu_Camera = camera

    local rotateStart = 0

    local scaleMin = 0
    local scaleMax = 1
    local speed = 3

    local firstStartPos = copy:GetPos() + copy:GetForward() * 30 + copy:GetUp() * 60
    local firstEndPos = firstStartPos + copy:GetUp() * 40
    local zoomOutPos = firstEndPos - copy:GetUp() * 40
    local zoomOutPos2 = zoomOutPos + copy:GetForward() * 150

    camera:SetThink(function()
        if not ply:IsValid() then camera:Stop() return end
        if not ply:Alive() then camera:Stop() return end
        
        local curTime = SysTime()
        
        local weapon = ply:GetActiveWeapon()
        
        ply:SetNoDraw(true)
        ply:SetEyeAngles(oldLook)
        
        ply:SetPos(cinematicPos)
    end)

    camera:AddEvent(0, 850, function(ply, pos, ang, fov)
        local initialAng = ang
        if camera.CurFrame >= 1 and camera.CurFrame <= 300 then
            pos = LerpVector(camera:GetTime(1, 400), firstStartPos, firstStartPos)
        end
        if camera.CurFrame >= 300 and camera.CurFrame <= 500 then
            ang:RotateAroundAxis(ang:Up(), Lerp(math.ease.OutExpo(camera:GetTime(300, 500)), 0, 0))
            pos = LerpVector(math.ease.InOutQuart(camera:GetTime(300, 500)), firstEndPos, zoomOutPos)
        end
        if camera.CurFrame >= 500 and camera.CurFrame <= 850 then
            pos = LerpVector(math.ease.InOutQuart(camera:GetTime(500, 600)), zoomOutPos, zoomOutPos2)
        end
        ang:RotateAroundAxis(ang:Up(), 180)

        /*if camera.CurFrame >= 700 and camera.CurFrame <= 1100 then
            if camera:FrameFirstTime(700) then
                rotateStart = SysTime()
            end

            pos = math.QuadraticBezier(math.ease.InOutQuart(math.min((SysTime() - rotateStart) / 2, 1)), zoomOutPos, headPos - copy:GetRight() * 90, headPos - copy:GetForward() * 100)
            ang = (headPos - pos):Angle()
        end*/

        /*if camera.CurFrame >= 1100 then
            local startPos = backPos + copy:GetForward() * 25 - copy:GetUp() * 40
            pos = LerpVector(math.ease.OutExpo(camera:GetTime(1100, 1150)), startPos, startPos - copy:GetForward() * 80 - copy:GetRight() * 70)
            ang:RotateAroundAxis(ang:Up(), 180)
            ang:RotateAroundAxis(ang:Up(), Lerp(math.ease.OutExpo(camera:GetTime(1100, 1150)), 0, -5))
        end*/
        return pos, ang
    end)

    camera:SetEnd(function()
        hook.Remove("CalcMainActivity", "SUKUNA_StopPlayerAnims" .. steamID)
        hook.Remove("DrawOverlay", "SUKUNA_CinematicBars" .. steamID)
        hook.Remove("HUDShouldDraw", "SUKUNA_NoHudCinematic" .. steamID)

        copy:Remove()
        ply:SetNoDraw(false)

		owner.gJujutsu_Camera = nil
    end)
    
    if localPlayer == ply then
        camera:Play()
    else
        camera:Play(true)
    end
end
