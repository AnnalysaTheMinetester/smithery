--print("item_definitions.lua LOADED")

-- H A M M E R S

minetest.register_tool("smithery:stone_hammer", {
	description = "Stone Hammer",
	inventory_image = "stone_hammer.png",
	groups = {hammer = 1, hammer_hardness = 1},
	tool_capabilities = { -- stone pickaxe
		full_punch_interval = 1.5,
		max_drop_level=0,
		groupcaps={
			cracky = {times={[2]=2.0, [3]=1.00}, uses=5, maxlevel=1},
		},
		damage_groups = {fleshy=3},
	},
	sound = {breaks = "default_tool_breaks"},

})
minetest.register_tool("smithery:steel_hammer", {
	description = "Steel Hammer",
	inventory_image = "steel_hammer.png",
	groups = {hammer = 1, hammer_hardness = 2},
	tool_capabilities = {--steel pickaxe
		full_punch_interval = 1.1,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=20, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},

})
minetest.register_tool("smithery:bronze_hammer", {
	description = "Bronze Hammer",
	inventory_image = "bronze_hammer.png",
	groups = {hammer = 1, hammer_hardness = 3},
	tool_capabilities = {--bronze pickaxe
		full_punch_interval = 1.3,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=4.50, [2]=1.80, [3]=0.90}, uses=20, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},

})

-- C R A F T S

minetest.register_craft({
    output = "smithery:stone_hammer",
    recipe = {
            {"default:stone", "default:stone", ""},
            {"", "default:stick", ""},
    }
})
minetest.register_craft({
    output = "smithery:steel_hammer",
    recipe = {
            {"default:steel_ingot", "default:steel_ingot", ""},
            {"", "basic_materials:steel_bar", ""},
    }
})
minetest.register_craft({
    output = "smithery:bronze_hammer",
    recipe = {
            {"default:bronze_ingot", "default:bronze_ingot", ""},
            {"", "basic_materials:steel_bar", ""},
    }
})

-- I R O N --

minetest.register_craftitem("smithery:iron_ingot", {
	description = "Iron Ingot",
	inventory_image = "iron_ingot.png",
	groups = {ingot = 1}
})

minetest.register_node("smithery:iron_block", {
	description = "Iron Block",
	tiles = {"iron_block.png"},
	sounds = default.node_sound_metal_defaults(),
	is_ground_content = false,
	groups = {cracky = 1, level = 2},
})


minetest.register_craft({
  output = "smithery:iron_block",
  recipe = {
          {"smithery:iron_ingot", "smithery:iron_ingot", "smithery:iron_ingot"},
          {"smithery:iron_ingot", "smithery:iron_ingot", "smithery:iron_ingot"},
          {"smithery:iron_ingot", "smithery:iron_ingot", "smithery:iron_ingot"},
  }
})

-- FAKE ITEMS TO ALLOW REPAIRING OF TOOLS AND ARMOURS

local t = {"sword", "pick", "axe", "shovel", "hoe",}
local a = {"helmet", "chestplate", "leggings", "boots", "shield"}

for i=1,#t do
	minetest.register_craftitem("smithery:repair_".. t[i], {
		description = "Repair ".. t[i],
		inventory_image = "smithery_repair_".. t[i] ..".png^smithing_hammer_hit.png",
		groups = {not_in_creative_inventory = 1}
	})
end
for i=1,#a do
	minetest.register_craftitem("smithery:repair_".. a[i], {
		description = "Repair ".. a[i],
		inventory_image = "smithery_repair_".. a[i] ..".png^smithing_hammer_hit.png",
		groups = {not_in_creative_inventory = 1}
	})
end
