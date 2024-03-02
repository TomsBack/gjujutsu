local statsUpdateRate = 0.3
local nextStatsUpdate = CurTime() + statsUpdateRate

function SWEP:FingerStatsThink()
	if CurTime() < nextStatsUpdate then return end
	nextStatsUpdate = CurTime() + statsUpdateRate

	local fingers = self:GetFingers()
	local owner = self:GetOwner()

	self:SetMaxCursedEnergy(self.DefaultMaxCursedEnergy + (self.EnergyPerFinger * fingers))
	self:SetCursedEnergyRegen(self.DefaultCursedEnergyRegen + (self.EnergyGainPerFinger * fingers))

	self.HealthGain = self.DefaultHealthGain + (self.HealthGainPerFinger * fingers)

	if SERVER and owner:IsValid() then
		owner:SetMaxHealth(self.DefaultMaxHealth + (self.HealthPerFinger * fingers))
	end
end

function SWEP:SukunaConvarsThink()
	if SERVER and not self.MahoragaWheelConvar:GetBool() and self:GetMahoragaWheel():IsValid() then
		self:GetMahoragaWheel():Remove()
	end

	if SERVER and self:GetFingers() < self.MahoragaWheelFingerConVar:GetInt() and self:GetMahoragaWheel():IsValid() then
		self:GetMahoragaWheel():Remove()
	end
end
