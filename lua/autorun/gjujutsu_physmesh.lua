if SERVER then
	AddCSLuaFile()
end

physmesh = {}

-- Point, Normal -> Plane
function physmesh.ToPlane( point, normal )	
	local proj		= point:ProjectOnto( normal )
	local dist		= proj:Length()
		
	-- Projection is in the opposite direction
	if ( !normal:IsEqualTol( proj:GetNormalized(), 0.01 ) ) then
		dist = -dist
	end

	return { normal = normal, dist = dist }
end

-- Convex triangles -> Planes
function physmesh.ConvexToPlanes( convex )
	local planes = {}
	
	local count	= #convex
	
	for index = 1, count, 3 do
		local a = convex[index  ].pos
		local b = convex[index+1].pos
		local c = convex[index+2].pos
		
		local normal 	= (c-a):Cross(b-a):GetNormalized()
		
		local proj		= a:ProjectOnto( normal )
		local dist		= proj:Length()
		
		-- Projection is in the opposite direction
		if ( !normal:IsEqualTol( proj:GetNormalized(), 0.01 ) ) then
			dist = -dist
		end
				
		-- Search for a plane with similar aspects
		local isMerged = false
		
		for _, plane in pairs( planes ) do
			if ( normal:IsEqualTol( plane.normal, 0.05 ) and math.abs( dist - plane.dist ) < 1 ) then
				isMerged = true
				break
			end
		end
	
		if ( !isMerged ) then	
			table.insert( planes, { normal = normal, dist = dist } )
		end	
	end
	
	return planes
end

-- Planes -> Convex triangles
local function isClipped( vector, cnormal, cdist )	
	local cpos = cnormal * cdist
	local off  = vector:ProjectOnto( cnormal ) - cpos
					
	return off:Dot( cnormal ) > 0
end

function physmesh.PlanesToConvex( planes )
	local mesh = {}

	for index, plane in pairs( planes ) do
		local normal	= plane.normal
		
		local pos		= normal * plane.dist
		local angle		= normal:Angle()
		
		local axisX = angle:Right() * 10000
		local axisY = angle:Up() * 10000
		
		local vertexes = {
			pos - axisX + axisY,
			pos + axisX + axisY,
				
			pos + axisX - axisY,
			pos - axisX - axisY,
		}
		
		for cindex, cplane in pairs( planes ) do
			if ( cindex == index ) then continue end
	
			local cnormal	= cplane.normal
	
			local cdist		= cplane.dist
			local cpos 		= cnormal * cdist 
			
			local lastVertex	= vertexes[ #vertexes ]	
			local lastIsClipped	= isClipped( lastVertex, cnormal, cdist )
		
			local newVertexes = {}
			
			for index, vertex in pairs( vertexes ) do
				local isClipped = isClipped( vertex, cnormal, cdist )
			
				if ( isClipped != lastIsClipped ) then
					local ray = lastVertex - vertex
					local hit = util.IntersectRayWithPlane( vertex, ray, cpos, cnormal )
					
					table.insert( newVertexes, hit )
				end
					
				if ( !isClipped ) then
					table.insert( newVertexes, vertex )
				end
				
				lastVertex		= vertex
				lastIsClipped	= isClipped
			end
			
			vertexes = newVertexes
			
			if ( #vertexes == 0 ) then
				break -- The entire plane got clipped
			end
		end
		
		-- Insert into physics mesh
		local count = #vertexes
		local baseVertex = vertexes[ 1 ]
		local lastVertex = vertexes[ 2 ]
		
		for index = 3, count do
			local currVertex = vertexes[ index ]
		
			table.insert( mesh, baseVertex )
			table.insert( mesh, currVertex )
			table.insert( mesh, lastVertex )
			
			lastVertex = currVertex
		end		
	end

	return mesh
end

-- Utility
function physmesh.ClipConvex( convex, clips )
	local planes = physmesh.ConvexToPlanes( convex )
		table.Add( planes, clips )

	return physmesh.PlanesToConvex( planes )
end

function physmesh.ClipMultiConvex( convexes, clips )
	local result = {}
	
	for index, convex in pairs( convexes ) do
		local mesh = physmesh.ClipConvex( convex, clips )
		
		if ( #mesh > 0 ) then	-- Convexes may get clipped entirely!
			table.insert( result, mesh )
		end
	end
	
	return result
end


-- Vector meta
local meta = FindMetaTable( "Vector" )

function meta:ProjectOnto( vec )
	return self:Dot(vec) / vec:Dot(vec) * vec
end

-- Entity meta
local meta = FindMetaTable( "Entity" )

function meta:ToLocalPlane( point, normal )
	local pos		= target:WorldToLocal( point )
	local normal	= target:WorldToLocalAngles( normal:Angles() ):Forward()
		
	return physmesh.ToPlane( pos, normal )
end

-- This thing is full of dark magic!
function meta:InitClippedPhysics( planes )
	if ( !planes ) then error( "No planes defined" ) end
	
	-- Init normal physics, to obtain MeshConvexes
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )

	local phys		= self:GetPhysicsObject()

	local volume	= phys:GetVolume()
	local mass		= phys:GetMass()

	-- Clip convexes
	local convexes	= phys:GetMeshConvexes()
	local clipped	= physmesh.ClipMultiConvex( convexes, planes )
	
	-- Init clipped physics
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )

	self:PhysicsInitMultiConvex( clipped )

	self:EnableCustomCollisions( true )
--	self:SetCustomCollisionCheck( true )

	-- Calculate new mass, based off changed volume
	local phys	= self:GetPhysicsObject()
		phys:SetMass( mass * ( phys:GetVolume() / volume ) )
	
	return clipped
end


local function CopyGenericData( ply, A, B )
	local data = duplicator.CopyEntTable( A )
		data.PhysicsObjects = nil

	B.EntityMods = data.EntityMods

	duplicator.DoGeneric( B, data )
	duplicator.ApplyEntityModifiers( ply, B )
end

-- Undo
local function UndoClipPlane( entry, target )
	if !IsValid( target ) or !target.Planes then
		return
	end
	
	local ply		= entry.Owner
	
	local planes 	= target.Planes
	local count		= #planes
	
	if ( #planes == 1 ) then
		-- Respawn the old prop
		local prop = ents.Create( "prop_physics" )
			CopyGenericData( ply, target, prop )
	
			prop:Spawn()

		undo.ReplaceEntity( target, prop )
		cleanup.ReplaceEntity( target, prop )
		
		target:Remove()
	else
		-- Undo the last plane		
		planes[count] = nil
		
		target:SetClipPlanes( planes )
	end
	
end


-- Cut apply
local meta = FindMetaTable( "Entity" )

function meta:AddClipPlane( ply, plane )

	if ( self:GetClass() == "prop_physics_clipped" ) then
		
		local planes 	= self.Planes
		local count		= #planes
			
		planes[count +1] = plane
	
		-- Apply new plane
		self:SetClipPlanes( self.Planes )

	else
		-- Create new entity
		if SERVER then
			local ent = ents.Create( "prop_physics_clipped" )
			CopyGenericData( ply, self, ent )
			
			ent:SetClipPlanes( { plane } )
			ent:Spawn()
			
			local phys = ent:GetPhysicsObject()
			if IsValid( phys ) and self:IsValid() and self:GetPhysicsObject():IsValid() then
				local motion = self:GetPhysicsObject():IsMotionEnabled()
				phys:EnableMotion( motion )
				phys:Wake()
			end
		end

		--undo.ReplaceEntity( self, ent )
		--cleanup.ReplaceEntity( self, ent )
	
		--self:Remove()
	end
end

function SukunaPropCut(ply, prop, angle)
	local target = prop
	if !( target:IsValid() and target:GetClass() == "prop_physics" ) then return end

	local targetAngles = target:GetAngles()

	local planePos = target:WorldToLocal( target:WorldSpaceCenter() )
	local planeNormal = target:WorldToLocalAngles( Angle( targetAngles.x, targetAngles.y, targetAngles.z + angle ) ):Up()

	target:AddClipPlane( ply, physmesh.ToPlane( planePos, planeNormal ) )
	target:AddClipPlane( ply, physmesh.ToPlane( planePos, -planeNormal ) )
	target:Remove()
end
