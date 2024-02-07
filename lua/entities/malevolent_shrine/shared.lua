AddCSLuaFile()

ENT.PrintName = "Domain Expansion: Malevolent Shrine"
ENT.Author = "El Tomlino" 
ENT.Contact = "Steam"
ENT.Purpose = "Malevolent Shrine!"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.Category = "Domain Expansions"

ENT.AutomaticFrameAdvance = true
ENT.RenderGroup	= RENDERGROUP_OPAQUE

ENT.DamageSoundTime = 3
ENT.NextDamageSound = 0

function ENT:Initialize()
	self:SetModel(Model("models/gjujutsu/malevolent_shrine/malevolent_shrine.mdl"))
	self:SetMoveType(MOVETYPE_NONE)
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:DrawShadow(false)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableGravity(false)
		phys:EnableMotion(false)
	end
end

function ENT:Think()

	if SERVER then
		self:NextThink(CurTime())
		return true
	end
end

function ENT:OnTakeDamage(dmg)
	local curTime = CurTime()
	
	if curTime > self.NextDamageSound then
		self:EmitSound(Sound("gjujutsu_kaisen/sfx/domain_expansion/crash_0"..math.random(1,3)..".wav"))
	end

	local owner = self:GetOwner()

	owner:SetHealth(owner:Health() - dmg:GetDamage())

	self.NextDamageSound = curTime + self.DamageSoundTime
end

function ENT:CanTool()
	return false
end
