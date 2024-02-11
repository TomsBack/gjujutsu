
local screenMat = Material("models/limitless/matsdomainsukuna")

function SWEP:DomainExpansionCinematic()
	local ply = self:GetOwner()
	local owner = ply
	local ownerPos = owner:GetPos()
	local aimAngles = owner:GetAimVector():Angle()

	local weapon = self

	self:SetBusy(true)
	self:SetBlockCamera(true)
	self:SetInCinematic(true)
	
	if SERVER then
		owner:Freeze(true)

		self:EmitSound("sukuna/sfx/domain_cinematic.mp3")
	end

	local camera = gebLib_Camera.New("Sukuna_Domain", ply, 60, 850)
	owner.gJujutsu_Camera = camera

	local copy = camera.Copy
	ply.gJujutsu_Copy = copy
	local plyPos = nil
	local headPos = nil
	local forw = nil

	if CLIENT then
		copy:SetSequence(owner:LookupSequence("domain"))
	end

	local caughtInDomain = false

	local localPlayer = NULL
	local localPlayerPos = NULL

	if CLIENT then
		localPlayer = LocalPlayer()
		localPlayerPos = localPlayer:GetPos()

		plyPos = copy:GetPos()
		headPos = plyPos + copy:GetUp() * 70
		forw = copy:GetForward()

		caughtInDomain = false
	end

	local fps = 30
	local animRate = 1 / fps
	local interval = CurTime() + animRate
	local currentFrame = 0

	local playedClap = false
	local screenEffectPaused = true

	hook.Add("RenderScreenspaceEffects", tostring(self) .. "_SukunaHudEffect", function()
		if not localPlayer:gebLib_Alive() then hook.Remove("RenderScreenspaceEffects", tostring(self) .. "_SukunaHudEffect") return end
		if localPlayer ~= owner then return end
		if screenEffectPaused then return end

		local curTime = CurTime()

		render.SetMaterial(screenMat)
		if curTime > interval then
			interval = curTime + animRate
			currentFrame = currentFrame + 1

			screenMat:SetInt("$frame", currentFrame)
		end
		render.DrawScreenQuad()
	end)

	camera:SetThink(function()
		if not camera:IsValid() then camera:Stop() return end

		if SERVER and not weapon:GetDomain():IsValid() then
			camera:Stop()

			net.Start("gJujutsu_cl_clearCamera")
			net.WriteEntity(ply)
			net.Broadcast()
			return 
		end

		if camera.CurFrame > 100 and not playedClap then
			playedClap = true

			if CLIENT then
				owner:EmitSound(Sound("sukuna/sfx/clap.wav"))
			end
		end

		if camera.CurFrame > 130 and screenEffectPaused then
			screenEffectPaused = false
		end

		if camera.CurFrame > 382 and not screenEffectPaused then
			screenEffectPaused = true
		end

		if not weapon:IsValid() then return end

		local domain = weapon:GetDomain()

		if not domain:IsValid() then return end
    end)

	camera:SetEnd(function()
		hook.Remove("RenderScreenspaceEffects", tostring(self) .. "_SukunaHudEffect")

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

				domain:StartDomain()
			end
		end

		owner.gJujutsu_Camera = nil
    end)

	if SERVER then
		camera:Play()
	end

	if SERVER then return end
    
    local head = copy:LookupBone("ValveBiped.Bip01_Head1")
    local rightHand = copy:LookupBone("ValveBiped.Bip01_R_Hand")
    local headPos = copy:GetPos() + copy:GetUp() * 60

    local rotateStart = 0

    local scaleMin = 0
    local scaleMax = 1
    local speed = 3

    local firstStartPos = copy:GetPos() + copy:GetForward() * 30 + copy:GetUp() * 60
    local firstEndPos = firstStartPos + copy:GetUp() * 40
    local zoomOutPos = firstEndPos - copy:GetUp() * 40
    local zoomOutPos2 = zoomOutPos + copy:GetForward() * 150

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
    
    if localPlayer == ply then
        camera:Play()
    else
        camera:Play(true)
    end
end

if SERVER then return end

-- Handling nets
