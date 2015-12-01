-- GENERATED CODE
-- Node Box Editor, version 0.9.0
-- Namespace: test
d = {
	n_1 = math.floor(math.random(0,1)),
	n_2 = "dot",
	n_3 = math.floor(math.random(0,9)),
	n_4 = math.floor(math.random(0,9)),
	n_5 = math.floor(math.random(0,9)),
	n_6 = math.floor(math.random(0,9)),
	n_7 = math.floor(math.random(0,9)),
	n_8 = math.floor(math.random(0,9))
}
d.n = d.n_1.."."..d.n_3..d.n_4..d.n_5..d.n_6..d.n_7..d.n_8
WORLD_LINE = minetest.get_worldpath().."/world_line.txt"
for line in io.lines(WORLD_LINE) do
	if line == nil then
		local file = io.open(WORLD_LINE,"w")
		file:write(minetest.serialize(d))
		file:close()
	end
	d = minetest.deserialize(line)
	break
end

function time_travel(player)
	d = {
		n_1 = math.floor(math.random(0,1)),
		n_2 = "dot",
		n_3 = math.floor(math.random(0,9)),
		n_4 = math.floor(math.random(0,9)),
		n_5 = math.floor(math.random(0,9)),
		n_6 = math.floor(math.random(0,9)),
		n_7 = math.floor(math.random(0,9)),
		n_8 = math.floor(math.random(0,9))
	}
	d.n = d.n_1.."."..d.n_3..d.n_4..d.n_5..d.n_6..d.n_7..d.n_8
	--save number on a world file
	local file = io.open(WORLD_LINE,"w")
	file:write(minetest.serialize(d))
	if player:get_player_name() == nil then return end
	--FIXME try reboot
	minetest.kick_player(player:get_player_name(),"Time Traveller, please log again!!!")
end

minetest.register_node("time_travel:div_meter", {
	description = "Divergence Meter",
	tiles = {
		"textop.png",
		"textop.png",
		"texfront.png", --right
		"texfront.png", --left
		"(texback.png^[combine:200x200:0,0=texback.png:1,50="..d.n_1..".png:16,50="..d.n_2..".png:31,50="..d.n_3..".png:46,50="..d.n_4..".png:61,50="..d.n_5..".png:76,50="..d.n_6..".png:91,50="..d.n_7..".png:106,50="..d.n_8..".png^texfront.png)^[transformFX", --back
		"texback.png^[combine:200x200:0,0=texback.png:1,50="..d.n_1..".png:16,50="..d.n_2..".png:31,50="..d.n_3..".png:46,50="..d.n_4..".png:61,50="..d.n_5..".png:76,50="..d.n_6..".png:91,50="..d.n_7..".png:106,50="..d.n_8..".png^texfront.png", --front
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
	groups = {cracky=3, wood=1},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		time_travel(player)
	end,
})
minetest.register_craftitem("time_travel:phone", {
	description = "A common telephone",
	wield_image = "timetravel_phone.png",
	inventory_image = "timetravel_phone.png",
	visual = "sprite",
	physical = true,
	textures = {"timetravel_phone.png"},
	on_use = function(itemstack, user, pointed_thing)
		print(dump(minetest.rollback_revert_actions_by(user:get_player_name(), 5))) -- hours*minutes*seconds
		--time_travel(user)
		--help --> https://github.com/minetest/minetest/blob/master/doc/lua_api.txt#L1343
		--minetest.show_formspec(user:get_player_name(), "time_travel:phoneform",
		--		"size[4,3]" ..
		--		"image_button[0,0;10,10>;timetravel_button.png;Botão;Meu butão;]"..
		--		"field[1,1.5;3,1;name;Name;]" ..
		--		"button_exit[1,2;2,1;exit;Save]")
	end,
})
