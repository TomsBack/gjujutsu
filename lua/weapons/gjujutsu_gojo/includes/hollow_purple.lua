function SWEP:HollowPurpleBegin()
	if CurTime() < self:GetNextAbility5() then return end
	if self:GetPurpleProcess() then return end
	self:SetPurpleProcess(true)
	local owner = self:GetOwner()
	self:SetBusy(true)

	self.LastMoveType = owner:GetMoveType()
	owner:SetMoveType(MOVETYPE_NONE)

	if SERVER then
		local blue = ents.Create("purple_blue")
		self:SetPurpleBlue(blue)
		blue:SetOwner(owner)
		blue:SetPos(owner:EyePos() - owner:GetAngles():Forward() * 25 - owner:GetRight() * self.PurplePosOffset)
		blue:Spawn()

		blue:EmitSound(self.BlueSummonSound)
	end

	self:SetTimedEvent("PurpleSpawnRed", 0.5)
end

function SWEP:PurpleSpawnRed()
	local owner = self:GetOwner()

	if SERVER then
		local red = ents.Create("purple_red")
		self:SetPurpleRed(red)
		red:SetOwner(owner)

		red:SetPos(owner:EyePos() - owner:GetAngles():Forward() * 25 + owner:GetRight() * self.PurplePosOffset)
		red:Spawn()

		red:EmitSound(self.BlueSummonSound)
	end

	self:SetTimedEvent("PurpleCombineBlueRed", 0.75)
end

function SWEP:PurpleCombineBlueRed()
    local owner = self:GetOwner()
	local weapon = owner:GetActiveWeapon()

	owner:gebLib_PlayAction("gojo_hollow_purple", 1.75)

	self.PurpleThinkName = "gJujutsu_HollowPurpleCombine" .. tostring(self) .. tostring(self:GetOwner())

	local blue = self:GetPurpleBlue()
	local red = self:GetPurpleRed()

	local start = CurTime()
	local endTime = 1.25
	local finishedAnim = false

	local combined = false
	
	hook.Add("FinishMove", self.PurpleThinkName, function(ply, mv)
		if ply ~= owner then return end
		if not ply:IsValid() then hook.Remove("FinishMove", self.PurpleThinkName) return end
		if not weapon:IsValid() then hook.Remove("FinishMove", self.PurpleThinkName) return end
		if not ply:Alive() then hook.Remove("FinishMove", self.PurpleThinkName) return end

		local angles = mv:GetAngles()
		local startPos = mv:GetOrigin() + angles:Up() * 60 - angles:Forward() * 25

		local blueInitPos = startPos - angles:Right() * self.PurplePosOffset
		local redInitPos = startPos + angles:Right() * self.PurplePosOffset
		local combinePos = startPos
		
		local currentAnimTime = math.ease.InOutQuart(math.min((CurTime() - start) / endTime, 1))

		local bluePos = LerpVector(currentAnimTime, blueInitPos, combinePos)
		local redPos = LerpVector(currentAnimTime, redInitPos, combinePos)

		if finishedAnim then
			local hollowPurple = self:GetHollowPurple()

			if hollowPurple:IsValid() then
				hollowPurple:SetPos(ply:EyePos() + angles:Forward() * self.HollowPurpleOffset)
				hollowPurple:SetAngles(angles)
			end
		end

		if not blue:IsValid() then return end
		if not red:IsValid() then return end

		--If red and blue combined
		if currentAnimTime >= 0.6 and not combined then
			combined = true

			ParticleEffect("blue_red_combine", combinePos, angle_zero, blue)

			if CLIENT and IsFirstTimePredicted() or SERVER then
				util.ScreenShake(owner:GetPos(), 5, 5, 1, 200)
			end

			if SERVER then
				owner:EmitSound(Sound("gjujutsu_kaisen/sfx/gojo/blue_red_combine.wav"))
			end
		end

		if currentAnimTime >= 1 and not finishedAnim then
			finishedAnim = true

			if SERVER then
				local hollowPurplePos = ply:EyePos() + angles:Forward() * self.HollowPurpleOffset

				for i = 1, math.random(20, 35) do
					local fragment = ents.Create("purple_fragment")
					fragment.StartPos = combinePos - angles:Forward() * math.Rand(-25, 25)
					fragment.BezierPos = ply:EyePos() + angles:Right() * math.Rand(-150, 150) + angles:Up() * math.Rand(-150, 150)
					fragment.EndPos = hollowPurplePos
                    fragment:SetOwner(owner)
					fragment:SetPos(fragment.StartPos)
					fragment:Spawn()
					
					timer.Simple(1.5, function()
						if fragment:IsValid() then fragment:Remove() end
					end)
				end

				timer.Simple(0.25, function()
					owner:EmitSound(Sound("gjujutsu_kaisen/sfx/gojo/fragments_combine.wav"))
				end)

				blue:Remove()
				red:Remove()

				-- owner:EmitSound(Sound("gjujutsu_kaisen/sfx/gojo/hollow_1.wav"))
			end

			if CLIENT then
				blue.Particle:StopEmission(false, true)
				red.Particle:StopEmission(false, true)
			end
		end

		blue:SetNetworkOrigin(bluePos)
		red:SetNetworkOrigin(redPos)
	end)

	self:SetTimedEvent("SpawnHollowPurple", endTime + endTime * 0.75)
    timer.Simple(0.5, function ()
        if SERVER and owner:IsValid() and not self:GetHoldingPurple() then
			owner:EmitSound(Sound("gjujutsu_kaisen/gojo/voice/purple_voice_0".. math.random(1, 2) ..".wav"))
		end
    end)
end

function SWEP:SpawnHollowPurple()
	if not IsFirstTimePredicted() then return end
	local owner = self:GetOwner()

	if SERVER then
		local hollowPurplePos = owner:EyePos() + owner:GetForward() * self.HollowPurpleOffset

		local hollowPurple = ents.Create("hollow_purple")
		hollowPurple:SetOwner(owner)
		hollowPurple:SetPos(hollowPurplePos)
		hollowPurple:SetAngles(owner:GetAngles())
		hollowPurple:SetFireVelocity(owner:GetAimVector())
		hollowPurple:Activate()
		hollowPurple:Spawn()
		self:SetHollowPurple(hollowPurple)
		self.purple = hollowPurple

		if not self:GetHoldingPurple() then
			local effectData = EffectData()
			effectData:SetEntity(owner)
			effectData:SetOrigin(owner:EyePos() + owner:GetForward() * 50)
			util.Effect("vm_distort", effectData, true, true)

			hollowPurple:EmitSound(Sound("gjujutsu_kaisen/sfx/gojo/hollow_purple_fire.wav"))
		end
	end
	
	owner:gebLib_PauseAction()

	if not self:GetHoldingPurple() then
		owner:gebLib_ResumeAction(1.75)
		self:SetNextAbility5(CurTime() + self.Ability5CD)
		self:SetTimedEvent("FireHollowPurple", 1)
	end
end

function SWEP:FireHollowPurple()
	hook.Remove("FinishMove", self.PurpleThinkName)
	local owner = self:GetOwner()
	local hollowPurple = self:GetHollowPurple()

	self:SetBusy(false)
	self:SetHoldingPurple(false)
	self:SetPurpleProcess(false)

	if hollowPurple:IsValid() and hollowPurple:GetFired() then
		return
	end
	
	owner:SetMoveType(self.LastMoveType)
	
	if hollowPurple:IsValid() then
		if CLIENT and IsFirstTimePredicted() or SERVER then
			for _, ent in ipairs(ents.FindInSphere(owner:GetPos(), 700)) do
				if ent:IsPlayer() then
					ent:ScreenFade(SCREENFADE.PURGE, Color(200, 0, 255), 0.01, 0.1)
				end
			end
			util.ScreenShake(owner:GetPos(), 20, 5, 5, 1000)
		end
		
		hollowPurple:SetFireVelocity(owner:GetAimVector())
		self:GetHollowPurple():Release()
		
		if owner:IsValid() then
			owner:RemoveFlags(FL_ATCONTROLS)
		end
	end

	if hollowPurple:IsValid() then
		local finalCost = math.Remap(math.max(hollowPurple:GetFinalHoldTime(), 0), 0, hollowPurple.MaxHoldTime, self.Ability5Cost.Min, self.Ability5Cost.Max)
		self:RemoveCursedEnergy(finalCost)
	end
end
