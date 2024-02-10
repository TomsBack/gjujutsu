if SERVER then
	AddCSLuaFile("shared.lua")
end

--
ENT.PrintName = "Gojo Blue"
ENT.Author = "El Tomlino" 
ENT.Contact = "Steam"
ENT.Purpose = "Blue!"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.Category = "Domain Expansions"

ENT.DisableDuplicator = true
ENT.DoNotDuplicate = true
ENT.PhysgunDisabled = true

ENT.AutomaticFrameAdvance = true
ENT.RenderGroup	= RENDERGROUP_BOTH

ENT.Initialized = false

ENT.Model = Model("models/hunter/misc/sphere2x2.mdl")
ENT.PredictedThinkName = ""

ENT.Range = 750
ENT.Radius = 750 -- Attract radius
ENT.AttractForce = 2500
ENT.CursedEnergyDrain = 0.75 -- Per tick

ENT.DamageMin = 1
ENT.DamageMax = 20
ENT.DamageCD = 0.1

-- Entities that are not attracted by blue, identified by entity class
ENT.AttractBlacklistClass = {}

-- Entities that are not attracted by blue, identified by entity base
ENT.AttractBlacklistBase = {
	["domain_base"] = true
}

local timeScale = GetConVar("host_timescale") -- Used with RealTime, so that effects are timed correctly

ENT.DebrisEnabled = GetConVar("gjujutsu_fps_debris")
ENT.DebrisCD = 0.4 -- How fast are rocks going to spawn, when hollow purple is close to ground. Lower is faster
ENT.NextDebris = 0
ENT.PropDebrisAmount = 1 -- How many rocks with physics spawn. Can get laggy at higher numbers
ENT.StaticDebrisAmount = 2 -- How many non movable rocks spawn. Can get laggy at higher numbers

-- I'm saving particles in to a table, so I can manually render them when needed to avoid culling and flickering
ENT.Particles = {}

-- FIXME: Sound is not playing for some reason, possibly corrupted?
local loopSound = Sound("gjujutsu_kaisen/sfx/gojo/blue_on.mp3")

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "AroundMode")
	self:NetworkVar("Float", 0, "NextDamage")
end

function ENT:Initialize()
	self.Initialized = true
	self:SetModel(self.Model)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:DrawShadow(false)

	if CLIENT and LocalPlayer() == self:GetOwner() then
		self:SetPredictable(true)
	end

	if SERVER then
		self:SetLagCompensated(true)
	end

	local owner = self:GetOwner()
	local weapon = owner:GetActiveWeapon()

	-- Spawn predicted think hook
	local thinkName = "gJujutsu_BlueLapse" .. tostring(owner)
	self.PredictedThinkName = thinkName

	hook.Add("FinishMove", thinkName, function(ply, mv)
		if not self:IsValid() or not owner:IsValid() then hook.Remove("FinishMove", thinkName) return end
		if SERVER and (not owner:Alive() or not weapon:IsValid()) then self:Remove() return end
		if not weapon:IsValid() then return end

		weapon:SetCursedEnergy(math.max(weapon:GetCursedEnergy() - self.CursedEnergyDrain))

		if weapon:GetCursedEnergy() <= 0 then
			weapon:BlueRemove()
		end

		if not game.SinglePlayer() then
			self:MovementThink(ply, mv)
		end
		self:AttractThink()
	end)

	if CLIENT then	
		table.insert(self.Particles, CreateParticleSystem(self, "YLapse", PATTACH_ABSORIGIN_FOLLOW, 1))
		table.insert(self.Particles, CreateParticleSystem(self, "YLapse", PATTACH_ABSORIGIN_FOLLOW, 1))
	end

	if SERVER then
		self:EmitSound(loopSound)
	end
end

function ENT:Think()
	if not self.Initialized then
		self:Initialize()
		return
	end

	if CLIENT and self.DebrisEnabled:GetBool() and SysTime() > self.NextDebris then
		self:SpawnDebrisThink()
	end

	if CLIENT then
		self:MovementLight()
	end

	if game.SinglePlayer() then
		self:MovementThink()
	end

	if SERVER then
		self:NextThink(CurTime())
		return true
	end
end

function ENT:Draw()
	for _, particle in ipairs(self.Particles) do
		if not particle:IsValid() then continue end
		particle:SetShouldDraw(false)
		particle:Render()
	end
end

function ENT:OnRemove()
	hook.Remove("FinishMove", self.PredictedThinkName)
	self:StopSound(loopSound)

	for _, particle in ipairs(self.Particles) do
		particle:SetShouldDraw(true)
		particle:StopEmission()
	end
end

function ENT:MovementThink(ply, mv)
	if ply ~= self:GetOwner() and not game.SinglePlayer() then return end

	local owner = self:GetOwner()
	local startPos
	local angles

	if game.SinglePlayer() then
		startPos = owner:EyePos()
		angles = owner:GetAimVector():Angle()
	else
		startPos = ply:EyePos()
		angles = mv:GetAngles()
	end
	local curTime = CurTime()
	
	if self:GetAroundMode() then
		self:SetNetworkOrigin(owner:WorldSpaceCenter() + Vector(math.sin(curTime * 3) * 570, math.cos(curTime * 3) * 570, 70))
	else
		local traceData = {
			start = startPos,
			endpos = startPos + owner:GetAimVector() * self.Range,
			filter = {self, owner}
		}

		local trace = util.TraceLine(traceData)

		self:SetNetworkOrigin(trace.HitPos)
	end
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
	if owner:IsValid() then dmg:SetAttacker(owner) end
	if self:IsValid() then dmg:SetInflictor(self) end

	for _, ent in ipairs(ents.FindInSphere(self:GetPos(), self.Radius)) do
		if not ent:IsValid() then continue end
		if ent == self or ent == owner then continue end
		if gJujutsu_EntsBlacklist[ent:GetClass()] then continue end
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

function ENT:PropDebris(pos)
    local prop = gebLib_utils.CreateDebris(Model("models/props_debris/concrete_chunk03a.mdl"), true, 10)
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
end

function ENT:StaticDebris(pos, rightSide)
    if rightSide == null then rightSide = true end
    local sideDirection = rightSide and self:GetRight() or -self:GetRight()

    local model = gebLib_utils.CreateDebris(Model("models/props_debris/concrete_chunk03a.mdl"), false, 10)
    model:SetPos(pos + sideDirection * VectorRand(50, 150) + self:GetForward() * VectorRand(-50, 50) + vector_up * 15)
    model:SetAngles(AngleRand(0, 360))
    model:Spawn()
    model:SetModelScale(math.Rand(2.75, 5.75))   
end

function ENT:MovementLight()
	local light = DynamicLight(self:EntIndex())
	if light then
		light.pos = self:GetPos()
		light.r = 15
		light.g = 20
		light.b = 150
		light.brightness = 4
		light.decay = 1000
		light.size = 350
		light.dietime = CurTime() + 1
	end
end
