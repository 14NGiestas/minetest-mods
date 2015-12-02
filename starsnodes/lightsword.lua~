cores={"green","blue","red", "yellow"}
function on_off(cor)
	for _,player in ipairs(minetest.get_connected_players()) do
		if player:get_player_control().RMB == true then
			if player:get_wielded_item():get_name() == "starwars:lightsaberon"..cor then
				player:set_wielded_item("starwars:lightsaberoff"..cor)
				minetest.sound_play("starwars_lightsaberoff", {object = minetest.get_player_by_name(player:get_player_name()), gain = 1.0, max_hear_distance = 32, loop = false })
			elseif player:get_wielded_item():get_name() == "starwars:lightsaberoff"..cor then
				player:set_wielded_item("starwars:lightsaberon"..cor)
				minetest.sound_play("starwars_lightsaberon", {object = minetest.get_player_by_name(player:get_player_name()), gain = 1.0, max_hear_distance = 32, loop = false })
			end
		end
	end
end
function atk(cor)
	for _,player in ipairs(minetest.get_connected_players()) do
		if player:get_player_control().LMB == true and  player:get_wielded_item():get_name() == "starwars:lightsaberon"..cor then
			minetest.sound_play("starwars_lightsaberatk", {object = minetest.get_player_by_name(player:get_player_name()), gain = 1.0, max_hear_distance = 32, loop = false })
		end
	end
end
for n,cor in ipairs(cores) do
	minetest.register_tool("starwars:lightsaberoff"..cor, {
		description = "Light Saber "..cor,
		inventory_image = "starwars_lightsaberon"..cor..".png",
		wield_image = "starwars_lightsaberoff.png",
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level=0,
		},
	})
	minetest.register_tool("starwars:lightsaberon"..cor, {
		description = "Light Saber "..cor,
		inventory_image = "starwars_lightsaberon"..cor..".png",
		wield_image = "starwars_lightsaberon"..cor..".png",
		groups = {
			not_in_creative_inventory=1,
		},
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level=10,
			groupcaps={
				cracky={times={[1]=1.0, [2]=0.5, [3]=0.5}, uses=30, maxlevel=10},
				crumbly={times={[1]=1.0, [2]=0.5, [3]=0.5}, uses=30, maxlevel=10},
				snappy={times={[1]=1.0, [2]=0.5, [3]=0.5}, uses=30, maxlevel=10},
				choppy={times={[1]=1.0, [2]=0.5, [3]=0.5}, uses=30, maxlevel=10},
			},
			damage_groups = {fleshy=8}
		},
	})
	minetest.register_craft({
		output = "starwars:lightsaberoff"..cor,
		recipe = {
			{"default:steel_ingot"},
			{"starwars:adegan"..cor},
			{"default:steel_ingot"},
		}
	})
end
local t=0
for n,cor in ipairs(cores) do
	minetest.register_globalstep(function(dtime)
		t=t+dtime
		if t>0.3 then
			on_off(cor)
			atk(cor)
			t=0
		end
	end)
end
