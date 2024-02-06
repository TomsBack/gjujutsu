local defaultinnate = "Nothing"

net.Receive("gjujutsu_spins_control", function()
    local ply = net.ReadEntity()
    local amount = net.ReadInt(32)
    ply.spinsamount = amount
    print(ply:GetName().." have "..ply.spinsamount.." spins")
end)

net.Receive("gjujutsu_innate_control", function()
    local ply = net.ReadEntity()
    local innate = net.ReadString()
    ply.currentinnate = innate
    if ply.currentinnate != defaultinnate then
        print(ply:GetName().." have "..ply.currentinnate.." innate")
        else
        print(ply:GetName().." have't innate")
    end
end)
