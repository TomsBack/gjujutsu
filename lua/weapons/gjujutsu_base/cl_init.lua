include("shared.lua")

local abilityBox = Material("hud/ability_box_black2.png","smooth")
local keyBox = Material("hud/ability_box_white.png","smooth")
local statsBox = Material("hud/general_box.png","smooth")
local healthBox = Material("hud/health.png","smooth")

local defaultW = 400
local defaultH = 30

local width = ScrW()
local height = ScrH()
local mult = width / 1920

gJujutsu_width = width
gJujutsu_height = height
gJujutsu_mult = mult

local color_white = color_white
local color_black = color_black
local cdColor = Color(255,255,255,30)
local cursedEnergyColor = Color(72,167,255)

local healthColor = Color(255, 0, 0, 255)
local armorColor = Color(16, 73, 158)

-- TODO: Broken in older gmod versions
hook.Add("OnScreenSizeChanged", "gJujutsu_CacheScreenSize", function(oldW, oldH, newW, newH)
	print(newW, newH)
	width = newW
	healthBox = newH
	mult = width / 1920
	
	gJujutsu_width = width
	gJujutsu_height = height
	gJujutsu_mult = mult
end)

local oldHealth = -1
local oldArmor = -1
local oldCursedEnergy = -1

function SWEP:DrawStatsHud()
	local owner = self:GetOwner()
	local ang = EyeAngles()
	
	local upperindex = -1
	if width > 2000 then 
		upperindex = -0.40
	end

	if oldHealth == -1 then
		oldHealth = owner:Health()
		oldArmor = owner:Armor()
		oldCursedEnergy = self:GetCursedEnergy()
	end
	
	DisableClipping(true)
	cam.Start3D(nil, nil, 65, width*0.001, height * .462, width/2, height * .7)
		local opacity = 255*80
		local up, right, forward = ang:Up(), ang:Right(), ang:Forward()
		ang:RotateAroundAxis(up, 180)
		ang:RotateAroundAxis(right, 114.5)
		ang:RotateAroundAxis(forward, -90)

		local pos = EyePos() + (forward * 7) + (up * upperindex) + (right * -3 )

		local health = owner:Health()
		local maxHealth = owner:GetMaxHealth()
		local healthProgress = Lerp(FrameTime() * 15, oldHealth, math.Clamp(health, 0, maxHealth))
		local healthString = "Health " .. health .. "/" .. maxHealth
		oldHealth = healthProgress

		local armor = owner:Armor()
		local maxArmor = owner:GetMaxArmor()
		local armorProgress = Lerp(FrameTime() * 15, oldArmor, math.Clamp(armor, 0, maxArmor))
		local armorString = "Armor " .. armor .. "/" .. maxArmor
		oldArmor = armorProgress

		local cursedEnergy = self:GetCursedEnergy()
		local maxCursedEnergy = self:GetMaxCursedEnergy()
		local cursedEnergyProgress = Lerp(FrameTime() * 15, oldCursedEnergy, math.Remap(cursedEnergy, 0, maxCursedEnergy, 0, 100))
		local cursedEnergyString = math.Round(cursedEnergy) .. "/" .. maxCursedEnergy
		oldCursedEnergy = cursedEnergyProgress

		cam.Start3D2D(pos, ang, 0.011) 
			surface.SetMaterial(healthBox)
			surface.SetDrawColor(healthColor:Unpack())
			surface.DrawTexturedRect(54.5, -70, math.Remap(healthProgress, 0, maxHealth, 0, 515), 40)

			surface.SetDrawColor(armorColor:Unpack())
			surface.DrawTexturedRect(35.5, -37, math.Remap(armorProgress, 0, maxArmor, 0, 515), 40)
			
			draw.SimpleTextOutlined(healthString, "gJujutsuFont2", 81, -47.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
			draw.SimpleTextOutlined(armorString, "gJujutsuFont2", 60, -15.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(statsBox)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(-100, -120, 663, 155)

			gebLib_DrawCircularBar(-32, -51, cursedEnergyProgress, 67, 9, 0, cursedEnergyColor)
			draw.SimpleTextOutlined(cursedEnergyString, "gJujutsuFont2", -84.5, -50, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
		cam.End3D2D()

	cam.End3D()
	DisableClipping(false)
end

function SWEP:DrawCDAbilityBox(x, y, title, key, cdTime)
	local curTime = CurTime()

	surface.SetFont("gJujutsuFont3")
	local textW, textH = surface.GetTextSize(title)
	local textX = x + defaultW - textW - 35
	local textY = y + defaultH / 2

	local keyString = string.upper(input.GetKeyName(key))
	local keyX = x + defaultW - 25
	local cdX = x + defaultW - 20

	if curTime > cdTime then
		surface.SetMaterial(abilityBox)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(x, y, defaultW, defaultH)
	end
	surface.SetMaterial(keyBox)
	surface.SetDrawColor(color_white)
	surface.DrawTexturedRect(x, y, defaultW, defaultH)
	if curTime > cdTime then
		draw.SimpleTextOutlined(title, "gJujutsuFont3", textX, textY, color_white, 0, 1, 1, color_black)
		draw.SimpleTextOutlined(keyString, "gJujutsuFont3", keyX, textY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
	else
		draw.SimpleTextOutlined(title, "gJujutsuFont3", textX, textY, cdColor, 0, 1, 1, color_black)
		draw.SimpleTextOutlined(math.Round(cdTime - curTime), "gJujutsuFont3", cdX, textY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	end
end

function SWEP:DrawActivateAbilityBox(x, y, title, key, cdTime, activeTitle, active)
	local curTime = CurTime()
	
	local finalTitle = title

	if active then
		finalTitle = activeTitle
	end

	surface.SetFont("gJujutsuFont3")
	local textW, textH = surface.GetTextSize(finalTitle)
	local textX = x + defaultW - textW - 35
	local textY = y + defaultH / 2

	local keyString = string.upper(input.GetKeyName(key))
	local keyX = x + defaultW - 25
	local cdX = x + defaultW - 20

	if curTime > cdTime then
		surface.SetMaterial(abilityBox)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(x, y, defaultW, defaultH)
	end
	surface.SetMaterial(keyBox)
	surface.SetDrawColor(color_white)
	surface.DrawTexturedRect(x, y, defaultW, defaultH)

	if curTime > cdTime then
		draw.SimpleTextOutlined(finalTitle, "gJujutsuFont3", textX, textY, color_white, 0, 1, 1, color_black)
		draw.SimpleTextOutlined(keyString, "gJujutsuFont3", keyX, textY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
	else
		draw.SimpleTextOutlined(finalTitle, "gJujutsuFont3", textX, textY, cdColor, 0, 1, 1, color_black)
		draw.SimpleTextOutlined(math.Round(cdTime - curTime), "gJujutsuFont3", cdX, textY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	end
end

function SWEP:DrawHUD()
	local owner = self:GetOwner()
	local ang = EyeAngles()

	local upperindex = -1
	if width > 2000 then 
		upperindex = -0.40
	end

	self:DrawStatsHud()

	DisableClipping(true)
	cam.Start3D(nil, nil, 65, width*.6, height * .3, width/2, height * .7)
		local opacity = 255*80
		local up, right, forward = ang:Up(), ang:Right(), ang:Forward()
		ang:RotateAroundAxis(up, 170)
		ang:RotateAroundAxis(right, 79.5)
		ang:RotateAroundAxis(forward, -98)

		local pos = EyePos() + (forward * 7) + (up * upperindex) + (right * -2.1 )

		cam.Start3D2D(pos, ang, 0.011) 
			self:DrawCDAbilityBox(-9, -80, "ability1", 15, self:GetNextAbility3())
			self:DrawCDAbilityBox(-5, -40, "ability2", 16, self:GetNextAbility4())
			self:DrawActivateAbilityBox(-1, 0, "ability3 inactive", 22, self:GetNextAbility4(), "ability 3 active", self:GetInfinity())
			self:DrawCDAbilityBox(3, 40, "ability4", 18, self:GetNextAbility5())
			self:DrawActivateAbilityBox(7, 80, "ability5 activation", 22, self:GetNextAbility4())
			self:DrawCDAbilityBox(11, 120, "ultimate", 20, self:GetNextUltimate())
		cam.End3D2D()

	cam.End3D()
	DisableClipping(false)
end

-- Hooks

local ThirdPersonConvar = GetConVar("gjujutsu_thirdperson_offset")

local traceMins = Vector(-5, -5, -5)
local traceMaxs = Vector(5, 5, 5)

hook.Add("CalcView", "gJujutsu_ThirdPerson", function(ply, pos, ang, fov)
	if not ply:gebLib_ValidAndAlive() then return end
	
	local weapon = ply:GetActiveWeapon()

	if not weapon:IsValid() then return end
	if not weapon:IsGjujutsuSwep() then return end
	if weapon:GetBlockCamera() then return end

	local offsetString = ThirdPersonConvar:GetString()
	local splittedOffset = string.Split(offsetString, ",")

	local offset = Vector(splittedOffset[1], splittedOffset[2], splittedOffset[3])
	offset:Rotate(ang)

	local endPos = pos - ang:Forward() * 100

	if weapon:Gjujutsu_IsGojo() then
		local hollowPurple = weapon:GetHollowPurple()

		if hollowPurple:IsValid() and hollowPurple.Initialized and not hollowPurple:GetFired() then
			local holdTime = math.Clamp(CurTime() - hollowPurple:GetHoldStart(), 4, hollowPurple.MaxHoldTime)

			local finalOffset = math.Remap(holdTime, 4, hollowPurple.MaxHoldTime, 100, 500)
			
			endPos = pos - ang:Forward() * finalOffset
		end
	end
	
	local trace = util.TraceHull({
		start = pos,
		endpos = endPos,
		filter = { ply:GetActiveWeapon(), ply, ply:GetVehicle() },
		mins = traceMins,
		maxs = traceMaxs,
	})

	pos = trace.HitPos

	local view = {
		origin = pos + offset,
		angles = ang,
		fov = fov,
		drawviewer = true,
	}

	return view
end)

local hudToHide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
}

hook.Add("HUDShouldDraw", "gJujutsu_NoDefaultHUD", function(currentElement)
	local ply = LocalPlayer()

	if not ply:IsValid() then return true end

	local weapon = ply:GetActiveWeapon()

	if not weapon:IsValid() then return true end
	if not weapon:IsGjujutsuSwep() then return true end

	if hudToHide[currentElement] then
		return false
	end
end)

local clashKeyMaterial = Material("hud/key_box_white.png","smooth")
local pressedColor = Color(0, 150, 0)

hook.Add("HUDPaint", "gJujutsu_DomainClashHUD", function()
	local ply = LocalPlayer()
	local weapon = ply:GetActiveWeapon()

	if not ply.gJujutsu_ClashKey then return end
	if ply.gJujutsu_ClashKey <= 0 then return end
	if not ply:gebLib_ValidAndAlive() then return end
	if not weapon:IsValid() then return end
	if not weapon:IsGjujutsuSwep() then return end
	if ply:IsFrozen() then return end
	if not weapon:GetDomainClash() then return end

	local keyText = input.GetKeyName(ply.gJujutsu_ClashKey)
	local textW, textH = surface.GetTextSize(keyText)

	local x = width * 0.5 - (textW * 0.5)
	local y = height * 0.4

	if input.IsKeyDown(ply.gJujutsu_ClashKey) then
		draw.SimpleTextOutlined(keyText, "gJujutsuFontClash1", x, y, pressedColor, 0, 1, 1, color_black)
	else
		draw.SimpleTextOutlined(keyText, "gJujutsuFontClash1", x, y, color_white, 0, 1, 1, color_black)
	end
end)

hook.Add("ContextMenuOpen", "gJujutsu_NoContextMenu", function()
	local localPlayer = LocalPlayer()
    local weapon = localPlayer:GetActiveWeapon()

    if weapon:IsValid() and weapon:IsGjujutsuSwep() then
        return false
    end
end)

hook.Add("SpawnMenuOpen", "Gjujutsu_ClashNoSpawnMenu", function()
	local ply = LocalPlayer()
	local weapon = ply:GetActiveWeapon()

	if not weapon:IsValid() then return end
	if not weapon:IsGjujutsuSwep() then return end

	if weapon:GetDomainClash() or weapon:GetInCinematic() then
		return false
	end
end)
