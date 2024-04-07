GM.Name = "Battle Builder"
GM.Author = "FosterZRussian (76561198227935544)"
GM.Email = "72today@gmail.com"
GM.Website = "vk.com/cf_source"

include("cl_init.lua")


util.AddNetworkString("BuildMap")

hook.Add("PlayerSpawn", "BattleBuilder_PlayerSpawn", function(ply)
	ply:AllowFlashlight(true)
	net.Start("BuildMap")
	net.Send(ply)
end)