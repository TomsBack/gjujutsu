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

function NiceDuration(inSoundDuration)
	local dur = inSoundDuration * 2 --Gives us minutes:second notation in decimal
	dur = dur/100 --Separates minutes and seconds where minutes is whole and seconds is decimal
	durM = math.floor(dur)
	durS = (dur - durM) * 100
	return (durM * 60) + durS
end

if SERVER then return end

function DrawCirlce(x, y, radius, color, progress, angle)
    local circle = {}
    local percentage = progress/100
    local x1, y1 = x + radius, y + radius
    local seg = 100
    if !angle then angle = 180 end
    table.insert( circle, { x = x1, y = y1 } )
    for i = 0, seg do
        local a = math.rad( (( i / seg ) * (-360*percentage))+angle )
        table.insert( circle, { x = x1 + math.sin( a ) * radius, y = y1 + math.cos( a ) * radius } )
    end
    table.insert( circle, { x = x1, y = y1 } )
    draw.NoTexture()
    surface.SetDrawColor( color )
    surface.DrawPoly( circle )    
end

function DrawCircularBar(x, y, progress, radius, thickness, angle,color)
    render.SetStencilWriteMask( 0xFF )
    render.SetStencilTestMask( 0xFF )
    render.SetStencilReferenceValue( 0 )
    render.SetStencilCompareFunction( STENCIL_ALWAYS )
    render.SetStencilPassOperation( STENCIL_KEEP )
    render.SetStencilFailOperation( STENCIL_KEEP )
    render.SetStencilZFailOperation( STENCIL_KEEP )
    render.ClearStencil()
    render.SetStencilEnable( true )
    render.SetStencilReferenceValue( 1 )
    render.SetStencilCompareFunction( STENCIL_NEVER )
    render.SetStencilFailOperation( STENCIL_REPLACE )
    DrawCirlce(x-(radius-thickness), y-(radius-thickness), radius-thickness, color_white, 100)
    render.SetStencilCompareFunction( STENCIL_GREATER )
    render.SetStencilFailOperation( STENCIL_KEEP )
    DrawCirlce(x-radius, y-radius, radius, color, progress, angle)
    render.SetStencilEnable( false )
end

function TextWithShadow(text, font, x, y, color, x_a, y_a, color_shadow)
    color_shadow = color_shadow or color_black
    draw.SimpleText(text, font, x+1.5 , y+1.5, color_shadow, x_a, y_a)
    local w,h = draw.SimpleText(text, font, x, y, color, x_a, y_a)
    return w,h
end
