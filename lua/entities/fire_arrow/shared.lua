AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Fire Arrow"
ENT.Author = "El Tomlino"
ENT.Purpose = "Open"
ENT.Category = "El Tomlino"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

ENT.Initialized = false
ENT.PostInitialized = false

ENT.DebrisEnabled = GetConVar("gjujutsu_fps_debris")
ENT.Model = Model("models/gjujutsu/fire_arrow/fire_arrow.mdl")
ENT.PredictedThinkName = ""

ENT.Particle = NULL
ENT.ParticleGlow = NULL
ENT.GlowStart = 1.3

ENT.DestroyCD = 1 -- CD that applies if the player has not met the minimum charge threshold instead of applying the full CD
ENT.BurstCD = 1 -- CD for effects
ENT.NextBurst = 0

ENT.DefaultHealth = 5000 -- The projectile's health, when it reaches 0, it will explode
ENT.LifeTime = 10 -- Time before exploding on its own
ENT.Damage = {Min = 500, Max = 1200}
ENT.Charge = {Min = 0.9, Max = 10}
ENT.Cost = {Min = 50, Max = 3000}
ENT.IgniteTime = 120
ENT.DamageMultiplier = 1 -- Used to save damage multiplier before firing

ENT.Velocity = {Min = 40, Max = 70}
ENT.HitBox = {Min = 35, Max = 75}
ENT.ExplosionRadius = {Min = 750, Max = 1200}

ENT.DamageExceptions = {
    ["npc_monk"] = DMG_GENERIC,
    ["npc_strider"] = DMG_GENERIC,
    ["npc_alyx"] = DMG_GENERIC,
    ["npc_barney"] = DMG_GENERIC,
    ["npc_mossman"] = DMG_GENERIC,
    ["npc_gman"] = DMG_GENERIC,
}

-- For certain entities to watch for, I check this table to see if the entity class contains one of these
ENT.DamageExceptionsMatch = {
	"vj_ds"
}

-- I'm saving particles in to a table, so I can manually render them when needed to avoid culling and flickering
ENT.FireRing = NULL
ENT.Particles = {}

-- Saving the swep before firing off projectile
ENT.Weapon = NULL

gebLib.ImportFile("includes/thinks.lua")

function ENT:SetupDataTables() 
	self:NetworkVar("Bool", 0, "Ready")
	self:NetworkVar("Bool", 1, "Fired")

	self:NetworkVar("Float", 0, "SpawnTime")
	self:NetworkVar("Float", 1, "HoldTime")
	self:NetworkVar("Float", 3, "FireTime")
	self:NetworkVar("Float", 4, "Speed")

	self:NetworkVar("Vector", 0, "FireVelocity")
end

function ENT:Initialize()
	self.Initialized = true

	self:SetSpawnTime(CurTime())
	self.NextBurst = CurTime() + self.BurstCD

	self:SetModel(self.Model)
	self:SetSequence(1)
	self:SetPlaybackRate(2)

	self:SetMoveType(MOVETYPE_NONE)
    -- self:DrawShadow(false)
	self:SetHealth(self.DefaultHealth)

	local owner = self:GetOwner()

	if CLIENT and owner:IsValid() then
		local fireRing = CreateParticleSystem(self, "fire_ring", PATTACH_POINT, 0, owner:GetPos() + vector_up * 15)
		local fireAura = CreateParticleSystem(self, "fire_aura", PATTACH_ABSORIGIN_FOLLOW, 0)
		
		self.FireRing = fireRing
		table.insert(self.Particles, fireRing)
		table.insert(self.Particles, fireAura)
	end

	if CLIENT and LocalPlayer() == owner then
		self:SetPredictable(true)
	end

	if SERVER then
		self:SetLagCompensated(true)

		owner:EmitSound(Sound("sukuna/sfx/fire_arrow_spawn.wav"), 75, 100, 1, CHAN_STATIC)
		owner:EmitSound(Sound("sukuna/sfx/fire_arrow_ambience.wav"), 75, 100, 1, CHAN_STATIC)
	end

	print("Spawned fire arrow", owner)

	-- Spawn predicted think hook
	local thinkName = "gJujutsu_FireArrow" .. tostring(owner) .. tostring(self)
	self.PredictedThinkName = thinkName

	hook.Add("FinishMove", thinkName, function(ply, mv)
		if not self:IsValid() or not owner:IsValid() then hook.Remove("FinishMove", thinkName) return end

		if not game.SinglePlayer() then
			self:MovementThink(ply, mv)
		end
	end)
end

function ENT:Think()
    if not self.Initialized then
        self:Initialize()
        return
    end

	if SERVER then
		self:LifeTimeThink()
		self:HitDetectionThink()
	end

	if game.SinglePlayer() then
		self:MovementThink()
	end

	self:BurstThink()
	-- self:LightThink()

	if SERVER then
		self:NextThink(CurTime())
		return true
	end
end

function ENT:OnRemove()
	if self:GetFired() then
		self:Explode()
	else
		local owner = self:GetOwner()
		local weapon = owner:GetWeapon("gjujutsu_sukuna")

		if weapon:IsValid() then
			weapon:FireArrowEnd()
		end

		if weapon:IsValid() then
			weapon:SetNextAbility5(CurTime() + 1)
		end

		self:StopFireRing()

		for _, particle in ipairs(self.Particles) do
			if particle:IsValid() then particle:StopEmission() end
		end
	end

	print("Removed Fire Arrow")
end

function ENT:Release()
	local curTime = CurTime()
	local holdTime = curTime - self:GetSpawnTime()

	self:StopFireRing()

	if holdTime < self.Charge.Min then 
		if SERVER then self:Remove() end
		return
	end
		
	local owner = self:GetOwner()
	local aimVector = owner:GetAimVector()
	local weapon = owner:GetActiveWeapon()

	self.Weapon = weapon
	self.DamageMultiplier = 1 + weapon:GetFingers() / 5

	if CLIENT and owner:gebLib_PredictedOrDifferentPlayer() then
		local fireBurst = CreateParticleSystemNoEntity("fire_ring_burst_charge", owner:GetPos() + vector_up * 5)
		local fireWind = CreateParticleSystem(self, "fire_wind", PATTACH_ABSORIGIN_FOLLOW, 0)

		table.insert(self.Particles, fireWind)
		table.insert(self.Particles, fireBurst)
	end

	if SERVER and owner:IsValid() then
		owner:EmitSound(Sound("sukuna/sfx/fire_arrow_release.wav"), 75, 100, 1, CHAN_STATIC)
	end

	-- Substract the minimum charge time so the final calculations are accurate
	local finalHoldTime = math.Clamp(holdTime - self.Charge.Min, self.Charge.Min, self.Charge.Max)
	local finalSpeed = math.Remap(finalHoldTime, self.Charge.Min, self.Charge.Max, self.Velocity.Min, self.Velocity.Max)

	self:SetHoldTime(finalHoldTime)
	self:SetSpeed(finalSpeed)
	self:SetFireTime(curTime)
	self:SetFireVelocity(aimVector)
	self:SetFired(true)
	
	print("Released fire arrow")
	print("HoldTime:", finalHoldTime)
	print("Speed:", finalSpeed)
end

function ENT:Explode()
	print("Exploded fire arrow")

	self:ExplosionDamage()
	if SERVER then
		util.ScreenShake(self:GetPos(), 100, 50, 2, 3000, true)
	end
	
	if CLIENT then
		self:EmitSound(Sound("sukuna/sfx/fire_arrow_impact.wav"), 105, 100, 1, CHAN_STATIC)
		CreateParticleSystemNoEntity("explosion_huge", self:GetPos())
	end
end

function ENT:ExplosionDamage()
	if CLIENT then return end
	local owner = self:GetOwner()
	local weapon = self.Weapon

	local pos = self:GetPos()
	local holdTime = self:GetHoldTime()
	local chargeMin = self.Charge.Min
	local chargeMax = self.Charge.Max
	local finalDamage = math.Remap(holdTime, chargeMin, chargeMax, self.Damage.Min, self.Damage.Max) * self.DamageMultiplier
	local finalRadius = math.Remap(holdTime, chargeMin, chargeMax, self.ExplosionRadius.Min, self.ExplosionRadius.Max)

	print("Fire Arrow Damage", finalDamage)
	print("Fire Arrow Radius", finalRadius)

	local damageInfo = DamageInfo()
	if owner:IsValid() then damageInfo:SetAttacker(owner) end
	if self:IsValid() then damageInfo:SetInflictor(self) end
	damageInfo:SetDamageType(DMG_DISSOLVE)
	damageInfo:SetDamageForce(vector_up * 150 + VectorRand() * 150)
	damageInfo:SetDamage(finalDamage)

	for _, ent in ipairs(ents.FindInSphere(pos, finalRadius)) do
		if gebLib_ClassBlacklist[ent:GetClass()] then continue end
		if ent == weapon or ent == owner or ent == self then continue end
		if ent:GetOwner() == owner then continue end
		if ent == weapon:GetDomain() then continue end
		if ent:IsWeapon() and ent:gebLib_IsCarried() then continue end
		
		local customDamageType = weapon.DamageExceptions[ent:GetClass()]

		if customDamageType ~= nil then
			damageInfo:SetDamageType(customDamageType)
		else
			damageInfo:SetDamageType(DMG_DISSOLVE)
		end

		ent:Ignite(self.IgniteTime)

		if ent:gebLib_IsProp() or (ent:IsWeapon() and not ent:gebLib_IsCarried()) or ent:gebLib_IsItem() then
			ent:gebLib_Dissolve()
			continue
		end

		ent:TakeDamageInfo(damageInfo)
	end
end

function ENT:StopFireRing()
	if SERVER then return end

	if CLIENT and self.FireRing:IsValid() then
		self.FireRing:StopEmission()
	end
end
