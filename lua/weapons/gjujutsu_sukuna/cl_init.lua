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
	draw.DrawText(self:GetFingers() .. "/" .. self.MaxFingers, "gJujutsuFont2", ScrW() * 0.048, ScrH() * 0.75)

	DisableClipping(true)
	cam.Start3D(nil, nil, 65, gJujutsu_width*.6, gJujutsu_height * .3, gJujutsu_width/2, gJujutsu_height * .7)
		local opacity = 255*80
		local up, right, forward = ang:Up(), ang:Right(), ang:Forward()
		ang:RotateAroundAxis(up, 170)
		ang:RotateAroundAxis(right, 79.5)
		ang:RotateAroundAxis(forward, -98)

		local pos = EyePos() + (forward * 7) + (up * upperindex) + (right * -2.1 )

		cam.Start3D2D(pos, ang, 0.011)

			self:DrawCDAbilityBox(-13, -120, "Fuga (Open)", ability5:GetInt(), self:GetNextAbility5())
			if self:GetDomain():IsValid() then
				self:DrawCDAbilityBox(11, 120, "Clear Domain", abilityUltimate:GetInt(), self:GetNextUltimate())
			else 
				self:DrawCDAbilityBox(11, 120, "Domain Expansion: Malevolent shrine", abilityUltimate:GetInt(), self:GetNextUltimate())
			end
			self:DrawCDAbilityBox(-9, -80, "Cleave", ability4:GetInt(), self:GetNextAbility4())
			if not owner:KeyDown(IN_SPEED) then
				self:DrawCDAbilityBox(-5, -40, "Dismantle", ability3:GetInt(), self:GetNextAbility3())
				self:DrawActivateAbilityBox(7, 80, "Reverse Cursed Technique (Inactive)", ability8:GetInt(), self:GetNextAbility8(), "Reverse Cursed Technique (Active)", self:GetReverseTechniqueEnabled())
			end
			if owner:KeyDown(IN_SPEED) then
				-- self:DrawCDAbilityBox(-9, -80, "Cursed Technique Reversal (Projectile): Red", ability4:GetInt(), self:GetNextAbility4())
				self:DrawCDAbilityBox(-5, -40, "Dismantle Barrage", ability3:GetInt(), self:GetNextAbility3())
				self:DrawCDAbilityBox(7, 80, "Brain Recover", ability8:GetInt(), self:GetNextAbility8())
			end
		cam.End3D2D()

	cam.End3D()
	DisableClipping(false)
end
