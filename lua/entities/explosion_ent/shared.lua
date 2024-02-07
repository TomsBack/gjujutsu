AddCSLuaFile()

ENT.PrintName = "Explosion Entity"
ENT.Author = "& Tom" 
ENT.Contact = "Steam"
ENT.Purpose = "An effect which fades out"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.Category = "gJujutsu Misc"

ENT.AutomaticFrameAdvance = true
ENT.RenderGroup	= RENDERGROUP_OPAQUE

ENT.PhysgunDisabled = true
ENT.DisableDuplicator = true
ENT.DoNotDuplicate = true

ENT.SphereSize = 20
ENT.EffectTime = 1
ENT.EffectColor = color_white
ENT.StartAlpha = 255
ENT.SpawnTime = 0

function ENT:Initialize()
	self.SpawnTime = CurTime()

	self:SetModel(Model("models/xqm/rails/gumball_1.mdl"))
	self:SetMaterial("models/additive_white")

	self:SetMoveType(MOVETYPE_NONE)
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:DrawShadow(false)
end

function ENT:Think()
	local lifeTime = CurTime() - self.SpawnTime

	if lifeTime > self.EffectTime then
		self:Remove()
	end
end

function ENT:CanTool()
	return false
end

function ENT:Draw()
	local lifeTime = CurTime() - self.SpawnTime

	local effectAlpha = math.Remap(lifeTime, 0, self.EffectTime, self.StartAlpha, 0)
	local sphereSize = math.Remap(lifeTime, 0, self.EffectTime, 0, self.SphereSize)

	render.SetColorMaterial()
	render.DrawSphere(self:GetPos(), sphereSize, 50, 50, ColorAlpha(self.EffectColor, effectAlpha))
end
