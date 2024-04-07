AddCSLuaFile()
BattleBuilder.GamePlayer = {
	hull_size_x = 10,
	hull_size_y = 40,
}
for k,v in ipairs({
	[1] = "hud/cl_hud.lua",
}) do
	AddCSLuaFile(v)
	include(v)
end

if SERVER then
	util.AddNetworkString("DestroyVoxel")
	util.AddNetworkString("BuildVoxel")

	net.Receive("DestroyVoxel", function()
		local voxel_x = net.ReadUInt(32)
		local voxel_y = net.ReadUInt(32)
		local voxel_z = net.ReadUInt(32)
		local voxel = BattleBuilder.Chunks:Voxel_GetByReal(voxel_x,voxel_y,voxel_z)
		-- voxel.visible = false DESTROY VOXEL HERE


		BattleBuilder.Chunks:DestroyVoxel(voxel_x, voxel_y, voxel_z)
	end)
	net.Receive("BuildVoxel", function()
		local voxel_x = net.ReadUInt(32)
		local voxel_y = net.ReadUInt(32)
		local voxel_z = net.ReadUInt(32)
		local voxel = BattleBuilder.Chunks:Voxel_GetByReal(voxel_x,voxel_y,voxel_z)

		
		BattleBuilder.Chunks:BuildVoxel(voxel_x, voxel_y, voxel_z)
		-- voxel.visible = true DESTROY VOXEL HERE
	end)
end


function CheckCollisionBlock(movement_vec, origin_pos, PlyGameLogicPos, move_ang, debug_mode)

	--[[ movement_vec = movement_vec * 30

	movement_vec:Rotate(move_ang)--]] 

	local NextStepPos = BattleBuilder.World:GetGameVectorPositionFromReal(movement_vec + origin_pos )
	local BlockSidePos_Center = math.VectorFloor(NextStepPos,true)

	VisibleBlockFromCenter = BattleBuilder.Chunks:VoxelIsVisible(BlockSidePos_Center.x, BlockSidePos_Center.y, BlockSidePos_Center.z)	
	return !VisibleBlockFromCenter
end

local CheckBlockLen = 8
function GM:Move( ply, mv )
	local move_ang = mv:GetMoveAngles()
	local origin_pos = mv:GetOrigin()
	move_ang.p = 0

	local ob_vec_up_l = Vector(-1,1,0)
	local ob_vec_up_r = Vector(1,1,0)
	local ob_vec_down_l = Vector(-1,-1,0)
	local ob_vec_down_r = Vector(1,-1,0)

	local last_vel = mv:GetVelocity()


	local movement_vec = Vector(0,0,0) 
	local x_block = false
	local y_block = false
	local z_block = false


	--[[ if mv:KeyDown(IN_JUMP) then
		movement_vec.z = movement_vec.z + 1
	end
	if movement_vec.z > 0 then
		movement_vec.z = math.Approach(movement_vec.z, 0, 0.1)
	end--]] 

	if mv:KeyDown(IN_FORWARD) then
		movement_vec.x = 1
	elseif mv:KeyDown(IN_BACK) then
		movement_vec.x = -1
	end
	if mv:KeyDown(IN_MOVELEFT) then
		movement_vec.y = 1
	elseif mv:KeyDown(IN_MOVERIGHT) then
		movement_vec.y = -1
	end


	local PlyGameLogicPos =  math.VectorFloor(BattleBuilder.World:GetGameVectorPositionFromReal(origin_pos ),true)
	if PlyGameLogicPos.z > 0 then
		movement_vec.z = -1
	elseif mv:KeyDown(IN_JUMP) then
		movement_vec.z = 1
	end
		
	movement_vec:Rotate(move_ang)
	local add_normalized = (last_vel:GetNormalized())
	movement_vec = movement_vec + add_normalized



	local r_corner_vec = origin_pos+Vector(CheckBlockLen,CheckBlockLen,0)
	local l_corner_vec = origin_pos+Vector(-CheckBlockLen,CheckBlockLen,0)
	local u_corner_vec = origin_pos+Vector(CheckBlockLen,-CheckBlockLen,0)
	local d_corner_vec = origin_pos+Vector(-CheckBlockLen,-CheckBlockLen,0)

	
	local x_movement = Vector(movement_vec.x,0,0)
	local y_movement = Vector(0,movement_vec.y,0)
	local z_movement = Vector(0,0,movement_vec.z)
			

	local head_level_vec = Vector(0,0,70)

	local can_up = false


	if movement_vec.y != 0 then
		if !CheckCollisionBlock(y_movement, r_corner_vec+head_level_vec, PlyGameLogicPos,  move_ang, true) then
			movement_vec.y = 0
			y_block = true
		elseif !CheckCollisionBlock(y_movement, l_corner_vec+head_level_vec, PlyGameLogicPos,  move_ang, true) then
			movement_vec.y = 0
			y_block = true
		elseif !CheckCollisionBlock(y_movement, u_corner_vec+head_level_vec, PlyGameLogicPos,  move_ang) then
			movement_vec.y = 0
			y_block = true
		elseif !CheckCollisionBlock(y_movement, d_corner_vec+head_level_vec, PlyGameLogicPos,  move_ang) then
			movement_vec.y = 0
			y_block = true
		elseif !CheckCollisionBlock(y_movement, r_corner_vec, PlyGameLogicPos,  move_ang) then
			-- movement_vec.z = 0
			can_up = true
		elseif !CheckCollisionBlock(y_movement, l_corner_vec, PlyGameLogicPos,  move_ang) then
			-- movement_vec.z = 0
			can_up = true
		elseif !CheckCollisionBlock(y_movement, u_corner_vec, PlyGameLogicPos,  move_ang) then
			-- movement_vec.z = 0
			can_up = true
		elseif !CheckCollisionBlock(y_movement, d_corner_vec, PlyGameLogicPos,  move_ang) then
			-- movement_vec.z = 0
			can_up = true
		end
	end


	if movement_vec.x != 0 then
		if !CheckCollisionBlock(x_movement, r_corner_vec+head_level_vec, PlyGameLogicPos,  move_ang) then
			movement_vec.x = 0
			x_block = true
		elseif !CheckCollisionBlock(x_movement, u_corner_vec+head_level_vec, PlyGameLogicPos,  move_ang) then
			movement_vec.x = 0
			x_block = true
		elseif !CheckCollisionBlock(x_movement, l_corner_vec+head_level_vec, PlyGameLogicPos,  move_ang) then
			movement_vec.x = 0
			x_block = true
		elseif !CheckCollisionBlock(x_movement, d_corner_vec+head_level_vec, PlyGameLogicPos,  move_ang) then
			movement_vec.x = 0
			x_block = true
		elseif !CheckCollisionBlock(x_movement, r_corner_vec, PlyGameLogicPos,  move_ang) then
			-- movement_vec.z = 1
			can_up = true
		elseif !CheckCollisionBlock(x_movement, u_corner_vec, PlyGameLogicPos,  move_ang) then
			-- movement_vec.z = 1
			can_up = true
		elseif !CheckCollisionBlock(x_movement, l_corner_vec, PlyGameLogicPos,  move_ang) then
			-- movement_vec.z = 1
			can_up = true
		elseif !CheckCollisionBlock(x_movement, d_corner_vec, PlyGameLogicPos,  move_ang) then
			-- movement_vec.z = 1
			can_up = true
		end
	end





	--if movement_vec.z < 0 then
	if !CheckCollisionBlock(z_movement, r_corner_vec, PlyGameLogicPos,  move_ang) then
		movement_vec.z = 0
		z_block = true
	elseif !CheckCollisionBlock(z_movement, u_corner_vec, PlyGameLogicPos,  move_ang) then
		movement_vec.z = 0
		z_block = true
	elseif !CheckCollisionBlock(z_movement, l_corner_vec, PlyGameLogicPos,  move_ang) then
		movement_vec.z = 0
		z_block = true
	elseif !CheckCollisionBlock(z_movement, d_corner_vec, PlyGameLogicPos,  move_ang) then
		movement_vec.z = 0
		z_block = true
	end
	if !CheckCollisionBlock(z_movement, origin_pos+Vector(CheckBlockLen,CheckBlockLen,head_level_vec.z), PlyGameLogicPos,  move_ang) then
		can_up = false
		if movement_vec.z > 0 then
			movement_vec.z = 0
			z_block = true
		end
	elseif !CheckCollisionBlock(z_movement, origin_pos+Vector(CheckBlockLen,-CheckBlockLen,head_level_vec.z), PlyGameLogicPos,  move_ang) then
		can_up = false
		if movement_vec.z > 0 then
			movement_vec.z = 0
			z_block = true
		end
	elseif !CheckCollisionBlock(z_movement, origin_pos+Vector(-CheckBlockLen,CheckBlockLen,head_level_vec.z), PlyGameLogicPos,  move_ang) then
		can_up = false
		if movement_vec.z > 0 then
			movement_vec.z = 0
			z_block = true
		end
	elseif !CheckCollisionBlock(z_movement, origin_pos+Vector(-CheckBlockLen,-CheckBlockLen,head_level_vec.z), PlyGameLogicPos,  move_ang) then
		can_up = false
		if movement_vec.z > 0 then
			movement_vec.z = 0
			z_block = true
		end
	end


	//

	
	local new_velocity = Vector()
	if z_block then
		new_velocity.z = 0
	else
		new_velocity.z = 40 * FrameTime() * (movement_vec.z-add_normalized.z) + last_vel.z * 0.75
	end
	if y_block then
		origin_pos.y = origin_pos.y - add_normalized.y * 0.5
		new_velocity.y = 0
	else
		new_velocity.y = 40 * FrameTime() * (movement_vec.y-add_normalized.y) + last_vel.y * 0.75
	end
	if x_block then
		origin_pos.x = origin_pos.x - add_normalized.x * 0.55
		new_velocity.x = 0
	else
		new_velocity.x = 40 * FrameTime() * (movement_vec.x-add_normalized.x)  + last_vel.x * 0.75
	end

	mv:SetVelocity(new_velocity) 


	local newpos = origin_pos + new_velocity 


	if can_up then
		if movement_vec.z == 0 then
			if CheckCollisionBlock(Vector(0,0,1), origin_pos+Vector(0,0,head_level_vec.z), PlyGameLogicPos,  move_ang) then
				newpos = newpos + Vector(0,0,20)	
			end
		end
	end
	
	mv:SetOrigin( newpos )

	return true

end


