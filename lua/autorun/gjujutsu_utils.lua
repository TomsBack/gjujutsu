local MENT = FindMetaTable("Entity")
local MPLY = FindMetaTable("Player")
local MSWEP = FindMetaTable("Weapon")

local abilityClasses = {
	["purple_blue"] = true,
	["purple_red"] = true,
	["hollow_purple"] = true,
	["lapse_blue"] = true,
	["reversal_red"] = true,
	["fire_arrow"] = true,
	[""] = true,
}

function MENT:Gjujutsu_IsAbility()
	return abilityClasses[self:GetClass()]
end

function MENT:Gjujutsu_IsInDomain()
	for owner, domain in pairs(gJujutsuDomains) do
		local isInDomain = domain:IsInDomain(self)

		if isInDomain then
			return true
		end
	end

	return false
end

function MPLY:Gjujutsu_ResetKnockback()
	local oldVelocity = self.gJujutsu_OldVelocity

	if not oldVelocity then return end

	local knockbackVelocity = oldVelocity - self:GetVelocity()
	
	self:SetVelocity(knockbackVelocity)
	self:ViewPunchReset()
end

function MPLY:CreateDomainClashTable()
	local clashData = {
		ClashStart = CurTime() + gjujutsu_ClashWindUp,
		ClashEnd = 0,
		Players = {[1] = self}
	}

	gJujutsuDomainClashes[self] = clashData

	return clashData
end

function MPLY:Gjujutsu_GetDomainClashData()
	if (gJujutsuDomainClashes[self]) then
		return gJujutsuDomainClashes[self]
	end

	if (gJujutsuDomainClashCache[self]) then
		return gJujutsuDomainClashCache[self]
	end

	for owner, data in pairs(gJujutsuDomainClashes) do
		for _, ply in ipairs(data.Players) do
			if ply == self then
				gJujutsuDomainClashCache[self] = gJujutsuDomainClashes[owner]
				return gJujutsuDomainClashes[owner]
			end
		end
	end

	return nil
end

function MPLY:Gjujutsu_IsInDomainClash()
	if (gJujutsuDomainClashes[self]) then
		return true
	end

	for owner, data in pairs(gJujutsuDomainClashes) do
		for _, ply in ipairs(data.Players) do
			if ply == self then
				return true
			end
		end
	end

	return true
end

function MPLY:PredictedOrDifferentPlayer()
	if SERVER then return true end

	return IsFirstTimePredicted() or LocalPlayer() ~= self
end

function MSWEP:IsGjujutsuSwep()
	return self.Base == "gjujutsu_base"
end

function MSWEP:Gjujutsu_IsGojo()
	return self:GetClass() == "gjujutsu_gojo"
end

function MSWEP:Gjujutsu_IsSukuna()
	return self:GetClass() == "gjujutsu_sukuna"
end

if SERVER then return end
