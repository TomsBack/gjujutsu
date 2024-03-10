AddCSLuaFile()

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

ENT.DamageMin = 1
ENT.DamageMax = 20
ENT.DamageCD = 0.1

ENT.FireVelocity = 20

ENT.HitBoxMins = Vector(-35, -35, -35)
ENT.HitBoxMaxs = Vector(35, 35, 35)

ENT.StopTime = 3
ENT.LifeTime = 10

-- Entities that are not attracted by blue, identified by entity class
ENT.AttractBlacklistClass = {
	["mahoraga_wheel"] = true
}

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

local loopSound = Sound("gjujutsu_kaisen/sfx/gojo/blue_on.mp3")

local renderMins = Vector(-9999999, -9999999, -9999999)
local renderMaxs = Vector(9999999, 9999999, 9999999)

gebLib.ImportFile("includes/thinks.lua")

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "NextDamage")
	self:NetworkVar("Float", 1, "SpawnTime")

	self:NetworkVar("Bool", 0, "Stopped")

	self:NetworkVar("Vector", 0, "FireVelocity")
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

	if CLIENT then	
		self:SetRenderBoundsWS(renderMins, renderMaxs)
		self:SetRenderBounds(renderMins, renderMaxs)
		self:SetRenderClipPlaneEnabled(false)
	end

	self:SetSpawnTime(CurTime())

	local owner = self:GetOwner()
	local weapon = owner:GetActiveWeapon()

	-- Spawn predicted think hook
	local thinkName = "gJujutsu_BlueProjectile" .. tostring(owner)
	self.PredictedThinkName = thinkName

	hook.Add("FinishMove", thinkName, function(ply, mv)
		if not self:IsValid() or not owner:IsValid() then hook.Remove("FinishMove", thinkName) return end
		if SERVER and (not owner:Alive() or not weapon:IsValid()) then self:Remove() return end
		if not weapon:IsValid() then return end

		if weapon:GetCursedEnergy() <= 0 then
			weapon:BlueRemove()
		end

		if not game.SinglePlayer() then
			self:MovementThink(ply, mv)
		end

		self:AttractThink()
		self:HitDetectionThink()
		self:StopThink()
	end)

	if CLIENT then	
		table.insert(self.Particles, CreateParticleSystem(self, "gj_blue_projectile", PATTACH_ABSORIGIN_FOLLOW, 1))
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

	if SERVER then
		self:LifeTimeThink()
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
