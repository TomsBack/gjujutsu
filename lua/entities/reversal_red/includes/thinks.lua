function ENT:MovementThink(ply, mv)
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
	
	if self:GetFired() and self:GetProjectileMode() then
		finalPos = self:GetPos() + self:GetFireVelocity() * self.FireVelocity
	end

	self:SetNetworkOrigin(finalPos)
end

local vector_origin = vector_origin
function ENT:ParticleScaleThink()
	if SERVER then return end
	if not self.Particle:IsValid() then return end

	local scale = math.min(CurTime() - self:GetSpawnTime(), self.MaxCharge + self.MinHoldTime)
	local scaleVector = vector_origin
	scaleVector.x = scale

	if self:GetFired() and self.SavedScale == -1 then
		self.SavedScale = scale
	end

	if self:GetFired() then
		scale = self.SavedScale
	end

	self.Particle:SetControlPoint(1, scaleVector)
end

function ENT:PrepareExplosionThink()
	if not self:GetFired() then return end
	if self:GetProjectileMode() then return end
	if CurTime() - self:GetFireTime() < self.ExplodeTime then return end

	self:Explode()
end

function ENT:ReadyThink()
	if self:GetReady() then return end
	if CurTime() - self:GetSpawnTime() < self.MinHoldTime then return end
	local owner = self:GetOwner()

	self:SetReady(true)

	if SERVER then
		if self:GetProjectileMode() then owner:EmitSound(self.ProjectileVoiceSound) end

		self:EmitSound(self.ReadySound)
	end
end

function ENT:HitDetectionThink()
	if CLIENT then return end
	if not self:GetProjectileMode() then return end
	if self.Explosion then return end
	if not self:GetFired() then return end
	local owner = self:GetOwner()

	local redPos = self:GetPos()

	local traceData = {
		start = redPos,
		endpos = redPos + self:GetFireVelocity() * 10,
		mins = self.HitBoxMins,
		maxs = self.HitBoxMaxs,
		filter = {self, owner},
		mask = MASK_ALL
	}

	if SERVER then owner:LagCompensation(true) end
	local trace = util.TraceHull(traceData)
	if SERVER then owner:LagCompensation(false) end

	-- Found entity, explode red
	if trace.Hit then
		self:ProjectileServerExplode()
	end
end

function ENT:LightThink()
	if SERVER then return end
	if CurTime() - self:GetSpawnTime() < self.GlowStart then return end

	local curTime = CurTime()

	local light = DynamicLight(self:EntIndex())
	if light then
		light.pos = self:GetPos()
		light.r = 255
		light.g = 0
		light.b = 0
		light.brightness = 4
		light.decay = 1000
		light.size = math.Clamp((curTime - self:GetSpawnTime()) * 45, 0, 2000)
		light.dietime = curTime + 1
	end
end

function ENT:LifeTimeThink()
	if self.Explosion then return end

	local owner = self:GetOwner()

	if not owner:IsValid() then self:ProjectileServerExplode() return end
	if not owner:Alive() then self:ProjectileServerExplode() return end

	if self:Health() <= 0 then
		self:ProjectileServerExplode()
	end
end
