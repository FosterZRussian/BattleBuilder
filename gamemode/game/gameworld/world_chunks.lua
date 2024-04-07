
BattleBuilder.Chunks = {
	Settings = {
		chunk_size_x = 12,
		chunk_size_y = 12,
		chunk_size_z = 32,
		source_xorld_start_pos = Vector(-56.655914, -2431.784424, 1600),
		chunks_counts_x = 32,
		chunks_counts_y = 32,
		chunks_counts_z = 32,
		chunks_visibledist_horizontal = 5500,
		chunks_visibledist_vertical = 5500,
	},
	World = {
		Chunks = {},
		Vars = {},
		PreBuildedChunks = {},
	}
}

BattleBuilder.Chunks.World.Vars.chunk_size_x_of1 = BattleBuilder.Chunks.Settings.chunk_size_x - 1
BattleBuilder.Chunks.World.Vars.chunk_size_y_of1 = BattleBuilder.Chunks.Settings.chunk_size_y - 1
BattleBuilder.Chunks.World.Vars.chunk_size_z_of1 = BattleBuilder.Chunks.Settings.chunk_size_z - 1

BattleBuilder.Chunks.World.Vars.chunk_realsize_x = BattleBuilder.Chunks.World.Vars.chunk_size_x_of1*BattleBuilder.Voxel.Settings.voxel_size/2
BattleBuilder.Chunks.World.Vars.chunk_realsize_y = BattleBuilder.Chunks.World.Vars.chunk_size_y_of1*BattleBuilder.Voxel.Settings.voxel_size/2
BattleBuilder.Chunks.World.Vars.chunk_realsize_z = BattleBuilder.Chunks.World.Vars.chunk_size_z_of1*BattleBuilder.Voxel.Settings.voxel_size/2
BattleBuilder.Chunks.World.Vars.chunk_halfsize_vec = Vector(BattleBuilder.Chunks.World.Vars.chunk_realsize_x,BattleBuilder.Chunks.World.Vars.chunk_realsize_y,BattleBuilder.Chunks.World.Vars.chunk_realsize_z)



function BattleBuilder.World:GetGameVectorPositionFromReal(pos)
	return ((pos-BattleBuilder.Chunks.Settings.source_xorld_start_pos)/BattleBuilder.Voxel.Settings.voxel_size)+Vector(1,1,0)
end



function BattleBuilder.Chunks:GetIndex_ByXYZ(x,y,z, d,w)
	return (y*d+z)*w+x
end



local ch_sz_x = BattleBuilder.Chunks.Settings.chunk_size_x   
local ch_sz_y = BattleBuilder.Chunks.Settings.chunk_size_y 
local ch_sz_z = BattleBuilder.Chunks.Settings.chunk_size_z 

local jjj_xyz = ch_sz_x * ch_sz_y * ch_sz_z
local jjj_yz = ch_sz_y * ch_sz_z 

local jj_ind = 1025 -- максимальный размер поля (1024) + 1 
local jj_ind_2 = 1025 ^ 2




--local xof,yof,zof = 100000000000, 100000000 , 10000
local XS = 512
local YS = 512
-- local k = x + X*(y-1) + X*Y*(z-1);


function GetVoxelIndex_ByXYZ(x,y,z)
	return x + XS*(y-1) + XS*YS*(z-1)
	--return xof + x * yof + y * zof + z
	-- return self:PackTreeQuadValue( x,y,z )	
	-- return (x+jj_ind) * jj_ind_2 + (y+jj_ind) * jj_ind + (z+jj_ind)

	--[[ local value =  x * (1024 + 1)^2 + y * (1024 + 1) + z
	return value--]] 

	-- >
	--[[ 	local s = 1

	local x2 = 512
	local x1 = -512

	local y2 = 512
	local y1 = -512

	local z2 = 512
	local z1 = -512 

	return ((s*(x2 - x1) + (x - x1))*(y2 - y1) + (y - y1))*(z2 - z1) + (z - z1)
	--]] 
	--return x * (jjj_xyz + 1)^2 + y * (jjj_xyz + 1) 
end




function BattleBuilder.Chunks:GetChunkPosForVoxel(x,y,z)
	local chunk_x, chunk_y, chunk_z = math.floor(x/BattleBuilder.Chunks.Settings.chunk_size_x), math.floor(y/BattleBuilder.Chunks.Settings.chunk_size_y), math.floor(z/BattleBuilder.Chunks.Settings.chunk_size_z)
	return chunk_x, chunk_y, chunk_z
end

function BattleBuilder.Chunks:Voxel_GetByReal(x,y,z)
	if !BattleBuilder.Chunks:Voxel_IS_IN(x,y,z) then return end
	local chunk_x, chunk_y, chunk_z = math.floor(x/BattleBuilder.Chunks.Settings.chunk_size_x), math.floor(y/BattleBuilder.Chunks.Settings.chunk_size_y), math.floor(z/BattleBuilder.Chunks.Settings.chunk_size_z)
	-- local voxel_x, voxel_y, voxel_z = x-chunk_x*BattleBuilder.Chunks.Settings.chunk_size_x,y-chunk_y*BattleBuilder.Chunks.Settings.chunk_size_y,z-chunk_z*BattleBuilder.Chunks.Settings.chunk_size_z
	local voxel_index = GetVoxelIndex_ByXYZ(x,y,z) -- BattleBuilder.Chunks:GetIndex_ByXYZ(voxel_x, voxel_y, voxel_z, BattleBuilder.Chunks.Settings.chunk_size_z,BattleBuilder.Chunks.Settings.chunk_size_x)
	local chunk_index = BattleBuilder.Chunks:GetChunkIndex_ByXYZ(chunk_x, chunk_y, chunk_z)

	return voxel_index, chunk_index, chunk_x, chunk_y, chunk_z
	
end




local VoxelColorMeta = {}
VoxelColorMeta.__index = VoxelColorMeta
debug.getregistry().VoxelColorMeta = VoxelColorMeta
function BattleBuilder.Chunks:CreateColorTableForVoxel( r, g, b )
	return setmetatable( { r = math.min( tonumber(r), 255 ), g =  math.min( tonumber(g), 255 ), b =  math.min( tonumber(b), 255 )}, VoxelColorMeta )
end
function VoxelColorMeta:__eq( c )
	return self.r == c.r and self.g == c.g and self.b == c.b 
end

BattleBuilder.Chunks.CachedColors = {}


function BattleBuilder.Chunks:PackColor( r, g, b )
	--[[ local ColorID = GetVoxelIndex_ByXYZ(r,g,b)
	if BattleBuilder.Chunks.CachedColors[ColorID] == nil then
		BattleBuilder.Chunks.CachedColors[ColorID] = BattleBuilder.Chunks:CreateColorTableForVoxel(r,g,b)
	end
	return ColorID--]] 

	return 100000000 + r * 1000000 + g * 1000 + b 

end
function BattleBuilder.Chunks:UnpackColor(ColorID)

	local b = ColorID % 1000
	ColorID = (ColorID - b) / 1000
	local g = ColorID % 1000
	ColorID = (ColorID - g) / 1000
	local r = ColorID - 100
	return Color(r,g,b)
end


function BattleBuilder.Chunks:PackTreeQuadValue( r, g, b )
	return 100000000000 + r * 100000000 + g * 10000 + b 

end
function BattleBuilder.Chunks:UnpackTreeQuadValue(qv)

	local z = qv % 10000
	qv = (qv - z) / 10000
	local y = qv % 10000
	qv = (qv - y) / 10000
	local x = qv - 1000
	return x,y,z 
end




function BattleBuilder.Chunks:GetChunkIndex_ByXYZ(x,y,z)
	return ((BattleBuilder.Chunks.Settings.chunks_counts_z * BattleBuilder.Chunks.Settings.chunks_counts_y) * (x-1) ) + ((z-1) + BattleBuilder.Chunks.Settings.chunks_counts_z * (y-1))
	--return BattleBuilder.Chunks:GetIndex_ByXYZ(x,y,z, BattleBuilder.Chunks.Settings.chunks_counts_z,BattleBuilder.Chunks.Settings.chunks_counts_x)
end



local _WriteStarted = 0



function BattleBuilder.Chunks:LevelEndWrite(SaveStructure)

	BattleBuilder.Chunks:LevelSaveVoxels(SaveStructure)

	for k,v in pairs(SaveStructure.Files) do
		SaveStructure.FileReaders[k]:Close()
	end


	
	local _LevelTime = os.clock()
	
	for k,v in pairs(SaveStructure.Files) do

		local StTime = os.clock()
		print("[Processing]: " .. k)
		_WriteStarted = os.clock()
		SaveStructure.FileReaders[k] = file.Open(v .. ".dat","rb","DATA")
		local FileContent = SaveStructure.FileReaders[k]:Read()
		local CompressedString = util.Compress(FileContent)
		SaveStructure.FileReaders[k]:Close()

		print("  [File Reading]:\t", os.clock() - _WriteStarted .. " sec")
		_WriteStarted = os.clock()

		SaveStructure.FileReaders[k] = file.Open(v .. "_compressed.dat", "wb", "DATA")
		SaveStructure.FileReaders[k]:Write(CompressedString)
		SaveStructure.FileReaders[k]:Close()

		print("  [File Compressing]:\t", os.clock() - _WriteStarted .. " sec")
		_WriteStarted = os.clock()

		SaveStructure.FileReaders[k] = file.Open(v .. "_compressed.dat", "rb", "DATA")
		local DecompressedString = util.Decompress(SaveStructure.FileReaders[k]:Read())
		SaveStructure.FileReaders[k]:Close()

		print("  [File Reading Compressed]:\t", os.clock() - _WriteStarted .. " sec")
		_WriteStarted = os.clock()
			

		print("  [File Decompressed Size]:\t", string.len(DecompressedString) )
		print("  [File Compressed Size:]:\t", string.len(CompressedString) )

		print("  [File saving took]:\t", os.clock() - StTime)
	end
	print("[Level saving took]:\t", os.clock() - _LevelTime .. " sec")
end

function BattleBuilder.Chunks:LevelSaveVoxels(SaveStructure)
	
end

local last_chunk_id = nil
local _ChunkStorage = {}
local _CachedChunks = {}
local _WriteColors = {}
local _WriteColorsIndexer = {}


function BattleBuilder.Chunks:SaveCachedChunk(data)
	PrintTable(data)

end
function BattleBuilder.Chunks:LevelWriteVoxel(data, SaveStructure)


	


	if data.chunk_id != last_chunk_id then
		local ColorRange = {}
		

		local last_color = nil
		local last_x = nil
		local last_y = nil
		local last_z = nil


		local writefile = "battlebuilder/levels/" .. SaveStructure.LevelData.LevelName .. "/level_storage/"
		--print(14)


		if last_chunk_id != nil then
			local FileWriter = file.Open(writefile .. "chunk_" .. last_chunk_id .. ".dat", "wb", "DATA")
			for x, y_data in ipairs(_ChunkStorage) do
				for y, z_data in ipairs(y_data) do
					for z, color_index in ipairs(z_data) do
						--[[ FileWriter:WriteByte(x)
						FileWriter:WriteByte(y)
						FileWriter:WriteByte(z)--]] 
						FileWriter:WriteShort(color_index)
					end
				end
			end
			FileWriter:Close()


			FileWriter = file.Open(writefile .. "chunk_" .. last_chunk_id .. ".dat", "rb", "DATA")
			local FileStr = FileWriter:Read()
			FileWriter:Close()

			local cache = util.SHA256(FileStr)
			if _CachedChunks[cache] != nil then
				file.Delete(writefile .. "chunk_" .. last_chunk_id .. ".dat")
			else
				FileWriter = file.Open(writefile .. "chunk_" .. last_chunk_id .. "_compressed.dat", "wb", "DATA")
				FileWriter:Write(util.Compress(FileStr))
				FileWriter:Close()


			
				file.Delete(writefile .. "chunk_" .. last_chunk_id .. ".dat")

				--[[ 

				FileWriter = file.Open(writefile .. "chunk_" .. last_chunk_id .. "_compressed.dat", "rb", "DATA")
				local decompressed = util.Decompress(FileWriter:Read())
				FileWriter:Close()

				FileWriter = file.Open(writefile .. "chunk_" .. last_chunk_id .. "_decompressed.dat", "wb", "DATA")
				FileWriter:Write(decompressed)
				FileWriter:Close()--]] 


				_CachedChunks[cache] = last_chunk_id	
			end

			SaveStructure.FileReaders.LevelData:WriteShort(data.chunk_x)
			SaveStructure.FileReaders.LevelData:WriteShort(data.chunk_y)
			SaveStructure.FileReaders.LevelData:WriteShort(data.chunk_z)
			SaveStructure.FileReaders.LevelData:WriteShort(last_chunk_id)


		end

		_ChunkStorage = {}
		last_chunk_id = data.chunk_id
	end



	_WriteColors[data.block_r] = _WriteColors[data.block_r] or {}
	_WriteColors[data.block_r][data.block_g] = _WriteColors[data.block_r][data.block_g] or {}
	if _WriteColors[data.block_r][data.block_g][data.block_b] == nil then

		local color_id = #_WriteColorsIndexer+1
		_WriteColorsIndexer[color_id] = {
			r = data.block_r,
			g = data.block_g,
			b = data.block_b
		}
		_WriteColors[data.block_r][data.block_g][data.block_b] = color_id

		SaveStructure.FileReaders.LevelColors:WriteShort(color_id)
		SaveStructure.FileReaders.LevelColors:WriteByte(data.block_r)
		SaveStructure.FileReaders.LevelColors:WriteByte(data.block_g)
		SaveStructure.FileReaders.LevelColors:WriteByte(data.block_b)

	end
	_ChunkStorage[data.block_x] = _ChunkStorage[data.block_x] or {}
	_ChunkStorage[data.block_x][data.block_y] = _ChunkStorage[data.block_x][data.block_y] or {}
	_ChunkStorage[data.block_x][data.block_y][data.block_z] = _WriteColors[data.block_r][data.block_g][data.block_b]
	
end
function BattleBuilder.Chunks:LevelStartWrite(level_name)

	_WriteStarted = os.clock()
	_WriteColors = {}
	_WriteColorsIndexer = {}

	local SaveStructure = {
		LevelData = {
			Chunks = {},
			LevelName = level_name,
		},
		Files = {
			LevelData = "battlebuilder/levels/" .. level_name .. "/level_storage/level_content",
			LevelColors = "battlebuilder/levels/" .. level_name .. "/level_storage/level_colors",
		},
		FileReaders = {},
	}


	for k,v in pairs(SaveStructure.Files) do
		SaveStructure.FileReaders[k] = file.Open(v .. ".dat","wb","DATA")
	end

	

	return SaveStructure
end


function BattleBuilder.Chunks:CreateChunkTable(chunk_id, chunk_x, chunk_y, chunk_z, FILE)
	--local voxels = {}
	-- sql.Query("DELETE * FROM BattleBuilder_PreBuildedGameChunks WHERE chunk_id='"..chunk_id.."'")
	for y = 0, self.Settings.chunk_size_y do
		for z = 0, self.Settings.chunk_size_z do
			for x = 0, self.Settings.chunk_size_x do
				local index = self:GetIndex_ByXYZ(x,y,z, self.Settings.chunk_size_z,self.Settings.chunk_size_x  )
				--[[ voxels[index] = {
					visible = true,--x < 7 && z < 7 && y < 7,
					health = 100,
					v_type = 1,
					--v_upd = false,
					--color_r = math.random(100,255),
					--color_g = math.random(100,255),
					--color_b = math.random(100,255),
					--color_a = 90,
				}--]] 
				--if z > 32 then
				--	voxels[index].color_r = 200
				--end

				--local
				self:LevelWriteVoxel({
					chunk_id = chunk_id,
					chunk_x = chunk_x,
					chunk_y = chunk_y,
					chunk_z = chunk_z,
					block_x =  x,
					block_y =  y,
					block_z  = z,
					block_r = math.random(100,255), --voxels[index].color_r,
					block_g = math.random(100,255), --voxels[index].color_g,
					block_b = math.random(100,255) --voxels[index].color_r,
				}, FILE) 
 



				
			end
		end	
	end
	return voxels
end

if SERVER then

	hook.Add("NetworkEntityCreated","SomeTest_NetworkEntityCreated", function(ent)
		print(ent, " serverside")
	end)
	hook.Add("InitPostEntity", "SomeTest_InitPostEntity", function()
	end)
end


function math.VectorFloor(vector, copy_vector)
	if copy_vector then
		return Vector(math.floor(vector.x), math.floor(vector.y), math.floor(vector.z))
	else
		vector.x = math.floor(vector.x)
		vector.y = math.floor(vector.y)
		vector.z = math.floor(vector.z)
	end 
end
function math.VectorRound(vector, copy_vector)	
	if copy_vector then
		return Vector(math.Round(vector.x), math.Round(vector.y), math.Round(vector.z))
	else
		vector.x = math.Round(vector.x)
		vector.y = math.Round(vector.y)
		vector.z = math.Round(vector.z)
		return vector
	end 

end


function BattleBuilder.Chunks:Voxel_IS_IN(x,y,z)
	return (x >= 0 && x < BattleBuilder.Chunks.Settings.chunk_size_x*BattleBuilder.Chunks.Settings.chunks_counts_x && y >= 0 && y < BattleBuilder.Chunks.Settings.chunk_size_y*BattleBuilder.Chunks.Settings.chunks_counts_y && z >= 0 && z < BattleBuilder.Chunks.Settings.chunk_size_z*BattleBuilder.Chunks.Settings.chunks_counts_z)
	//return (x >= 0 && x < BattleBuilder.Chunks.Settings.chunk_size_x && y >= 0 && y < BattleBuilder.Chunks.Settings.chunk_size_y && z >= 0 && z < BattleBuilder.Chunks.Settings.chunk_size_z)
end

function BattleBuilder.Chunks:Voxel_GetLocal(x,y,z, chunk)
	return chunk.voxels[(y*BattleBuilder.Chunks.Settings.chunk_size_z+z)*BattleBuilder.Chunks.Settings.chunk_size_x+x]
end


function BattleBuilder.Chunks:Chunk_GetXYZByReal(x,y,z) -- may be not working correctly + not used
	return math.floor((x/BattleBuilder.Chunks.World.Vars.chunk_size_x_of1/BattleBuilder.Chunks.Settings.chunk_size_x)), math.floor((y/BattleBuilder.Chunks.World.Vars.chunk_size_y_of1)/BattleBuilder.Chunks.Settings.chunk_size_y), math.floor((z/BattleBuilder.Chunks.World.Vars.chunk_size_z_of1)/BattleBuilder.Chunks.Settings.chunk_size_z)
end


function BattleBuilder.Chunks:VoxelIsVisible(real_x,real_y,real_z, VoxelID)
	if VoxelID == nil then
		VoxelID = GetVoxelIndex_ByXYZ(real_x,real_y,real_z)
	end
	local VoxelType = BattleBuilder.Chunks.VoxelsGameStorage.DataColor.InGame[VoxelID] -- replace to InG

	if VoxelType == nil then 

		return false, VoxelID 
	end

	return true, VoxelID
end

function BattleBuilder.Chunks:Voxel_NotCreated(x,y,z, chunk)
	return !BattleBuilder.Chunks:Voxel_IS_IN(x,y,z)
end



function BattleBuilder.Chunks:GetChunkVertexPos(x,y,z)
	return BattleBuilder.Chunks.Settings.source_xorld_start_pos+Vector(x*BattleBuilder.Chunks.Settings.chunk_size_x,y*BattleBuilder.Chunks.Settings.chunk_size_y,z*BattleBuilder.Chunks.Settings.chunk_size_z)*BattleBuilder.Voxel.Settings.voxel_size
end


function BattleBuilder.Chunks:GetRealVector(vec)
	return BattleBuilder.Chunks.Settings.source_xorld_start_pos+(vec*BattleBuilder.Voxel.Settings.voxel_size)
end

function BattleBuilder.Chunks:GetVertexPos(x,y,z, vertex_table)
	return vertex_table.pos+Vector(x,y,z)*BattleBuilder.Voxel.Settings.voxel_size
end

function BattleBuilder.Chunks:AddVertex(x,y,z,tb)
	for k,v in pairs(tb) do
		mesh.Position( BattleBuilder.Chunks:GetVertexPos(x,y,z,v) )
		mesh.TexCoord( 0, v.u, v.v )
		mesh.AdvanceVertex()
	end
end
function BattleBuilder.Chunks:GetVertexesPosFromTable(x,y,z,side_type, tb_insert, chunk_pos)


	local vertexes_table = tb_insert.vertexes

	local _linkedclr = tb_insert.draw_side_colors[side_type]

	for k,v in pairs(BattleBuilder.Voxel.VoxelVertexTable[side_type]) do
		vertexes_table[#vertexes_table+1] = {			
			pos = BattleBuilder.Chunks:GetVertexPos(x,y,z,v)+chunk_pos,
			tex_u = v.u,
			tex_v = v.v,
			voxel_pos = Vector(x,y,z),
			linked_color = _linkedclr,
			face_type = side_type
		}
	end
end



local Cube_Material = "BattleBuilder_Dev_2"
if CLIENT then
	local mat = CreateMaterial( Cube_Material, "UnLitGeneric", {
		["$basetexture"] = "battlebuilder/fosterz/voxels/block_4",
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 0,
	} )
end
local Used_Cube_Material = "!BattleBuilder_Dev_2"


--[[ function BattleBuilder.Chunks:SetVoxelNeedUpdate(x,y,z,chunk_index, update_chunk)
	BattleBuilder.Chunks.World.Chunks[chunk_index].voxels[GetVoxelIndex_ByXYZ(x,y,z)].v_upd = true
	if update_chunk then
		BattleBuilder.Chunks:PreBuildChunk(chunk_index, true)
	end
end
--]] 


file.CreateDir("battlebuilder/cashed_chunks")

local function SaveCompressedString(path, str)
	file.Write(path, str)
end
local function AppedCompressedString(path, str)
	file.Write(path, util.Compress(str))
end


function BattleBuilder.Chunks:BuildVoxel(voxel_x, voxel_y, voxel_z, voxel_index)

	--[[ local voxel_in_chunk, voxel_x, voxel_y, voxel_z, chunk_index, chunk_x, chunk_y, chunk_z = BattleBuilder.Chunks:Voxel_GetByReal(x,y,z)
	if voxel_in_chunk != nil then
		voxel_in_chunk.v_upd = true
		voxel_in_chunk.visible = true
		voxel_in_chunk.color_r = math.random(122,255)
		voxel_in_chunk.color_g = math.random(122,255)
		voxel_in_chunk.color_b = math.random(122,255)
		BattleBuilder.Chunks:UpdateLocalVoxel(voxel_x, voxel_y, voxel_z, chunk_index, chunk_x, chunk_y, chunk_z)
	end--]] 
	BattleBuilder.Chunks:VoxelGameStorage_CreateBlock(voxel_x, voxel_y, voxel_z, voxel_index, Color(math.random(0,255), math.random(0,255), math.random(0,255)))
	local voxel_real_pos = BattleBuilder.Chunks:GetRealVector(Vector(voxel_x, voxel_y, voxel_z))
	sound.Play( "garrysmod/balloon_pop_cute.wav", voxel_real_pos )
	


end

function BattleBuilder.Chunks:DestroyVoxel(voxel_x, voxel_y, voxel_z, voxel_index)
	BattleBuilder.Chunks:VoxelGameStorage_DeleteBlock(voxel_x, voxel_y, voxel_z, voxel_index)

	local voxel_real_pos = BattleBuilder.Chunks:GetRealVector(Vector(voxel_x, voxel_y, voxel_z))
	
	sound.Play( "garrysmod/balloon_pop_cute.wav", voxel_real_pos )

	-- BattleBuilder.Chunks:RemoveBlockPhysGroup(voxel_x, voxel_y, voxel_z, nil, voxel_index)


	
	--[[ cube_selected.visible = false
	cube_selected.v_upd = true
	BattleBuilder.Chunks:UpdateLocalVoxel(voxel_x, voxel_y, voxel_z, chunk_index, chunk_x, chunk_y, chunk_z)--]] 

	
end


function BattleBuilder.Chunks:CheckSQLTables()
	
	if !sql.TableExists( "BattleBuilder_PreBuildedGameChunks" ) then
		sql.Query("CREATE TABLE BattleBuilder_PreBuildedGameChunks( chunk_id NUMBER, chunk_x NUMBER,chunk_y NUMBER,chunk_z NUMBER, block_x NUMBER,block_y NUMBER,block_z NUMBER,block_r NUMBER,block_g NUMBER,block_b NUMBER)" )
	end

end




--

--[[ local VoxelMeta = {
	DataColorInGame = 0,
	DataColorInStorage = 0,
	DataTypeInGame = 0,
	DataTypeInStorage = 0,
	DataHealthInGame = 0,
	DataHealthInStorage = 0,
	DataGroupInGame = 0,
	DataGroupInStorage = 0,
}

-- Функция для создания блока с начальными значениями
function CreateVoxelData()
	return setmetatable({}, { __index = VoxelMeta })
end--]] 


--


BattleBuilder.Chunks:CheckSQLTables()



BattleBuilder.Chunks.ChunksGameStorage = {
	PrebuildedMeshes = {},
	PrebuildedMeshesBuildInfo = {},
	ChunkVisible = {},
	NeedVisLisUpdate = {},
	CachedVoxelsVertex = {},

}
BattleBuilder.Chunks.VoxelsGameStorage = {

	DataColor = {
		InStorageMap = {},
		InGame = {},
	},
	DataType = {
		InStorageMap = {},
		InGame = {},
	},
	DataHealth = {
		InGame = {},
	},
	DataGroup = {
		InGame = {

		},
	},
}
	

--[[ 
[1] = Не разрушаемый блок
[2] = SpawnPoint (Команда 1)
[3] = SpawnPoint (Команда 2)
[4] = SpawnPoint (Все\ДМ\ЗОМБИ МОД)
[5] = Ящик (Боезапас)
[6] = Ящик (Ресурсы)
[7] = Ящик (Здоровье)
[8] = База\Флаг (Команда 1)
[9] = База\Флаг (Команда 2)--]] 

--[[ local t={}
local max_limit = (1024 * 1024 * 128)
for i=1, max_limit-(max_limit/2) do t[i]=i end
print(#t)

if 1 == 1 then return end--]] 





function BattleBuilder.Chunks:VoxelGameStorage_GetBlockChunk(block_x,block_y,block_z)
	local chunk_x = math.floor(block_x/BattleBuilder.Chunks.Settings.chunk_size_x)
	local chunk_y = math.floor(block_y/BattleBuilder.Chunks.Settings.chunk_size_y)
	local chunk_z = math.floor(block_z/BattleBuilder.Chunks.Settings.chunk_size_z)
	return chunk_x, chunk_y, chunk_z
end


local BlockPhysGroups = {}
local BlockPhysGroupsIsStatic = {}
local DataGroup = {}
local NeedCheck = {}
local CalcCounter = 0
local CachedBlocksPos = {}
local IgnoreBlocksOnCalcPhys = {}

function BattleBuilder.Chunks:CheckNeighboursStatic(block_x, block_y, block_z, group_id)
	if BlockPhysGroupsIsStatic[group_id] then

		--[[ local locale_group_id = DataGroup[GetVoxelIndex_ByXYZ(block_x-1,block_y,block_z)]
		if locale_group_id != nil then BlockPhysGroupsIsStatic[locale_group_id] = BlockPhysGroupsIsStatic[group_id] end

		locale_group_id = DataGroup[GetVoxelIndex_ByXYZ(block_x,block_y-1,block_z)]
		if locale_group_id != nil then BlockPhysGroupsIsStatic[locale_group_id] = BlockPhysGroupsIsStatic[group_id] end
		locale_group_id = DataGroup[GetVoxelIndex_ByXYZ(block_x,block_y,block_z-1)]
		if locale_group_id != nil then BlockPhysGroupsIsStatic[locale_group_id] = BlockPhysGroupsIsStatic[group_id] end

		locale_group_id = DataGroup[GetVoxelIndex_ByXYZ(block_x,block_y+1,block_z)]
		if locale_group_id != nil then BlockPhysGroupsIsStatic[locale_group_id] = BlockPhysGroupsIsStatic[group_id] end
		locale_group_id = DataGroup[GetVoxelIndex_ByXYZ(block_x,block_y,block_z+1)]
		if locale_group_id != nil then BlockPhysGroupsIsStatic[locale_group_id] = BlockPhysGroupsIsStatic[group_id] end
		locale_group_id = DataGroup[GetVoxelIndex_ByXYZ(block_x+1,block_y,block_z)]
		if locale_group_id != nil then BlockPhysGroupsIsStatic[locale_group_id] = BlockPhysGroupsIsStatic[group_id] end --]] 
 
		return true
	end
	if block_z == 0 then
		BlockPhysGroupsIsStatic[group_id] = true

		return true
	else
		local is_blockd = BlockPhysGroupsIsStatic[DataGroup[GetVoxelIndex_ByXYZ(block_x-1,block_y,block_z)]] or
		BlockPhysGroupsIsStatic[DataGroup[GetVoxelIndex_ByXYZ(block_x,block_y-1,block_z)]] or
		BlockPhysGroupsIsStatic[DataGroup[GetVoxelIndex_ByXYZ(block_x,block_y,block_z-1)]] or
		BlockPhysGroupsIsStatic[DataGroup[GetVoxelIndex_ByXYZ(block_x+1,block_y,block_z)]] or
		BlockPhysGroupsIsStatic[DataGroup[GetVoxelIndex_ByXYZ(block_x,block_y+1,block_z)]] or
		BlockPhysGroupsIsStatic[DataGroup[GetVoxelIndex_ByXYZ(block_x,block_y,block_z+1)]]
		if is_blockd then
			BlockPhysGroupsIsStatic[group_id] = is_blockd
			return is_blockd
		end
		
	end
end
function BattleBuilder.Chunks:SetupBlockPhysGroup(block_x, block_y, block_z, group_id, VoxelID)
	
	CalcCounter = CalcCounter + 1

	if CalcCounter == 10000 then
		CalcCounter = 0
		coroutine.yield()
	end



	if VoxelID == nil then
		VoxelID = GetVoxelIndex_ByXYZ(block_x,block_y,block_z)
	end

	if DataGroup[VoxelID] != nil then 
		self:CheckNeighboursStatic(block_x,block_y,block_z, DataGroup[VoxelID])
		return 
	end
	if IgnoreBlocksOnCalcPhys[VoxelID] or !BattleBuilder.Chunks:VoxelIsVisible(nil,nil,nil, VoxelID) then return end



	if group_id == nil then

		group_id = DataGroup[GetVoxelIndex_ByXYZ(block_x+1,block_y,block_z)] or 
		DataGroup[GetVoxelIndex_ByXYZ(block_x,block_y-1,block_z)] or 
		DataGroup[GetVoxelIndex_ByXYZ(block_x,block_y+1,block_z)] or 
		DataGroup[GetVoxelIndex_ByXYZ(block_x,block_y,block_z-1)] or 
		DataGroup[GetVoxelIndex_ByXYZ(block_x,block_y,block_z+1)] or
		DataGroup[VoxelID] or 
		VoxelID 
	end


	if BlockPhysGroupsIsStatic[group_id] == nil then
		BlockPhysGroupsIsStatic[group_id] = false
	end


	--[[ if self:CheckNeighboursStatic(block_x,block_y,block_z, group_id) then
		--return
	end--]] 

	if block_z == 0 then
		BlockPhysGroupsIsStatic[group_id] = true
	end



	BlockPhysGroups[group_id] = BlockPhysGroups[group_id] or {}
	BlockPhysGroups[group_id][VoxelID] = Vector(block_x, block_y, block_z)

	DataGroup[VoxelID] = group_id


	NeedCheck[#NeedCheck+1] = { [0] = Vector(block_x+1, block_y, block_z), [1] = group_id }
	NeedCheck[#NeedCheck+1] = { [0] = Vector(block_x, block_y+1, block_z), [1] = group_id }
	NeedCheck[#NeedCheck+1] = { [0] = Vector(block_x, block_y, block_z+1), [1] = group_id }
	NeedCheck[#NeedCheck+1] = { [0] = Vector(block_x-1, block_y, block_z), [1] = group_id }
	NeedCheck[#NeedCheck+1] = { [0] = Vector(block_x, block_y-1, block_z), [1] = group_id }
	NeedCheck[#NeedCheck+1] = { [0] = Vector(block_x, block_y, block_z-1), [1] = group_id }




end



function BattleBuilder.Chunks:RemoveBlockPhysGroup(block_x, block_y, block_z, group_id, VoxelID)
		
	if VoxelID == nil then
		VoxelID = GetVoxelIndex_ByXYZ(block_x,block_y,block_z)
	end

		
	local group_id = BattleBuilder.Chunks.VoxelsGameStorage.DataGroup.InGame[VoxelID]
	-- print(block_x,block_y,block_z)
	for k,v in pairs(BlockPhysGroups[group_id]) do
		if k == 'minindex' then continue end
		BattleBuilder.Chunks:VoxelGameStorage_DeleteBlock(v.x,v.y,v.z, k)	
	end
	 	
	
end
 	


function BattleBuilder.Chunks:VoxelGameStorage_SetupBlock(block_x,block_y,block_z, block_color, block_type)
	-- if 1 == 1 then return end
	local VoxelID = GetVoxelIndex_ByXYZ(block_x,block_y,block_z)

	if block_type != 0 then 
		BattleBuilder.Chunks.VoxelsGameStorage.DataType.InStorageMap[VoxelID] = block_type
	end


	local ColorIndex = GetVoxelIndex_ByXYZ(block_color.r,block_color.g,block_color.b)
	--BattleBuilder.Chunks.CachedColors[ColorIndex] = block_color -- 100 + block_color.r  block_color.y block_color.z
	-- BattleBuilder.Chunks.CachedColors
	--BattleBuilder.Chunks.VoxelsGameStorage.DataColor.InStorageMap[VoxelID] = block_color

	BattleBuilder.Chunks.VoxelsGameStorage.DataColor.InGame[VoxelID] = BattleBuilder.Chunks:PackColor(block_color.r,block_color.g,block_color.b) 

	--BattleBuilder.Chunks.VoxelsGameStorage.DataColor.InGame[VoxelID] = block_color

	

	--BattleBuilder.Chunks.VoxelsGameStorage.DataType.InGame[VoxelID] = block_type

	-- BattleBuilder.Chunks.VoxelsGameStorage.DataHealth.InGame[VoxelID] = 100

	local ChunkIndex = BattleBuilder.Chunks:GetChunkIndex_ByXYZ(BattleBuilder.Chunks:VoxelGameStorage_GetBlockChunk(block_x,block_y,block_z))
	BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[ChunkIndex] = true


	--BattleBuilder.Chunks.ChunksGameStorage.ChunkVisible[ChunkIndex] = true
end



function BattleBuilder.Chunks:VoxelGameStorage_GetBlockInfo(block_x,block_y,block_z, InfoType)
	local VoxelID = GetVoxelIndex_ByXYZ(block_x,block_y,block_z)
	return BattleBuilder.Chunks.VoxelsGameStorage[InfoType].InGame[VoxelID] or BattleBuilder.Chunks.VoxelsGameStorage[InfoType].InStorageMap[VoxelID]
end
function BattleBuilder.Chunks:VoxelGameStorage_SetBlockInfo(block_x,block_y,block_z, InfoType, value)
	local VoxelID = GetVoxelIndex_ByXYZ(block_x,block_y,block_z)
	BattleBuilder.Chunks.VoxelsGameStorage[InfoType].InGame[VoxelID] = value

	local ChunkIndex = BattleBuilder.Chunks:GetChunkIndex_ByXYZ(BattleBuilder.Chunks:VoxelGameStorage_GetBlockChunk(block_x,block_y,block_z))
	BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[ChunkIndex] = true
end
function BattleBuilder.Chunks:VoxelGameStorage_ResetBlock(block_x,block_y,block_z)
	local VoxelID = GetVoxelIndex_ByXYZ(block_x,block_y,block_z)
	BattleBuilder.Chunks.VoxelsGameStorage.DataColor.InGame[VoxelID] = nil
	BattleBuilder.Chunks.VoxelsGameStorage.DataType.InGame[VoxelID] = nil
	BattleBuilder.Chunks.VoxelsGameStorage.DataHealth.InGame[VoxelID] = 100

	local ChunkIndex = BattleBuilder.Chunks:GetChunkIndex_ByXYZ(BattleBuilder.Chunks:VoxelGameStorage_GetBlockChunk(block_x,block_y,block_z))
	BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[ChunkIndex] = true
end

function BattleBuilder.Chunks:VoxelGameStorage_CreateBlock(block_x,block_y,block_z, VoxelID, block_color)

	if !BattleBuilder.Chunks:Voxel_IS_IN(block_x,block_y,block_z) then return end

	local VoxelID = VoxelID or GetVoxelIndex_ByXYZ(block_x,block_y,block_z)

	-- local ColorIndex = GetVoxelIndex_ByXYZ(block_color.r,block_color.g,block_color.b)
	-- BattleBuilder.Chunks.CachedColors[ColorIndex] = 1

	BattleBuilder.Chunks.ChunksGameStorage.CachedVoxelsVertex[VoxelID] = false


	BattleBuilder.Chunks.VoxelsGameStorage.DataColor.InGame[VoxelID] = BattleBuilder.Chunks:PackColor(block_color.r,block_color.g,block_color.b)  -- Color(255,255,255)
	BattleBuilder.Chunks.VoxelsGameStorage.DataType.InGame[VoxelID] = 0
	BattleBuilder.Chunks.VoxelsGameStorage.DataHealth.InGame[VoxelID] = nil

	IgnoreBlocksOnCalcPhys[VoxelID] = true

	self:VoxelGameStorage_UpdateChunkAfterBlockEditing(block_x,block_y,block_z, true)
end


function BattleBuilder.Chunks:VoxelGameStorage_DeleteBlock(block_x,block_y,block_z, VoxelID, dontcheck_flying, net_sync)

	local VoxelID = VoxelID or GetVoxelIndex_ByXYZ(block_x,block_y,block_z)

	BattleBuilder.Chunks.VoxelsGameStorage.DataColor.InGame[VoxelID] = nil
	BattleBuilder.Chunks.VoxelsGameStorage.DataType.InGame[VoxelID] = nil
	BattleBuilder.Chunks.VoxelsGameStorage.DataHealth.InGame[VoxelID] = nil

	BattleBuilder.Chunks.ChunksGameStorage.CachedVoxelsVertex[VoxelID] = false
	

	self:VoxelGameStorage_UpdateChunkAfterBlockEditing(block_x,block_y,block_z, false)
end

--[[ function BattleBuilder.Chunks:UpdateLocalVoxel(voxel_x, voxel_y, voxel_z, chunk_index, chunk_x, chunk_y, chunk_z)
	if voxel_x > 0 then BattleBuilder.Chunks:SetVoxelNeedUpdate(voxel_x-1,voxel_y,voxel_z,chunk_index)
	elseif chunk_x > 0 then BattleBuilder.Chunks:SetVoxelNeedUpdate(BattleBuilder.Chunks.World.Vars.chunk_size_x_of1, voxel_y, voxel_z, BattleBuilder.Chunks:GetChunkIndex_ByXYZ(chunk_x-1, chunk_y, chunk_z), true) end
	
	if voxel_x < BattleBuilder.Chunks.World.Vars.chunk_size_x_of1 then BattleBuilder.Chunks:SetVoxelNeedUpdate(voxel_x+1,voxel_y,voxel_z,chunk_index) 
	elseif chunk_x < BattleBuilder.Chunks.Settings.chunks_counts_x-1 then BattleBuilder.Chunks:SetVoxelNeedUpdate(0, voxel_y, voxel_z, BattleBuilder.Chunks:GetChunkIndex_ByXYZ(chunk_x+1, chunk_y, chunk_z), true) end


	if voxel_y > 0 then BattleBuilder.Chunks:SetVoxelNeedUpdate(voxel_x,voxel_y-1,voxel_z,chunk_index)
	elseif chunk_y > 0 then BattleBuilder.Chunks:SetVoxelNeedUpdate(voxel_x, BattleBuilder.Chunks.World.Vars.chunk_size_y_of1, voxel_z, BattleBuilder.Chunks:GetChunkIndex_ByXYZ(chunk_x, chunk_y-1, chunk_z), true) end

	if voxel_y < BattleBuilder.Chunks.World.Vars.chunk_size_y_of1 then BattleBuilder.Chunks:SetVoxelNeedUpdate(voxel_x,voxel_y+1,voxel_z,chunk_index)
	elseif chunk_y < BattleBuilder.Chunks.Settings.chunks_counts_y-1 then BattleBuilder.Chunks:SetVoxelNeedUpdate(voxel_x, 0, voxel_z, BattleBuilder.Chunks:GetChunkIndex_ByXYZ(chunk_x, chunk_y+1, chunk_z), true) end

	if voxel_z > 0 then BattleBuilder.Chunks:SetVoxelNeedUpdate(voxel_x,voxel_y,voxel_z-1,chunk_index)
	elseif chunk_z > 0 then BattleBuilder.Chunks:SetVoxelNeedUpdate(voxel_x, voxel_y, BattleBuilder.Chunks.World.Vars.chunk_size_z_of1, BattleBuilder.Chunks:GetChunkIndex_ByXYZ(chunk_x, chunk_y, chunk_z-1), true) end

	if voxel_z < BattleBuilder.Chunks.World.Vars.chunk_size_z_of1 then BattleBuilder.Chunks:SetVoxelNeedUpdate(voxel_x,voxel_y,voxel_z+1,chunk_index)
	elseif chunk_z < BattleBuilder.Chunks.Settings.chunks_counts_z-1 then BattleBuilder.Chunks:SetVoxelNeedUpdate(voxel_x, voxel_y, 0, BattleBuilder.Chunks:GetChunkIndex_ByXYZ(chunk_x, chunk_y, chunk_z+1), true) end 


	BattleBuilder.Chunks:PreBuildChunk(chunk_index, true)


end--]] 



-- Функция для удаления соседних вокселей, используя алгоритм обхода в ширину


local is_calcing_air_block = false
local current_calced_air_blocks = {}
function removeConnectedVoxels(sx, sy, sz)
    

    local minz = nil


    local query = {
    	[1] = {sx,sy,sz},-- Vector(sx,sy,sz),
    }	 

    local _tableToCheckIsValidBlocks = BattleBuilder.Chunks.VoxelsGameStorage.DataColor.InGame



	local to_delete = {}

	local count = 0
    while (#query > 0) do


    	    	
    	local x,y,z = unpack(query[#query]) --query[#query]:Unpack()

    	local VoxelID = GetVoxelIndex_ByXYZ(x,y,z)

    	query[#query] = nil
	    if current_calced_air_blocks[VoxelID] then continue end
	    current_calced_air_blocks[VoxelID] = true
	    local VoxelIsHave = _tableToCheckIsValidBlocks[VoxelID] != nil
	    

	    if !VoxelIsHave then continue end
	    to_delete[#to_delete+1] = VoxelID

	    if minz == nil then
	    	minz = z
	    else
	    	if z < minz then
	    		minz = z
	    	end
	    end

	    query[#query+1] = {x+1,y,z}
	    query[#query+1] = {x-1,y,z}
	    query[#query+1] = {x,y+1,z}
	    query[#query+1] = {x,y-1,z}
	    query[#query+1] = {x,y,z+1}
	    query[#query+1] = {x,y,z-1}

	    count = count + 1

	    if count == 600 then
	    	coroutine.yield()
	    	count = 0
	    end

	    continue	
    end

    
    if minz != nil then
    	if minz > 0 then
    		for k,v in pairs(to_delete) do
    			--BattleBuilder.Chunks:VoxelGameStorage_DeleteBlock(block_x,block_y,block_z, VoxelID, dontcheck_flying, net_sync)
    			BattleBuilder.Chunks.VoxelsGameStorage.DataColor.InGame[v] = nil
    		end			
    	end
    end

    coroutine.wait(.02)
end


local CheckAndDeleteAirBlocks = {}

local co_f_CheckAndDeleteAirBlocks = function()

	while (true) do

		local len = #CheckAndDeleteAirBlocks
		if len == 0 then 
			coroutine.wait(0.05) 
			coroutine.yield()
			continue
		end


		local x,y,z = unpack(table.remove(CheckAndDeleteAirBlocks, 1))

		

		table.Empty(current_calced_air_blocks)

		is_calcing_air_block = true

		removeConnectedVoxels(x+1,y,z)
		removeConnectedVoxels(x-1,y,z)
		removeConnectedVoxels(x,y+1,z)
		removeConnectedVoxels(x,y-1,z)
		removeConnectedVoxels(x,y,z+1)
		removeConnectedVoxels(x,y,z-1) 
		is_calcing_air_block = false
		coroutine.wait(0.1)
		coroutine.yield()
	end	
end
local co_act_CheckAndDeleteAirBlocks

hook.Add("Think", "DeleteAirBlocks", function()
	co_act_CheckAndDeleteAirBlocks = co_act_CheckAndDeleteAirBlocks or coroutine.create(co_f_CheckAndDeleteAirBlocks)

	coroutine.resume(co_act_CheckAndDeleteAirBlocks)
end)

function RemoveAirVoxels(x,y,z)
	--[[ if is_calcing_air_block then
		if current_calced_air_blocks[GetVoxelIndex_ByXYZ(x,y,z)] == nil then
			return
		end
	end--]] 
	
	CheckAndDeleteAirBlocks[#CheckAndDeleteAirBlocks+1] = {x,y,z}
end

function BattleBuilder.Chunks:VoxelGameStorage_UpdateChunkAfterBlockEditing(block_x,block_y,block_z, add_block)
	local block_local_x, block_local_y, block_local_z, ChunkX, ChunkY, ChunkZ = BattleBuilder.Chunks:Voxel_GetLocalXYZByReal(block_x,block_y,block_z) 





	local ChunkIndex = BattleBuilder.Chunks:GetChunkIndex_ByXYZ(ChunkX, ChunkY, ChunkZ) -- BattleBuilder.Chunks:VoxelGameStorage_GetBlockChunk(block_x,block_y,block_z))
	BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[ChunkIndex] = true

	if !add_block then
		RemoveAirVoxels(block_x,block_y,block_z)
	end
--[[ 		
	if add_block then
		BattleBuilder.Chunks.ChunksGameStorage.CubesCounter[ChunkIndex] = BattleBuilder.Chunks.ChunksGameStorage.CubesCounter[ChunkIndex] + 1

		local group_id = BattleBuilder.Chunks.VoxelsGameStorage.DataGroup.InGame[VoxelID]
		if block_local_z < BlockPhysGroups[group_id]['minindex'] then
			BlockPhysGroups[group_id]['minindex'] = block_local_z
		end
	elseif !add_block then
		--['minindex'] = block_z
		BattleBuilder.Chunks.ChunksGameStorage.CubesCounter[ChunkIndex] = BattleBuilder.Chunks.ChunksGameStorage.CubesCounter[ChunkIndex] - 1
	end--]] 

	if block_local_x == BattleBuilder.Chunks.World.Vars.chunk_size_x_of1 then
		BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[BattleBuilder.Chunks:GetChunkIndex_ByXYZ(ChunkX+1, ChunkY, ChunkZ)] = true
	elseif block_local_x == 0 then 
		BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[BattleBuilder.Chunks:GetChunkIndex_ByXYZ(ChunkX-1, ChunkY, ChunkZ)] = true		
	end
	
	

	if block_local_y == BattleBuilder.Chunks.World.Vars.chunk_size_y_of1 then
		BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[BattleBuilder.Chunks:GetChunkIndex_ByXYZ(ChunkX, ChunkY+1, ChunkZ)] = true

	elseif block_local_y == 0 then
		BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[BattleBuilder.Chunks:GetChunkIndex_ByXYZ(ChunkX, ChunkY-1, ChunkZ)] = true

	end

	if block_local_z == BattleBuilder.Chunks.World.Vars.chunk_size_z_of1 then
		BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[BattleBuilder.Chunks:GetChunkIndex_ByXYZ(ChunkX, ChunkY, ChunkZ+1)] = true

	elseif block_local_z == 0 then
		BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[BattleBuilder.Chunks:GetChunkIndex_ByXYZ(ChunkX, ChunkY, ChunkZ-1)] = true
	end 

	BattleBuilder.Chunks.ChunksGameStorage.CachedVoxelsVertex[GetVoxelIndex_ByXYZ(block_x-1,block_y,block_z)] = false -- uno optimizato
	BattleBuilder.Chunks.ChunksGameStorage.CachedVoxelsVertex[GetVoxelIndex_ByXYZ(block_x+1,block_y,block_z)] = false -- uno optimizato
	BattleBuilder.Chunks.ChunksGameStorage.CachedVoxelsVertex[GetVoxelIndex_ByXYZ(block_x,block_y-1,block_z)] = false -- uno optimizato
	BattleBuilder.Chunks.ChunksGameStorage.CachedVoxelsVertex[GetVoxelIndex_ByXYZ(block_x,block_y+1,block_z)] = false -- uno optimizato
	BattleBuilder.Chunks.ChunksGameStorage.CachedVoxelsVertex[GetVoxelIndex_ByXYZ(block_x,block_y,block_z-1)] = false -- uno optimizato
	BattleBuilder.Chunks.ChunksGameStorage.CachedVoxelsVertex[GetVoxelIndex_ByXYZ(block_x,block_y,block_z+1)] = false -- uno optimizato


end


BattleBuilder.Chunks.World.ChunksToPrebuild = {}
BattleBuilder.Chunks.World.ChunksToPrebuildIndexer = {}

local LastPrebuildPriority = 0
local NextPriorityTask = 1



timer.Create("BattleBuilder_CheckGarbage", 5, 0, function()
	if 1 == 1 then return end
	local garbage = collectgarbage( "count" )
	if garbage > 1000000 then -- 1 gb == 1048576
		collectgarbage( "step", 2)
	end


	--[[ if 1 == 1 then return end
	local chunk_rebuilt_data = BattleBuilder.Chunks.World.ChunksToPrebuild[NextPriorityTask]
	if chunk_rebuilt_data != nil then

		local chunk = BattleBuilder.Chunks.World.Chunks[chunk_rebuilt_data.chunk_index]
		BattleBuilder.Chunks:PreBuildChunk(chunk_rebuilt_data.chunk_pos, chunk_rebuilt_data.chunk_index, true)
		BattleBuilder.Chunks.World.ChunksToPrebuild[NextPriorityTask] = nil
		BattleBuilder.Chunks.World.ChunksToPrebuildIndexer[chunk_rebuilt_data.chunk_index] = nil
		NextPriorityTask = NextPriorityTask + 1	
	else
		LastPrebuildPriority = 0
		NextPriorityTask = 1 
	end--]] 
end)



local active_co_prebuildchunks_ch_id = nil
local co_prebuildchunks
hook.Add( "Think", "BattleBuilder_PreBuildChunks", function()
	local chunk_rebuilt_data = BattleBuilder.Chunks.World.ChunksToPrebuild[NextPriorityTask]
	if chunk_rebuilt_data != nil then
		if co_prebuildchunks == nil then
			co_prebuildchunks = coroutine.create(BattleBuilder.Chunks.PreBuildChunk)
			active_co_prebuildchunks_ch_id = chunk_rebuilt_data.chunk_index
		else
			local status, args = coroutine.resume(co_prebuildchunks, nil, chunk_rebuilt_data.chunk_pos, chunk_rebuilt_data.chunk_index,true )
			if args == 4 then
				BattleBuilder.Chunks.World.ChunksToPrebuild[NextPriorityTask] = nil
				BattleBuilder.Chunks.World.ChunksToPrebuildIndexer[chunk_rebuilt_data.chunk_index] = nil
				NextPriorityTask = NextPriorityTask + 1	
				co_prebuildchunks = nil
				active_co_prebuildchunks_ch_id = nil
			end
			if !status then
				print(args)
				co_prebuildchunks = nil
			end
		end
		--local status = BattleBuilder.Chunks:PreBuildChunk(chunk_rebuilt_data.chunk_pos, chunk_rebuilt_data.chunk_index, true)
	else
		LastPrebuildPriority = 0
		NextPriorityTask = 1 
	end
end )

local pre_builded_chunk_table = {}



function BattleBuilder.Chunks:AddChunkToPreBuild(ChunkPos,chunk_index)

	if BattleBuilder.Chunks.World.ChunksToPrebuildIndexer[chunk_index] != nil then
		return
	end
	LastPrebuildPriority = LastPrebuildPriority + 1

	BattleBuilder.Chunks.World.ChunksToPrebuild[LastPrebuildPriority] = BattleBuilder.Chunks.World.ChunksToPrebuild[LastPrebuildPriority] or {
		chunk_index = chunk_index,
		chunk_pos = ChunkPos,
	}

	BattleBuilder.Chunks.World.ChunksToPrebuildIndexer[chunk_index] = LastPrebuildPriority
end


local def_PrebuildedMeshBuildInfo_voxel_Index = {
	real_voxel_id = 0,
	vertex_count = 0,
	vertexes = {},
	need_update = false,
	visibles = {
		front = false,
		back = false,
		left = false,
		right = false,
		up = false,
		down = false,
	},
	voxel_color = Color(255,255,255) 
}

function BattleBuilder.Chunks:PreBuildChunk( ChunkLocalePos, chunk_index, BuildMesh )



	--[[ local args = { ... } 
	local ChunkLocalePos = args.ChunkLocalePos 
	local chunk_index = args.chunk_index 
	local BuildMesh = args.BuildMesh--]] 
	local self = BattleBuilder.Chunks


	local _ChunksGameStorage =  self.ChunksGameStorage

	if _ChunksGameStorage.NeedVisLisUpdate[chunk_index] == nil then
		return 4
	end
	if _ChunksGameStorage.RenderVisibleListIndexer[chunk_index] == nil then
		return 4
	end 

	local ReBuild = _ChunksGameStorage.PrebuildedMeshes[chunk_index] != nil



	if !ReBuild then
		_ChunksGameStorage.PrebuildedMeshesBuildInfo[chunk_index] = {}
	end
	local PrebuildedMeshBuildInfo = _ChunksGameStorage.PrebuildedMeshesBuildInfo[chunk_index]

	--[[ if _ChunksGameStorage.CubesCounter[chunk_index] == 0 then
		_ChunksGameStorage.NeedVisLisUpdate[chunk_index] = false
		_ChunksGameStorage.ChunkVisible[chunk_index] = false
		return 4
	end--]] 

	

	-- if _ChunksGameStorage.PrebuildedMeshes[chunk_index] != nil 

	if BuildMesh != true then 
		self:AddChunkToPreBuild(ChunkLocalePos,chunk_index) -- ВОТ ЭТО ВКЛЮЧИТЬ ЧТОБЫ РАБОТАЛО НОРМ
		return 4
	end

		

--	pre_builded_chunk_table = {}
	
	_ChunksGameStorage.NeedVisLisUpdate[chunk_index] = false

	local chunk_x,chunk_y,chunk_z = ChunkLocalePos.x, ChunkLocalePos.y, ChunkLocalePos.z

	local w_chunk_x, w_chunk_y, w_chunk_z = chunk_x*self.Settings.chunk_size_x, chunk_y*self.Settings.chunk_size_y, chunk_z*self.Settings.chunk_size_z


	local chunk_real_pos = self:GetChunkVertexPos(chunk_x,chunk_y,chunk_z)

	local counter = 0


	for x = 0, self.Settings.chunk_size_x-1 do

		for y = 0, self.Settings.chunk_size_y-1 do
			for z = 0, self.Settings.chunk_size_z-1 do
				counter =  counter + 1
				local voxed_index = (y*self.Settings.chunk_size_z+z)*self.Settings.chunk_size_x+x

				


				local real_x, real_y, real_z = w_chunk_x+x, w_chunk_y+y, w_chunk_z+z

				local ThisVoxelIndex = GetVoxelIndex_ByXYZ(real_x, real_y, real_z)
				
				local VoxelIsAlreadyCached = _ChunksGameStorage.CachedVoxelsVertex[ThisVoxelIndex]

				if VoxelIsAlreadyCached == true then
					continue
				else
					_ChunksGameStorage.CachedVoxelsVertex[ThisVoxelIndex] = true
				end

				local voxel_render_storage_table = PrebuildedMeshBuildInfo[voxed_index]


				local VoxelVisible = self:VoxelIsVisible(nil,nil,nil, ThisVoxelIndex)

 				if VoxelVisible == false then 
 					if voxel_render_storage_table then
 						voxel_render_storage_table.skip = true
 					end
					continue 
				end 


				local vertex_count = 0
				local show_front = false
				local show_back = false
				local show_left = false
				local show_right = false
				local show_up = false
				local show_down = false




				if show_up == false && !self:VoxelIsVisible(real_x,real_y,real_z+1) then show_up = true vertex_count = vertex_count + 6  end
				
				if show_down == false && !self:VoxelIsVisible(real_x,real_y,real_z-1) then show_down = true vertex_count = vertex_count + 6 end

				if show_front == false && !self:VoxelIsVisible(real_x,real_y+1,real_z) then show_front = true vertex_count = vertex_count + 6 end

				if show_back == false && !self:VoxelIsVisible(real_x,real_y-1,real_z) then show_back = true vertex_count = vertex_count + 6 end

				if show_left == false && !self:VoxelIsVisible(real_x+1,real_y,real_z) then show_left = true vertex_count = vertex_count + 6 end

				if show_right == false && !self:VoxelIsVisible(real_x-1,real_y,real_z) then show_right = true vertex_count = vertex_count + 6 end
 	

				
					
				if vertex_count == 0 then 
					--[[ if ReBuild then
						pre_builded_chunk_table[voxed_index] = nil
					end--]] 

					if voxel_render_storage_table then
						voxel_render_storage_table.skip = true
					end

					continue 
				end





				if voxel_render_storage_table == nil then

					PrebuildedMeshBuildInfo[voxed_index] = table.Copy(def_PrebuildedMeshBuildInfo_voxel_Index)

					voxel_render_storage_table = PrebuildedMeshBuildInfo[voxed_index]

					voxel_render_storage_table.real_voxel_id = ThisVoxelIndex

					voxel_render_storage_table.voxel_color = self:UnpackColor(self.VoxelsGameStorage.DataColor.InGame[ThisVoxelIndex], true)
					voxel_render_storage_table.update_draw_side_color = true
					voxel_render_storage_table.draw_side_colors = {}

					--[[ local r,g,b = self:UnpackColor(self.VoxelsGameStorage.DataColor.InGame[ThisVoxelIndex], true)
					PrebuildedMeshBuildInfo[voxed_index].voxel_color.r = r
					PrebuildedMeshBuildInfo[voxed_index].voxel_color.g = g
					PrebuildedMeshBuildInfo[voxed_index].voxel_color.b = b--]] 

					--[[ PrebuildedMeshBuildInfo[voxed_index] = {
						real_voxel_id = ThisVoxelIndex,
						vertex_count = vertex_count,
						vertexes = {},
						need_update = need_update,
						visibles = {
							front = show_front,
							back = show_back,
							left = show_left,
							right = show_right,
							up = show_up,
							down = show_down,
						},
						voxel_color = self:UnpackColor(self.VoxelsGameStorage.DataColor.InGame[ThisVoxelIndex]) 
					}--]] 
				end

				if VoxelIsAlreadyCached then
					voxel_render_storage_table.update_draw_side_color = true
				end

				table.Empty(voxel_render_storage_table.vertexes)

				voxel_render_storage_table.vertex_count = vertex_count

				--voxel_render_storage_table.need_update = need_update

				voxel_render_storage_table.visibles.up = show_up
				voxel_render_storage_table.visibles.down = show_down
				voxel_render_storage_table.visibles.front = show_front
				voxel_render_storage_table.visibles.back = show_back
				voxel_render_storage_table.visibles.left = show_left
				voxel_render_storage_table.visibles.right = show_right

				
				


				--local VoxelID = v.real_voxel_id
				--local VoxelColor = self:UnpackColor(self.VoxelsGameStorage.DataColor.InGame[VoxelID]) 

				

				if voxel_render_storage_table.update_draw_side_color then
					voxel_render_storage_table.update_draw_side_color = false

					local r,g,b = voxel_render_storage_table.voxel_color.r,voxel_render_storage_table.voxel_color.g,voxel_render_storage_table.voxel_color.b


					--if show_up then
						voxel_render_storage_table.draw_side_colors[BattleBuilder_Enum_CubeSides.up] = voxel_render_storage_table.voxel_color
					--end 

					--if show_down then
						voxel_render_storage_table.draw_side_colors[BattleBuilder_Enum_CubeSides.down] = Color(r*0.3,g*0.3,b*0.3)
					--end 

					--if show_right then
						voxel_render_storage_table.draw_side_colors[BattleBuilder_Enum_CubeSides.right] = Color(r*0.95,g*0.95,b*0.95)
					--end 

					--if show_left then
						voxel_render_storage_table.draw_side_colors[BattleBuilder_Enum_CubeSides.left] = Color(r*0.98,g*0.98,b*0.98)
					--end 

					--if show_front then
						voxel_render_storage_table.draw_side_colors[BattleBuilder_Enum_CubeSides.front] = Color(r*0.93,g*0.93,b*0.93)
					--end 
					--if show_back then
						voxel_render_storage_table.draw_side_colors[BattleBuilder_Enum_CubeSides.back] = Color(r*0.99,g*0.99,b*0.99)
					--end 
				end

				if show_up then 
					self:GetVertexesPosFromTable(x,y,z, BattleBuilder_Enum_CubeSides.up, voxel_render_storage_table, chunk_real_pos) 
				end
				if show_down then 
					self:GetVertexesPosFromTable(x,y,z, BattleBuilder_Enum_CubeSides.down, voxel_render_storage_table, chunk_real_pos) 
				end
				if show_right then 
					self:GetVertexesPosFromTable(x,y,z, BattleBuilder_Enum_CubeSides.right, voxel_render_storage_table, chunk_real_pos) 
				end
				if show_left then 
					self:GetVertexesPosFromTable(x,y,z, BattleBuilder_Enum_CubeSides.left, voxel_render_storage_table, chunk_real_pos) 
				end
				if show_front then 
					self:GetVertexesPosFromTable(x,y,z, BattleBuilder_Enum_CubeSides.front, voxel_render_storage_table, chunk_real_pos) 
				end
				if show_back then 
					self:GetVertexesPosFromTable(x,y,z, BattleBuilder_Enum_CubeSides.back, voxel_render_storage_table, chunk_real_pos) 
				end

				voxel_render_storage_table.skip = false


				if counter > 525 then
					-- coroutine.yield() !!!!!!!!!!!!!!!! ТУТ ЧТОБЫ НЕ ЛАГАЛО УБРАТЬ ДВЕ ТОЧКАИ
					counter = 0
				end
			
			end
		end	

		-- coroutine.wait(0.00001)
	end


	


	if CLIENT then

		local chunk_mesh = _ChunksGameStorage.PrebuildedMeshes[chunk_index]
		

		if chunk_mesh != nil then
			chunk_mesh:Destroy()
		end 

		
		local mesh_vertexes = {}
		local count_vertexes = 0
		local save_table = {}
		for k,v in pairs(PrebuildedMeshBuildInfo) do
			if v.skip then continue end
			count_vertexes = count_vertexes + v.vertex_count
			--local VoxelColor = Color(math.random(0,255), math.random(0,255), math.random(0,255)) -- self.CachedColors[ColorIndex]

			
			for k2, v2 in pairs(v.vertexes) do									
				if v2.precalced == nil then
					v2.precalced = {pos = v2.pos,u=v2.tex_u,v = v2.tex_v, color = v2.linked_color}					
				end
				mesh_vertexes[#mesh_vertexes+1] = v2.precalced
			end
		end


		if #mesh_vertexes == 0 then
			_ChunksGameStorage.PrebuildedMeshes[chunk_index] = nil
			_ChunksGameStorage.ChunkVisible[chunk_index] = false
			return 4
		else
			_ChunksGameStorage.ChunkVisible[chunk_index] = true
		end
		chunk_mesh = Mesh(Material(Used_Cube_Material))
		chunk_mesh:BuildFromTriangles(mesh_vertexes)	
		_ChunksGameStorage.PrebuildedMeshes[chunk_index] = chunk_mesh



		--pre_builded_chunk_table = nil
	end
	return 4
	-- collectgarbage("step", 1)
end


function BattleBuilder.Chunks:DynamicChunkRender(vertex_table)
	render.SetMaterial(Material(Used_Cube_Material))
	

	mesh.Begin( MATERIAL_TRIANGLES, vertex_table.vertex_count )
	//{pos = v2.pos,u=v2.tex_u,v = v2.tex_v, color = Color(face_color_r,face_color_g,face_color_b,255)}
	for k,v in pairs(vertex_table.vertexes) do
		mesh.Position( v.pos )
		mesh.TexCoord( 0, v.u, v.v )
		mesh.Color(v.color.r,v.color.g,v.color.b,v.color.a)
		mesh.AdvanceVertex()
	end
	mesh.End()
end


local _LoadedStorageChunks = {}
function BattleBuilder.Chunks:BuildChunkData(chunk_x,chunk_y,chunk_z,chunk_storage_id)
	local index = BattleBuilder.Chunks:GetChunkIndex_ByXYZ(chunk_x,chunk_y,chunk_z)
	BattleBuilder.Chunks.World.Chunks[index] = index
	_LoadedStorageChunks[chunk_storage_id] = _LoadedStorageChunks[chunk_storage_id] or {}
	_LoadedStorageChunks[chunk_storage_id][#_LoadedStorageChunks[chunk_storage_id]+1] = index
end


local BlockTypeInfo = {
	[0] = "IsEmpty",
	[1] = "IsLive",
	[2] = "IsProtected",
}

local BlockFunctions = {
	[1] = {
		CheckType = "SetColorR",
		WriteFunction = function()
		end,
	},
}

function BattleBuilder.Chunks:SetBlockData(block_x,block_y,block_z, func, value)


end


function BattleBuilder.Chunks:Voxel_GetLocalXYZByReal(x,y,z) 
	local chunk_x, chunk_y, chunk_z = math.floor(x/BattleBuilder.Chunks.Settings.chunk_size_x), math.floor(y/BattleBuilder.Chunks.Settings.chunk_size_y), math.floor(z/BattleBuilder.Chunks.Settings.chunk_size_z)
	local voxel_x, voxel_y, voxel_z = x-chunk_x*BattleBuilder.Chunks.Settings.chunk_size_x,y-chunk_y*BattleBuilder.Chunks.Settings.chunk_size_y,z-chunk_z*BattleBuilder.Chunks.Settings.chunk_size_z
	return voxel_x, voxel_y, voxel_z, chunk_x, chunk_y, chunk_z
end

function BattleBuilder.Chunks:GetBlockData(block_x,block_y,block_z, ReaderCallBack)
	local x,y,z = BattleBuilder.Chunks:Voxel_GetLocalXYZByReal(block_x,block_y,block_z)
	local chunk_x, chunk_y, chunk_z = math.floor(block_x/BattleBuilder.Chunks.Settings.chunk_size_x), math.floor(block_y/BattleBuilder.Chunks.Settings.chunk_size_y), math.floor(block_z/BattleBuilder.Chunks.Settings.chunk_size_z)
	local chunk_id = BattleBuilder.Chunks:GetChunkIndex_ByXYZ(chunk_x,chunk_y,chunk_z)

	local FireReader = file.Open("battlebuilder/levels/"..BattleBuilder.Game.active_level_name.."/level_game/gamechunk_".. chunk_id+1 .."_content.dat", "rb", "DATA")


	
	x = x + 1
	y = y + 1
	z = z + 1 



	local data =  (BattleBuilder.Chunks.Settings.chunk_size_z * BattleBuilder.Chunks.Settings.chunk_size_y) * (x-1) 

	local add_data =  (z-1) + BattleBuilder.Chunks.Settings.chunk_size_z * (y-1)
	
	data = (data + add_data) * 4


	FireReader:Seek( data )
	if ReaderCallBack == nil then
		local VoxelData = {}
		VoxelData.ColorIndex = FireReader:ReadShort()
		VoxelData.BlockHealth = FireReader:ReadByte()
		VoxelData.Type = FireReader:ReadByte()
		FireReader:Close()
		return VoxelData
	else
		ReaderCallBack(ReaderCallBack)
	end
	FireReader:Close()
end
function BattleBuilder.Chunks:SaveLoadedChunksToChunks(chunk_x,chunk_y,chunk_z,chunk_storage_id)
	local levelname = BattleBuilder.Game.active_level_name
	local ChunkBaseData
	for chunk_storage_id,v in pairs(_LoadedStorageChunks) do

		if file.Exists("battlebuilder/levels/"..levelname.."/level_storage_uncompressed/chunk_" .. chunk_storage_id .. "_uncompressed.dat", "DATA") != true then
			ChunkBaseData = file.Open("battlebuilder/levels/"..levelname.."/level_storage/chunk_" .. chunk_storage_id .. "_compressed.dat", "rb", "DATA")
			local ChunkBaseData_Str = util.Decompress(ChunkBaseData:Read())
			ChunkBaseData:Close()

			ChunkBaseData = file.Open("battlebuilder/levels/"..levelname.."/level_storage_uncompressed/chunk_" .. chunk_storage_id .. "_uncompressed.dat", "wb", "DATA")
			ChunkBaseData:Write(ChunkBaseData_Str)
			ChunkBaseData:Close()
		end

		ChunkBaseData = file.Open("battlebuilder/levels/"..levelname.."/level_storage_uncompressed/chunk_" .. chunk_storage_id .. "_uncompressed.dat", "rb", "DATA") 

		local ChunkDataWriter = {}
		local block_x = 0
		local block_y = 0
		local block_z = 0
		while (!ChunkBaseData:EndOfFile()) do

			--[[ local block_x = ChunkBaseData:ReadByte()
			local block_y = ChunkBaseData:ReadByte()
			local block_z = ChunkBaseData:ReadByte()--]] 

			local block_color_index = ChunkBaseData:ReadShort()

			ChunkDataWriter[block_x] = ChunkDataWriter[block_x] or {}
			ChunkDataWriter[block_x][block_y] = ChunkDataWriter[block_x][block_y] or {}
			ChunkDataWriter[block_x][block_y][block_z] = block_color_index

			block_z = block_z + 1 
			if block_z == BattleBuilder.Chunks.Settings.chunk_size_z then
				block_y = block_y + 1
				block_z = 0

				if block_y == BattleBuilder.Chunks.Settings.chunk_size_y then
					block_y = 0
					block_x = block_x + 1
				end
			end

		end
		ChunkBaseData:Close()



		ChunkBaseData = file.Open("battlebuilder/levels/"..levelname.."/level_game/gamechunk_" .. chunk_storage_id .. "_content.dat", "wb", "DATA") 
		
			
		local chunk_jsondata = {}
		for block_x, block_y_table in pairs(ChunkDataWriter) do
			chunk_jsondata[block_x] = {}
			for block_y, block_z_table in pairs(block_y_table) do
				chunk_jsondata[block_x][block_y] = {}
				for block_z, block_color_index in pairs(block_z_table) do -- will bne replace to {} block data with block type, or will be used with special-data storage for invididual settings
					--[[ 
					ChunkBaseData:WriteByte(block_x)
					ChunkBaseData:WriteByte(block_y)
					ChunkBaseData:WriteByte(block_z) 
					--]] 						 
					ChunkBaseData:WriteShort(block_color_index)
					ChunkBaseData:WriteByte(100) -- block health
					ChunkBaseData:WriteByte(1) -- block type  						 
					--[[ chunk_jsondata[block_x][block_y][block_z] = {
						block_color_index = block_color_index,
						block_health = 100,
						block_type = 1,
					}--]] 
				end
			end
		end			
		ChunkBaseData:Close()

			--file.Write( "battlebuilder/levels/"..levelname.."/level_game/gamechunk_" .. chunk_id .. "_content.dat", util.TableToJSON(chunk_jsondata) )
	end
	_LoadedStorageChunks = {}	
end

BattleBuilder.Game = {}

concommand.Add("generate_save_chekc", function()

end)

function BattleBuilder.Chunks:ImportLevelFromVXLAOS(level_name)

	local vxl_map_reader = file.Open("battlebuilder/vlx_level/ArcticBase.vxl", "rb", "DATA") 


--[[ 
one block data
0
239
239
0
88
53
7
255
--]] 
	local method_read = vxl_map_reader.ReadULong
	local this_sp
	local this_sp2
	local xv8 = 0
 	for x = 0, 511 do
		for y = 0, 511 do
			for z = 0, 63 do
					
				this_sp = vxl_map_reader:ReadULong() -- 32
				this_sp2 = vxl_map_reader:ReadULong() -- 32
				
				xv8 = this_sp2
			end
		end
	end 

	print(this_sp2)
	vxl_map_reader:Close()
	
	
	--[[ while (!vxl_map_reader:EndOfFile()) do
		print(vxl_map_reader:ReadByte())
	end--]] 
	-- BattleBuilder.Chunks:VoxelGameStorage_SetupBlock(x,y,z, Color(math.random(0,255),math.random(0,255),math.random(0,255) ), 0)
end


function BattleBuilder.Chunks:LoadLevel(level_name)
	BattleBuilder.Game = {
		active_level_name = level_name
	}

	local time = os.time() 
	local LevelChunksFile
	local BuildLevel = false

	--[[ исправить генерацию чанков, чтобы была с 0 везде до 128
	отправка инфы на клиент
	отстройка мешей
	кэширование мешей
	редактирование блоков реализовать !)--]] 
	--[[ if BuildLevel then
		if file.Exists("battlebuilder/levels/" .. level_name .. "/level_storage/level_content_decompressed.dat", "DATA") != true then
			LevelChunksFile = file.Open("battlebuilder/levels/" .. level_name .. "/level_storage/level_content_compressed.dat","rb","DATA")
			local LevelChunksData = util.Decompress(LevelChunksFile:Read())
			LevelChunksFile:Close()

			LevelChunksFile = file.Open("battlebuilder/levels/" .. level_name .. "/level_storage/level_content_decompressed.dat","wb","DATA")
			LevelChunksFile:Write(LevelChunksData)
			LevelChunksFile:Close()
		end

		LevelChunksFile = file.Open("battlebuilder/levels/" .. level_name .. "/level_storage/level_content_decompressed.dat","rb","DATA")
		_LoadedStorageChunks = {}
		while (!LevelChunksFile:EndOfFile()) do
			local chunk_x = LevelChunksFile:ReadShort()
			local chunk_y = LevelChunksFile:ReadShort()
			local chunk_z = LevelChunksFile:ReadShort()
			local chunk_storage_id = LevelChunksFile:ReadShort()

			BattleBuilder.Chunks:BuildChunkData(chunk_x,chunk_y,chunk_z,chunk_storage_id)
		end


		BattleBuilder.Chunks:SaveLoadedChunksToChunks()

		
		LevelChunksFile:Close()
	end--]] 
	
--[[ 	for x = 0, 512 do
		for y = 0, 512 do
			for z = 0, 128 do
				BattleBuilder.Chunks:VoxelGameStorage_SetupBlock(x,y,z, Color(math.random(0,255),math.random(0,255),math.random(0,255) ), 3)
			end
		end
	end--]] 

	--[[ local setuped_x = 0
	if timer.Exists("BattleBuilder_LoadLevel_PreBuild") then
		timer.Remove("BattleBuilder_LoadLevel_PreBuild")
	end
	timer.Create("BattleBuilder_LoadLevel_PreBuild", 0.05, 0, function()
		if setuped_x < 512 then

			for y = 0, 511 do
				for z = 0, 127 do
					BattleBuilder.Chunks:VoxelGameStorage_SetupBlock(setuped_x,y,z, Color(math.random(0,255),math.random(0,255),math.random(0,255) ), 3)		
				end 
			end
			print(setuped_x)
			setuped_x = setuped_x + 1
	
		else

			timer.Remove("BattleBuilder_LoadLevel_PreBuild")
		end
	end)--]] 

	local t = os.time()
	local blocks_count = 0
	local blocks_limit = 33030144

	local y_limit = 125
	local z_limit = 64
	local x_limit = 64


	local time_to_load = SysTime()
	local f = file.Open( "battlebuilder/DoubleKO.dat", "rb", "DATA" )
	

	for x = 0, 511 do
		if x <= 40 then continue end
		if x >= 100 then break end
		for y = 0, 511 do
			local z_limit = f:ReadByte()
			if z_limit == 0 then continue end
			for i = 1, z_limit  do
				local z = 63-f:ReadByte()
				local r = f:ReadByte()
				local g = f:ReadByte()
				local b = f:ReadByte()
				BattleBuilder.Chunks:VoxelGameStorage_SetupBlock(x,y,z, Color(r,g,b,0), 0)
			end
		end
	end 
	f:Close()

	print("LevelLoaded", SysTime()-time_to_load)
				
--[[ 
	for x = 0, x_limit do
		if x == 15 or x == 20 then
			continue 
		end

		for y = 0, y_limit do
			for z = 0, z_limit do

				if blocks_count == blocks_limit then 
					break
				end

				BattleBuilder.Chunks:VoxelGameStorage_SetupBlock(x,y,z, Color(math.random(0,255),math.random(0,255),math.random(0,255) ), 0)
				blocks_count = blocks_count + 1
			end
		end
	end
--]] 
	
	collectgarbage("collect")


	--[[ if CLIENT then
		for y = 0, BattleBuilder.Chunks.Settings.chunks_counts_y-1 do
			for z = 0, BattleBuilder.Chunks.Settings.chunks_counts_z-1 do
				for x = 0, BattleBuilder.Chunks.Settings.chunks_counts_x-1 do
					BattleBuilder.Chunks:PreBuildChunk(x,y,z)
				end
			end	
		end
	end--]] 

	--BattleBuilder.Chunks:GetBlockData(1,1,64)
end

function BattleBuilder.Chunks:SaveLevel(level_name) -- load level there
	
	level_name = level_name or "cube"

	local FILE = BattleBuilder.Chunks:LevelStartWrite("cube")




	for y = 0, BattleBuilder.Chunks.Settings.chunks_counts_y-1 do
		for z = 0, BattleBuilder.Chunks.Settings.chunks_counts_z-1 do
			for x = 0, BattleBuilder.Chunks.Settings.chunks_counts_x-1 do
				local index = BattleBuilder.Chunks:GetChunkIndex_ByXYZ(x,y,z)
				BattleBuilder.Chunks.World.Chunks[index] = nil
				BattleBuilder.Chunks.World.Chunks[index] = {
					voxels = BattleBuilder.Chunks:CreateChunkTable(index,x,y,z, FILE),
					chunk_info = {
						chunk_x = x,
						chunk_y = y,
						chunk_z = z,
						chunk_index = index
					},
					cache_info = {
						PlayerDistance = 0,
					},
				}
			end
		end	
	end
	BattleBuilder.Chunks:LevelEndWrite(FILE)	
	--[[ if CLIENT then
		for y = 0, BattleBuilder.Chunks.Settings.chunks_counts_y do
			for z = 0, BattleBuilder.Chunks.Settings.chunks_counts_z do
				for x = 0, BattleBuilder.Chunks.Settings.chunks_counts_x do
					local chunk_index = BattleBuilder.Chunks:GetChunkIndex_ByXYZ(x,y,z)
					BattleBuilder.Chunks:PreBuildChunk(chunk_index)
				end
			end	
		end
	end--]] 
end



local LastChunkX = 0
local LastChunkY = 0
local LastChunkZ = 0
BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleList = {}
BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleListIndexer = {}

local ct = 0

local Render_List = {
	Last_MinX,
	Last_MaxX,
	Last_MinY,
	Last_MaxY,
	Last_MinZ,
	Last_MaxZ,
	VisibleOnX = {},
	VisibleOnY = {},
	VisibleOnZ = {},
}


local VisibleChunks_X = 150
local VisibleChunks_Y = 150
local VisibleChunks_Z = 100



function BattleBuilder.Chunks:AddChunkToVisLis(ChunkPosX,ChunkPosY,ChunkPosZ)
	local ChunkID = BattleBuilder.Chunks:GetChunkIndex_ByXYZ(ChunkPosX,ChunkPosY,ChunkPosZ) 		
	if BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[ChunkID] == nil then return end
	Render_List.VisibleOnX[ChunkPosX] = Render_List.VisibleOnX[ChunkPosX] or {}
	Render_List.VisibleOnX[ChunkPosX][ChunkID] = true
	Render_List.VisibleOnY[ChunkPosY] = Render_List.VisibleOnY[ChunkPosY] or {}
	Render_List.VisibleOnY[ChunkPosY][ChunkID] = true
	Render_List.VisibleOnZ[ChunkPosZ] = Render_List.VisibleOnZ[ChunkPosZ] or {}
	Render_List.VisibleOnZ[ChunkPosZ][ChunkID] = true
	BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleListIndexer[ChunkID] = Vector(ChunkPosX,ChunkPosY,ChunkPosZ)
	
end
function BattleBuilder.Chunks:RemoveChunkFromVisList(ResetTable, Dist, ResetValue)
	if ResetValue != nil then
		if ResetTable[ResetValue] != nil then
			for ChunkIndex, _ in pairs(ResetTable[ResetValue]) do
				--[[ print(BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleListIndexer[ChunkIndex], ResetValue)
				if --]] 
				--[[ if BattleBuilder.Chunks.ChunksGameStorage.ChunkVisible[ChunkIndex] then
					if BattleBuilder.Chunks.ChunksGameStorage.PrebuildedMeshes[ChunkIndex] != nil then
						BattleBuilder.Chunks.ChunksGameStorage.PrebuildedMeshes[ChunkIndex]:Destroy()
						BattleBuilder.Chunks.ChunksGameStorage.PrebuildedMeshes[ChunkIndex] = nil
						BattleBuilder.Chunks.ChunksGameStorage.ChunkVisible[ChunkIndex] = false
						BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[ChunkIndex] = true
					end
				end--]] 
				BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleListIndexer[ChunkIndex] = nil
			end
			ResetTable[ResetValue] = {} 
		end

		--[[ BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleList[#BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleList+1] = v
		local id = BattleBuilder.Chunks:GetChunkIndex_ByXYZ(v.x, v.y, v.z) 
		if !BattleBuilder.Chunks.ChunksGameStorage.ChunkVisible[id] then
			BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[id] = true
		end--]] 

		if ResetTable == Render_List.VisibleOnX then
			local ChunkPosX = Dist == 1 && Render_List.Last_MaxX or Render_List.Last_MinX
			for ChunkPosY = Render_List.Last_MinY, Render_List.Last_MaxY do
				if ChunkPosY < 0 then continue end
				if ChunkPosY >= BattleBuilder.Chunks.Settings.chunks_counts_y then continue end
				for ChunkPosZ = Render_List.Last_MinZ, Render_List.Last_MaxZ do
					if ChunkPosZ < 0 then continue end
					if ChunkPosZ >= BattleBuilder.Chunks.Settings.chunks_counts_z then continue end
					BattleBuilder.Chunks:AddChunkToVisLis(ChunkPosX,ChunkPosY,ChunkPosZ)
				end
			end 
		elseif ResetTable == Render_List.VisibleOnY then
			local ChunkPosY = Dist == 1 && Render_List.Last_MaxY or Render_List.Last_MinY
			for ChunkPosX = Render_List.Last_MinX, Render_List.Last_MaxX do
				if ChunkPosX < 0 then continue end
				if ChunkPosX >= BattleBuilder.Chunks.Settings.chunks_counts_x then continue end
				for ChunkPosZ = Render_List.Last_MinZ, Render_List.Last_MaxZ do
					if ChunkPosZ < 0 then continue end
					if ChunkPosZ >= BattleBuilder.Chunks.Settings.chunks_counts_z then continue end
					BattleBuilder.Chunks:AddChunkToVisLis(ChunkPosX,ChunkPosY,ChunkPosZ)
				end
			end 
		elseif ResetTable == Render_List.VisibleOnZ then
			local ChunkPosZ = Dist == 1 && Render_List.Last_MaxZ or Render_List.Last_MinZ
			for ChunkPosX = Render_List.Last_MinX, Render_List.Last_MaxX do
				if ChunkPosX < 0 then continue end
				if ChunkPosX >= BattleBuilder.Chunks.Settings.chunks_counts_x then continue end
				for ChunkPosY = Render_List.Last_MinY, Render_List.Last_MaxY do
					if ChunkPosY < 0 then continue end
					if ChunkPosY >= BattleBuilder.Chunks.Settings.chunks_counts_y then continue end
					BattleBuilder.Chunks:AddChunkToVisLis(ChunkPosX,ChunkPosY,ChunkPosZ)
				end
			end 
		end 
	end
end




function BattleBuilder.Chunks:RebuildVisList(c_chunk_x, c_chunk_y, c_chunk_z)


	BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleList = {}
	BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleListIndexer = {}
	for x = -16, 16 do
		for y = -16, 16 do
			for z = -16, 16 do
				local ch_vec = Vector(x+c_chunk_x,y+c_chunk_y,z+c_chunk_z)

				local ch_id = BattleBuilder.Chunks:GetChunkIndex_ByXYZ(ch_vec.x,ch_vec.y,ch_vec.z)
				if BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[ch_id] == nil then continue end
				BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleListIndexer[ch_id] = ch_vec -- true
				BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleList[#BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleList+1] = ch_vec
			end
		end
	end
	--BattleBuilder.Chunks:AddChunkToVisLis(ChunkPosX,ChunkPosY,ChunkPosZ)
	--[[ local DistX, DistY, DistZ = c_chunk_x-LastChunkX, c_chunk_y-LastChunkY, c_chunk_z-LastChunkZ

	local ResetX, ResetY, ResetZ
	local RebuildList = false

	if Render_List.Last_MinX == nil then
		Render_List.Last_MinX = c_chunk_x - VisibleChunks_X
		Render_List.Last_MaxX = c_chunk_x + VisibleChunks_X	
		RebuildList = true
		 
	else
		if DistX != 0 then
			if DistX == -1 then
				ResetX = Render_List.Last_MaxX
			else
				ResetX = Render_List.Last_MinX
			end
			Render_List.Last_MinX = Render_List.Last_MinX + DistX
			Render_List.Last_MaxX = Render_List.Last_MaxX + DistX
		end
	end

	if Render_List.Last_MinY == nil then
		Render_List.Last_MinY = c_chunk_y - VisibleChunks_Y
		Render_List.Last_MaxY = c_chunk_y + VisibleChunks_Y	
		RebuildList = true
	else
		if DistY != 0 then
			if DistY == -1 then
				ResetY = Render_List.Last_MaxY 
			else
				ResetY = Render_List.Last_MinY 
			end
			Render_List.Last_MinY = Render_List.Last_MinY + DistY
			Render_List.Last_MaxY = Render_List.Last_MaxY + DistY
		end
	end
	

	if Render_List.Last_MinZ == nil then
		Render_List.Last_MinZ = c_chunk_z - VisibleChunks_Z
		Render_List.Last_MaxZ = c_chunk_z + VisibleChunks_Z	
		RebuildList = true
	else
		if DistZ != 0 then
			if DistZ == -1 then
				ResetZ = Render_List.Last_MaxZ 
			else
				ResetZ = Render_List.Last_MinZ
			end
			Render_List.Last_MinZ = Render_List.Last_MinZ + DistZ
			Render_List.Last_MaxZ = Render_List.Last_MaxZ + DistZ
		end
	end
	if RebuildList == true then
		for ChunkPosX = Render_List.Last_MinX, Render_List.Last_MaxX do
			if ChunkPosX < 0 then continue end
			if ChunkPosX >= BattleBuilder.Chunks.Settings.chunks_counts_x then continue end
			for ChunkPosY = Render_List.Last_MinY, Render_List.Last_MaxY do
				if ChunkPosY < 0 then continue end
				if ChunkPosY >= BattleBuilder.Chunks.Settings.chunks_counts_y then continue end
				for ChunkPosZ = Render_List.Last_MinZ, Render_List.Last_MaxZ do
					if ChunkPosZ < 0 then continue end
					if ChunkPosZ >= BattleBuilder.Chunks.Settings.chunks_counts_z then continue end

					BattleBuilder.Chunks:AddChunkToVisLis(ChunkPosX,ChunkPosY,ChunkPosZ)
				end
			end
		end
	else
		BattleBuilder.Chunks:RemoveChunkFromVisList(Render_List.VisibleOnX, DistX, ResetX)
		BattleBuilder.Chunks:RemoveChunkFromVisList(Render_List.VisibleOnY, DistY, ResetY)
		BattleBuilder.Chunks:RemoveChunkFromVisList(Render_List.VisibleOnZ, DistZ, ResetZ) 
	end--]] 

	--[[ for k,v in pairs(BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleListIndexer) do
		BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleList[#BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleList+1] = v
	end
--]] 

	 
	


--[[ 

	local last_vis = BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleList
	local old_indexer = BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleListIndexer

	BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleList = {}
	BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleListIndexer = {}

	for x = -20, 20 do
		local ChunkPosX = x+c_chunk_x
		if ChunkPosX < 0 then continue end
		if ChunkPosX >= BattleBuilder.Chunks.Settings.chunks_counts_x then continue end
		for y = -20, 20 do
			local ChunkPosY = y+c_chunk_y
			if ChunkPosY < 0 then continue end
			if ChunkPosY >= BattleBuilder.Chunks.Settings.chunks_counts_y then continue end
			for z = -10, 10 do
				local ChunkPosZ = z+c_chunk_z
				if ChunkPosZ < 0 then continue end
				if ChunkPosZ >= BattleBuilder.Chunks.Settings.chunks_counts_z then continue end


				local ChunkID = BattleBuilder.Chunks:GetChunkIndex_ByXYZ(ChunkPosX,ChunkPosY,ChunkPosZ) 


				if BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[ChunkID] == nil then continue end

				
				 if old_indexer[ChunkID] != true then
					if BattleBuilder.Chunks.ChunksGameStorage.ChunkVisible[ChunkID] then
						BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[ChunkID] = true	
					end
				end 
				BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleListIndexer[ChunkID] = true

				BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleList[#BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleList+1] = Vector(ChunkPosX,ChunkPosY,ChunkPosZ)

			end
		end
	end--]] 
end

	


function BattleBuilder.Chunks:WorldRender()

	

	render.FogColor( 255, 0 ,0 )

	local pl_pos = LocalPlayer():GetPos()

		
	local LocalPlayerPosition = BattleBuilder.World:GetGameVectorPositionFromReal(pl_pos)

	local c_chunk_x, c_chunk_y, c_chunk_z = BattleBuilder.Chunks:GetChunkPosForVoxel(LocalPlayerPosition.x,LocalPlayerPosition.y,LocalPlayerPosition.z)

	if LastChunkX != c_chunk_x or LastChunkY != c_chunk_y or LastChunkZ != c_chunk_z then
		BattleBuilder.Chunks:RebuildVisList(c_chunk_x, c_chunk_y, c_chunk_z)
	end
	render.SetMaterial(Material(Used_Cube_Material))
	for i = 1, #BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleList do
		local ChunkVec = BattleBuilder.Chunks.ChunksGameStorage.RenderVisibleList[i]
		local ChunkID = BattleBuilder.Chunks:GetChunkIndex_ByXYZ(ChunkVec.x, ChunkVec.y, ChunkVec.z) 
		if BattleBuilder.Chunks.ChunksGameStorage.NeedVisLisUpdate[ChunkID] then
			BattleBuilder.Chunks:PreBuildChunk(ChunkVec, ChunkID)
		end 
		if BattleBuilder.Chunks.ChunksGameStorage.ChunkVisible[ChunkID] then
			if BattleBuilder.Chunks.ChunksGameStorage.PrebuildedMeshes[ChunkID]:IsValid() then
				BattleBuilder.Chunks.ChunksGameStorage.PrebuildedMeshes[ChunkID]:Draw()
			end
		end
	end

	LastChunkX = c_chunk_x
	LastChunkY = c_chunk_y
	LastChunkZ = c_chunk_z
	
end
function BattleBuilder.Chunks:ChunkRender_Vertexex(prebuilder_chunk)
	for k,v in pairs(prebuilder_chunk) do
		render.SetMaterial(Material(Used_Cube_Material))
		mesh.Begin( 2, v.vertex_count )
		for k2, v2 in pairs(v.vertexes) do
			mesh.Position( v2.pos )
			mesh.TexCoord( 0, v2.tex_u, v2.tex_v )
			mesh.AdvanceVertex()
		end
		mesh.End()
	end
end

function BattleBuilder.Chunks:ChunkRender_RealTime(chunk)
	for y = 0, BattleBuilder.Chunks.Settings.chunk_size_y-1 do
		for z = 0, BattleBuilder.Chunks.Settings.chunk_size_z-1 do
			for x = 0, BattleBuilder.Chunks.Settings.chunk_size_x-1 do
				local voxel = BattleBuilder.Chunks:Voxel_GetLocal(x,y,z, chunk)
				if voxel == nil then continue end
				if !voxel.visible then continue end

				local vertex_count = 0
				local show_front = false
				local show_back = false
				local show_left = false
				local show_right = false
				local show_up = false
				local show_down = true
				if BattleBuilder.Chunks:Voxel_NotVisible(x,y,z+1, chunk) then show_up = true vertex_count = vertex_count + 6 end
				if BattleBuilder.Chunks:Voxel_NotVisible(x,y,z-1, chunk) then show_down = true vertex_count = vertex_count + 6 end
				if BattleBuilder.Chunks:Voxel_NotVisible(x,y+1,z, chunk) then show_front = true vertex_count = vertex_count + 6 end
				if BattleBuilder.Chunks:Voxel_NotVisible(x,y-1,z, chunk) then show_back = true vertex_count = vertex_count + 6 end
				if BattleBuilder.Chunks:Voxel_NotVisible(x+1,y,z, chunk) then show_left = true vertex_count = vertex_count + 6 end
				if BattleBuilder.Chunks:Voxel_NotVisible(x-1,y,z, chunk) then show_right = true vertex_count = vertex_count + 6 end
				if vertex_count == 0 then continue end
				render.SetMaterial(Material("!DEV_3"))
				mesh.Begin( 2, vertex_count )
					if show_up then BattleBuilder.Chunks:AddVertex(x,y,z,BattleBuilder.Voxel.VoxelVertexTable['up']) end
					if show_down then print("!") BattleBuilder.Chunks:AddVertex(x,y,z,BattleBuilder.Voxel.VoxelVertexTable['down']) end
					if show_right then BattleBuilder.Chunks:AddVertex(x,y,z,BattleBuilder.Voxel.VoxelVertexTable['right']) end
					if show_left then BattleBuilder.Chunks:AddVertex(x,y,z,BattleBuilder.Voxel.VoxelVertexTable['left']) end
					if show_front then BattleBuilder.Chunks:AddVertex(x,y,z,BattleBuilder.Voxel.VoxelVertexTable['front']) end
					if show_back then BattleBuilder.Chunks:AddVertex(x,y,z,BattleBuilder.Voxel.VoxelVertexTable['back']) end
				mesh.End()

			end
		end	
	end
end
