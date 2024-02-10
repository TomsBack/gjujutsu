AddCSLuaFile()

if SERVER then
	util.AddNetworkString("gJujutsu_cl_projectileExplode") -- Clientside traces are inaccurate so i need to send a message from server to spawn effects
	util.AddNetworkString("gJujutsu_cl_explode")
end

ENT.Type = "anim"
ENT.PrintName = "Reversal Red"
ENT.Author = "El Tomlino"
ENT.Purpose = "Reversal red"
ENT.Category = "El Tomlino"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

ENT.Initialized = false
ENT.PostInitialized = false

ENT.DebrisEnabled = GetConVar("gjujutsu_fps_debris")
ENT.Model = Model("models/hunter/misc/sphere2x2.mdl")
ENT.PredictedThinkName = ""

ENT.ProjectileHealth = 2000 -- The projectile health, when it reaches 0, it will explode

ENT.Particle = NULL
ENT.ParticleGlow = NULL
ENT.GlowStart = 1.3

ENT.DamageMin = 250
ENT.DamageMax = 2500
ENT.MaxCharge = 10
ENT.DamageMultiplier = 1 -- Used to save damage multiplier before firing a reversal red projectile

ENT.HitBoxMins = Vector(-35, -35, -35)
ENT.HitBoxMaxs = Vector(35, 35, 35)

ENT.MinHoldTime = 4.5

ENT.ExplosionRadius = 150
ENT.ExplosionForce = 10000

ENT.FireVelocity = 40
ENT.SavedScale = -1

ENT.ExplodeTime = 4
ENT.Explosion = false

ENT.ActivateSound = Sound("gjujutsu_kaisen/sfx/gojo/reversal_red_windup.wav")
ENT.ReadySound = Sound("gjujutsu_kaisen/sfx/gojo/reversal_red_spark.wav")
ENT.ExplosionSound = Sound("gjujutsu_kaisen/sfx/gojo/reversal_red_explosion.wav")
ENT.PrepareExplosionSound = Sound("gjujutsu_kaisen/sfx/gojo/reversal_red_fire.wav")

ENT.ProjectileVoiceSound = Sound("gjujutsu_kaisen/gojo/voice/reversal_red_01.wav")
ENT.ProjectileFireSound = Sound("gjujutsu_kaisen/sfx/gojo/reversal_red_projectile_fire.wav")

ENT.ScreenFadeColor = Color(230, 33, 33)

ENT.Cost = {Min = 250, Max = 500}

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
ENT.Particles = {}

-- Saving the swep before firing off projectile
ENT.Weapon = NULL

gebLib.ImportFile("includes/thinks.lua")

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "SpawnTime")
	self:NetworkVar("Float", 1, "FireTime")
	self:NetworkVar("Float", 2, "HoldTime")

	self:NetworkVar("Vector", 0, "FireVelocity")

	self:NetworkVar("Bool", 0, "Fired")
	self:NetworkVar("Bool", 1, "ProjectileMode")
	self:NetworkVar("Bool", 3, "Ready")
end

function ENT:Initialize()
	self.Initialized = true
	self:SetSpawnTime(CurTime())

	self:SetFired(false)
	self:SetSolid(SOLID_NONE)

	self:SetModel(self.Model)
	self:SetMoveType(MOVETYPE_NONE)
    self:DrawShadow(false)

	self:SetHealth(self.ProjectileHealth)

	if CLIENT and LocalPlayer() == self:GetOwner() then
		self:SetPredictable(true)
	end

	local owner = self:GetOwner()

	if CLIENT then
        self.Particle = CreateParticleSystem(self, "technique_red", 1)
		table.insert(self.Particles, self.Particle)
		self:EmitSound(self.ActivateSound)
    end

	if SERVER then
		self:SetLagCompensated(true)
	end

	local owner = self:GetOwner()

	-- Spawn predicted think hook
	local thinkName = "gJujutsu_ReversalRed" .. tostring(owner) .. tostring(self)
	self.PredictedThinkName = thinkName

	hook.Add("Move", thinkName, function(ply, mv)
		if not self:IsValid() or not owner:IsValid() then hook.Remove("Move", thinkName) return end

		-- Only remove red if its not a projectile and was not fired, so it does not randomly explode in air
		if SERVER and self:GetProjectileMode() and not self:GetFired() and not owner:Alive() then
			self:Remove() return 
		end

		self:ReadyThink()
		if not game.SinglePlayer() then
			self:MovementThink(ply, mv)
		end
		self:PrepareExplosionThink()
	end)
end

function ENT:Think()
    if not self.Initialized then
        self:Initialize()
        return
    end

	if SERVER then
		self:HitDetectionThink()
		self:LifeTimeThink()
	end

	if game.SinglePlayer() then
		self:MovementThink()
	end

	self:ParticleScaleThink()
	self:LightThink()

	if SERVER then
		self:NextThink(CurTime())
		return true
	end
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(math.max(0, self:Health() - dmg:GetDamage()))
end

function ENT:Draw()
	for _, particle in ipairs(self.Particles) do
		if not particle:IsValid() then continue end
		particle:SetShouldDraw(false)
		particle:Render()
	end
end

function ENT:OnRemove()
	hook.Remove("Move", self.PredictedThinkName)
	local owner = self:GetOwner()

	-- Stop all reversal red sounds
	self:StopSound(self.ReadySound)
	self:StopSound(self.ActivateSound)

	if not self:GetFired() and owner:IsValid() then
		local weapon = owner:GetActiveWeapon()
		
		if weapon:IsValid() and weapon:IsGjujutsuSwep() then
			weapon:SetBusy(false)
		end
	end

	if CLIENT and self:GetFired() then
		if self.Particle:IsValid() then
			self.Particle:StopEmission(false, true)
		end

		local explosionParticle = CreateParticleSystemNoEntity("technique_red_explosion", self:GetPos())
		local scaleVector = vector_origin
		scaleVector.x = self:GetHoldTime() * 50
		explosionParticle:SetControlPoint(1, scaleVector)

		table.insert(self.Particles, explosionParticle)
	end
end

function ENT:FireOff()
	local curTime = CurTime()
	local owner = self:GetOwner()
	local weapon = owner:GetActiveWeapon()
	local ownerPos = owner:GetPos()
	local heldTime = curTime - self:GetSpawnTime()

	if heldTime <= self.MinHoldTime then
		timer.Remove("reversal_red_key_pause" .. tostring(owner))
		owner:gebLib_ResumeAction(-1)
		
		if SERVER then 
			self:Remove()
		end

		return
	end
	
	self:SetHoldTime(math.min(heldTime - self.MinHoldTime, self.MaxCharge))
	self:SetFireTime(curTime)

	if self:GetProjectileMode() then
		self:FireEffects()
		self:SetFireVelocity(owner:GetAimVector())

		self.DamageMultiplier = weapon.DamageMultiplier
		self.Weapon = weapon
	else
		self:PrepareExplosion()
	end

	self:SetFired(true)
end

function ENT:FireEffects()
	local owner = self:GetOwner()
	local ownerPos = owner:GetPos()

	if SERVER then
		util.ScreenShake(ownerPos, 25, 25, 3, 750, true)

		if self:GetProjectileMode() then
			owner:EmitSound(self.ProjectileFireSound)
		end
	end

	if CLIENT then
		local ply = LocalPlayer()

		-- First spawn debris at the owner
		if self.DebrisEnabled:GetBool() then
			CreateParticleSystemNoEntity("debris_2", ownerPos)
			CreateParticleSystemNoEntity("smoke_debris_ring", ownerPos)
		end

		local distance = ownerPos:Distance(ply:GetPos())

		if distance <= self.ExplosionRadius then
			ply:ScreenFade(SCREENFADE.PURGE, self.ScreenFadeColor, 0.1, 0.1)
		end
	end
end

function ENT:PrepareExplosion()
	local owner = self:GetOwner()

	-- Does not run on client when playing singleplayer
	if SERVER and game.SinglePlayer() then
		local particle = ParticleEffectAttach("technique_red_prepare_explosion", PATTACH_ABSORIGIN_FOLLOW, self, 0)
		table.insert(self.Particles, particle)
	end

	if CLIENT and owner:PredictedOrDifferentPlayer() then
		local particle = CreateParticleSystem(self, "technique_red_prepare_explosion", 1)
		table.insert(self.Particles, particle)
	end

	if SERVER then
		self:EmitSound(self.PrepareExplosionSound)
		owner:EmitSound("gjujutsu_kaisen/gojo/voice/reversal_red_0".. math.random(1, 5) ..".wav")
	end
end

function ENT:Explode()
	if self.Explosion then return end
	self.Explosion = true -- No need for dt vars as its not going to be predicted

	local owner = self:GetOwner()
	local weapon = owner:GetActiveWeapon()
	local ownerPos = owner:GetPos()
	local eyeAngles = owner:EyeAngles()
	
	self:FireEffects()

	owner:gebLib_ResumeAction()

	if SERVER then
		owner:EmitSound(self.ProjectileFireSound)
		owner:EmitSound(self.ExplosionSound)

		net.Start("gJujutsu_cl_explode")
		gebLib_net.WriteEntity(self)
		gebLib_net.SendToAllExcept(owner)
	end

    if CLIENT and self.DebrisEnabled:GetBool() then
		local spawnTime = 0.01
		for i = 1, 100 do
			timer.Simple(spawnTime, function()
                local forw = eyeAngles:Forward()
                local right = eyeAngles:Right()
				local debrisPos = ownerPos + forw * 35 * i + (right * math.random(-300, 300))
				local traceData = {
					start = debrisPos + vector_up * 100,
					endpos = debrisPos - vector_up * 500,
					filter = {self, owner},
					mask = MASK_NPCWORLDSTATIC
				}

				local traceDown = util.TraceLine(traceData)
				
				debugoverlay.Line(traceData.start, traceDown.HitPos, 10, color_white, true)
				if not traceDown.Hit then return end

				local prop = gebLib_utils.CreateDebris(Model("models/props_debris/concrete_chunk03a.mdl"), true, 10)
				prop:SetPos(traceDown.HitPos)
				prop:SetModelScale(math.Rand(1.75, 2.75))
				prop:SetAngles(AngleRand(0, 360))
				prop:SetCollisionGroup(3)
				prop:Spawn()
				prop:Activate()

				local phys = prop:GetPhysicsObject()

				if phys:IsValid() then
					phys:SetVelocity(vector_up * 700 + VectorRand() * 500)
					phys:SetAngleVelocity(VectorRand() * 150)
				end

				local model = gebLib_utils.CreateDebris(Model("models/props_debris/concrete_chunk03a.mdl"), false, 10)
				model:SetPos(traceDown.HitPos + vector_up * 8)
				model:SetAngles(AngleRand(0, 360))
				model:Spawn()
				model:SetModelScale(math.Rand(3.75, 5.75))

				if math.Rand(0, 1) >= 0.45 then
					CreateParticleSystemNoEntity("debris_1", model:GetPos() + VectorRand() * math.random(-100, 100))
				end
			end)
			spawnTime = spawnTime + 0.009
		end
	end

	if SERVER then
        local velocity = owner:GetAimVector() * 500000 + vector_up

		local timeHeld = self:GetHoldTime()
		local finalDamage = math.Remap(timeHeld, 0, self.MaxCharge, self.DamageMin, self.DamageMax * 1.25) * weapon.DamageMultiplier

        local dmgInfo = DamageInfo()
        dmgInfo:SetDamage(finalDamage)
        if owner:IsValid() then dmgInfo:SetAttacker(owner) end
		if self:IsValid() then dmgInfo:SetInflictor(self) end
        dmgInfo:SetDamageForce(velocity)
		
        for _, ent in ipairs(ents.FindInCone(ownerPos, owner:GetAimVector(), 3000, 0.7)) do
			if not ent:IsValid() then return end
			if ent == self or ent == owner then continue end
			if ent == weapon:GetDomain() then continue end
			if gJujutsu_EntsBlacklist[ent:GetClass()] then continue end

			if (self.DamageExceptions[ent:GetClass()]) then
				dmgInfo:SetDamageType(self.DamageExceptions[ent:GetClass()])
			else
				dmgInfo:SetDamageType(DMG_BLAST)
			end

			for _, strMatch in ipairs(self.DamageExceptionsMatch) do
				if string.match(ent:GetClass(), strMatch) then
					dmgInfo:SetDamageType(DMG_GENERIC)
					break
				end
			end

			owner:LagCompensation(true)
			SuppressHostEvents(nil)
			ent:TakeDamageInfo(dmgInfo)
			SuppressHostEvents(owner)
			owner:LagCompensation(false)

			if ent:IsPlayer() or ent:Health() > dmgInfo:GetDamage() then
				velocity = velocity / 150
				ent:SetPos(ent:GetPos() + (vector_up * 10))
			end

			ent:SetVelocity(velocity)
			if not ent:IsPlayer() and not ent:IsNPC() then
				constraint.RemoveAll(ent)
				ent:SetGravity(physenv.GetGravity():Length())
			end

			local phys = ent:GetPhysicsObject()

			if phys:IsValid() and not ent:IsPlayer() then
				phys:EnableGravity(true)
				phys:SetVelocity(velocity)
			end
        end
    end

	if SERVER then
		self:Remove()
	end
end

function ENT:ProjectileExplode()
	if self.Explosion then return end
	self.Explosion = true

	local owner = self:GetOwner()
	local weapon = owner:GetWeapon("gjujutsu_gojo")

	if weapon:IsValid() and not self:GetFired() then
		weapon:SetBusy(false)
	end

	if SERVER then
		self:EmitSound(self.ExplosionSound)
	end

	local timeHeld = self:GetHoldTime()
	local finalDamage = math.Remap(timeHeld, 0, self.MaxCharge, self.DamageMin, self.DamageMax) * self.DamageMultiplier
	
	local dmg = DamageInfo()
	if owner:IsValid() then dmg:SetAttacker(owner) end
	if self:IsValid() then dmg:SetInflictor(self) end
	dmg:SetDamage(finalDamage)

	local redPos = self:GetPos()

	if CLIENT and self.DebrisEnabled:GetBool() then
		CreateParticleSystemNoEntity("debris_1", redPos)
		CreateParticleSystemNoEntity("debris_2", redPos)

		CreateParticleSystemNoEntity("debris_1", redPos)
		CreateParticleSystemNoEntity("debris_2", redPos)
		CreateParticleSystemNoEntity("smoke_debris_ring", redPos)
	end

	local holdTimeMult = math.max(self:GetHoldTime(), 1)

	if SERVER then
		util.ScreenShake(redPos, 30, 5, 1, self.ExplosionRadius * holdTimeMult, true)
	end
	debugoverlay.Sphere(redPos, self.ExplosionRadius * holdTimeMult, 3, color_white, true)

	for _, ent in ipairs(ents.FindInSphere(redPos, self.ExplosionRadius * holdTimeMult)) do
		if not ent:IsValid() then continue end
		if ent == self then continue end
		if self.Weapon:IsValid() and ent == self.Weapon:GetDomain() then continue end
		if gJujutsu_EntsBlacklist[ent:GetClass()] then continue end

		local velocity = (ent:GetPos() - redPos):GetNormalized() * self.ExplosionForce * holdTimeMult

		dmg:SetDamageForce(velocity)
		if (self.DamageExceptions[ent:GetClass()]) then
			dmg:SetDamageType(self.DamageExceptions[ent:GetClass()])
		else
			dmg:SetDamageType(DMG_BLAST)
		end

		for _, strMatch in ipairs(self.DamageExceptionsMatch) do
			if string.match(ent:GetClass(), strMatch) then
				dmg:SetDamageType(DMG_GENERIC)
				break
			end
		end

		if SERVER then
			owner:LagCompensation(true)
			SuppressHostEvents(nil)
			ent:TakeDamageInfo(dmg)
			SuppressHostEvents(owner)
			owner:LagCompensation(false)
		end
		ent:SetVelocity(velocity)

		local phys = ent:GetPhysicsObject()

		if phys:IsValid() then
			phys:SetVelocity(velocity)
		end
	end

	-- Spawn the explosion effect entity
	if CLIENT then
		local windWaveEnt = ents.CreateClientside("explosion_ent")
		windWaveEnt.SphereSize = timeHeld * 350
		windWaveEnt.EffectTime = 0.75
		windWaveEnt.StartAlpha = 100
		windWaveEnt:SetPos(redPos)
		windWaveEnt:Spawn()

		timer.Simple(0.1, function()
			local explosionEnt = ents.CreateClientside("explosion_ent")
			explosionEnt.EffectColor = Color(255, 0, 0)
			explosionEnt.SphereSize = timeHeld * 200
			explosionEnt:SetPos(redPos)
			explosionEnt:Spawn()
		end)
	end

	if SERVER then
		self:Remove()
	end
end

function ENT:ProjectileServerExplode()
	if CLIENT then return end
	
	self:ProjectileExplode()

	net.Start("gJujutsu_cl_projectileExplode")
	gebLib_net.WriteEntity(self)
	net.Broadcast()
end

-- Handling nets

if CLIENT then
	net.Receive("gJujutsu_cl_projectileExplode", function()
		local redEntity = gebLib_net.ReadEntity()

		if redEntity:IsValid() then
			redEntity:ProjectileExplode()
		end
	end)

	net.Receive("gJujutsu_cl_explode", function()
		local redEntity = gebLib_net.ReadEntity()

		if redEntity:IsValid() then
			redEntity:Explode()
		end
	end)
end
