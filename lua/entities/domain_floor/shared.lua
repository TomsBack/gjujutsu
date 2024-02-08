AddCSLuaFile()

ENT.PrintName = "Domain Expansion Floor"
ENT.Author = "Tom" 
ENT.Contact = "Steam"
ENT.Purpose = "So you can walk properly in domains"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.Category = "Domain Expansions"

ENT.DisableDuplicator = true
ENT.DoNotDuplicate = true
ENT.PhysgunDisabled = true

ENT.AutomaticFrameAdvance = true
ENT.RenderGroup	= RENDERGROUP_OPAQUE

ENT.Model = Model("models/hunter/plates/plate32x32.mdl")

ENT.MinCollisionSize = Vector(-2000, -2000, -3)
ENT.MaxCollisionSize = Vector(2000, 2000, 3)

function ENT:Initialize()
	local domain = self:GetOwner()

	if domain:IsValid() then
		domain.Children[self] = true
	end

	self:SetModel(self.Model)
	self:PhysicsInitBox(self.MinCollisionSize, self.MaxCollisionSize)
	self:DrawShadow(false)
	self:SetCustomCollisionCheck(true)
	self:SetNoDraw(true)

	local phys = self:GetPhysicsObject()

	if SERVER then
		self:SetLagCompensated(true)
	end

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:AddGameFlag(bit.bor(FVPHYSICS_NO_PLAYER_PICKUP, FVPHYSICS_NO_SELF_COLLISIONS, FVPHYSICS_NO_NPC_IMPACT_DMG, FVPHYSICS_NO_IMPACT_DMG, FVPHYSICS_CONSTRAINT_STATIC))
		phys:EnableMotion(false)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
	end

	self:AddFlags(FL_STATICPROP)
end

function ENT:Draw()
	return false
end

-- Handling hooks

hook.Add("ShouldCollide", "gJujutus_DomainFloorCollide", function(ent1, ent2)
	if not ent1:IsValid() then return false end
	if not ent2:IsValid() then return false end
	
	local domainFloor = NULL
	local otherEnt = NULL

	if ent1:GetClass() == "domain_floor" then
		 domainFloor = ent1 
		 otherEnt = ent2
	end

	if ent2:GetClass() == "domain_floor" then
		domainFloor = ent2
		otherEnt = ent1
	end

	if not domainFloor:IsValid() then return false end
	if not domainFloor:GetOwner():IsValid() then return false end

	local domain = domainFloor:GetOwner()

	if not domain then return false end

	return domain:IsInDomain(otherEnt)
end)
