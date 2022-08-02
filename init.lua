smithery = {}
smithery.modname = minetest.get_current_modname()
local path = minetest.get_modpath(smithery.modname) .. "/"

smithery.armor   = minetest.get_modpath("3d_armor")
smithery.shields = minetest.get_modpath("shields")
smithery.hoes_enabled = false
if minetest.global_exists("farming") and farming.mod == "redo" then
  smithery.hoes_enabled = true
end

-- TODO repair and dismantle spears and castle_weapons, brass ingot default crafting recipe do not get cleared
-- in recipe guide, the handle shown is only 1 instead of the correct quantity
-- when doing TRASLATOR S, "Repair tool" IS used: by the craft guide!

if minetest.get_modpath("unified_inventory") then
  unified_inventory.register_craft_type("smithing", {
     description = "Smithing",
     icon = "smithing_anvil_icon.png",
     width = 3,
     height = 1,
     uses_crafting_grid = false
  })
elseif minetest.get_modpath("i3") then
  i3.register_craft_type("smithing", {
    description = "Smithing",
    icon = "smithing_anvil_icon.png",
  })
end

smithery.material_items = {
--                                            hammer_hardness_min
-- name in output,  full ingot name,     handle item,  |, has_tools, has 3d_armor, has hoe, itemstring_pattern, (different patter for armour)
  ["steel"]   = {"default:steel_ingot",  "group:stick", 2,  true,       true,       true,  "default"},
  ["bronze"]  = {"default:bronze_ingot", "group:stick", 3,  true,       true,       true,  "default"},
  ["gold"]    = {"default:gold_ingot",   "group:stick", 2,  false,      true,      false,  "default"},
  ["mese"]    = {"default:mese_crystal", "group:stick", 3,  true,       false,      true,  "default"},
  ["diamond"] = {"default:diamond",      "group:stick", 3,  true,       true,       true,  "default"}
}
-- if there is an ingot with the full tool set and possibly a full armor set, it gets added here, if it is a single item or doesnt follow the pattern, it is added singularly in lib
if minetest.get_modpath("ethereal") then
  smithery.material_items["crystal"] = {"ethereal:crystal_ingot", "group:stick", 3, true, true, false, "default"}
end

if minetest.get_modpath("moreores") then
  smithery.material_items["silver"] = {"moreores:silver_ingot",   "group:stick", 2, true, false, true, "default"}
  smithery.material_items["mithril"] = {"moreores:mithril_ingot", "group:stick", 3, true, true, true, "default"}
end

if minetest.get_modpath("rainbow_ore") then
  smithery.material_items["rainbow_ore"] = {"rainbow_ore:rainbow_ore_ingot", "group:stick", 3, true, true, false, "reverse"}
end

if minetest.get_modpath("could_items") then
  smithery.material_items["cloud"] = {"cloud_items:cloud_ingot", "group:stick", 2, true, true, false, "reverse"}
end

if minetest.get_modpath("obsidianstuff") then
  smithery.material_items["obsidian"] = {"obsidianstuff:ingot", "default:obsidian_shard", 2, true, true, false, "mono"}
end

if minetest.get_modpath("lavastuff") then
  smithery.material_items["lava"] = {"lavastuff:ingot", "default:obsidian_shard", 3, true, true, false, "mono"}
end

if minetest.get_modpath("gs_amethyst") then
  smithery.material_items["amethyst"] = {"gs_amethyst:amethyst", "group:stick", 2, true, true, false, "reverse", "default"}
end
if minetest.get_modpath("gs_emerald") then
  smithery.material_items["emerald"] = {"gs_emerald:emerald", "group:stick", 2, true, true, false, "reverse", "default"}
end
if minetest.get_modpath("gs_ruby") then
  smithery.material_items["ruby"] = {"gs_ruby:ruby", "group:stick", 2, true, true, false, "reverse", "default"}
end
if minetest.get_modpath("gs_shappire") then
  smithery.material_items["shappire"] = {"gs_shappire:shappire", "group:stick", 2, true, false, "reverse", "default"}
end

if minetest.get_modpath("nether") and minetest.registered_items["nether:nether_ingot"] then
  smithery.material_items["nether"] = {"nether:nether_ingot", "group:stick", 3, true, true, false, "default"}
end

-- rainbow_ingot

dofile(path .. "lib.lua")
dofile(path .. "item_definitions.lua")
dofile(path .. "smithing_anvil.lua")
--dofile(path .. "smithing_anvil_recipes.lua")
--dofile(path .. "repair_recipes.lua")
