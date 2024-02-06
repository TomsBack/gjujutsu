AddCSLuaFile()

if SERVER then
	util.AddNetworkString("gJujutsu_cl_hollowPurpleClash")
	util.AddNetworkString("gJujutsu_cl_spawnElectricity")
end

ENT.Type = "anim"

ENT.PrintName = "Hollow Purple"
ENT.Author = "El Tomlino"
ENT.Purpose = "Magic go boom"
ENT.Category = "El Tomlino"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

ENT.Initialized = false
ENT.PostInitialized = false;

ENT.Damage = GetConVar("hollow_purple_damage")
ENT.Speed = {Min = 20, Max = 50} --How fast hollow purple travels
ENT.HitBoxSize = {Min = 100, Max = 550} --How big is the hit box size
ENT.Lifetime = 10 --How long does hollow purple live, before exploding

ENT.DamagedList = {}

ENT.DebrisEnabled = GetConVar("gjujutsu_debris")
ENT.DebrisCD = 0.1 --How fast are rocks going to spawn, when hollow purple is close to ground. Lower is faster
ENT.NextDebris = 0
ENT.PropDebrisAmount = 4 --How many rocks with physics spawn. Can get laggy at higher numbers
ENT.StaticDebrisAmount = 2 --How many non movable rocks spawn. Can get laggy at higher numbers

ENT.ScreenShakeTime = 0.1
ENT.NextScreenShake = 0

ENT.HollowPurpleParticle = nil
ENT.FullOutputParticle = nil

-- I'm saving particles in to a table, so I can manually render them when needed to avoid culling and flickering
ENT.Particles = {}

ENT.ExplosionForce = 2000
ENT.ExplosionRadius = 600

ENT.MinCharge = 5
ENT.MaxCharge = 10

ENT.DamageMin = 2000
ENT.DamageMax = 12500
ENT.DamageMultiplier = 1 -- Used to save damage multiplier before firing hollow purple

ENT.PurpleClashRadius = 3000

ENT.MaxHoldTime = 10

ENT.MinSize = 0.25
ENT.MaxSize = 50

-- Saving the swep before firing off projectile
ENT.Weapon = NULL

ENT.ExplosionParticleColor = Color(167, 46, 167)

local timeScale = GetConVar("host_timescale") -- Used with RealTime, so that effects are timed correctly

local explosionSound = Sound("gjujutsu_kaisen/sfx/gojo/hollow_explosion.wav")
local continuousSound = Sound("gjujutsu_kaisen/sfx/gojo/hollow_purple_fire.wav") --TODO: Add incinerate sound
local clashSound = Sound("gjujutsu_kaisen/sfx/gojo/purple_clash.wav")
local blackholeExplosionSound = Sound("gjujutsu_kaisen/sfx/gojo/purple_blackhole_explode.wav")

local clashExplosionFinish = 5

ENT.DamageExceptions = {
    ["npc_monk"] = DMG_GENERIC,
    ["npc_strider"] = DMG_GENERIC,
    ["npc_alyx"] = DMG_GENERIC,
    ["npc_barney"] = DMG_GENERIC,
    ["npc_mossman"] = DMG_GENERIC,
    ["npc_gman"] = DMG_GENERIC,
	["npc_rollermine"] = DMG_BLAST,
}

-- For certain entities to watch for, I check this table to see if the entity class contains one of these
ENT.DamageExceptionsMatch = {
	"vj_ds"
}

function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "FireVelocity")

    self:NetworkVar("Float", 0, "Lifetime")
	self:NetworkVar("Float", 1, "HoldStart")
	self:NetworkVar("Float", 2, "FinalHoldTime")
	
    self:NetworkVar("Bool", 0, "Fired")
    self:NetworkVar("Bool", 1, "Exploded")
    self:NetworkVar("Bool", 2, "Clash")
    self:NetworkVar("Bool", 3, "FullOutput")
end

function ENT:Initialize()
    self.Initialized = true

    self:SetLifetime(CurTime() + self.Lifetime)
    self:SetModel("models/hunter/misc/sphere2x2.mdl")
    self:SetMaterial("entities/gojo_technique.vmt")
    self:DrawShadow(false)
	
	self:SetModelScale(self.MinSize / 11, 0)

	self:SetHoldStart(CurTime())

    if SERVER then
        self:SetLagCompensated(true)
    end

	if CLIENT and LocalPlayer() == self:GetOwner() then
		self:SetPredictable(true)
	end

    if CLIENT then
		local hollowPurpleParticle = CreateParticleSystem(self, "hollow_purple", 1)
		local scaleVector = vector_origin
		scaleVector.x = self.MinSize
		hollowPurpleParticle:SetControlPoint(1, scaleVector)
		
        self.HollowPurpleParticle = hollowPurpleParticle
		table.insert(self.Particles, self.HollowPurpleParticle)
    end

	local owner = self:GetOwner()
	local weapon = owner:GetActiveWeapon()

	self.DamageMultiplier = weapon.DamageMultiplier

	--Creating a new player tick hook that supports prediction for smoother hollow purple movement
	self.ThinkName = "GOJO_HollowPurple_" .. tostring(self:EntIndex())
	hook.Add("PlayerTick", self.ThinkName, function(ply)
		self:PredictedThink()
	end)
end

function ENT:PostInitialize()
    self.PostInitialized = true
end

function ENT:Think()
    if not self.Initialized then
        self:Initialize()
        return
    end

    if self.Initialized and not self.PostInitialized then
        self:PostInitialize()
    end

	if self:GetClash() then
		return
	end

    local owner = self:GetOwner()
    local pos = self:GetPos()

    local curTime = CurTime()

    if CLIENT then
        if self.DebrisEnabled:GetBool() and self:GetFired() and SysTime() > self.NextDebris then
            self:SpawnDebris()
        end

		if self:GetFired() then
			self:ShakeScreens()
		end

		--Spawn purple light when the hollow purple didn't eplode yet
        if not self.Exploded then
			self:MovementLight()
        end
    end

	if SERVER then
		if (owner:IsPlayer()) then
			owner:LagCompensation(true)
		end
		self:DoDamage()
		if (owner:IsPlayer()) then
			owner:LagCompensation(false)
		end
	end

	self:ScaleHollowPurple()

    if SERVER then
        self:NextThink(curTime)
        return true
    end
end

function ENT:ShakeScreens()
	if SERVER then return end
	if CurTime() < self.NextScreenShake then return end
	self.NextScreenShake = CurTime() + self.ScreenShakeTime

	for _, ply in player.Pairs() do
		local plyPos = ply:GetPos()
		local distance = self:GetPos():Distance(plyPos)

		local finalHitbox = math.Remap(self:GetFinalHoldTime(), 0, self.MaxHoldTime, self.HitBoxSize.Min, self.HitBoxSize.Max)

		if distance <= finalHitbox * 10 then
			util.ScreenShake(plyPos, 10, 10, self.ScreenShakeTime * 2, 100, true)
		end
	end
end

function ENT:PredictedThink()
	if self:GetClash() then
		return
	end
	
    local curTime = CurTime()
    local pos = self:GetPos()
	local owner = self:GetOwner()

    if self:IsValid() and self:GetFired() then
		local finalSpeed = math.Remap(self:GetFinalHoldTime(), 0, self.MaxHoldTime, self.Speed.Min, self.Speed.Max)

        self:SetNetworkOrigin(self:GetPos() + self:GetFireVelocity() * finalSpeed)
    end

	if not owner:Alive() and not self:GetFired() then
		self:Explode()
	end
    
    if self:GetFired() and curTime > self:GetLifetime() then
		self:Explode()
    end
end

local vector_up = vector_up
function ENT:SpawnDebris()
    self.NextDebris = SysTime() + (self.DebrisCD / timeScale:GetFloat())
    local startPos = self:GetPos() + vector_up * 50

	local finalSize = math.Remap(self:GetFinalHoldTime(), 0, self.MaxHoldTime, self.HitBoxSize.Min, self.HitBoxSize.Max)


    local traceData = {
        start = startPos,
        endpos = startPos - vector_up * finalSize,
        filter = {self, owner},
        mask = MASK_NPCWORLDSTATIC
    }
    
    local trace = util.TraceLine(traceData)
    if trace.HitWorld then
        traceData.endpos = startPos + self:GetForward() * 10

		if math.Rand(0, 1) >= 0.45 then
			CreateParticleSystemNoEntity("debris_2", self:GetPos() + VectorRand() * math.random(-50, 50))
			-- table.insert(self.Particles, debrisParticle)
		end
        
        local traceForw = util.TraceLine(traceData)

        if not traceForw.Hit then
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
end

function ENT:PropDebris(pos)
    local prop =  gebLib_utils.CreateDebris(Model("models/props_debris/concrete_chunk03a.mdl"), true, 10)
    prop:SetPos(pos)
    prop:SetModelScale(math.Rand(1.75, 2.75))
    prop:SetAngles(AngleRand(0, 360))
    prop:SetCollisionGroup(3)
    prop:Spawn()
    prop:Activate()

    local phys = prop:GetPhysicsObject()

    if phys:IsValid() then
        phys:SetVelocity(vector_up * 300 + VectorRand() * 700)
        phys:SetAngleVelocity(VectorRand() * 150)
    end

    timer.Simple(10, function()
        if prop:IsValid() then prop:Remove() end
    end)
end

function ENT:StaticDebris(pos, rightSide)
    if rightSide == null then rightSide = true end
    local sideDirection = rightSide and self:GetRight() or -self:GetRight()

    local model =  gebLib_utils.CreateDebris(Model("models/props_debris/concrete_chunk03a.mdl"), false, 10)
    model:SetPos(pos + sideDirection * VectorRand(50, 150) + self:GetForward() * VectorRand(-50, 50) + vector_up * 15)
    model:SetAngles(AngleRand(0, 360))
    model:Spawn()
    model:SetModelScale(math.Rand(2.75, 5.75))   

    timer.Simple(10, function()
        if model:IsValid() then model:Remove() end
    end)
end

function ENT:Release()
    if self:GetFired() then return end

	local owner = self:GetOwner()
	local weapon = owner:GetActiveWeapon()

	self:SetFinalHoldTime(math.min(CurTime() - self:GetHoldStart(), self.MaxHoldTime))

	if SERVER and self:GetFullOutput() then
		util.ScreenShake(owner:GetPos(), 100, 100, 2, 3000, true)
	end

	if CLIENT and self.FullOutputParticle then
		self.FullOutputParticle:StopEmission()
	end

	self.Weapon = weapon
	self.DamageMultiplier = weapon.DamageMultiplier
    self:SetFired(true)
    self:SetLifetime(CurTime() + self.Lifetime)

    self:DoDamage()
end

function ENT:MovementLight()
	local light = DynamicLight(self:EntIndex())
	if light then
		light.pos = self:GetPos()
		light.r = 138
		light.g = 43
		light.b = 226
		light.brightness = 4
		light.decay = 1000
		light.size = 350
		light.dietime = CurTime() + 1
	end
end

function ENT:Explode()
	hook.Remove("PlayerTick", self.ThinkName)

	local owner = self:GetOwner()
	local purplePos = self:GetPos()

	if CLIENT and IsFirstTimePredicted() then
		self:EmitSound(explosionSound, 100, math.Rand(97, 103))   
		  
		local explosionParticle = CreateParticleSystemNoEntity("hollow_purple_explosion", self:GetPos())

		self.HollowPurpleParticle:StopEmissionAndDestroyImmediately()

		table.insert(self.Particles, explosionParticle)

		--Spawn an epxlosion light
		local light = DynamicLight(self:EntIndex())
		if light then
			light.pos = self:GetPos()
			light.r = 138
			light.g = 43
			light.b = 226
			light.brightness = 4
			light.decay = 500
			light.size = 600
			light.dietime = CurTime() + 2
		end
	end

	self:ExplosionDamage()

	if CLIENT then
		ExplosionParticle(self:GetPos())
	end
	
	if SERVER then
		self:Remove()
	end
end

function ENT:OnRemove()
	hook.Remove("PlayerTick", self.ThinkName)

	if CLIENT and self.FullOutputParticle and self.FullOutputParticle:IsValid() then
		self.FullOutputParticle:StopEmission()
	end

	self:StopSound(continuousSound)
end

function ENT:DoDamage()
    if CLIENT then return end

    local owner = self:GetOwner()

	local finalHitbox = math.Remap(self:GetFinalHoldTime(), 0, self.MaxHoldTime, self.HitBoxSize.Min, self.HitBoxSize.Max)
	local finalDamage = math.Remap(self:GetFinalHoldTime(), 0, self.MaxHoldTime, self.DamageMin, self.DamageMax)

	local purplePos = self:GetPos()

    for _, v in ents.Pairs() do
		if not v:IsValid() then continue end
		if v == self or v == owner or v:GetOwner() == owner then continue end
		if gJujutsu_EntsBlacklist[v:GetClass()] then continue end
		if self.Weapon:IsValid() and v == self.Weapon:GetDomain() then continue end
		if self.DamagedList[v] then continue end
		
		local distance = purplePos:Distance(v:GetPos())

		if distance > finalHitbox then continue end

		self.DamagedList[v] = v

		if v:GetClass() == "hollow_purple" and v:GetFired() then
			self:HollowPurpleClash(v)
			return
		end

		local damageInfo = DamageInfo()
		if owner:IsValid() then damageInfo:SetAttacker(owner) end
		if self:IsValid() then damageInfo:SetInflictor(self) end
		damageInfo:SetDamage(finalDamage * self.DamageMultiplier)
		
		if (self.DamageExceptions[v:GetClass()]) then
			damageInfo:SetDamageType(self.DamageExceptions[v:GetClass()])
		else
			damageInfo:SetDamageType(bit.bor(DMG_DISSOLVE, DMG_PREVENT_PHYSICS_FORCE))
		end

		for _, strMatch in ipairs(self.DamageExceptionsMatch) do
			if string.match(v:GetClass(), strMatch) then
				damageInfo:SetDamageType(DMG_GENERIC)
				break
			end
		end

		if SERVER then
			owner:LagCompensation(true)
			SuppressHostEvents(nil)
			v:TakeDamageInfo(damageInfo)
			SuppressHostEvents(owner)
			owner:LagCompensation(false)
		end

		if SERVER and v:gebLib_IsProp() then
			v:gebLib_Dissolve()
		end
    end
end

function ENT:ExplosionDamage(size, damageMin, damageMax)
	if not size then size = self.ExplosionRadius end
	if not damageMin then damageMin = self.DamageMin end
	if not damageMax then damageMax = self.DamageMax end

	local purplePos = self:GetPos()
	local owner = self:GetOwner()

	local dmg = DamageInfo()
	if owner:IsValid() then dmg:SetAttacker(owner) end
	if self:IsValid() then dmg:SetInflictor(self) end

	for _, ent in ipairs(ents.FindInSphere(purplePos, size)) do
		if not ent:IsValid() then continue end
		if not ent:IsSolid() then continue end
		if ent == self then continue end
		if self.Weapon:IsValid() and ent == self.Weapon:GetDomain() then continue end
		if gJujutsu_EntsBlacklist[ent:GetClass()] then continue end
		if self.DamagedList[ent] then continue end

		local velocity = (ent:GetPos() - purplePos):GetNormalized() * self.ExplosionForce
		local distance = purplePos:Distance(ent:GetPos())
		local finalDamage = math.Remap(distance, size, 25, damageMin * 0.65, damageMax) * self.DamageMultiplier

		dmg:SetDamage(finalDamage)
		dmg:SetDamageForce(velocity)
		if owner:IsValid() then dmg:SetAttacker(owner) end
		if self:IsValid() then dmg:SetInflictor(self) end
		if (self.DamageExceptions[ent:GetClass()]) then
			dmg:SetDamageType(self.DamageExceptions[ent:GetClass()])
		else
			dmg:SetDamageType(bit.bor(DMG_DISSOLVE, DMG_PREVENT_PHYSICS_FORCE))
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

		if SERVER and ent:gebLib_IsProp() then
			ent:gebLib_Dissolve()
		end
	end
end

function ENT:ScaleHollowPurple()
	if not self:IsValid() then return end
	if self:GetFired() then return end

	local owner = self:GetOwner()
	local ownerPos = owner:GetPos()

	local holdTime = CurTime() - self:GetHoldStart()
	local size = math.Remap(math.min(holdTime, self.MaxHoldTime), 0, self.MaxHoldTime, self.MinSize, self.MaxSize)

	if not self:GetFullOutput() and holdTime >= self.MaxHoldTime then
		self:SetFullOutput(true)

		if SERVER then
			net.Start("gJujutsu_cl_spawnElectricity")
			net.WriteEntity(owner)
			net.WriteEntity(self)
			net.Broadcast()
			owner:EmitSound(Sound("gjujutsu_kaisen/sfx/gojo/purple_full_output.wav"))
		end
	end

	self:SetModelScale(size / 11, 0)
	
	if self.HollowPurpleParticle then
		local scaleVector = vector_origin
		scaleVector.x = size
		self.HollowPurpleParticle:SetControlPoint(1, scaleVector)
	end
end

function ENT:HollowPurpleClash(otherEnt)
	if CLIENT then return end
	if not self:IsValid() then return end
	if not otherEnt:IsValid() then return end
	if self:GetExploded() then return end
	if not self:GetFired() then return end

	local finalDamage = math.Remap(self:GetFinalHoldTime(), 0, self.MaxHoldTime, self.DamageMin, self.DamageMax) * self.DamageMultiplier
	local finalDamageOtherEnt = math.Remap(otherEnt:GetFinalHoldTime(), 0, otherEnt.MaxHoldTime, otherEnt.DamageMin, otherEnt.DamageMax) * otherEnt.DamageMultiplier
	local finalDamage = finalDamage + finalDamageOtherEnt

	self:SetExploded(true)
	self:SetClash(true)
	otherEnt:SetExploded(true)

	self:EmitSound(clashSound, 10)

	timer.Simple(0.75, function()
		self:EmitSound(blackholeExplosionSound, 130)
	end)

	if SERVER then
		timer.Simple(clashExplosionFinish, function()
			self:ExplosionDamage(self.PurpleClashRadius, finalDamage * 0.1, finalDamage)
			self:Remove()
		end)
	end

	if SERVER then
		net.Start("gJujutsu_cl_hollowPurpleClash")
		net.WriteVector(self:GetPos())
		net.WriteUInt(self.PurpleClashRadius, 12)
		net.Broadcast()

		otherEnt:Remove()
	end
		
	print("Hollow purple clash")
end

function ExplosionParticle(pos, size)
	if SERVER then return end
	if not pos then pos = self:GetPos() end
	if not size then size = 500 end

	local windWaveEnt = ents.CreateClientside("explosion_ent")
	windWaveEnt.SphereSize = size
	windWaveEnt.EffectTime = 0.75
	windWaveEnt.StartAlpha = 100
	windWaveEnt:SetPos(pos)
	windWaveEnt:Spawn()

	timer.Simple(0.1, function()
		local explosionEnt = ents.CreateClientside("explosion_ent")
		explosionEnt.EffectColor = Color(167, 46, 167)
		explosionEnt.SphereSize = size * 0.9
		explosionEnt:SetPos(pos)
		explosionEnt:Spawn()
	end)
end

if SERVER then return end

local mat = Material("trails/laser")
local color = Color(177, 0, 168)
local minSize = -250
local maxSize = 250

local width = 50

function ENT:Draw()
	local startPos = self:GetPos()
	local endPos = self:GetPos() + self:GetRight() * 500

	local uv = math.Rand(0, 1)

	local isClashing = self:GetClash()

	if not isClashing then
		minSize = -250
		maxSize = 250
		width = 50
	end

	if isClashing then
		minSize = -5000
		maxSize = 5000
		width = 90
	end

	for i = 1, 10 do
		local tr = util.TraceLine({
			start = startPos,
			endpos = startPos + self:GetRight() * math.Rand(minSize, maxSize) + self:GetUp() * math.Rand(minSize, maxSize) + self:GetForward() * math.Rand(minSize, maxSize),
			filter = self
		})
		
		if tr.Hit then
			local dist = startPos:Distance(tr.HitPos) / 5
			local fragment = tr.Normal
	
			render.SetMaterial(mat)
			render.StartBeam(5)
			for j = 0, 4 do
				render.AddBeam(startPos + fragment * j * dist + VectorRand() * math.Rand(-50, 50), math.random(width, width * 1.5), uv * j, color)
			end
			render.EndBeam()
		end
	end

	if not isClashing then
		for _, particle in ipairs(self.Particles) do
			if not particle:IsValid() then continue end
			particle:SetShouldDraw(false)
			particle:Render()
		end
	end
end

-- Nets handling

net.Receive("gJujutsu_cl_hollowPurpleClash", function()
	local pos = net.ReadVector()
	local size = net.ReadUInt(12)

	local nextParticle = 0
	local finalParticleTime = clashExplosionFinish

	local electricity = CreateParticleSystemNoEntity("purple_electricity", pos)
	local blackHole = CreateParticleSystemNoEntity("[5]black_hole_b", pos)
	CreateParticleSystemNoEntity("hollow_purple_explosion", pos)

	for i = 1, 10 do
		timer.Simple(nextParticle, function()
			local explosionEnt = ents.CreateClientside("explosion_ent")
			explosionEnt.EffectColor = Color(167, 46, 167)
			explosionEnt.SphereSize = math.random(600, 1200)
			explosionEnt:SetPos(pos)
			explosionEnt:Spawn()

			util.ScreenShake(pos, 25, 25, 1, 1000, true)
		end)

		nextParticle = nextParticle + 0.4
	end
	
	timer.Simple(finalParticleTime, function()
		ExplosionParticle(pos, size)
	
		util.ScreenShake(pos, 100, 100, 2, size * 1.25, true)
	
		CreateParticleSystemNoEntity("debris_2", pos)
		CreateParticleSystemNoEntity("smoke_debris_ring", pos)
		CreateParticleSystemNoEntity("clash_explosion", pos)

		if blackHole then
			blackHole:StopEmission()
		end

		if electricity then
			electricity:StopEmission()
		end
	end)
end)

net.Receive("gJujutsu_cl_spawnElectricity", function()
	local localPly = LocalPlayer()
	local ply = net.ReadEntity()
	local purple = net.ReadEntity()

	local fullOutputParticle = CreateParticleSystemNoEntity("purple_electricity", ply:GetPos())
	purple.FullOutputParticle = fullOutputParticle

	if localPly == ply then
		ply:ScreenFade(SCREENFADE.IN, color_white, 0.15, 0.15)
	end
end)
