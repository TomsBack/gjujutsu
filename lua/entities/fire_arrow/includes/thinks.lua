function ENT:MovementThink(ply, mv)
	if ply ~= self:GetOwner() and not game.SinglePlayer() then return end

	local owner = self:GetOwner()
	local ownerPos
	local angles
	local fixangle
	local ang
	if game.SinglePlayer() then
		ownerPos = owner:GetPos()
		angles = owner:GetAngles()
	else
		ownerPos = mv:GetOrigin()
		angles = owner:GetAngles()
	end
	angles.x = 0
	angles:RotateAroundAxis(owner:GetRight(), -2)

	local finalPos = ownerPos + angles:Up() * 53 + angles:Forward() * 28 + angles:Right() * 3
	
	if self:GetFired() then
		finalPos = self:GetPos() + self:GetFireVelocity() * self:GetSpeed()
		ang = self:GetFireVelocity():Angle()
		fixangle = Angle(ang.z,ang.y+90,ang.x)
		self:SetAngles(fixangle)
	else
		self:SetAngles(angles)
	end

	self:SetNetworkOrigin(finalPos)
end

function ENT:HitDetectionThink()
	if CLIENT then return end
	if not self:GetFired() then return end
	local owner = self:GetOwner()

	local pos = self:GetPos()
	local mins = Vector(-self.HitBox.Min, -self.HitBox.Min, -self.HitBox.Min)
	local maxs = Vector(self.HitBox.Min, self.HitBox.Min, self.HitBox.Min)

	local traceData = {
		start = pos,
		endpos = pos + self:GetFireVelocity() * 10,
		mins = mins,
		maxs = maxs,
		filter = {self, owner},
		mask = MASK_ALL
	}

	if SERVER then owner:LagCompensation(true) end
	local trace = util.TraceHull(traceData)
	if SERVER then owner:LagCompensation(false) end

	-- Found entity, explode red
	if trace.Hit then
		gebLib.PrintDebug("Fire Arrow hit")
		self:Remove()
	end
end

function ENT:LifeTimeThink()
	if CLIENT then return end
	
	local currentLifeTime = CurTime() - self:GetFireTime()
	local owner = self:GetOwner()

	if not owner:gebLib_ValidAndAlive() and not self:GetFired() then
		self:Remove()
		return
	end

	if self:Health() <= 0 then
		gebLib.PrintDebug("Removing FireArrow: No health")
		self:Remove()
		return
	end

	if self:GetFired() and currentLifeTime > self.LifeTime then
		gebLib.PrintDebug("Removing FireArrow: No life time")
		self:Remove()
	end
end

function ENT:BurstThink() 
	if self:GetFired() then return end
	if CurTime() < self.NextBurst then return end
	if CurTime() - self:GetSpawnTime() - self.Charge.Min > self.Charge.Max then return end
	self.NextBurst = CurTime() + self.BurstCD

	local owner = self:GetOwner()
	local ownerPos = owner:GetPos()
	gebLib.PrintDebug("Burst")

	if not owner:IsValid() then return end
	
	if CLIENT then
		util.ScreenShake(ownerPos, 10, 10, 0.4, 500, true)
		local fireBurst = CreateParticleSystemNoEntity("fire_ring_burst_charge", owner:GetPos() + vector_up * 5)
		table.insert(self.Particles, fireBurst)
	end
end