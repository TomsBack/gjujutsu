AddCSLuaFile()

if SERVER then
    util.AddNetworkString("GOJO_HollowPurpleCinematic")
    util.AddNetworkString("SUKUNA_DomainExpansionCinematic")
    util.AddNetworkString("GOJO_DomainExpansionCinematic")
end

if SERVER then return end

local gojoBackground = Material("overlays/gojo_cinmetic_background.vmt")

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

		print("sukuna cinematic remove")
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

local beamstbl = {} -- Вне хука
local colorslines = {
	Color(170, 0, 255),
	Color(255, 0, 0),
	Color(255, 167, 167)
}

local Laser = Material( "trails/plasma" )

local maxFrames4 = 80
local fps4 = 60
local animRate4 = 1 / fps4
local interval4 = CurTime() + animRate4
local currentFrame4 = 0
------------------------------------------
local maxFrames5 = 80
local fps5 = 60
local animRate5 = 1 / fps5
local interval5 = CurTime() + animRate5
local currentFrame5 = 0
------------------------------------------
local maxFrames6 = 59
local fps6 = 60
local animRate6 = 1 / fps6
local interval6 = CurTime() + animRate6
local currentFrame6 = 0

local trees = Material("models/limitless/gojodomain1final")
local waterHexagon = Material("models/limitless/gojodomain2final")
local waterBubbles = Material("models/limitless/gojodomain3final")

function GOJO_DomainExpansionCinematic(ply)
    local localPlayer = LocalPlayer()
    local cinematicPos = ply:GetPos()
    local steamID = ply:SteamID()

	local caughtInDomain = localPlayer:GetPos():Distance(ply:GetPos()) <= 1000

    if caughtInDomain then
        local screenWidth = ScrW()
        local screenHeight = ScrH()
        local blackBarSize = screenHeight * 0.09
        local bottomPos = screenHeight - blackBarSize + 1
        local color_black = color_black --Localize the global var

        local start = SysTime()
        local animDuration = 1 

        hook.Add("DrawOverlay", "GOJO_CinematicBars2" .. steamID, function()
            local lerpedSize = Lerp((SysTime() - start) / animDuration, 0, blackBarSize)
            local lerpedBottom = Lerp((SysTime() - start) / animDuration, screenHeight + 1, bottomPos) --Need to lerp the bottom pos, so it goes from down to up

            surface.SetDrawColor(color_black)
            surface.DrawRect(0, 0, screenWidth, lerpedSize)
            surface.DrawRect(0, lerpedBottom, screenWidth, lerpedSize)
        end)
        
        hook.Add("HUDShouldDraw", "GOJO_NoHudCinematic2" .. steamID, function()
            return false
        end)
    end

	local linesStart = CurTime() + 8
	local linesEnd = CurTime() + 27
	
	local nextLine = CurTime()

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
    copy:SetSequence(copy:LookupSequence( "gojo_domain_anim" ))
    copy:SetBodygroup(0, 1)
    copy:SetBodygroup(1, 1)
    copy:SetBodygroup(2, 1)
    copy:SetBodygroup(3, 1)
    copy:SetBodygroup(4, 1)
	    
    copy.RenderOverride = function(self)
		copy:DrawModel()
		copy:FrameAdvance()
    end

	hook.Add("PostDrawOpaqueRenderables", "GOJO_DomainLines", function()
		if CurTime() < linesStart then return end
		if not localPlayer:IsValid() then hook.Remove("PostDrawOpaqueRenderables", "GOJO_DomainLines") return end
		if not localPlayer:Alive() then hook.Remove("PostDrawOpaqueRenderables", "GOJO_DomainLines") return end
		if not caughtInDomain then return end

		if CurTime() > linesEnd then
			hook.Remove("PostDrawOpaqueRenderables", "GOJO_DomainLines")
		end

		local plyPos = ply:GetPos()
		local forw = ply:GetForward()

		cam.Start3D()
			cam.IgnoreZ( true )
			render.SuppressEngineLighting( true )
			render.SetMaterial( Material("models/rendertarget") )
			render.DrawSphere( plyPos, -9999, 9999, 9999, color_white)
			--local randomend = math.random(-100, 1000)
			local endpos = ply:GetPos() + forw * 250000
			if CurTime()  > nextLine then
				nextLine = CurTime() + 0.03 -- Задержка перед новыми лучами
				table.Empty( beamstbl )
				local seg = math.random(210, 280) -- Количество лучей
				for i = 0, seg do
					local randommount = math.random(720,-720)
					local r = math.random(10000, 12000) -- Радиус
					local a = math.rad((i / seg) * randommount)
					local x = math.cos(a) * r
					local y = math.sin(a) * r
					local beampos = forw + Vector(0, y, x)
					beampos:Rotate(copy:EyeAngles())
					table.insert(beamstbl, endpos + beampos)
				end
			end
			render.SetMaterial( Laser )
			local color
			for i = 1, #beamstbl - 1 do
				color = colorslines[math.random(#colorslines)]
				local weightmult = math.random(3,5)
				render.DrawBeam( beamstbl[i], plyPos + forw * -5000,weightmult, 0, 0, color )
			end

			render.SuppressEngineLighting( false )
			cam.IgnoreZ( false )
		cam.End3D()
	end)
    
    local head = copy:LookupBone("ValveBiped.Bip01_Head1")
    local rightHand = copy:LookupBone("ValveBiped.Bip01_R_Hand")

    local headPos = copy:GetPos() + copy:GetUp() * 60

    local camera = gebLib_Camera.New("Hollow_Purple", ply, 60, 1440)

    local rotateStart = 0

    local scaleMin = 0
    local scaleMax = 1
    local speed = 3

	local copyPos = copy:GetPos()
	local copyEyeAngles = copy:EyeAngles()
	local copyForw = copyEyeAngles:Forward()
	local copyRight = copyEyeAngles:Right()
	local copyUp = copyEyeAngles:Up()

    local firstStartPos = copyPos + copyForw * 7.5 + copyUp * 40
    local firstEndPos = firstStartPos + copyUp * 40
    local zoomOutPos = firstEndPos - copyUp * 40
    local zoomOutPos2 = zoomOutPos + copyForw * 150
    local firstonce = firstStartPos + copyRight * 15
    local firstonce2 = copyPos + copyForw * 20 + copyUp * 65
    local firstonce3 = copyPos + copyForw * 5000 + copyUp * 65 + copyRight * 50
    local firstonce4 = copyPos + copyForw * -270 + copyUp * 65 + copyRight * 50
    local firstonce5 = copyPos + copyForw * -200 + copyUp * 65 + copyRight * 120
    local firstonce6 = copyPos + copyForw * -230 + copyUp * 65 + copyRight * 90
    camera:SetThink(function()
        if not ply:IsValid() then camera:Stop() return end
        if not ply:Alive() then camera:Stop() return end
        
        local curTime = SysTime()
        
        local weapon = ply:GetActiveWeapon()
        
        ply:SetNoDraw(true)
        ply:SetEyeAngles(oldLook)
        
        ply:SetPos(cinematicPos)
    end)

    camera:AddEvent(0, 1630, function(cameraPly, pos, ang, fov)
		local curFrame = camera.CurFrame
		ang = copy:EyeAngles()
        if curFrame >= 0 and curFrame <= 15 then
            ang:RotateAroundAxis(ang:Up(),120)
            pos = LerpVector(camera:GetTime(100, 200), firstonce, firstonce)
        end
        if curFrame >= 15 and curFrame <= 560 then
            pos = LerpVector(camera:GetTime(100, 200), firstonce, firstonce2)
            ang:RotateAroundAxis(ang:Up(),120)
            ang:RotateAroundAxis(ang:Up(), Lerp(math.ease.OutExpo(camera:GetTime(100, 200)), 0, 60))
        end
        if curFrame >= 560 and curFrame <= 1180 then
            pos = LerpVector(camera:GetTime(560, 1180), firstonce2, firstonce3)
            ang:RotateAroundAxis(ang:Up(),180)
			if curFrame >= 570 then
				ang:RotateAroundAxis(ang:Up(), Lerp(math.ease.OutExpo(camera:GetTime(570, 950)), 0, -150))
			end
			util.ScreenShake(localPlayer:GetPos(), 25, 25, 0.5, 100, true)
        end
        if curFrame >= 1180 and curFrame <= 1450 then
            pos = LerpVector(camera:GetTime(1180, 1450), firstonce4, firstonce5)
            ang:RotateAroundAxis(ang:Up(),150)
			util.ScreenShake(localPlayer:GetPos(), 25, 25, 0.5, 100, true)
        end
        if curFrame >= 1450 and curFrame <= 1630 then
            pos = LerpVector(camera:GetTime(1450, 1470), firstonce5, firstonce6)
            ang:RotateAroundAxis(ang:Up(),150)
			util.ScreenShake(localPlayer:GetPos(), 25, 25, 0.5, 100, true)
        end

		if camera:FrameFirstTime(320) then
			localPlayer:ScreenFade(SCREENFADE.OUT, color_white, 0.7, 3.35)
		end

		if camera:FrameFirstTime(1200) then
			localPlayer:ScreenFade(SCREENFADE.OUT, color_white, 3, 1)
		end
        return pos, ang
    end)

    camera:SetEnd(function()
        hook.Remove("CalcMainActivity", "GOJO_StopPlayerAnims2" .. steamID)
        hook.Remove("DrawOverlay", "GOJO_CinematicBars2" .. steamID)
        hook.Remove("HUDShouldDraw", "GOJO_NoHudCinematic2" .. steamID)
		hook.Remove("PostDrawOpaqueRenderables", "GOJO_DomainLines")

		util.ScreenShake(localPlayer:GetPos(), 75, 10, 0.35, 200, true)

        copy:Remove()
        ply:SetNoDraw(false)
    end)
    
    if caughtInDomain then
        camera:Play()
    else
        camera:Play(true)
    end
end

function GOJO_HollowPurpleCinematic(ply)
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

        hook.Add("DrawOverlay", "GOJO_CinematicBars" .. steamID, function()
            local lerpedSize = Lerp((SysTime() - start) / animDuration, 0, blackBarSize)
            local lerpedBottom = Lerp((SysTime() - start) / animDuration, screenHeight + 1, bottomPos) --Need to lerp the bottom pos, so it goes from down to up

            surface.SetDrawColor(color_black)
            surface.DrawRect(0, 0, screenWidth, lerpedSize)
            surface.DrawRect(0, lerpedBottom, screenWidth, lerpedSize)
        end)
        
        hook.Add("HUDShouldDraw", "GOJO_NoHudCinematic" .. steamID, function()
            return false
        end)
    end

    if localPlayer == ply then
        ply:ScreenFade(SCREENFADE.IN, color_black, 2, 0)
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
    copy:SetParent(dummyEntity)
    copy:SetSkin(ply:GetSkin())
    copy:SetPlaybackRate(1)
    
    copy:SetBodygroup(0, 1)
    copy:SetBodygroup(1, 1)
    copy:SetBodygroup(2, 1)
    copy:SetBodygroup(3, 1)
    copy:SetBodygroup(4, 1)
    
    local head = copy:LookupBone("ValveBiped.Bip01_Head1")
    local rightHand = copy:LookupBone("ValveBiped.Bip01_R_Hand")

    local headPos = copy:GetPos() + copy:GetUp() * 60
    local backPos = headPos - copy:GetForward() * 45
    local bluePos = backPos - copy:GetRight() * 50
    local redPos = backPos + copy:GetRight() * 50
	
	local drawEffect = true
    
    copy.RenderOverride = function(self)
		if localPlayer == ply and drawEffect then
			render.Clear(0, 0, 0, 0)
			render.SuppressEngineLighting(true)
			cam.Start2D()
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(gojoBackground)
				surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			cam.End2D()
			render.SuppressEngineLighting(false)
		end
		
        copy:DrawModel()
        copy:FrameAdvance()
    end

    local camera = gebLib_Camera.New("Hollow_Purple", ply, 60, 1400)

    local rotateStart = 0

    local scaleMin = 0
    local scaleMax = 1
    local speed = 3

    local blue = NULL
    local blueStart = 0
    local blueReady = false

    local red = NULL
    local redStart = 0
    local redReady = false

    local blueFadeStart = SysTime()
    local redFadeStart = SysTime()

    local firstStartPos = copy:GetPos() + copy:GetForward() * 30 + copy:GetUp() * 60 + copy:GetRight() * 40
    local firstEndPos = firstStartPos - copy:GetRight() * 40
    local zoomOutPos = firstEndPos + copy:GetForward() * 30

    ply:EmitSound("hollo_purple_cinematic2.wav")
    ply:ScreenFade(SCREENFADE.IN, color_black, 1, 3)
    
    camera:SetThink(function()
        if not ply:IsValid() then camera:Stop() return end
        if not ply:Alive() then camera:Stop() return end
        
        local curTime = SysTime()
        local blueTime = (curTime - blueStart) * speed
        local redTime = (curTime - redStart) * speed
        
        local weapon = ply:GetActiveWeapon()
        
        ply:SetNoDraw(true)
        ply:SetEyeAngles(oldLook)
        
        if blue:IsValid() and not blueReady and blueTime < 1 then
            blue:SetModelScale(Lerp(blueTime, scaleMin, scaleMax))
        end
        
        if not blueReady and blueStart != 0 and blueTime > 1 then
            blueReady = true
            blueStart = SysTime()
        end
        
        if not redReady and redStart != 0 and redTime > 1 then
            redReady = true
            redStart = SysTime()
        end
        
        if red:IsValid() and not redReady and redTime < 1 then
            red:SetModelScale(Lerp(redTime, scaleMin, scaleMax))
        end
        
        ply:SetPos(cinematicPos)
    end)

    camera:AddEvent(0, 1400, function(ply, pos, ang, fov)
        local initialAng = ang
        if camera.CurFrame >= 180 and camera.CurFrame <= 255 then
            pos = LerpVector(camera:GetTime(180, 250), firstStartPos, firstEndPos)
        end
        if camera.CurFrame >= 255 and camera.CurFrame <= 700 then
            pos = LerpVector(math.ease.InOutQuart(camera:GetTime(255, 300)), firstEndPos, zoomOutPos)
        end
        ang:RotateAroundAxis(ang:Up(), 180)
        if camera.CurFrame >= 700 and camera.CurFrame <= 1100 then
            if camera:FrameFirstTime(700) then
                rotateStart = SysTime()
            end

            pos = math.QuadraticBezier(math.ease.InOutQuart(math.min((SysTime() - rotateStart) / 2, 1)), zoomOutPos, headPos - copy:GetRight() * 90, headPos - copy:GetForward() * 100)
            ang = (headPos - pos):Angle()
        end

        if camera.CurFrame >= 1100 then
            local startPos = backPos + copy:GetForward() * 25 - copy:GetUp() * 40
            pos = LerpVector(math.ease.OutExpo(camera:GetTime(1100, 1150)), startPos, startPos - copy:GetForward() * 80 - copy:GetRight() * 70)
            ang:RotateAroundAxis(ang:Up(), 180)
            ang:RotateAroundAxis(ang:Up(), Lerp(math.ease.OutExpo(camera:GetTime(1100, 1150)), 0, -5))
        end

		if camera:FrameFirstTime(1100) then
			drawEffect = false;
		end

		if camera:FrameFirstTime(1190) then
			local effectData = EffectData()
			effectData:SetEntity(copy)
			effectData:SetOrigin(headPos + copy:GetForward() * 50)
			util.Effect("vm_distort", effectData, true, true)
		end

        local curTime = SysTime()

        if camera:FrameFirstTime(445) then
            blue = ClientsideModel("models/xqm/rails/gumball_1.mdl")
            blue:SetMaterial("entities/gojo_technique.vmt")
            blue:SetColor(Color(0, 174, 255))
            blueStart = curTime
            blueFadeStart = curTime
            blue.RenderOverride = function(self)
                render.SetBlend(Lerp((SysTime() - blueFadeStart) * speed, 0, 1))
                self:DrawModel()
                render.SetBlend(1)
            end
            blue:SetOwner(copy)
            blue:SetPos(bluePos)
            blue:SetAngles(AngleRand())
            blue:SetModelScale(0, 0)
            blue:Spawn()
        end

        if camera:FrameFirstTime(575) then
            red = ClientsideModel("models/xqm/rails/gumball_1.mdl")
            red:SetMaterial("entities/gojo_technique.vmt")
            red:SetColor(Color(218, 40, 40))
            redStart = curTime
            redFadeStart = curTime
            red.RenderOverride = function(self)
                render.SetBlend(Lerp((SysTime() - redFadeStart) * speed, 0, 1))
                self:DrawModel()
                render.SetBlend(1)
            end
            red:SetOwner(copy)
            red:SetPos(redPos)
            red:SetAngles(AngleRand())
            red:SetModelScale(0, 0)
            red:Spawn()
        end

        if camera.CurFrame > 930 then
            if camera:FrameFirstTime(200) then
                blueStart = SysTime()
                redStart = SysTime()
            end

            local blueTime = (curTime - blueStart) * 0.45
            local redTime = (curTime - redStart) * 0.45
    
            if blue:IsValid() and blueReady then
                local bluePos  = LerpVector(math.ease.InOutQuart(math.min(blueTime, 1)), bluePos, backPos)
                blue:SetPos(bluePos)
            end

            if red:IsValid() and redReady then
                local redPos  = LerpVector(math.ease.InOutQuart(math.min(redTime, 1)), redPos, backPos)
                red:SetPos(redPos)
            end
        end

        return pos, ang
    end)

    camera:SetEnd(function()
        hook.Remove("CalcMainActivity", "GOJO_StopPlayerAnims" .. steamID)
        hook.Remove("DrawOverlay", "GOJO_CinematicBars" .. steamID)
        hook.Remove("HUDShouldDraw", "GOJO_NoHudCinematic" .. steamID)

        if blue:IsValid() then
            blue:Remove()
        end

        if red:IsValid() then
            red:Remove()
        end

        copy:Remove()
        ply:SetNoDraw(false)
    end)

    
    if localPlayer == ply then
        camera:Play()
    else
        camera:Play(true)
    end
end

net.Receive("GOJO_HollowPurpleCinematic", function()
    local ply = net.ReadEntity();

    if LocalPlayer() == ply then return end

    GOJO_HollowPurpleCinematic(ply)
end)

net.Receive("SUKUNA_DomainExpansionCinematic", function()
    local ply = net.ReadEntity();

    if LocalPlayer() == ply then return end

    SUKUNA_DomainExpansionCinematic(ply)
end)

net.Receive("GOJO_DomainExpansionCinematic", function()
    local ply = net.ReadEntity();

    if LocalPlayer() == ply then return end

    GOJO_DomainExpansionCinematic(ply)
end)
