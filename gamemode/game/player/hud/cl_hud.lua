local nect = CurTime()
local vox_size = BattleBuilder.Voxel.Settings.voxel_size
BattleBuilder.HUD = {}

function BattleBuilder.HUD:DrawCubeSelection(real_vec)
	local side_1_start_point = real_vec:ToScreen()
	local side_1_end_point = (real_vec+Vector(0,0,vox_size)):ToScreen()
	local side_2_start_point = (real_vec-Vector(vox_size,0,0)):ToScreen()
	local side_2_end_point = (real_vec-Vector(vox_size,0,-vox_size)):ToScreen()
	local side_3_start_point = (real_vec-Vector(vox_size,vox_size,0)):ToScreen()
	local side_3_end_point = (real_vec-Vector(vox_size,vox_size,-vox_size)):ToScreen()
	local side_4_start_point = (real_vec-Vector(0,vox_size,0)):ToScreen()
	local side_4_end_point = (real_vec-Vector(0,vox_size,-vox_size)):ToScreen()
	local side_5_start_point = real_vec:ToScreen()
	local side_5_end_point = (real_vec-Vector(0,vox_size,0)):ToScreen()
	local side_6_start_point = real_vec:ToScreen()
	local side_6_end_point = (real_vec-Vector(vox_size,0,0)):ToScreen()
	local side_7_start_point = (real_vec+Vector(-vox_size,0,0)):ToScreen() 
	local side_7_end_point = (real_vec-Vector(vox_size,vox_size,0)):ToScreen()
	local side_8_start_point = (real_vec+Vector(0,-vox_size,0)):ToScreen() 
	local side_8_end_point = (real_vec-Vector(vox_size,vox_size,0)):ToScreen()
	local side_9_start_point = (real_vec+Vector(0,0,vox_size)):ToScreen()
	local side_9_end_point = (real_vec-Vector(0,vox_size,-vox_size)):ToScreen()
	local side_10_start_point = (real_vec+Vector(0,0,vox_size)):ToScreen()
	local side_10_end_point = (real_vec-Vector(vox_size,0,-vox_size)):ToScreen()
	local side_11_start_point = (real_vec+Vector(-vox_size,0,vox_size)):ToScreen() 
	local side_11_end_point = (real_vec-Vector(vox_size,vox_size,-vox_size)):ToScreen()
	local side_12_start_point = (real_vec+Vector(0,-vox_size,vox_size)):ToScreen() 
	local side_12_end_point = (real_vec-Vector(vox_size,vox_size,-vox_size)):ToScreen()
	surface.DrawLine(side_1_start_point.x, side_1_start_point.y, side_1_end_point.x,side_1_end_point.y)
	surface.DrawLine(side_2_start_point.x, side_2_start_point.y, side_2_end_point.x,side_2_end_point.y)
	surface.DrawLine(side_3_start_point.x, side_3_start_point.y, side_3_end_point.x,side_3_end_point.y)
	surface.DrawLine(side_4_start_point.x, side_4_start_point.y, side_4_end_point.x,side_4_end_point.y)
	surface.DrawLine(side_5_start_point.x, side_5_start_point.y, side_5_end_point.x,side_5_end_point.y)
	surface.DrawLine(side_6_start_point.x, side_6_start_point.y, side_6_end_point.x,side_6_end_point.y)
	surface.DrawLine(side_7_start_point.x, side_7_start_point.y, side_7_end_point.x,side_7_end_point.y)
	surface.DrawLine(side_8_start_point.x, side_8_start_point.y, side_8_end_point.x,side_8_end_point.y)
	surface.DrawLine(side_9_start_point.x, side_9_start_point.y, side_9_end_point.x,side_9_end_point.y)
	surface.DrawLine(side_10_start_point.x, side_10_start_point.y, side_10_end_point.x,side_10_end_point.y)
	surface.DrawLine(side_11_start_point.x, side_11_start_point.y, side_11_end_point.x,side_11_end_point.y)
	surface.DrawLine(side_12_start_point.x, side_12_start_point.y, side_12_end_point.x,side_12_end_point.y)
end
function BattleBuilder.HUD:DestroyVoxel(voxel_id, game_pos,chunk_index,chunk_x, chunk_y, chunk_z, normal)
	local SCR_W, SCR_H = ScrW(), ScrH()
	surface.SetTextColor( 255, 255, 255 )
	surface.SetTextPos( 136, SCR_H-397 )
	surface.SetFont( "Default" )
	if voxel_id == nil then
		surface.DrawText( "Блок не выбран" )
	else
		local real_vec = BattleBuilder.Chunks:GetRealVector(game_pos)
		surface.DrawText("Блок: " .. game_pos.x .. ";" .. game_pos.y .. ";".. game_pos.z .. "      Вектор стороны:" .. normal.x .. ";" .. normal.y .. ";" .. normal.z)
		
		surface.SetDrawColor( 255, 0, 0, 200 )
		BattleBuilder.HUD:DrawCubeSelection(real_vec)
		if input.IsMouseDown( MOUSE_LEFT ) && BattleBuilder.Chunks:VoxelIsVisible(nil,nil,nil, voxel_id) && CurTime() > nect then
			net.Start("DestroyVoxel")
			net.WriteUInt(game_pos.x, 32)
			net.WriteUInt(game_pos.y, 32)
			net.WriteUInt(game_pos.z, 32)
			net.SendToServer()
			timer.Simple(0, function()
				BattleBuilder.Chunks:DestroyVoxel(game_pos.x, game_pos.y, game_pos.z, voxel_id)
			end)
			nect = CurTime() + 0.02
		end
	end
end

function BattleBuilder.HUD:BuildVoxel(voxel_id, game_pos,chunk_index,chunk_x, chunk_y, chunk_z, normal)
	if voxel_id != nil then
		local real_vec = BattleBuilder.Chunks:GetRealVector(game_pos+normal)
		surface.SetDrawColor( 255, 255, 0, 200 )
		BattleBuilder.HUD:DrawCubeSelection(real_vec)

		if input.IsMouseDown( MOUSE_RIGHT ) && CurTime() > nect then
			net.Start("BuildVoxel")
			net.WriteUInt(game_pos.x+normal.x, 32)
			net.WriteUInt(game_pos.y+normal.y, 32)
			net.WriteUInt(game_pos.z+normal.z, 32)
			net.SendToServer()
			timer.Simple(0, function()
				BattleBuilder.Chunks:BuildVoxel(game_pos.x+normal.x, game_pos.y+normal.y, game_pos.z+normal.z)
			end)
			nect = CurTime() + 0.02
		end
	end
end



function BattleBuilder.HUD:ShowPlayerCollision(game_pos)
	local ply = LocalPlayer()
	

	local player_ign_pos = math.VectorFloor(BattleBuilder.World:GetGameVectorPositionFromReal(LocalPlayer():GetPos()),true)
	surface.SetDrawColor( 0, 255, 0, 200 )
	BattleBuilder.HUD:DrawCubeSelection(BattleBuilder.Chunks:GetRealVector(player_ign_pos+Vector(0,1,0)))
	BattleBuilder.HUD:DrawCubeSelection(BattleBuilder.Chunks:GetRealVector(player_ign_pos+Vector(0,-1,0)))
	BattleBuilder.HUD:DrawCubeSelection(BattleBuilder.Chunks:GetRealVector(player_ign_pos+Vector(1,0,0)))
	BattleBuilder.HUD:DrawCubeSelection(BattleBuilder.Chunks:GetRealVector(player_ign_pos+Vector(-1,0,0)))
end

 
hook.Add("HUDPaint", "BattleBuilder_HUDPaint", function()
	
	local voxel_id, game_pos,chunk_index,chunk_x, chunk_y, chunk_z, normal = BattleBuilder.Voxel:RayCast_New(LocalPlayer():EyePos(), LocalPlayer():EyeAngles(), 100)
	BattleBuilder.HUD:ShowPlayerCollision(game_pos)
	BattleBuilder.HUD:BuildVoxel(voxel_id, game_pos,chunk_index,chunk_x, chunk_y, chunk_z, normal)
	BattleBuilder.HUD:DestroyVoxel(voxel_id, game_pos,chunk_index,chunk_x, chunk_y, chunk_z, normal)
end)