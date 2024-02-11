function EFFECT:Init(data)
	self.Position = data:GetOrigin()

	local emitter = ParticleEmitter(self.Position)
	local particle = emitter:Add("particles/slash_black", self.Position)
	self.Particle = particle
	particle:SetDieTime(0.5)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(255)
	particle:SetStartSize(150)
	emitter:Finish()
end

function EFFECT:Render()
end

function EFFECT:Think()
	return true
end
