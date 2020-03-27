-- landfill is sticky, making it difficult to isolate

local table_insert = table.insert

local vectors = {}
table_insert(vectors, {0, 0})
for r = 1, 64, 1 do
	table_insert(vectors, {0, r})
	table_insert(vectors, {0, r * -1})
	table_insert(vectors, {r, 0})
	table_insert(vectors, {r * -1, 0})
end

local vectors_2 = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}

local function is_position_sticky(surface, position)
	local tile = surface.get_tile(position)
	if not tile.collides_with("resource-layer") then return end
	
	for _, v in pairs(vectors_2) do
		tile = surface.get_tile({position.x + v[1], position.y + v[2]})
		if not tile.collides_with("resource-layer") then
			return true
		end
	end
end

local function move_tile(surface, tile_name, position)	
	for key, v in pairs(vectors) do
		local p = {x = position.x + v[1], y = position.y + v[2]}

		if is_position_sticky(surface, p) then
			surface.set_tiles({{name = tile_name, position = p}}, true)
			return
		end
	end
end
	
local function sticky(surface, tiles, tile_name)
	local revert_tiles = {}
	local i = 1
	for _, placed_tile in pairs(tiles) do
		revert_tiles[i] = {name = placed_tile.old_tile.name, position = placed_tile.position}
		i = i + 1	
	end
	surface.set_tiles(revert_tiles, true)
	
	for _, placed_tile in pairs(tiles) do
		move_tile(surface, tile_name, placed_tile.position)
	end		
end

local function on_player_built_tile(event)
	if event.item.name ~= "landfill" then return end
	sticky(game.surfaces[event.surface_index], event.tiles, event.tile.name)
end

local function on_robot_built_tile(event)
	if event.item.name ~= "landfill" then return end
	sticky(event.robot.surface, event.tiles, event.tile.name)
end

local Event = require 'utils.event'
Event.add(defines.events.on_robot_built_tile, on_robot_built_tile)
Event.add(defines.events.on_player_built_tile, on_player_built_tile)