if SERVER then
	util.AddNetworkString("gJujutsu_cl_sixEyesCinematic")
end

local color_black = color_black
function SWEP:SixEyesCinematic()
	local owner = self:GetOwner()

	self:SetBusy(true)
	self:SetBlockCamera(true)
	self:SetInCinematic(true)
	
	if SERVER then
		owner:Freeze(true)

		-- net.Start("gJujutsu_cl_sixEyesCinematic")
		-- gebLib_net.WriteEntity(self)
		-- gebLib_net.SendToAllExcept(owner)

		timer.Simple(3, function()
			owner:Freeze(false)

			if not self:IsValid() then return end

			self:SetBusy(false)
			self:SetBlockCamera(false)
			self:SetInCinematic(false)
		end)
	end

	if SERVER then return end

	local localPly = LocalPlayer()
	local cinematicPos = owner:GetPos()
    local steamID = owner:SteamID()

	if localPly == owner then
        owner:ScreenFade(SCREENFADE.IN, color_black, 1, 1)
    end

	local camera = gebLib_Camera.New("Six_Eyes", owner)
	owner.gJujutsu_Camera = camera

	--FIXME: angles are not right, because the NEW stupid model is bad and is defaulty rotated on a different side
    local copy = camera.Copy
	print(copy:GetModel())
	owner.gJujutsu_Copy = copy
	copy:SetSequence(owner:LookupSequence("gojo_idle"))
	local headPos = copy:GetPos() + copy:GetUp() * 70

	local bandage = ClientsideModel(Model("models/gjujutsu/gojo_bandage/gojo_bandage.mdl"))
	bandage:SetOwner(copy)
	bandage:SetAngles(copy:GetAngles())
	bandage.RenderOverride = function(self)
        bandage:DrawModel()
        bandage:FrameAdvance()
    end

	local headBone = copy:LookupBone("ValveBiped.Bip01_Head1")

	camera:SetThink(function()
        if not camera:IsValid() then camera:Stop() return end

		local bonePos, boneAng = copy:GetBonePosition(headBone)
		boneAng:RotateAroundAxis(boneAng:Right(), -90)
		boneAng:RotateAroundAxis(boneAng:Up(), -90)

        bandage:SetPos(copy:GetBonePosition(headBone) + copy:GetForward() * 2.5 + copy:GetUp() * 3)
    end) 

    camera:AddEvent(0, 250, function(ply, pos, ang, fov)
		ang.x = 0

		if camera:FrameFirstTime(75) then
			owner:EmitSound(Sound("gjujutsu_kaisen/gojo/voice/where_should_i_start.wav"))
		end

		if camera:FrameFirstTime(100) then
			copy:ResetSequence(owner:LookupSequence("gojo_bandage_off"))
			copy:SetPlaybackRate(1)
			copy:SetCycle(0)
			bandage:ResetSequence(2)
		end
		ang:RotateAroundAxis(ang:Up(), 180)

		pos = headPos + copy:GetForward() * 25 - copy:GetUp() * 5
		
        return pos, ang
    end)

    camera:SetEnd(function()
		bandage:Remove()

		owner.gJujutsu_Camera = nil
    end)
    
    if localPly == owner then
        camera:Play()
    else
        camera:Play(true)
    end
end

local beamstbl = {} -- Вне хука

local beamColors = {
    Color(255, 0, 106),
    Color(204, 0, 255),
    Color(255, 156, 214),
	Color(170, 0, 255),
	Color(255, 0, 0),
	Color(255, 167, 167)
}

local beamMat = Material( "trails/plasma" )
local gojoBackground = Material("overlays/gojo_cinmetic_background.vmt")

local fps = 30
local animRate = 1 / fps
local interval = CurTime() + animRate
local currentFrame = 0

local maxFrames1 = 22
local maxFrames2 = 22
local maxFrames3 = 25

local trees = Material("models/limitless/gojodomain1final")
local waterHexagon = Material("models/limitless/gojodomain2final")
local waterBubbles = Material("models/limitless/gojodomain3final")

function SWEP:DomainExpansionCinematic()
	local ply = self:GetOwner()
	local owner = ply
	local ownerPos = owner:GetPos()
	local weapon = owner:GetActiveWeapon()
	
	self:SetBusy(true)
	self:SetBlockCamera(true)
	self:SetInCinematic(true)
	
	if SERVER then
		owner:Freeze(true)
	end

	local camera = gebLib_Camera.New("Gojo_Domain", ply, 60, 1441)
	owner.gJujutsu_Camera = camera

	local linesStart = CurTime() + 8
	local linesEnd = CurTime() + 23
	local nextLine = CurTime()
	
	local copy = camera.Copy
	ply.gJujutsu_Copy = copy
	local plyPos = nil
	local headPos = nil
	local forw = nil

	if CLIENT then
		copy:SetSequence(owner:LookupSequence("gojo_domain_anim"))
	end
	
	local targetEnt = NULL
	local targetCopy = NULL

	local caughtInDomain = false

	local localPlayer = NULL
	local localPlayerPos = NULL

	if CLIENT then
		localPlayer = LocalPlayer()
		localPlayerPos = localPlayer:GetPos()

		plyPos = copy:GetPos()
		headPos = plyPos + copy:GetUp() * 70
		forw = copy:GetForward()

		caughtInDomain = localPlayerPos:Distance(ownerPos) <= 1000
	end

	camera:SetThink(function()
		if not camera:IsValid() then camera:Stop() return end

		if SERVER and not weapon:GetDomain():IsValid() then
			camera:Stop()

			net.Start("gJujutsu_cl_clearCamera")
			net.WriteEntity(ply)
			net.Broadcast()
			return 
		end

		if not weapon:IsValid() then return end

		local domain = weapon:GetDomain()

		if not domain:IsValid() then return end
		if not domain.EntsInDomain then return end

		if CLIENT then
			caughtInDomain = domain.EntsInDomain[LocalPlayer()]
			camera.Simulated = caughtInDomain
		end
    end)

	camera:SetEnd(function()
		if CLIENT and caughtInDomain then
			util.ScreenShake(localPlayer:GetPos(), 75, 10, 0.35, 200, true)
		end

		hook.Remove("RenderScreenspaceEffects", tostring(self) .. "_GojoHudEffect")
		hook.Remove("PostDrawTranslucentRenderables", tostring(self) .. "_GojoDomainLines")

		if SERVER then
			owner:Freeze(false)
		end

		if self:IsValid() then
			self:SetBusy(false)
			self:SetBlockCamera(false)
			self:SetInCinematic(false)

			local domain = self:GetDomain()
	
			if domain:IsValid() then
				domain:SetSpawnTime(CurTime())
			end
		end

		owner.gJujutsu_Camera = nil

		if CLIENT and targetCopy:IsValid() then
			targetCopy:Remove()
		end
    end)

	if SERVER then
		camera:Play()
	end

	if SERVER then return end
	
	self:EmitSound("gjujutsu_kaisen/sfx/domain_expansion/infinity_voide/gojo_domain_v2.wav", 0)

	-- Find target in domain radius, to show as the opponent in cinematic
	for _, ent in player.Pairs() do
		if not ent:gebLib_Alive() then continue end
		if ent == owner then continue end

		local distance = ent:GetPos():Distance(ownerPos)

		if distance > 1000 then continue end

		targetEnt = ent
		break
	end

	if not targetEnt:IsValid() then
		for _, ent in ipairs(ents.FindInSphere(ownerPos, 1000)) do
			if ent == owner then continue end
			if ent:IsPlayer() then continue end
			
			if ent:gebLib_IsPerson() then
				targetEnt = ent
				break;
			end
		end
	end

	if targetEnt:IsValid() then
		targetCopy = ClientsideModel(targetEnt:GetModel())
		targetCopy:SetPos(plyPos + forw * 1000)
		local lookAngle = (headPos - targetCopy:GetPos()):Angle()
		lookAngle.x = 0
		targetCopy:SetAngles(lookAngle)
		targetCopy:SetSequence(targetEnt:GetSequence())
		targetCopy:SetPlaybackRate(0)
		targetCopy:Spawn()
		
		targetCopy.RenderOverride = function(self)
			self:DrawModel()
			self:FrameAdvance()
		end
	end
	targetEnt.gJujutsu_Copy = tragetCopy
		
	local firstScreenTime = CurTime() + 16
	local secondScreenTime = CurTime() + 18
	local thirdScreenTime = CurTime() + 21

	local maxFrames = maxFrames1
	local screenMat = trees
	local screenEffectPaused = true

	hook.Add("RenderScreenspaceEffects", tostring(self) .. "_GojoHudEffect", function()
		if not localPlayer:gebLib_Alive() then hook.Remove("RenderScreenspaceEffects", tostring(self) .. "_GojoHudEffect") return end
		if not caughtInDomain then return end
		if screenEffectPaused then return end

		local curTime = CurTime()

		render.SetMaterial(screenMat)
		if curTime > interval then
			interval = curTime + animRate
			currentFrame = currentFrame + 1
			
			if currentFrame > maxFrames then
				currentFrame = 0
				interval = curTime + animRate
				screenEffectPaused = true

				screenMat:SetInt("$frame", currentFrame)
				return
			end

			screenMat:SetInt("$frame", currentFrame)
		end
		render.DrawScreenQuad()
	end)

	hook.Add("PostDrawTranslucentRenderables", tostring(self) .. "_GojoDomainLines", function()
		if CurTime() < linesStart then return end
		if not localPlayer:gebLib_Alive() then hook.Remove("PostDrawTranslucentRenderables", tostring(self) .. "_GojoDomainLines") return end
		if not caughtInDomain then return end

		if CurTime() > linesEnd then
			hook.Remove("PostDrawTranslucentRenderables", tostring(self) .. "_GojoDomainLines")
			return
		end

		cam.Start3D()
			cam.IgnoreZ( true )
			render.SetMaterial(gojoBackground)
			render.DrawSphere( plyPos, -9999, 9999, 9999, color_white)
			--local randomend = math.random(-100, 1000)
			local endpos = plyPos + forw * 250000
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
			render.SetMaterial(beamMat)
			local color
			for i = 1, #beamstbl - 1 do
				color = beamColors[math.random(#beamColors)]
				local weightmult = math.random(3,5)
				render.DrawBeam( beamstbl[i], plyPos + forw * -5000,weightmult, 0, 0, color )
			end

			cam.IgnoreZ( false )
		cam.End3D()

		copy:DrawModel()
		if targetCopy:IsValid() then
			targetCopy:DrawModel()
		end
	end)
    
    local head = copy:LookupBone("ValveBiped.Bip01_Head1")
    local rightHand = copy:LookupBone("ValveBiped.Bip01_R_Hand")

    local headPos = copy:GetPos() + copy:GetUp() * 60

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
    local firstonce3 = copyPos + copyForw * 900 + copyUp * 65 + copyRight * 50
    local firstonce4 = copyPos + copyForw * 1050 + copyUp * 65 + copyRight * 50
    local firstonce5 = copyPos + copyForw * 1050 + copyUp * 65 + copyRight * 120
    local firstonce6 = copyPos + copyForw * 1050 + copyUp * 65 + copyRight * 90

    camera:AddEvent(0, 1441, function(cameraPly, pos, ang, fov)
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
        end
        if curFrame >= 1180 and curFrame <= 1450 then
            pos = LerpVector(camera:GetTime(1180, 1450), firstonce4, firstonce5)
            ang:RotateAroundAxis(ang:Up(),150)
        end
        if curFrame >= 1450 and curFrame <= 1630 then
            pos = LerpVector(camera:GetTime(1450, 1470), firstonce5, firstonce6)
            ang:RotateAroundAxis(ang:Up(),150)
        end

		--Screen effects
		if camera:FrameFirstTime(960) then
			screenEffectPaused = false
		end
		if camera:FrameFirstTime(1060) then
			screenMat = waterHexagon
			
			screenEffectPaused = false
		end
		if camera:FrameFirstTime(1160) then
			screenMat = waterBubbles
			
			screenEffectPaused = false
		end

		if camera:FrameFirstTime(320) and caughtInDomain then
			localPlayer:ScreenFade(SCREENFADE.OUT, color_white, 0.7, 3.35)
		end

		if camera:FrameFirstTime(1200) and caughtInDomain then
			localPlayer:ScreenFade(SCREENFADE.OUT, color_white, 3, 1)
		end

		if camera:FrameFirstTime(1439) and caughtInDomain then
			self:SetInCinematic(false)
		end
		
        return pos, ang
    end)

	print("starting camera")
    
    if caughtInDomain then
        camera:Play()
    else
        camera:Play(true)
    end
end

if SERVER then return end

-- Handling nets

net.Receive("gJujutsu_cl_sixEyesCinematic", function()
	local weapon = gebLib_net.ReadEntity()

	if not weapon:IsValid() then return end

	weapon:SixEyesCinematic()
end)
