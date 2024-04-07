BattleBuilder.Voxel = {
	Settings = {
		voxel_size = 32
	}
}

local vox_half_size = BattleBuilder.Voxel.Settings.voxel_size/2
local vox_2_size = BattleBuilder.Voxel.Settings.voxel_size*2


function BattleBuilder.Voxel:RayCast_New(a, dir, maxDist)
	a = BattleBuilder.World:GetGameVectorPositionFromReal(a)
    local px, py, pz = a.x, a.y, a.z
 	dir = dir:Forward()
    local dx, dy, dz = dir.x,dir.y,dir.z
    //local f0 = 0.0
    local t = 0
    local ix, iy, iz = math.floor(px),math.floor(py),math.floor(pz)
    local end_vec,iend_vec,norm = Vector(),Vector(),Vector()
    local stepx, stepy, stepz = (dx > 0) and 1.0 or -1.0, (dy > 0) and 1.0 or -1.0, (dz > 0) and 1.0 or -1.0
    local delta_limit = 9999
    local txDelta, tyDelta, tzDelta = (dx == 0) and delta_limit or math.abs(1.0 / dx), (dy == 0) and delta_limit or math.abs(1.0 / dy), (dz == 0) and delta_limit or math.abs(1.0 / dz)
 
    local xdist, ydist, zdist = (stepx > 0) and (ix + 1 - px) or (px - ix), (stepy > 0) and (iy + 1 - py) or (py - iy), (stepz > 0) and (iz + 1 - pz) or (pz - iz)
 
    local txMax = (txDelta < delta_limit) and txDelta * xdist or delta_limit
    local tyMax = (tyDelta < delta_limit) and tyDelta * ydist or delta_limit
    local tzMax = (tzDelta < delta_limit) and tzDelta * zdist or delta_limit
    local steppedIndex = -1

    while (t <= maxDist) do

    	local voxel_index, chunk_index, chunk_x, chunk_y, chunk_z = BattleBuilder.Chunks:Voxel_GetByReal(ix, iy, iz)	

        if voxel_index != nil && BattleBuilder.Chunks:VoxelIsVisible(nil,nil,nil, voxel_index) && BattleBuilder.Chunks:Voxel_IS_IN(ix, iy, iz) then

            end_vec.x = px + t * dx
            end_vec.y = py + t * dy
            end_vec.z = pz + t * dz
            iend_vec.x = ix
            iend_vec.y = iy
            iend_vec.z = iz
 
            norm.x = 0
            norm.y = 0
            norm.z = 0
            if (steppedIndex == 0) then norm.x = -stepx end
            if (steppedIndex == 1) then norm.y = -stepy end
            if (steppedIndex == 2) then norm.z = -stepz end
            return voxel_index, Vector(ix, iy, iz), chunk_index, chunk_x, chunk_y, chunk_z, norm
        end
        if (txMax < tyMax) then
            if (txMax < tzMax) then
                ix = ix + stepx
                t = txMax
                txMax = txMax + txDelta
                steppedIndex = 0
            else
                iz = iz + stepz
                t = tzMax
                tzMax = tzMax + tzDelta
                steppedIndex = 2
            end
        else
            if (tyMax < tzMax) then
                iy = iy + stepy
                t = tyMax
                tyMax = tyMax + tyDelta
                steppedIndex = 1
            else
                iz = iz + stepz
                t = tzMax
                tzMax = tzMax + tzDelta
                steppedIndex = 2
            end
        end
    end
    
    
    iend_vec.x = ix iend_vec.y = iy iend_vec.z = iz
 
    end_vec.x = px + t * dx
    end_vec.y = py + t * dy
    end_vec.z = pz + t * dz
    norm.x = 0
	norm.y = 0
	norm.z = 0
    return nil, nil, nil, nil, Vector(ix, iy, iz), chunk_index, nil,nil,nil, norm
    
end


/*
function BattleBuilder.Voxel:RayCast(camera_vector, camera_dir, block_dist)

    local dir_normal = camera_dir:Forward()
	local t = 0
	local game_pos = Vector()
	local dir_vec = Vector()
	while (t<=block_dist*BattleBuilder.Voxel.Settings.voxel_size) do
		t = t + 1
		game_pos = BattleBuilder.World:GetGameVectorPositionFromReal(camera_vector+dir_normal*t)
		game_pos.x = math.floor(game_pos.x) 
		game_pos.y = math.floor(game_pos.y) 
		game_pos.z = math.floor(game_pos.z)		
		local voxel, voxel_x, voxel_y, voxel_z, chunk_index, chunk_x, chunk_y, chunk_z = BattleBuilder.Chunks:Voxel_GetByReal(game_pos.x, game_pos.y, game_pos.z)	
		if voxel != nil && voxel.visible == true && BattleBuilder.Chunks:Voxel_IS_IN(game_pos.x, game_pos.y, game_pos.z) then 
			return voxel, voxel_x, voxel_y, voxel_z, game_pos,chunk_index,chunk_x, chunk_y, chunk_z//, dir_normal
		end
	end

    
    return nil, game_pos, nil

end
*/

BattleBuilder_Enum_CubeSides = {
	front = 1,	
	back = 2,
	left = 3,
	right = 4,
	up = 5,
	down = 6,
}

BattleBuilder.Voxel.VoxelVertexTable = {
	[BattleBuilder_Enum_CubeSides.front] = {
		{ pos = Vector( 0, 0,  0 ), u = -1, v = 1 }, 
		{ pos = Vector( 0, 0,  BattleBuilder.Voxel.Settings.voxel_size ), u = -1, v = 0 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, 0, 0 ), u = 0, v = 1 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, 0,  0 ), u = 1, v = 1 }, 
		{ pos = Vector( 0, 0, BattleBuilder.Voxel.Settings.voxel_size ), u = 0, v = 0 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, 0, BattleBuilder.Voxel.Settings.voxel_size ), u = 1, v = 0 }, 
	},
	[BattleBuilder_Enum_CubeSides.back] = {
		{ pos = Vector( 0, -BattleBuilder.Voxel.Settings.voxel_size,  BattleBuilder.Voxel.Settings.voxel_size ), u = 1, v = -1 }, 
		{ pos = Vector( 0, -BattleBuilder.Voxel.Settings.voxel_size,  0 ), u = 1, v = 0 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, -BattleBuilder.Voxel.Settings.voxel_size, BattleBuilder.Voxel.Settings.voxel_size ), u = 0, v = -1 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, -BattleBuilder.Voxel.Settings.voxel_size,  BattleBuilder.Voxel.Settings.voxel_size ), u = -1, v = -1 }, 
		{ pos = Vector( 0, -BattleBuilder.Voxel.Settings.voxel_size, 0 ), u = 0, v = 0 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, -BattleBuilder.Voxel.Settings.voxel_size, 0 ), u = -1, v = 0 }, 
	},
	[BattleBuilder_Enum_CubeSides.left] = {
		{ pos = Vector( 0, 0,  BattleBuilder.Voxel.Settings.voxel_size ), u = 1, v = -1 }, 
		{ pos = Vector( 0, 0,  0 ), u = 1, v = 0 }, 
		{ pos = Vector( 0, -BattleBuilder.Voxel.Settings.voxel_size, BattleBuilder.Voxel.Settings.voxel_size ), u = 0, v = -1 }, 
		{ pos = Vector( 0, -BattleBuilder.Voxel.Settings.voxel_size,  BattleBuilder.Voxel.Settings.voxel_size ), u = -1, v = -1 }, 
		{ pos = Vector( 0, 0, 0 ), u = 0, v = 0 }, 
		{ pos = Vector( 0, -BattleBuilder.Voxel.Settings.voxel_size, 0 ), u = -1, v = 0 }, 
	},
	[BattleBuilder_Enum_CubeSides.right] = {
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, -BattleBuilder.Voxel.Settings.voxel_size,  BattleBuilder.Voxel.Settings.voxel_size ), u = 1, v = -1 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, -BattleBuilder.Voxel.Settings.voxel_size,  0 ), u = 1, v = 0 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, 0, BattleBuilder.Voxel.Settings.voxel_size ), u = 0, v = -1 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, 0,  BattleBuilder.Voxel.Settings.voxel_size ), u = -1, v = -1 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, -BattleBuilder.Voxel.Settings.voxel_size, 0 ), u = 0, v = 0 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, 0, 0 ), u = -1, v = 0 }, 
	},
	[BattleBuilder_Enum_CubeSides.up] = {
		{ pos = Vector( 0, -BattleBuilder.Voxel.Settings.voxel_size,  BattleBuilder.Voxel.Settings.voxel_size ), u = 1, v = -1 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, -BattleBuilder.Voxel.Settings.voxel_size,  BattleBuilder.Voxel.Settings.voxel_size ), u = 1, v = 0 }, 
		{ pos = Vector( 0, 0, BattleBuilder.Voxel.Settings.voxel_size ), u = 0, v = -1 }, 
		{ pos = Vector( 0, 0,  BattleBuilder.Voxel.Settings.voxel_size ), u = -1, v = -1 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, -BattleBuilder.Voxel.Settings.voxel_size, BattleBuilder.Voxel.Settings.voxel_size ), u = 0, v = 0 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, 0, BattleBuilder.Voxel.Settings.voxel_size ), u = -1, v = 0 }, 
	},
	[BattleBuilder_Enum_CubeSides.down] = {
		{ pos = Vector( 0, 0,  0 ), u = 1, v = -1 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, 0,  0 ), u = 1, v = 0 }, 
		{ pos = Vector( 0, -BattleBuilder.Voxel.Settings.voxel_size, 0 ), u = 0, v = -1 }, 
		{ pos = Vector( 0, -BattleBuilder.Voxel.Settings.voxel_size,  0 ), u = -1, v = -1 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, 0, 0 ), u = 0, v = 0 }, 
		{ pos = Vector( -BattleBuilder.Voxel.Settings.voxel_size, -BattleBuilder.Voxel.Settings.voxel_size, 0 ), u = -1, v = 0 }, 
	},
}


local dev_all = {}
for k,v in pairs(BattleBuilder.Voxel.VoxelVertexTable) do
	for k2,v2 in pairs(v) do
		table.insert(dev_all,v2)
	end	
end
BattleBuilder.Voxel.VoxelVertexTable["dev_all"] = dev_all






function BattleBuilder.Voxel:RenderVertex()

end