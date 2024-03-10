local timeScale = GetConVar("host_timescale") -- Used with RealTime, so that effects are timed correctly

function ENT:MovementThink(ply, mv)
	if self:GetStopped() then return end
	if ply ~= self:GetOwner() and not game.SinglePlayer() then return end

	local owner = self:GetOwner()
	local ownerPos
	local angles

	if game.SinglePlayer() then
		ownerPos = owner:GetPos()
		angles = owner:GetAimVector():Angle()
	else
		ownerPos = mv:GetOrigin()
		angles = mv:GetAngles()
	end
	angles.x = 0

	local finalPos = ownerPos + angles:Up() * 63 + angles:Forward() * 19
	finalPos = self:GetPos() + self:GetFireVelocity() * self.FireVelocity

	self:SetNetworkOrigin(finalPos)
end

function ENT:AttractThink()
	if not self:IsValid() then return end
	local owner = self:GetOwner()

	if not owner:IsValid() then return end
	if not owner:Alive() then return end

	local weapon = owner:GetActiveWeapon()

	local curTime = CurTime()

	local bluePos = self:GetPos()
	local phys = self:GetPhysicsObject()

	local dmg = DamageInfo()
	dmg:SetDamageType(DMG_CRUSH)
	if owner:IsValid() then dmg:SetAttacker(owner) end
	if weapon:IsValid() then dmg:SetInflictor(weapon) end

	for _, ent in ipairs(ents.FindInSphere(bluePos, self.Radius)) do
		if not ent:IsValid() then continue end
		if not ent:gebLib_IsUsableEntity() then continue end
		if ent == self or ent == owner then continue end
		if self.AttractBlacklistBase[ent.Base] or self.AttractBlacklistClass[ent:GetClass()] then continue end
		if ent == weapon:GetDomain() then continue end

		local entPos = ent:GetPos()

		local dir = (bluePos - entPos):GetNormalized()
		local phys = ent:GetPhysicsObject()

		if ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot() then
			ent:SetVelocity(dir * self.AttractForce / 20)
		else
			ent:SetVelocity(dir * self.AttractForce)
		end

		if phys:IsValid() then
			phys:SetVelocity(dir * self.AttractForce)
		end

		if ent:GetClass() == "reversal_red" and ent:GetFired() then
			if SERVER then
				local purple1 = ents.Create("hollow_purple")
				purple1:SetOwner(owner)
				purple1:SetFinalHoldTime(purple1.MinCharge)
				purple1:SetFired(true)
				purple1:SetPos(bluePos)
				purple1:Spawn()

				local purple2 = ents.Create("hollow_purple")
				purple2:SetOwner(owner)
				purple2:SetFinalHoldTime(purple2.MinCharge)
				purple2:SetFired(true)
				purple2:SetPos(bluePos)
				purple2:Spawn()

				timer.Simple(0, function()
					if not purple1:IsValid() then return end
					if not purple2:IsValid() then return end
					
					purple1:HollowPurpleClash(purple2)
				end)

				ent:Remove()
				self:Remove()

				weapon:RemoveCursedEnergy(1500)

				return
			end

		end

		if SERVER and curTime > self:GetNextDamage() then
			local distance = bluePos:Distance(entPos)
			local finalDamage = math.Remap(distance, self.Radius, 25, self.DamageMin, self.DamageMax) * weapon.DamageMultiplier
			
			owner:LagCompensation(true)
			SuppressHostEvents(nil)
			dmg:SetDamage(finalDamage)
			ent:TakeDamageInfo(dmg)
			SuppressHostEvents(owner)
			owner:LagCompensation(false)
		end
	end

	if curTime > self:GetNextDamage() then
		self:SetNextDamage(curTime + self.DamageCD)
	end
end

local vector_up = vector_up
function ENT:SpawnDebrisThink()
	if not self:IsValid() then return end

    self.NextDebris = SysTime() + (self.DebrisCD / timeScale:GetFloat())
    local startPos = self:GetPos() + vector_up * 50

    local traceData = {
        start = startPos,
        endpos = startPos - vector_up * 175,
        filter = {self, owner},
        mask = MASK_NPCWORLDSTATIC
    }
    
    local trace = util.TraceLine(traceData)

    if trace.HitWorld then
        traceData.endpos = startPos + self:GetForward() * 10

		if math.Rand(0, 1) >= 0.45 then
			CreateParticleSystemNoEntity("debris_2", self:GetPos() + VectorRand() * math.random(-50, 50))
		end
		for i = 1, self.PropDebrisAmount do
			self:PropDebris(trace.HitPos)
		end

		for i = 1, self.StaticDebrisAmount do
			self:StaticDebris(trace.HitPos)
		end

		for i = 1, self.StaticDebrisAmount do
			self:StaticDebris(trace.HitPos, false)
		end
    end
end

function ENT:StopThink()
	if self:GetStopped() then return end


	if CurTime() - self:GetSpawnTime() > self.StopTime then
		self:SetStopped(true)
	end
end

function ENT:HitDetectionThink()
	if CLIENT then return end
	if self:GetStopped() then return end
	local owner = self:GetOwner()

	local bluePos = self:GetPos()

	local traceData = {
		start = bluePos,
		endpos = bluePos + self:GetFireVelocity() * 15,
		mins = self.HitBoxMins,
		maxs = self.HitBoxMaxs,
		filter = {self, owner}
	}

	owner:LagCompensation(true)
	local trace = util.TraceHull(traceData)
	owner:LagCompensation(false)

	-- Found entity, explode red
	if trace.HitWorld then
		self:SetStopped(true)
	end
end

function ENT:LifeTimeThink()
	if CurTime() - self:GetSpawnTime() > self.LifeTime then
		self:Remove()
	end
end
