AddCSLuaFile()

ENT.PrintName = "Sukuna Finger"
ENT.Author = "Tom" 
ENT.Contact = "Steam"
ENT.Purpose = "Delicious food"
ENT.Type = "anim"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "gJujutsu"

ENT.AutomaticFrameAdvance = true
ENT.RenderGroup	= RENDERGROUP_OPAQUE

ENT.Model = Model("models/gjujutsu/sukuna_finger/sukuna_finger.mdl")

function ENT:Initialize()
	self.Initialized = true

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
end

function ENT:PostInitialize()
	self.PostInitialized = true
end

function ENT:Use(activator)
	if not activator:IsValid() then return end
	if not activator:IsPlayer() then return end
	local weapon = activator:GetWeapon("gjujutsu_sukuna")

	self:Remove()

	if weapon:IsValid() then
		weapon:SetFingers(math.min(weapon:GetFingers() + 1, 20))
		return
	end

	activator:EmitSound("gjujutsu_kaisen/sukuna/sukuna_laugh.wav")

	activator:Kill()
end
