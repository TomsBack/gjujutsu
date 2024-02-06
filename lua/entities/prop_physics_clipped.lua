
-- Network
do
	g_EntityPlanes = g_EntityPlanes or {}
	
	function ENT:SetClipPlanes( planes )
		self.Planes	= planes
			
		self:InitClippedPhysics( planes )
		
		if ( SERVER ) then
			self:SendPlanes()
		end
	end
	
	if ( SERVER ) then
	
		util.AddNetworkString( "EntityClipPlanes" )
	
		function ENT:SendPlanes( ply )
			net.Start( "EntityClipPlanes" )
				-- net.WriteUInt( self:EntIndex(), 8 )
				net.WriteTable( self.Planes )
				net.WriteEntity( self )
			
			if ( ply ) then
				net.Send( ply )
			else
				net.Broadcast()
			end
		end

		net.Receive( "EntityClipPlanes", function( len, ply )
			local ent = net.ReadEntity()

			if !( ent:GetClass() == "prop_physics_clipped" ) then return end
			ent:SendPlanes( ply )
		end )
	
		hook.Add( "PlayerInitialSpawn", "EntityClipPlanes", function( ply )
			
			-- Do a full update
			for _, ent in pairs( ents.GetAll() ) do
				if ( ent:GetClass() == "prop_physics_clipped" ) then
					ent:SendPlanes( ply )
				end
			end
		
		end )
	
	else
	
		net.Receive( "EntityClipPlanes", function()
			-- local index		= net.ReadUInt( 8 )
			local planes	= net.ReadTable()
			
			-- local entity	= Entity( index )
			local entity = net.ReadEntity()
			
			if ( IsValid( entity ) ) then
				entity.Planes	= planes
			end
		end )
	
		hook.Add( "EntityRemoved", "EntityClipPlanes", function( ent )
			g_EntityPlanes[ ent:EntIndex() ] = nil
		end )

		function ENT:RequestPlanes()
			net.Start( "EntityClipPlanes" )
				net.WriteEntity( self )
			net.SendToServer()
		end
	
	end

end

AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable			= false
ENT.AdminOnly			= false

function ENT:Initialize()
	
	if ( CLIENT ) then	-- Attempt to initialize physics
		local index 	= self:EntIndex()
		local planes	= g_EntityPlanes[index]
		
		if ( planes ) then
			self:SetClipPlanes( planes )
			
			g_EntityPlanes[index] = nil
		end
	end

end

if ( SERVER ) then
	
	-- I am sorry ;_;
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end
	
else

	-- Fake syncronization
	function ENT:CalcAbsolutePosition()
		local phys = self:GetPhysicsObject()
		
		if IsValid( phys ) then
			phys:SetPos( self:GetPos() )
			phys:SetAngles(	self:GetAngles() )
			
			phys:EnableMotion( false )	-- Turn off prediction
		end
	end
	
	function ENT:Draw()	
		local planes = self.Planes
		
		if ( !planes ) then

			debugoverlay.Cross( self:WorldSpaceCenter(), 128, 1, color_white, true )
			self:DrawModel()

			self:RequestPlanes()
			return
		end
		
		render.EnableClipping( true )
		
		for _, plane in pairs( planes ) do
			local normal	= self:LocalToWorldAngles( plane.normal:Angle() ):Forward()
			local point		= self:GetPos() + normal * plane.dist
			
			render.PushCustomClipPlane( -normal, -point:Dot(normal) )
		end
		
		-- Render the model 'inside out'
		render.CullMode(MATERIAL_CULLMODE_CW)
			self:DrawModel()	
		render.CullMode(MATERIAL_CULLMODE_CCW)
		
		self:DrawModel()
		
		for index = 1, #planes do
			render.PopCustomClipPlane()
		end
		
		render.EnableClipping( false )
	end

end

-- Duplicator support
duplicator.RegisterEntityClass( "prop_physics_clipped", function( ply, generic, planes )
	local ent = ents.Create( "prop_physics_clipped" )	
	
	duplicator.DoGeneric( ent, generic )
	
	ent:SetClipPlanes( planes )
	ent:Spawn()
			
	return ent
end, "Data", "Planes" )
