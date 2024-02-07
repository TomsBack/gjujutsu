include("shared.lua")

local ability3 = GetConVar("gjujutsu_ability3_key")
local ability4 = GetConVar("gjujutsu_ability4_key")
local ability5 = GetConVar("gjujutsu_ability5_key")
local ability6 = GetConVar("gjujutsu_ability6_key")
local ability7 = GetConVar("gjujutsu_ability7_key")
local ability8 = GetConVar("gjujutsu_ability8_key")
local abilityUltimate = GetConVar("gjujutsu_ultimate_key")
local abilityTaunt = GetConVar("gjujutsu_taunt_key")

function SWEP:DrawHUD()
	local owner = self:GetOwner()
	local ang = EyeAngles()

	local upperindex = -1
	if gJujutsu_width > 2000 then 
		upperindex = -0.40
	end

	self:DrawStatsHud()

	DisableClipping(true)
	cam.Start3D(nil, nil, 65, gJujutsu_width*.6, gJujutsu_height * .3, gJujutsu_width/2, gJujutsu_height * .7)
		local opacity = 255*80
		local up, right, forward = ang:Up(), ang:Right(), ang:Forward()
		ang:RotateAroundAxis(up, 170)
		ang:RotateAroundAxis(right, 79.5)
		ang:RotateAroundAxis(forward, -98)

		local pos = EyePos() + (forward * 7) + (up * upperindex) + (right * -2.1 )

		cam.Start3D2D(pos, ang, 0.011) 
			if self:GetSixEyes() then
				self:DrawCDAbilityBox(-13, -120, "Hollow Technique: Purple", ability5:GetInt(), self:GetNextAbility5())
				
				if self:GetDomain():IsValid() then
					self:DrawCDAbilityBox(11, 120, "Clear Domain", abilityUltimate:GetInt(), self:GetNextUltimate())
				else 
					self:DrawCDAbilityBox(11, 120, "Domain Expansion: Infinite Void", abilityUltimate:GetInt(), self:GetNextUltimate())
				end
			end
			if not owner:KeyDown(IN_SPEED) then
				self:DrawCDAbilityBox(-9, -80, "Cursed Technique Reversal: Red", ability4:GetInt(), self:GetNextAbility4())
				self:DrawCDAbilityBox(-5, -40, "Cursed Technique Lapse: Blue", ability3:GetInt(), self:GetNextAbility3())
			end
			if owner:KeyDown(IN_SPEED) then
				self:DrawCDAbilityBox(-9, -80, "Cursed Technique Reversal (Projectile): Red", ability4:GetInt(), self:GetNextAbility4())
				self:DrawCDAbilityBox(-5, -40, "Cursed Technique Lapse (Around): Blue", ability3:GetInt(), self:GetNextAbility3())
			end
			self:DrawActivateAbilityBox(-1, 0, "Infinite Technique (Inactive)", ability6:GetInt(), self:GetNextAbility6(), "Infinite Technique (Active)", self:GetInfinity())
			self:DrawActivateAbilityBox(3, 40, "Six Eyes Mode (Inactive)", ability7:GetInt(), self:GetNextAbility7(), "Six Eyes Mode (Active)", self:GetSixEyes())
			self:DrawActivateAbilityBox(7, 80, "Reverse Cursed Technique (Inactive)", ability8:GetInt(), self:GetNextAbility8(), "Reverse Cursed Technique (Active)", self:GetReverseTechniqueEnabled())
		cam.End3D2D()

	cam.End3D()
	DisableClipping(false)
end
