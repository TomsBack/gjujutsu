function SWEP:StatsRegenThink()
	if self:GetBusy() then return end

	local owner = self:GetOwner()

	if not owner:IsValid() then return end
	if owner:IsFrozen() or not owner:Alive() then return end
	
	if not self:GetReverseTechniqueEnabled() then
		self:SetCursedEnergy(math.min(self:GetCursedEnergy() + self:GetCursedEnergyRegen(), self:GetMaxCursedEnergy()))
		self:SetMind(math.min(self:GetMind() + self.MindRegen, self:GetMaxMind()))
	end
end

function SWEP:ReverseTechniqueThink()
	if not self:GetReverseTechniqueEnabled() then return end
	if self:GetMind() <= 0 or self:GetCursedEnergy() <= 0 then self:SetReverseTechniqueEnabled(false) return end
	local owner = self:GetOwner()

	if not owner:IsValid() then return end
	if owner:IsFrozen() or not owner:Alive() then return end

	if SERVER and owner:IsOnFire() then
		owner:Extinguish()
		self:SetMind(math.max(self:GetMind() - self.ExtinguishDrain, 0))
	end

	if owner:Health() < owner:GetMaxHealth() then
		self:SetCursedEnergy(math.min(self:GetCursedEnergy() - self.CursedEnergyDrain, self:GetMaxCursedEnergy()))
		self:SetMind(math.max(self:GetMind() - self.MindDrain, 0))
		owner:SetHealth(math.min(owner:Health() + self.HealthGain, owner:GetMaxHealth()))
	end
end

function SWEP:EventThink()
    if CurTime() > self:GetNextEvent() and self:GetNextEvent() ~= 0 then
        local event = self:GetEvent()
        self:SetNextEvent(0)
        self[event](self)

		local owner = self:GetOwner()

		if SERVER then
			-- Send to all players except the local one as he already played the function
			net.Start("gJujutsu_cl_runEventFunction")
			gebLib_net.WriteEntity(self)
			net.WriteString(event)
			gebLib_net.SendToAllExcept(owner)
		end
    end
end

function SWEP:ClampStatsThink()
	self:SetCursedEnergy(math.Clamp(self:GetCursedEnergy(), 0, self:GetMaxCursedEnergy()))
	self:SetMind(math.Clamp(self:GetMind(), 0, self:GetMaxMind()))
end

-- Animations in layers do not get killed when they are playing backwards and arrive at 0
function SWEP:ReversedActionClearThink()
	local owner = self:GetOwner()
	local actionLayer = 1

	if not owner:IsValidLayer(actionLayer) then return end

	local playback = owner:GetLayerPlaybackRate(actionLayer)
	local cycle = owner:GetLayerCycle(actionLayer)
	local duration = owner:GetLayerDuration(actionLayer)

	if playback < 0 and cycle <= 0 then
		owner:gebLib_StopAction()
	end
end
