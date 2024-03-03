AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Mahoraga's Wheel"
ENT.Author = "El Tomlino"
ENT.Purpose = "To adapt to all phenomena"
ENT.Category = "El Tomlino"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.AutomaticFrameAdvance = true

ENT.Initialized = false
ENT.PostInitialized = false

ENT.Model = Model("models/chromeda/wheel.mdl")
ENT.PredictedThinkName = ""

ENT.SpinSpeed = 0.25

ENT.AdaptationTime = 30
ENT.AdaptGain = 12.5 -- 8 spins each having 12.5% adaptation
ENT.DamageReduction = {Min = 0, Max = 100}

ENT.SpinSound = Sound("sukuna/sfx/mahoraga_wheel_turn.wav")

local damageReductionConvar = GetConVar("gjujutsu_sukuna_mahoraga_wheel_damage_reduction")
local spinTimeConvar = GetConVar("gjujutsu_sukuna_mahoraga_wheel_spin_time")

gebLib.ImportFile("includes/thinks.lua")

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "SpinTime")
	self:NetworkVar("Float", 1, "AdaptTimer")

	self:NetworkVar("Angle", 0, "OriginalAngle")
	self:NetworkVar("Angle", 1, "DesiredAngle")
end

function ENT:Initialize()
	self.Initialized = true

	self:SetModel(self.Model)
	self:SetAngles(angle_zero)
	self:SetAdaptTimer(0)
	
	if CLIENT then
		self:SetNoDraw(true)
		self:SetPredictable(true)
	end
end

function ENT:PostInitialize()
    self.PostInitialized = true

	if CLIENT then
		local effectData = EffectData()
		-- effectData:SetRadius(0.25)
		effectData:SetEntity(self)
		
		util.Effect("spawn_effect", effectData)
		self:SetNoDraw(false)
	end
end

function ENT:Think()
    if not self.Initialized then
        self:Initialize()
        return
    end

    if self.Initialized and not self.PostInitialized then
        self:PostInitialize()
    end

	self.AdaptationTime = spinTimeConvar:GetFloat()
	self.DamageReduction.Max = damageReductionConvar:GetFloat()

	self:SpinThink()
	self:AdaptThink()

	if SERVER then
		self:NextThink(CurTime())
		return true
	end
end

function ENT:StartAdaptation()
	if self:GetAdaptTimer() <= 0 then
		self:SetAdaptTimer(CurTime() + self.AdaptationTime)
		gebLib.PrintDebug("Started Adaptation")
	end
end

function ENT:Adapt()
	local curTime = CurTime()
	local owner = self:GetOwner()
	local weapon = owner:GetWeapon("gjujutsu_sukuna")

	if not weapon:IsValid() then return end

	for ent, data in pairs(weapon.AdaptationEnts) do
		for dmgType, adaptData in pairs(data) do
			adaptData.Percentage = math.min(adaptData.Percentage + self.AdaptGain, 100)

			if SERVER and owner:IsValid() and adaptData.Percentage >= 100 and not adaptData.ShownMessage then
				adaptData.ShownMessage = true
				owner:PrintMessage(HUD_PRINTTALK, "Adapted to " .. tostring(ent) .. " Damage Type " .. tostring(dmgType))
			end
		end
	end

	gebLib.PrintDebug("Adapted")
	PrintTable(weapon.AdaptationEnts)

	if self:EntsNeedAdapting() then
		self:SetAdaptTimer(curTime + self.AdaptationTime)
	else
		gebLib.PrintDebug("Adapted to everything, resetting timer to 0")
		self:SetAdaptTimer(0)
	end

	self:Spin()
end

function ENT:Spin()
	local curTime = CurTime()

	local angles = self:GetAngles()
	local rotatedAngles = self:GetAngles()
	rotatedAngles.y = rotatedAngles.y - 45

	if SERVER then
		self:EmitSound(self.SpinSound, 75, math.random(95, 105), 1, CHAN_STATIC)
	end

	self:SetOriginalAngle(angles)
	self:SetDesiredAngle(rotatedAngles)
	self:SetSpinTime(curTime)
end

function ENT:EntsNeedAdapting()
	local owner = self:GetOwner()
	local weapon = owner:GetWeapon("gjujutsu_sukuna")

	if not weapon:IsValid() then return end

	for ent, data in pairs(weapon.AdaptationEnts) do
		for dmgType, adaptData in pairs(data) do
			if adaptData.Percentage < 100 then
				return true
			end
		end
	end

	return false
end

function ENT:CreateAdaptationRow(entClass, dmgType)
	local owner = self:GetOwner()
	local weapon = owner:GetWeapon("gjujutsu_sukuna")

	if not weapon:IsValid() then return end

	if not weapon.AdaptationEnts[entClass] then
		gebLib.PrintDebug("New enemy adaptation", entClass, dmgType)
		weapon.AdaptationEnts[entClass] = {[dmgType] = {Percentage = 0, ShownMessage = false}}
		return
	end

	if weapon.AdaptationEnts[entClass] then
		local dmgTypeExists = weapon.AdaptationEnts[entClass][dmgType]

		if not dmgTypeExists then
			gebLib.PrintDebug("New Damage Type adaptation", dmgType, entClass)

			weapon.AdaptationEnts[entClass][dmgType] = {Percentage = 0, ShownMessage = false}
		end
	end
end

-- Handling hooks
if SERVER then
	hook.Add("EntityTakeDamage", "gjujutsu_MahoragaAdaptation", function(ent, dmgInfo)
		if not ent:IsPlayer() then return end
		if dmgInfo:GetAttacker() == ent then return end
		local attacker = dmgInfo:GetAttacker()

		local weapon = ent:GetWeapon("gjujutsu_sukuna")

		if weapon:IsValid() and weapon:GetMahoragaWheel():IsValid() then
			local wheel = weapon:GetMahoragaWheel()

			hook.Run("gJujutsu_OnMahoragaDamage", weapon, wheel, attacker, dmgInfo)
		end
	end)

	hook.Add("gJujutsu_OnMahoragaDamage", "gjujutsu_MahoragaAdaptation", function(weapon, wheel, ent, dmgInfo)
		local dmgType = dmgInfo:GetDamageType()
		local owner = ent:GetOwner()

		local finalEnt = ent

		if owner:IsValid() then
			finalEnt = owner
		end

		if dmgInfo:GetInflictor():IsWeapon() then
			finalEnt = dmgInfo:GetInflictor()
		end

		if not finalEnt:IsValid() then
			gebLib.PrintDebug("Entity is not valid, cannot adapt")
			return
		end

		local entClass = finalEnt:GetClass()

		if finalEnt:IsPlayer() then
			entClass = entClass .. "_" .. finalEnt:Name()
		end

		if weapon.AdaptationEnts[entClass] and weapon.AdaptationEnts[entClass][dmgType] then
			local adaptData = weapon.AdaptationEnts[entClass][dmgType]
			local adaptationPercentage =  weapon.AdaptationEnts[entClass][dmgType].Percentage
			local finalDamageReduction = math.Remap(math.min(adaptationPercentage, 100), 0, 100, wheel.DamageReduction.Min, wheel.DamageReduction.Max)

			dmgInfo:ScaleDamage(1 - finalDamageReduction / 100)

			if adaptData.Percentage < 100 and wheel:GetAdaptTimer() <= 0 then 
				gebLib.PrintDebug("Adapting to existing")
				wheel:StartAdaptation()
			end
		else
			wheel:StartAdaptation()
		end

		wheel:CreateAdaptationRow(entClass, dmgType)
	end)
end

function ENT:Draw()
	self:DrawModel()
end
