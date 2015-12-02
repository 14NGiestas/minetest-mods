cores={"green","blue","yellow"}
for n,cor in ipairs(cores) do
	minetest.register_node("starwars:stone_with_adegan_"..cor, {
		description = "Adegan "..cor.." Crystal in Stone",
		tiles = {"default_stone.png^starwars_adegan"..cor..".png"},
		is_ground_content = true,
		groups = {cracky=18},
		drop = "starwars:adegan"..cor,
		sounds = default.node_sound_stone_defaults(),
	})
	minetest.register_craftitem("starwars:adegan"..cor, {
		description = "Adegan "..cor.." Crystal",
		inventory_image = "starwars_adegan"..cor.."crystal.png",
	})
	minetest.register_ore({
		ore_type = "scatter",
		ore = "starwars:stone_with_adegan_"..cor,
		wherein = "default:stone",
		clust_scarcity = 5000,
		clust_num_ores = 4,
		clust_size = 3,
		height_min = -59,
		height_max = -52,
	})
	minetest.register_ore({
		ore_type = "scatter",
		ore = "starwars:stone_with_adegan_"..cor,
		wherein = "default:stone",
		clust_scarcity = 10000,
		clust_num_ores = 3,
		clust_size = 2,
		height_min = -55,
		height_max = -53,
	})
end
minetest.register_craftitem("starwars:adeganred", {
	description = "Adegan Red Crystal",
	inventory_image = "starwars_adeganredcrystal.png",
})
