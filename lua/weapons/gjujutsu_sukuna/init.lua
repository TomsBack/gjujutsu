AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

-- Adding hooks
function gJujutsuSlash(ply, target, minScale, maxScale)
    net.Start("gjujutsu_cl_slasheffect")
    net.WriteEntity(target) 
    net.WriteVector(target:WorldSpaceCenter())
    net.WriteInt(minScale, 16) 
    net.WriteInt(maxScale, 16) 
    net.Send(ply)
end