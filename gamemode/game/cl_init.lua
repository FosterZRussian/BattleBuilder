AddCSLuaFile()
BattleBuilder.Game = {
	Functions = {}
}

if SERVER then
	for k,v in ipairs({
		[1] = "functions/func_md5.lua",
	}) do
		include(v)
	end
end

for k,v in ipairs({
	[1] = "gameworld/cl_world.lua",
	[2] = "player/cl_player.lua"
}) do
	AddCSLuaFile(v)
	include(v)
end

