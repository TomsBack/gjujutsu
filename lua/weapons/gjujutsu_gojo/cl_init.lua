include("shared.lua")

local ability3 = GetConVar("gjujutsu_ability3_key")
local ability4 = GetConVar("gjujutsu_ability4_key")
local ability5 = GetConVar("gjujutsu_ability5_key")
local ability6 = GetConVar("gjujutsu_ability6_key")
local ability7 = GetConVar("gjujutsu_ability7_key")
local ability8 = GetConVar("gjujutsu_ability8_key")
local abilityUltimate = GetConVar("gjujutsu_ultimate_key")
local abilityTaunt = GetConVar("gjujutsu_taunt_key")

local sixEyesVisionConvar = GetConVar("gjujutsu_gojo_six_eyes_vision")
local auraVisionRangeConvar = GetConVar("gjujutsu_misc_ce_aura_range")

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
				
				if self.DomainConvar:GetBool() then
					if self:GetDomain():IsValid() then
						self:DrawCDAbilityBox(11, 120, "Clear Domain", abilityUltimate:GetInt(), self:GetNextUltimate())
					else 
						self:DrawCDAbilityBox(11, 120, "Domain Expansion: Infinite Void", abilityUltimate:GetInt(), self:GetNextUltimate())
					end
				end
			end
			if not owner:KeyDown(IN_SPEED) then
				self:DrawCDAbilityBox(-9, -80, "Cursed Technique Reversal: Red", ability4:GetInt(), self:GetNextAbility4())
				if not owner:KeyDown(IN_DUCK) then
					self:DrawCDAbilityBox(-5, -40, "Cursed Technique Lapse: Blue", ability3:GetInt(), self:GetNextAbility3())
				else
					self:DrawCDAbilityBox(-5, -40, "Blue Projectile", ability3:GetInt(), self:GetNextAbility3())
				end
				self:DrawActivateAbilityBox(7, 80, "Reverse Cursed Technique (Inactive)", ability8:GetInt(), self:GetNextAbility8(), "Reverse Cursed Technique (Active)", self:GetReverseTechniqueEnabled())
			end
			if owner:KeyDown(IN_SPEED) then
				self:DrawCDAbilityBox(-9, -80, "Cursed Technique Reversal (Projectile): Red", ability4:GetInt(), self:GetNextAbility4())
				if not owner:KeyDown(IN_DUCK) then
					self:DrawCDAbilityBox(-5, -40, "Cursed Technique Lapse (Around): Blue", ability3:GetInt(), self:GetNextAbility3())
				else
					self:DrawCDAbilityBox(-5, -40, "Blue Projectile", ability3:GetInt(), self:GetNextAbility3())
				end
				self:DrawCDAbilityBox(7, 80, "Brain Recover", ability8:GetInt(), self:GetNextAbility8())
			end
			if self.InfinityConvar:GetBool() then
				self:DrawActivateAbilityBox(-1, 0, "Infinite Technique (Inactive)", ability6:GetInt(), self:GetNextAbility6(), "Infinite Technique (Active)", self:GetInfinity())
			end
			self:DrawActivateAbilityBox(3, 40, "Six Eyes Mode (Inactive)", ability7:GetInt(), self:GetNextAbility7(), "Six Eyes Mode (Active)", self:GetSixEyes())
		cam.End3D2D()

	cam.End3D()
	DisableClipping(false)

	local startPos = owner:WorldSpaceCenter()

	-- Drawing cursed energy
	self:DrawCursedEnergyAura(ents.FindInSphere(startPos, auraVisionRangeConvar:GetFloat()))
end

hook.Add("PreRender", "gJujutsu_SixEyesVision", function()
	if not sixEyesVisionConvar:GetBool() then return end
	local ply = LocalPlayer()

	if not ply:IsValid() then return end

	local weapon = ply:GetActiveWeapon()

	if weapon:IsValid() and weapon:Gjujutsu_IsGojo() and weapon:GetSixEyes() then
		render.SetLightingMode(1)
	end
end)

local function DisableSixEyesVision()
	render.SetLightingMode(0)
end


hook.Add("PostRender", "gJujutsu_DisableSixEyesVision", DisableSixEyesVision)
hook.Add("PreDrawHUD", "gJujutsu_DisableSixEyesVision", DisableSixEyesVision)


local material = Material('hud/targetCursor.png')
function SWEP:DoDrawCrosshair(x,y)
	local owner = self:GetOwner()
	if IsValid(owner) and IsValid(LocalPlayer()) and !IsValid(LocalPlayer().targetPlayer)then
		local tr = util.TraceLine( {
			start = owner:EyePos(),
			endpos = owner:EyePos() + owner:GetAimVector() * 1500,
			filter = {owner},
			mask = MASK_SHOT_HULL
		} )
		local pos = tr.HitPos
		
		local pos2d = pos:ToScreen()
		if pos2d.visible then
			surface.SetMaterial( material )
			local clr = Color(255,255,255,255)
			local h,s,v = ColorToHSV(clr)
			h = h - 180
			clr = HSVToColor(h,s,v)
			surface.SetDrawColor( clr )
			surface.DrawTexturedRect( pos2d.x - 32, pos2d.y - 32, 64, 64 )
		end
		return true
	end
end