AddCSLuaFile()
BattleBuilder.World = {}
for k,v in ipairs({
	[1] = "world_voxel.lua",
	[2] = "world_chunks.lua"
}) do
	AddCSLuaFile(v)
	include(v)
end


function BattleBuilder.World:ClearCarbage()
	collectgarbage("collect")
end

BattleBuilder.World:ClearCarbage()

function BattleBuilder.World:Initialize()
			
	local level_name = "cube"
	file.CreateDir("battlebuilder/levels/" .. level_name)
	file.CreateDir("battlebuilder/levels/" .. level_name .. "/level_storage")
	file.CreateDir("battlebuilder/levels/" .. level_name .. "/level_storage_uncompressed")
	file.CreateDir("battlebuilder/levels/" .. level_name .. "/level_game")

	
	--BattleBuilder.Chunks:SaveLevel(level_name)
	BattleBuilder.Chunks:LoadLevel(level_name)
	

	if SERVER then return end
	//local chunk = BattleBuilder.Chunks:CreateChunk()
	//BattleBuilder.Chunks:PreBuildChunk(chunk)
	hook.Add( "PreDrawOpaqueRenderables", "BattleBuilder_DrawWorld", function()
		BattleBuilder.Chunks.WorldRender()
	end )
end
net.Receive("BuildMap", function()
	//BattleBuilder.World:Initialize()
end)
BattleBuilder.World:Initialize()







BattleBuilder.World:ClearCarbage()


hook.Add( "PlayerNoClip", "BattleBuilder_PlayerNoClip", function( ply, desiredState )
	return true
end )
