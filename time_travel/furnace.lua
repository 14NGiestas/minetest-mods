local find_node = minetest.find_node_near
--
-- Formspecs
--

-- GUI related stuff
function get_hotbar_bg(x,y)
	local out = ""
	for i=0,7,1 do
		out = out .."image["..x+i..","..y..";1,1;gui_hb_bg.png]"
	end
	return out
end

local function active_formspec(fuel_percent, item_percent)
	local formspec = 
		"size[8,8.5]"..
		"bgcolor[#080808BB;true]"..
		"background[5,5;1,1;gui_formbg.png;true]"..
		"listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"..
		"list[current_name;src;2.75,0.5;1,1;]"..
		"list[current_name;fuel;2.75,2.5;1,1;]"..
		"image[2.75,1.5;1,1;default_furnace_fire_bg.png^[lowpart:"..
		(100-fuel_percent)..":default_furnace_fire_fg.png]"..
		"image[3.75,1.5;1,1;gui_furnace_arrow_bg.png^[lowpart:"..
		(item_percent)..":gui_furnace_arrow_fg.png^[transformR270]"..
		"list[current_name;dst;4.75,0.96;2,2;]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"listring[current_name;dst]"..
		"listring[current_player;main]"..
		"listring[current_name;src]"..
		"listring[current_player;main]"..
		get_hotbar_bg(0, 4.25)
	return formspec
end

local inactive_formspec =
	"size[8,8.5]"..
	"bgcolor[#080808BB;true]"..
	"background[5,5;1,1;gui_formbg.png;true]"..
	"listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"..
	"list[current_name;src;2.75,0.5;1,1;]"..
	"list[current_name;fuel;2.75,2.5;1,1;]"..
	"image[2.75,1.5;1,1;default_furnace_fire_bg.png]"..
	"image[3.75,1.5;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
	"list[current_name;dst;4.75,0.96;2,2;]"..
	"list[current_player;main;0,4.25;8,1;]"..
	"list[current_player;main;0,5.5;8,3;8]"..
	"listring[current_name;dst]"..
	"listring[current_player;main]"..
	"listring[current_name;src]"..
	"listring[current_player;main]"..
	get_hotbar_bg(0, 4.25)

--
-- Node callback functions that are the same for active and inactive furnace
--

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("fuel") and inv:is_empty("dst") and inv:is_empty("src")
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "fuel" then
		if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then
			if inv:is_empty("src") then
				meta:set_string("infotext", "Furnace is empty")
			end
			return stack:get_count()
		else
			return 0
		end
	elseif listname == "src" then
		return stack:get_count()
	elseif listname == "dst" then
		return 0
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

--
-- Node definitions
--

minetest.register_node("time_travel:microwavephone", {
	description = "Microwave Cellphone (Name Subject to change)",
	tiles = {
		"timetravel_microwave_top.png",
		"timetravel_microwave_bottom.png",
		"timetravel_microwave_sides.png",
		"timetravel_microwave_sides.png",
		"timetravel_microwave_back.png",
		"timetravel_microwave_front.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.375, 0.5, 0.1875, 0.375}, -- NodeBox1
		}
	},
	can_dig = can_dig,
	diggable = true,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	paramtype2 = "facedir",
	groups = {cracky=3}
})

minetest.register_node("time_travel:microwavephone_active", {
	description = "Microwave Cellphone (Name Subject to change)",
	tiles = {
		"timetravel_microwave_top.png",
		"timetravel_microwave_bottom.png",
		"timetravel_microwave_sides.png",
		"timetravel_microwave_sides.png",
		"timetravel_microwave_back.png",
		{
			image = "timetravel_microwave_front_on.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 120,
				aspect_h = 120,
				length = 0.5
			},
		}
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.375, 0.5, 0.1875, 0.375}, -- NodeBox1
		}
	},

	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 8,
	drop = "time_travel:microwavephone",
	groups = {cracky=2, not_in_creative_inventory=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	
	can_dig = can_dig,
	
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
})

--
-- ABM
--

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

minetest.register_abm({
	nodenames = {"time_travel:microwavephone", "time_travel:microwavephone_active"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		-- Inizialize metadata
		--
		local meta = minetest.get_meta(pos)
		local fuel_time = meta:get_float("fuel_time") or 0
		local src_time = meta:get_float("src_time") or 0
		local fuel_totaltime = meta:get_float("fuel_totaltime") or 0
		
		--
		-- Inizialize inventory
		--
		local inv = meta:get_inventory()
		for listname, size in pairs({
				src = 1,
				fuel = 1,
				dst = 4,
		}) do
			if inv:get_size(listname) ~= size then
				inv:set_size(listname, size)
			end
		end
		local srclist = inv:get_list("src")
		local fuellist = inv:get_list("fuel")
		local dstlist = inv:get_list("dst")

		--
		-- Cooking
		--
		
		-- Check if we have cookable content
		local cooked, aftercooked = minetest.get_craft_result({method = "cooking", width = 1, items = srclist})
		local cookable = true
		if cooked.time == 0 then
			cookable = false
		end
		if not (fuellist[1]:is_empty() and srclist[1]:is_empty()) then
			if cooked.item:get_name():find("time_travel") then
				-- The mini-black-hole are opened only with a CRT TV near
				if find_node(pos, 5, {"homedecor:television"}) then
					cookable = true
				else
					cookable = false
				end
			end
		end
		-- Check if we have enough fuel to burn
		if fuel_time < fuel_totaltime then
			-- The furnace is currently active and has enough fuel
			fuel_time = fuel_time + 1
		
			-- If there is a cookable item then check if it is ready yet
			if cookable then
				src_time = src_time + 1
				if src_time >= cooked.time then
					-- Place result in dst list if possible
					if inv:room_for_item("dst", cooked.item) then
						inv:add_item("dst", cooked.item)
						inv:set_stack("src", 1, aftercooked.items[1])
						src_time = 0
					end
				end
			end
		else
			-- Furnace ran out of fuel
			if cookable then
				-- We need to get new fuel
				local fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})
			
				if fuel.time == 0 then
					-- No valid fuel in fuel list
					fuel_totaltime = 0
					fuel_time = 0
					src_time = 0
				else
					-- Take fuel from fuel list
					inv:set_stack("fuel", 1, afterfuel.items[1])
				
					fuel_totaltime = fuel.time
					fuel_time = 0
				
				end
			else
				-- We don't need to get new fuel since there is no cookable item
				fuel_totaltime = 0
				fuel_time = 0
				src_time = 0
			end
		end
		
		--
		-- Update formspec, infotext and node
		--
		local formspec = inactive_formspec
		local item_state = ""
		local item_percent = 0
		if cookable then
			item_percent =  math.floor(src_time / cooked.time * 100)
			item_state = item_percent .. "%"
		else
			if srclist[1]:is_empty() then
				item_state = "Empty"
			else
				item_state = "Not cookable"
			end
		end
		
		local fuel_state = "Empty"
		local active = "inactive "
		if fuel_time <= fuel_totaltime and fuel_totaltime ~= 0 then
			active = "active "
			local fuel_percent = math.floor(fuel_time / fuel_totaltime * 100)
			fuel_state = fuel_percent .. "%"
			formspec = active_formspec(fuel_percent, item_percent)
			swap_node(pos, "time_travel:microwavephone_active")
		else
			if not fuellist[1]:is_empty() then
				fuel_state = "0%"
			end
			swap_node(pos, "time_travel:microwavephone")
		end
		
		local infotext =  "Microwave " .. active .. "(Item: " .. item_state .. "; Fuel: " .. fuel_state .. ")"
		
		--
		-- Set meta values
		--
		meta:set_float("fuel_totaltime", fuel_totaltime)
		meta:set_float("fuel_time", fuel_time)
		meta:set_float("src_time", src_time)
		meta:set_string("formspec", formspec)
		meta:set_string("infotext", infotext)
	end,
})
