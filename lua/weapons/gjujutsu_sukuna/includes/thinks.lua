
function SWEP:FingerStatsThink()
	local fingers = self:GetFingers()

	local owner = self:GetOwner()

	self:SetMaxCursedEnergy(self.DefaultMaxCursedEnergy + (self.EnergyPerFinger * fingers))
	self:SetCursedEnergyRegen(self.DefaultCursedEnergyRegen + (self.EnergyGainPerFinger * fingers))

	self.HealthGain = self.DefaultHealthGain + (self.HealthGainPerFinger * fingers)

	print(self.HealthGain)
	if SERVER and owner:IsValid() then
		owner:SetMaxHealth(self.DefaultMaxHealth + (self.HealthPerFinger * fingers))
	end
end
