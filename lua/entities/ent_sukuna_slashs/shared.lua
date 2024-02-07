if SERVER then
	AddCSLuaFile("shared.lua")
end
--
ENT.PrintName = "Domain Expansion: Malevolent Shrine"
ENT.Author = "El Tomlino" 
ENT.Contact = "Steam"
ENT.Purpose = "Malevolent Shrine!"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.Category = "Domain Expansions"
ENT.DisableDuplicator = true
ENT.DoNotDuplicate = true
ENT.Animated = true
ENT.PhysgunDisabled = true
ENT.AutomaticFrameAdvance = true
ENT.RenderGroup	= RENDERGROUP_BOTH
--/me написал хук пуджа

function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "IdealPos")
end

function ENT:Initialize()
    if SERVER then
		self:SetModel("models/hunter/misc/sphere025x025.mdl")
		self:SetColor(Color(1,1,1,0))
		self:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self:DrawShadow( false )
		self:SetSolid( SOLID_OBB )
		self:SetMoveType( MOVETYPE_NOCLIP )
		self:SetSolidFlags( FSOLID_NOT_STANDABLE )
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetOwner(self.Owner)
		timer.Simple(6, function()
			if IsValid(self) then
				self:Remove()
			end
		end)
	end
	if CLIENT then
		CreateParticleSystem(self, "Shrine_Small", PATTACH_ABSORIGIN_FOLLOW, 1)
		CreateParticleSystem(self, "Shrine_CutsSmall", PATTACH_ABSORIGIN_FOLLOW, 1)
		CreateParticleSystem(self, "Shrine_DebrisSmall", PATTACH_ABSORIGIN_FOLLOW, 1)
		timer.Simple(3, function()
			if IsValid(self) then
				CreateParticleSystem(self, "Shrine_Small", PATTACH_ABSORIGIN_FOLLOW, 1)
				CreateParticleSystem(self, "Shrine_CutsSmall", PATTACH_ABSORIGIN_FOLLOW, 1)
				CreateParticleSystem(self, "Shrine_DebrisSmall", PATTACH_ABSORIGIN_FOLLOW, 1)
			end
		end)
	end
end
--			v.slashed:SetPos(v:GetPos() + v:GetUp() * 50)
function ENT:CanTool( ply, trace, mode, tool, button )
	return false
end

function ENT:Think()
	self:RemoveAllDecals()
	self:SetPos(self:GetPos())
	local owner = self.Owner
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableGravity(false)
		phys:EnableMotion(false)
	end
	if SERVER and IsValid(owner) and owner:Health() < 1 then
		self:Remove()
		elseif SERVER and IsValid(owner) and owner:Health() > 0 then
		self:SetPos(owner:GetPos()+ owner:GetUp() * 50)
		self:SetIdealPos(owner:GetPos()+ owner:GetUp() * 50)
	end
	self.antispam = self.antispam or CurTime()
	if SERVER and self.antispam < CurTime() then
		self.antispam = CurTime() + 0.001
		self:EmitSound(Sound("gjujutsu_kaisen/sfx/domain_expansion/malevolent_shrine/swing_0"..math.random(1,5)..".wav"))
		for k, v in pairs( ents.FindInSphere(self:GetPos(), 120)) do
			if (IsValid(v) and v:IsPlayer() or v:IsNPC() or v:IsNextBot()) and v != self.sukuna then
				v:TakeDamage(math.random(30,46))
				v:SetVelocity(Vector(0,0,0))
				v:EmitSound(Sound("gjujutsu_kaisen/sfx/domain_expansion/malevolent_shrine/hit_0"..math.random(1,2)..".wav"))
			end
		end
	end
end
function ENT:Draw()
    if IsValid( self ) then
		self:SetPos(LerpVector(1, owner:GetPos()+ v:GetUp() * 50, self:GetIdealPos() + v:GetUp() * 50)) 
		self:DrawModel()
	end
end
function ENT:OnRemove()
	if SERVER and IsValid(self) then
		self:Remove()
	end
end
