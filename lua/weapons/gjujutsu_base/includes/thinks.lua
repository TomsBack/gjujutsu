local nextConvarUpdate = 0
local convarCD = 0.5

function SWEP:MiscThink()
	local owner = self:GetOwner()

	if owner:IsValid() then
		owner.gJujutsu_OldVelocity = owner:GetVelocity()
	end
end

function SWEP:StatsRegenThink()
	if self:GetBusy() then return end
	if self:GetDomain():IsValid() then return end

	local owner = self:GetOwner()

	if not owner:IsValid() then return end
	if owner:IsFrozen() or not owner:Alive() then return end
	
	if not self:GetReverseTechniqueEnabled() then
		self:AddCursedEnergy(self:GetCursedEnergyRegen())
	end
end

function SWEP:ReverseTechniqueThink()
	if not self:GetReverseTechniqueEnabled() then return end
	if self:GetCursedEnergy() <= 0 then self:DisableReverseCursed() return end
	local owner = self:GetOwner()

	if not owner:IsValid() then return end
	if owner:IsFrozen() or not owner:Alive() then return end

	if SERVER and owner:IsOnFire() then
		owner:Extinguish()
		self:RemoveCursedEnergy(self.ExtinguishDrain)
	end

	if owner:Health() < owner:GetMaxHealth() then
		self:RemoveCursedEnergy(self.CursedEnergyDrain)
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
end

function SWEP:DomainClearThink()
	if not self:GetDomain():IsValid() then return end

	local cursedEnergy = self:GetCursedEnergy()
	local domain = self:GetDomain()

	if cursedEnergy <= self.DomainClearTreshold then
		if SERVER then
			domain:Remove()
		end
	end
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

function SWEP:BrainRecoverThink()
	if self:GetBrainRecoverCount() <= 0 then return end
	if CurTime() < self.NextBrainRecoverTimer then return end
	self.NextBrainRecoverTimer = CurTime() + self.BrainRecoverTimer

	self:SetBrainRecoverCount(self:GetBrainRecoverCount() - 1)

	print("Recovered brain recover", self:GetBrainRecoverCount())
end

local maxs = Vector(10, 10, 10)
function SWEP:HealOthersThink()
	if CLIENT then return end
	if not self:GetReverseTechniqueEnabled() then return end
	if not self.CanHealOthers then return end
	local owner = self:GetOwner()

	if not owner:KeyDown(IN_DUCK) then return end
	if not owner:gebLib_ValidAndAlive() then return end

	local startPos = owner:EyePos()
	
	local traceData = {
		start = startPos,
		endpos = startPos + owner:GetAimVector() * self.HealRange,
		filter = {self, owner},
		mins = -maxs,
		maxs = maxs
	}
	
	local trace = util.TraceHull(traceData)
	local ent = trace.Entity
	
	if ent:IsValid() then
		print("Healing others")
		ent:SetHealth(math.min(ent:Health() + self.HealthGain, ent:GetMaxHealth()))
		self:RemoveCursedEnergy(self.CursedEnergyDrain * 2)

		if ent:IsOnFire() then
			ent:Extinguish()
		end
	end
end

function SWEP:ConVarsThink()
	if CurTime() < nextConvarUpdate then return end
	nextConvarUpdate = CurTime() + convarCD
	
	self.BrainRecoverLimit = self.BrainRecoverConvar:GetInt()
end
