minetest.register_craftitem("smithery:rust_dust", {
	description = "Rust dust",
	inventory_image = "rust_dust.png",
	groups = {dust = 1, rust = 1}
})

minetest.register_node("smithery:rusted_iron_block", {
	description =  "Rusted iron block",
	tiles = {"rusted_iron_block.png"},
	sounds = default.node_sound_metal_defaults(),
	is_ground_content = false,
	groups = {cracky=1, crumbly=1},
	drop = {
    items = { { items = {"smithery:rust_dust 9"}, rarity = 1, }, },
  },
})

minetest.register_craft({
	output = "smithery:rust_dust 9",
	type = "shapeless",
	recipe = {"smithery:rusted_iron_block"}
})

minetest.register_abm({
	label = "iron_block_rusting_abm",
	nodenames = {
		"smithery:iron_block"
	},
	neighbors = {"group:water"},
	interval = 30,
	chance = 100,
	catch_up = false,
	action = function(pos, node)
		minetest.set_node(pos, {name = "smithery:rusted_iron_block",} )
			--param2 = node.param})
	end
})
