-- You don't need to add all nets here, but if you don't know where to put a net, then put it here

if SERVER then
	util.AddNetworkString("gJujutsu_cl_runEventFunction")
	util.AddNetworkString("gJujutsu_cl_clearCamera")
end

if CLIENT then
	net.Receive("gJujutsu_cl_runEventFunction", function()
		local ent = gebLib_net.ReadEntity()
		local eventFunction = net.ReadString()

		if ent[eventFunction] then
			ent[eventFunction](ent)
		end
	end)

	net.Receive("gJujutsu_cl_clearCamera", function()
		local ent = net.ReadEntity()
		local camera = ent.gJujutsu_Camera

		if camera then
			camera:Stop()
		end
	end)
end
