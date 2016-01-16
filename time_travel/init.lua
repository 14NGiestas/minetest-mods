local compress               = minetest.compress
local serialize	             = minetest.serialize
local get_worldpath          = minetest.get_worldpath
local floor                  = math.floor
local random                 = math.random
local decompress             = minetest.decompress
local deserialize            = minetest.deserialize
local minetest_register_node = minetest.register_node
local setting_get            = minetest.setting_get
local setting_set            = minetest.setting_set
local ls                     = minetest.get_dir_list
local mkdir                  = minetest.mkdir
local get_worldpath          = minetest.get_worldpath
local get_modpath            = minetest.get_modpath

--override the screenshot_path
w_path = get_worldpath()
mkdir(w_path.."/timetravel_data")
setting_set("screenshot_path",w_path.."/timetravel_data")

local path = get_modpath("time_travel")
minetest_register_node("time_travel:apple", {
	description = "(Gel) Apple",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_apple.png^[colorize:#22FF0088"},
	inventory_image = "default_apple.png^[colorize:#22FF0088",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0, 0.2}
	},
	groups = {fleshy = 3, dig_immediate = 3, flammable = 2,
		leafdecay = 3, leafdecay_drop = 1},
	on_use = minetest.item_eat(2),
	sounds = {
		footstep = {name = "default_grass_footstep", gain = 0.35},
		dug = {name = "default_grass_footstep", gain = 0.7},
		dig = {name = "default_dig_crumbly", gain = 0.4},
		place = {name = "default_place_node", gain = 1.0},
	},
	after_place_node = function(pos, placer, itemstack)
		if placer:is_player() then
			minetest.set_node(pos, {name = "time_travel:apple", param2 = 1})
		end
	end,
})
minetest.register_craft({
	type = "cooking",
	output = "time_travel:apple",
	recipe = "default:apple",
	cooktime = 10,
})

d = {
	n_1 = floor(random(0,1)),
	n_2 = "dot",
	n_3 = floor(random(0,9)),
	n_4 = floor(random(0,9)),
	n_5 = floor(random(0,9)),
	n_6 = floor(random(0,9)),
	n_7 = floor(random(0,9)),
	n_8 = floor(random(0,9))
}
d.n = d.n_1.."."..d.n_3..d.n_4..d.n_5..d.n_6..d.n_7..d.n_8

--WORLD LINE - number of divergence
WORLD_LINE = get_worldpath().."/timetrave_metadata.txt"
--Check if file exists else create a new one
f = io.open(WORLD_LINE,"r")
if f == nil then
	f2 = io.open(WORLD_LINE,"w")
	f2:write(compress(serialize(d)))
	io.close(f2)
else
	f = io.open(WORLD_LINE,"r")
	db = f:read("*all")
	if db then
		d = deserialize(decompress(db)) or d
	end
	f:close()
end

local function gen_tex(d)
	return { "(timetravel_texback.png^"..
		"[combine:200x200:0,0=timetravel_texback.png:"..
		"1,50=timetravel_"..d.n_1..".png:"..
		"16,50=timetravel_"..d.n_2..".png:"..
		"31,50=timetravel_"..d.n_3..".png:"..
		"46,50=timetravel_"..d.n_4..".png:"..
		"61,50=timetravel_"..d.n_5..".png:"..
		"76,50=timetravel_"..d.n_6..".png:"..
		"91,50=timetravel_"..d.n_7..".png:"..
		"106,50=timetravel_"..d.n_8..".png^timetravel_texfront.png)^[transformFX"
	,

		"timetravel_texback.png^"..			
		"[combine:200x200:0,0=timetravel_texback.png:"..
		"1,50=timetravel_"..d.n_1..".png:"..
		"16,50=timetravel_"..d.n_2..".png:"..
		"31,50=timetravel_"..d.n_3..".png:"..
		"46,50=timetravel_"..d.n_4..".png:"..
		"61,50=timetravel_"..d.n_5..".png:"..
		"76,50=timetravel_"..d.n_6..".png:"..
		"91,50=timetravel_"..d.n_7..".png:"..
		"106,50=timetravel_"..d.n_8..".png^timetravel_texfront.png"
	}
end

local function time_travel(player,node,pos)
	--update the world line
	d = {
		n_1 = floor(random(0,1)),
		n_2 = "dot",
		n_3 = floor(random(0,9)),
		n_4 = floor(random(0,9)),
		n_5 = floor(random(0,9)),
		n_6 = floor(random(0,9)),
		n_7 = floor(random(0,9)),
		n_8 = floor(random(0,9))
	}
	d.n = d.n_1.."."..d.n_3..d.n_4..d.n_5..d.n_6..d.n_7..d.n_8
	--save number on a world file
	local file = io.open(WORLD_LINE,"w")
	file:write(compress(serialize(d)))
	if player:get_player_name() == nil then return end
	local objects = minetest.env:get_objects_inside_radius(pos, 0.5)
	for _, v in ipairs(objects) do
		if v:get_entity_name() == "time_travel:div_meter_display" then
			v:set_properties({textures=gen_tex(d)})
		end
	end
	--Play sound and make something like Chrono Trigger travel
	
end
local signs_yard = {
	{yaw = 0},
	{yaw = math.pi / -2},
	{yaw = math.pi},
	{yaw = math.pi / 2},
}
minetest.register_entity("time_travel:div_meter_display", {
	collisionbox = { 0, 0, 0, 0, 0, 0 },
	visual = "upright_sprite",
	textures = {},
	on_activate = function(self)
		self.object:set_properties({textures = gen_tex(d)})
	end
})
minetest_register_node("time_travel:div_meter", {
	description = "Divergence Meter",
	tiles = {
		"timetravel_textop.png",
		"timetravel_texbottom.png",
		"timetravel_texfront.png", --right
		"timetravel_texfront.png", --left
	},

	diggable = true,
	drawtype = "nodebox",
	paramtype = "light",
	light_source = 10,
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1875, 0.5, -0.1875, 0.1875}, -- base
			{-0.5, -0.5, 0, 0.5, 0.1075, 0}, -- Nixie's tubes
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1875, 0.5, -0.1875, 0.1875} --base
		}
	},
	--visual_scale = 0.5,
	groups = {cracky=3},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		time_travel(player,node,pos)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local above = pointed_thing.above
		local under = pointed_thing.under
		local dir = {x = under.x - above.x,
					 y = under.y - above.y,
					 z = under.z - above.z}

		local wdir = minetest.dir_to_wallmounted(dir)

		local placer_pos = placer:getpos()
		if placer_pos then
			dir = {
				x = above.x - placer_pos.x,
				y = above.y - placer_pos.y,
				z = above.z - placer_pos.z
			}
		end

		local fdir = minetest.dir_to_facedir(dir)

		local sign_info
		if wdir == 0 then
			--how would you add sign to ceiling?
			minetest.env:add_item(above, "time_travel:div_meter")
			return ItemStack("")
		elseif wdir == 1 then
			minetest.env:add_node(above, {name = "time_travel:div_meter", param2 = fdir})
			sign_info = signs_yard[fdir + 1]
		else
			minetest.env:add_node(above, {name = "time_travel:div_meter", param2 = fdir})
			sign_info = signs_yard[fdir + 1]
		end

		local text = minetest.env:add_entity({
				x = above.x,
				y = above.y,
				z = above.z,
			}, 
			"time_travel:div_meter_display"
		)
		text:setyaw(sign_info.yaw)

		return ItemStack("")
	end,
	on_destruct = function(pos)
		local objects = minetest.env:get_objects_inside_radius(pos, 0.5)
		for _, v in ipairs(objects) do
			if v:get_entity_name() == "time_travel:div_meter_display" then
				v:remove()
			end
		end
	end,
})
--dofile(path.."/world_eye.lua")
dofile(path.."/phone.lua")
dofile(path.."/furnace.lua")


