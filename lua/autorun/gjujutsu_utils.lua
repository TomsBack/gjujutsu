local MENT = FindMetaTable("Entity")
local MPLY = FindMetaTable("Player")
local MSWEP = FindMetaTable("Weapon")

local abilityClasses = {
	["purple_blue"] = true,
	["purple_red"] = true,
	["hollow_purple"] = true,
	["lapse_blue"] = true,
	["reversal_red"] = true,
	[""] = true,
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

function MPLY:PredictedOrDifferentPlayer()
	if SERVER then return true end

	return IsFirstTimePredicted() or LocalPlayer() ~= self
end

function MSWEP:IsGjujutsuSwep()
	return self.Base == "gjujutsu_base"
end

function MSWEP:Gjujutsu_IsGojo()
	return self.Base == "gjujutsu_base"
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
