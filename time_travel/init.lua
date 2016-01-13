local path = minetest.get_modpath("time_travel")
minetest.register_node("time_travel:apple", {
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
dofile(path.."/phone.lua")
dofile(path.."/furnace.lua")


