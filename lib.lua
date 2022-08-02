local s = smithery
local material_list = s.material_items

local hammers_support_table = {
-- itemstring,                   material item (no repair),   handle,  hammers_hardness, max_uses,
  ["smithery:stone_hammer"] =   {"default:stone",        "group:stick",               1,  5},
  ["smithery:steel_hammer"] =   {"default:steel_ingot",  "basic_materials:steel_bar", 2, 20},
  ["smithery:bronze_hammer"] =  {"default:bronze_ingot", "basic_materials:steel_bar", 3, 30},
}
if minetest.get_modpath("xdecor") then
  hammers_support_table["xdecor:hammer"] = {"default:steel_ingot",  "group:stick", 2, 20}
--[[
  if minetest.registered_items["xdecor:hammer"][tool_capabilities] == nil then
    minetest.override_item("xdecor:hammer", {
      tool_capabilities = {--steel pickaxe
        full_punch_interval = 1.1,
        max_drop_level=1,
        groupcaps={
          cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=20, maxlevel=2},
        },
        damage_groups = {fleshy=4},
      },
    })
  end
]]--
end

local itemstring_patterns = {
  ["default"] = "modname:tool_ingot",
  ["reverse"] = "modname:ingot_tool",
  ["mono"] = "modname:tool",
}
-- different mods have different patterns for registering their tools and armours
-- gets a table with all correctly shaped output itemstrings, of tools and if has_armor, of armours too
local function get_correct_itemstring(modname, key, pattern, has_armor)
  local ip = itemstring_patterns[pattern]
  ip = string.gsub(ip, "ingot", key)

  local t = {"sword", "pick", "axe", "shovel", "hoe",}
  local a = {"helmet", "chestplate", "leggings", "boots",}
  local r = {}
  local m = string.gsub(ip, "modname", modname)
  local s

  for i=1,#t do
    s = t[i]
    print("modname ".. m .. " ingot ".. key .." tool ".. s)
    r[s] = string.gsub(m, "tool", s)
  end

  if has_armor then
    -- some armours are defined in the 3d_armor mod directly
    if modname == "default" or modname == "ethereal" or modname == "moreores" or modname == "nether" then
      m = string.gsub(ip, "modname", "3d_armor")
    end
    for i=1,#a do
      s = a[i]
      r[s] = string.gsub(m, "tool", s)
    end

    m = string.gsub(ip, "modname", "shields")
    r["shield"] = string.gsub(m, "tool", "shield")

  end -- if has_armor

  return r
end

local function get_ingot_recipe (inputs, hhm, ingot)
  local composed_inputs = {}
  local replacement, item
  for i=1,#inputs do
    item = inputs[i]
    composed_inputs[i] = item[1]
    replacement = item[2]
  end

  return {"compose", composed_inputs, hhm, ingot, replacement }
end

-- type, {ingredients max 3}, hammers_hardness_min, result, replacements
-- type: forge, repair, dismantle (smash with hammer to get back material from it), compose (ingot making)
-- result item è univoco, that item can be created only with that recipe.
-- dismantle and repair have a different mechanism though, with a different key and check in get_selected_recipe_results
local recipe_list = {}

recipe_list["default:ladder_steel"] =  {"forge", { "default:steel_ingot 7" }, 2, "default:ladder_steel 15 ", nil }

if minetest.get_modpath("bucket") then
  recipe_list["bucket:bucket_empty"] =   {"forge", { "default:steel_ingot 3" }, 2, "bucket:bucket_empty 1", nil }
end
if minetest.get_modpath("cart") then
  recipe_list["carts:cart"] =            {"forge", { "default:steel_ingot 5" }, 2, "carts:cart 1", nil }
end
if minetest.get_modpath("xpanes") then
  recipe_list["xpanes:chainlink_flat"] = {"forge", { "default:steel_ingot 5" }, 2, "xpanes:chainlink_flat 16", nil }
  recipe_list["xpanes:bar_flat"] =       {"forge", { "default:steel_ingot 6" }, 2, "xpanes:bar_flat 16", nil }
  recipe_list["xpanes:rusty_bar_flat"] = {"forge", { "smithery:iron_ingot 6" }, 1, "xpanes:rusty_bar_flat 16", nil }
  minetest.clear_craft({ output = "xpanes:rusty_bar_flat" })

  if minetest.get_modpath("doors") then
    recipe_list["doors:prison_door"] =       {"forge", { "xpanes:bar_flat 6" }, 2, "doors:prison_door 1", nil }
    recipe_list["xpanes:door_steel_bar"] =   {"forge", { "xpanes:bar_flat 6" }, 2, "xpanes:door_steel_bar 1", nil }
    recipe_list["doors:rusty_prison_door"] = {"forge", { "xpanes:rusty_bar_flat 6" }, 1, "doors:rusty_prison_door 1", nil }
  end
end
if minetest.get_modpath("doors") then
  recipe_list["doors:trapdoor_steel"] =  {"forge", { "default:steel_ingot 4" }, 2, "doors:trapdoor_steel 1", nil }
  recipe_list["doors:door_steel"] =      {"forge", { "default:steel_ingot 6" }, 2, "doors:door_steel 1", nil }
end
if minetest.get_modpath("vessels") then
  recipe_list["vessels:steel_bottle"] =  {"forge", { "default:steel_ingot 5" }, 2, "vessels:steel_bottle 5", nil }
  recipe_list["dismantle_steel_bottle"] = {"dismantle", { "vessels:steel_bottle 1" }, 2, "default:steel_ingot 3", nil }
end
if minetest.get_modpath("xdecor") then
  recipe_list["xdecor:rooster"] =  {"forge", { "default:gold_ingot 5" }, 1, "xdecor:rooster 1", nil }
  recipe_list["xdecor:speaker"] =  {"forge", { "default:gold_ingot 4", "default:copper_ingot 4" }, 1, "xdecor:speaker 1", nil }
end

recipe_list["smithery:iron_ingot"] = get_ingot_recipe({ {"smithery:iron_ingot 2", nil},
                                             {"default:coal_lump 3", nil}, }, 1, "default:steel_ingot 2" )
minetest.clear_craft({ -- iron lumps cooks into iron ingots, which then can be forged into steel adding coal
	type = "cooking",
	recipe = "default:iron_lump"
})
minetest.register_craft({
	type = "cooking",
	output = "smithery:iron_ingot",
	recipe = "default:iron_lump",
})

recipe_list["default:copper_ingot"] = get_ingot_recipe({ {"default:copper_ingot 8", nil},
                                             {"default:tin_ingot 1", nil}, }, 2, "default:bronze_ingot 9" )
minetest.clear_craft({ --type = "shaped",
 recipe = {
	{"default:copper_ingot", "default:copper_ingot", "default:copper_ingot"},
	{"default:copper_ingot", "default:tin_ingot", "default:copper_ingot"},
	{"default:copper_ingot", "default:copper_ingot", "default:copper_ingot"},
} })

if minetest.get_modpath("moreores") then
  recipe_list["basic_materials:brass_ingot"] = get_ingot_recipe({ {"default:copper_ingot 2", nil},
                                               {"moreores:silver_ingot 1", nil}, }, 1, "basic_materials:brass_ingot 2" )
  minetest.clear_craft({ type = "shapeless", recipe = {"default:copper_ingot 2", "moreores:silver_ingot 1"} })

  recipe_list["basic_materials:silver_wire"] = {"forge", { "moreores:silver_ingot 1", "basic_materials:empty_spool 2"}, 1, "basic_materials:silver_wire 2", nil }
  minetest.clear_craft({ output = "basic_materials:silver_wire" })

else -- only ONE recipe for brass_ingot can exist
  recipe_list["basic_materials:brass_ingot"] = get_ingot_recipe({ {"default:copper_ingot 5", nil},
                                               {"default:tin_ingot 3", nil},
                                               {"default:gold_ingot 1", nil}, }, 1, "basic_materials:brass_ingot 2" )
  minetest.clear_craft({ --type = "shaped",
   input = {
   	{"default:copper_ingot", "default:tin_ingot", "default:copper_ingot"},
   	{"default:gold_ingot", "default:copper_ingot", "default:tin_ingot"},
   	{"default:copper_ingot", "default:tin_ingot", "default:copper_ingot"},
  } })
end
if minetest.get_modpath("obsidianstuff") then
  recipe_list["obsidianstuff:ingot"] = get_ingot_recipe({ {"default:obsidian 1", nil},
                                               {"default:steel_ingot 1", nil}, }, 2, "obsidianstuff:ingot 1" )
   minetest.clear_craft({ type = "shapeless", recipe = {"default:obsidian 1", "default:steel_ingot 1"} })

end
if minetest.get_modpath("ethereal") then
  recipe_list["ethereal:crystal_ingot"] = get_ingot_recipe({ {"default:mese_crystal 2", nil},
                                               {"ethereal:crystal_spike 2", nil},
                           {"bucket:bucket_water 1", "bucket:bucket_empty"}, }, 3, "ethereal:crystal_ingot 1" )
  minetest.clear_craft({ type = "shapeless", recipe = {"default:mese_crystal 2", "default:bucket_water 1", "ethereal:crystal_spike 2"} })
end

recipe_list["basic_materials:copper_wire"] = {"forge", { "default:copper_ingot 1", "basic_materials:empty_spool 2"}, 1, "basic_materials:copper_wire 2", nil }
recipe_list["basic_materials:gold_wire"] =   {"forge", { "default:gold_ingot 1", "basic_materials:empty_spool 2"}, 2, "basic_materials:gold_wire 2", nil }
recipe_list["basic_materials:steel_wire"] =  {"forge", { "default:steel_ingot 1", "basic_materials:empty_spool 2"}, 2, "basic_materials:steel_wire 2", nil }

recipe_list["basic_materials:steel_bar"] =    {"forge", { "default:steel_ingot 3"}, 2, "basic_materials:steel_bar 6", nil }
recipe_list["basic_materials:steel_strip"] =  {"forge", { "default:steel_ingot 2"}, 2, "basic_materials:steel_strip 12", nil }
recipe_list["basic_materials:copper_strip"] = {"forge", { "default:copper_ingot 2"}, 1, "basic_materials:copper_strip 12", nil }

recipe_list["basic_materials:chainlink_steel"] = {"forge", { "default:steel_ingot 6"}, 2, "basic_materials:chainlink_steel 12", nil }
recipe_list["basic_materials:chain_steel"] =     {"forge", { "basic_materials:chainlink_steel 3"}, 2, "basic_materials:chain_steel 2", nil }

recipe_list["basic_materials:chainlink_brass"] = {"forge", { "basic_materials:brass_ingot 6"}, 2, "basic_materials:chainlink_brass 12", nil }
recipe_list["basic_materials:chain_brass"] =     {"forge", { "basic_materials:chainlink_brass 3"}, 2, "basic_materials:chain_brass 2", nil }

recipe_list["basic_materials:padlock"] =    {"forge", { "default:steel_ingot 2", "basic_materials:steel_bar 1"}, 2, "basic_materials:padlock 2", nil }
recipe_list["basic_materials:gear_steel"] = {"forge", { "default:steel_ingot 4", "basic_materials:chainlink_steel 1"}, 2, "basic_materials:gear_steel 6", nil }

recipe_list["basic_materials:heating_element"] =       {"forge", { "default:copper_ingot 2", "default:mese_crystal_fragment 1"}, 3, "basic_materials:heating_element 2", nil }
recipe_list["basic_materials:energy_crystal_simple"] = {"forge", { "default:diamond 2", "default:mese_crystal_fragment 2", "default:gold_ingot 1"}, 3, "basic_materials:energy_crystal_simple 2", nil }

minetest.clear_craft({ output = "basic_materials:copper_wire" })
minetest.clear_craft({ output = "basic_materials:gold_wire" })
minetest.clear_craft({ output = "basic_materials:steel_wire" })

minetest.clear_craft({ output = "basic_materials:steel_bar" })
minetest.clear_craft({ output = "basic_materials:steel_strip" })
minetest.clear_craft({ output = "basic_materials:copper_strip" })

minetest.clear_craft({ output = "basic_materials:chainlink_steel" })
minetest.clear_craft({ output = "basic_materials:chain_steel" })

minetest.clear_craft({ output = "basic_materials:chainlink_brass" })
minetest.clear_craft({ output = "basic_materials:chain_brass" })

minetest.clear_craft({ output = "basic_materials:padlock" })
minetest.clear_craft({ output = "basic_materials:gear_steel" })

minetest.clear_craft({ output = "basic_materials:heating_element" })
minetest.clear_craft({ output = "basic_materials:energy_crystal_simple" })


-- REPAIR NOT POSSIBLE at the moment, maybe by modyfing the description via metadata of the item in choice_slots, to say "rapair ".. item, instead of just items ??
-- YES ACTUALLY if in the get_selected_recipe_results i check whever there is a "repair" type recipe (aka src contains a tool and its ingot) and prioritize that recipe
-- WELL ACTUALLY NO, with the system currently used i think it isnt possible, but i dont want to create a new "repair facade item" for every single repairable item!!
-- MAYBE if i have ONE repair item per type item, as one rapair axe, for every axe, in the get_selected_recipe_results i could search the src for the correct type
--      of selected repair item, checking the selected before doing other things ... :)
-- what if someone puts in two pickaxes and their ingots? two fake repair item will appear, how will the user know which is which?? item meta? also this applies only with a lager src ...

-- table population of tools are armours
for k,v in pairs(material_list) do
  local ingot = v[1]
  local handle = v[2]
  local hhm = v[3]
  local has_tools = v[4]
  local has_armor = v[5]
  local has_hoe = v[6]
  local pattern = v[7]
  local modname = ingot:split(":")[1]

  local itemstring = get_correct_itemstring(modname, k, pattern, has_armor)

  if v[8] ~= nil then
    local alt_itemstring = get_correct_itemstring(modname, k, v[8], has_armor)
    itemstring["helmet"] = alt_itemstring["helmet"]
    itemstring["chestplate"] = alt_itemstring["chestplate"]
    itemstring["leggings"] = alt_itemstring["leggings"]
    itemstring["boots"] = alt_itemstring["boots"]
    itemstring["shield"] = alt_itemstring["shield"]
  end

  if has_tools then
    recipe_list[ itemstring["sword"] ] =  {"forge", { ingot .." 2", handle .." 1"}, hhm, itemstring["sword"] .." 1", nil }
    recipe_list[ itemstring["pick"] ] =   {"forge", { ingot .." 3", handle .." 2"}, hhm, itemstring["pick"] .." 1", nil }
    recipe_list[ itemstring["axe"] ] =    {"forge", { ingot .." 3", handle .." 2"}, hhm, itemstring["axe"] .." 1", nil }
    recipe_list[ itemstring["shovel"] ] = {"forge", { ingot .." 1", handle .." 2"}, hhm, itemstring["shovel"] .." 1", nil }

    recipe_list["dismantle_sword_".. k ] = {"dismantle", { itemstring["sword"] }, hhm, ingot .." 1", nil }
    recipe_list["dismantle_pick_".. k ] =  {"dismantle", { itemstring["pick"] },  hhm, ingot .." 2", nil }
    recipe_list["dismantle_axe_".. k ] =   {"dismantle", { itemstring["axe"] },   hhm, ingot .." 2", nil }
    --recipe_list["dismantle_".. k .."_shovel"] =   {"dismantle", { itemstring["shovel"] },   hhm, ingot .." 1", nil }

    minetest.clear_craft({ output = itemstring["sword"] })
    minetest.clear_craft({ output = itemstring["pick"] })
    minetest.clear_craft({ output = itemstring["axe"] })
    minetest.clear_craft({ output = itemstring["shovel"] })

    recipe_list["repair_sword_".. k ] =  {"repair", { itemstring["sword"] .." 1", ingot .." 1"},  hhm, "smithery:repair_sword 1", nil }
    recipe_list["repair_pick_".. k ] =   {"repair", { itemstring["pick"] .." 1", ingot .." 1"},   hhm, "smithery:repair_pick 1", nil }
    recipe_list["repair_axe_".. k ] =    {"repair", { itemstring["axe"] .." 1", ingot .." 1"},    hhm, "smithery:repair_axe 1", nil }
    recipe_list["repair_shovel_".. k ] = {"repair", { itemstring["shovel"] .." 1", ingot .." 1"}, hhm, "smithery:repair_shovel 1", nil }
  end

  if s.armor and has_armor then
    recipe_list[ itemstring["helmet"] ] =     {"forge", { ingot .." 4"}, hhm, itemstring["helmet"] .." 1", nil }
    recipe_list[ itemstring["chestplate"] ] = {"forge", { ingot .." 8"}, hhm, itemstring["chestplate"] .." 1", nil }
    recipe_list[ itemstring["leggings"] ] =   {"forge", { ingot .." 7"}, hhm, itemstring["leggings"] .." 1", nil }
    recipe_list[ itemstring["boots"] ] =      {"forge", { ingot .." 4"}, hhm, itemstring["boots"] .." 1", nil }

    recipe_list["dismantle_helmet_".. k ] =     {"dismantle", { itemstring["helmet"] .." 1" },     hhm, ingot .." 3", nil }
    recipe_list["dismantle_chestplate_".. k ] = {"dismantle", { itemstring["chestplate"] .." 1" }, hhm, ingot .." 5", nil }
    recipe_list["dismantle_leggings_".. k ] =   {"dismantle", { itemstring["leggings"] .." 1" },   hhm, ingot .." 4", nil }
    recipe_list["dismantle_boots_".. k ] =      {"dismantle", { itemstring["boots"] .." 1" },      hhm, ingot .." 2", nil }

    minetest.clear_craft({ output = itemstring["helmet"] })
    minetest.clear_craft({ output = itemstring["chestplate"] })
    minetest.clear_craft({ output = itemstring["leggings"] })
    minetest.clear_craft({ output = itemstring["boots"] })

    recipe_list["repair_helmet_".. k ] =     {"repair", { itemstring["helmet"] .." 1", ingot .." 1"},     hhm, "smithery:repair_helmet 1", nil }
    recipe_list["repair_chestplate_".. k ] = {"repair", { itemstring["chestplate"] .." 1", ingot .." 1"}, hhm, "smithery:repair_chestplate 1", nil }
    recipe_list["repair_leggings_".. k ] =   {"repair", { itemstring["leggings"] .." 1", ingot .." 1"},   hhm, "smithery:repair_leggings 1", nil }
    recipe_list["repair_boots_".. k ] =      {"repair", { itemstring["boots"] .." 1", ingot .." 1"},      hhm, "smithery:repair_boots 1", nil }

  end
  if s.shields and has_armor then
    recipe_list[ itemstring["shield"] ] =   {"forge", { ingot .." 7"}, hhm, itemstring["shield"] .." 1", nil }
    recipe_list["dismantle_shield_".. k ] = {"dismantle", { itemstring["shield"] .." 1" }, hhm, ingot .." 4", nil }
    recipe_list["repair_shield_".. k ] =    {"repair", { itemstring["shield"] .." 1", ingot .." 1"}, hhm, "smithery:repair_shield 1", nil }
    minetest.clear_craft({ output = itemstring["shield"] })
  end
  -- 3d_armor_gloves and has_gloves

  if s.hoes_enabled and has_hoe then
    local m = modname
    if modname == "default" then
      m = "farming"
    end
    local hoe_itemstring = string.gsub(itemstring["hoe"], modname, m)
    recipe_list[ hoe_itemstring ]      = {"forge", { ingot .." 2", handle .." 2"}, hhm, hoe_itemstring .." 1", nil }
    recipe_list["dismantle_hoe_".. k ] = {"dismantle", { hoe_itemstring .." 1" }, hhm, ingot .." 1", nil }
    recipe_list["repair_hoe".. k ]     = {"repair", { hoe_itemstring .." 1", ingot .." 1"}, hhm, "smithery:repair_hoe 1", nil }
    if k == "mithril" then
      recipe_list["farming:scythe_".. k] = {"forge", { ingot .." 3", handle .." 2"}, hhm, "farming:scythe_".. k .." 1" , nil }
      --recipe_list["repair_scythe_".. k ] = {"repair", { "farming:scythe_".. k, ingot .." 1"}, hhm, "smithery:repair_scythe", nil }
    end
  end

end -- for to fill recipe_list

if s.shields then
  recipe_list["shields:shield_enhanced_wood"]   = {"forge", { "default:steel_ingot 2", "shields:shield_wood 1"}, 2, "shields:shield_enhanced_wood 1", nil }
  recipe_list["shields:shield_enhanced_cactus"] = {"forge", { "default:steel_ingot 2", "shields:shield_cactus 1"}, 2, "shields:shield_enhanced_cactus 1", nil }
end

if minetest.get_modpath("mobs") and minetest.get_modpath("mobs_monster") then
  if not minetest.get_modpath("lavastuff") then
    recipe_list["mobs:pick_lava"] = {"forge", { "mobs:lava_orb 3", "default:obsidian_shard 2"}, 3, "mobs:pick_lava 1", nil }
  end
  recipe_list["mobs:shears"] = {"forge", { "default:steel_ingot 2", "group:stick 1"}, 2, "mobs:shears 1", nil }
end
if minetest.registered_items["vines:shears"] then
  recipe_list["vines:shears"] = {"forge", { "default:steel_ingot 2", "group:stick 2", "group:wood 1"}, 2, "vines:shears 1", nil }
end

local material_allowed = {
  ["spears"] = {"default:steel_ingot", "default:copper_ingot", "default:bronze_ingot", "default:gold_ingot", "default:obsidian", "default:diamond"},
}
if minetest.get_modpath("spears") then
  local hhm = { 2, 1, 3, 2, 2, 3 }
  local s = material_allowed["spears"]
  for i=1,#s do
    local mat = s:split(":")[2]:split("_")[1]
    recipe_list["spears:spear_".. mat] = {"forge", { s[i] .." 1",  "group:stick 2"}, hmm[i], "spears:spear_".. mat .." 1", nil }
  --recipe_list["repair_spear_".. mat] = {"repair", { "spears:spear_".. mat, s[i] .." 1"}, hhm, "smithery:repair_spear", nil }
  end
end

if minetest.get_modpath("castle_weapons") then
  recipe_list["castle_weapons:battleaxe"] =     {"forge", { "default:steel_ingot 5", "group:stick 2"}, 2, "castle_weapons:battleaxe 1", nil }
  recipe_list["castle_weapons:crossbow"] =      {"forge", { "default:steel_ingot 2", "group:stick 2", "farming:string 3"}, 2, "castle_weapons:crossbow 1", nil }
  recipe_list["castle_weapons:crossbow_bolt"] = {"forge", { "default:steel_ingot 1", "group:stick 2"}, 2, "castle_weapons:crossbow_bolt 6", nil }

  minetest.clear_craft({ output = "castle_weapons:battleaxe" })
  minetest.clear_craft({ output = "castle_weapons:crossbow" })

  -- how do i repair these?!
end
if minetest.get_modpath("bows") then
  recipe_list["bows:bow_steel"]  = {"forge", { "default:steel_ingot 3",   "farming:string 3"}, 2, "bows:bow_steel 1", nil }
  recipe_list["bows:bow_bronze"] = {"forge", { "default:bronze_ingot 3",  "farming:string 3"}, 2, "bows:bow_bronze 1", nil }

  minetest.clear_craft({ output = "bows:bow_steel" })
  minetest.clear_craft({ output = "bows:bow_bronze" })

  --recipe_list["repair_bow_steel"]  = {"repair", { "bows:bow_steel", "default:steel_ingot 1"}, 2, "smithery:repair_bow", nil }
  --recipe_list["repair_bow_bronze"] = {"repair", { "bows:bow_bronze", "default:bronze_ingot 1"}, 2, "smithery:repair_bow", nil }
end

--[[
local tool = recipe:split("_")[2]
local tool_groups = {
  ["sword"] =      "sword",
  ["pick"] =       "pickaxe",
  ["axe"] =        "axe",
  ["shovel"] =     "shovel",
  ["helmet"] =     "armor_head",
  ["chestplate"] = "armor_torso",
  ["leggings"] =   "armor_legs",
  ["boots"] =      "armor_feet",
  ["shield"] =     "armor_shield",
  -- gloves, spears, bows, etc
}
]]--


if minetest.get_modpath("unified_inventory") then
  local out
  for k,v in pairs(recipe_list) do
    out = v[4]
    if v[1] == "repair" then
      out = v[2][1]
    end
    unified_inventory.register_craft({
      type = "smithing",
      items = v[2],
      output = out
    })
  end -- for recipe_list

elseif minetest.get_modpath("i3") then
  local out
  for k,v in pairs(recipe_list) do
    out = v[4]
    if v[1] == "repair" then
      out = v[2][1]
    end
    i3.register_craft({
      type = "smithing",
      items = v[2],
      result = out
    })
  end -- for recipe_list

end -- if unified_inventory or i3


-------- SMITHERY FUNCTIONS ----------------------------------------------------

function s.get_stack_count (list, size)
  -- not how many items there are, just stacks
  local count = 0
  local l = list
  --local str = "list: "
  if l ~= nil then
    for i=1,size do
      if l[i]:is_empty() == false then
        count = count + 1
        --str = str.. l[i]:to_string() ..", "
      end -- if stack is not empty
    end -- for
  end -- if l is not null
  --minetest.chat_send_all(str)
  return count
end

function s.get_hammer_max_uses(weilded_item)
  local h = hammers_support_table[weilded_item]
  if h == nil then
    return 0
  end
  return h[4]
end -- use to add_wear to the hammer, while punching

function s.get_selected_recipe_results(selected_item_key)
  -- return items_needed, hammers_hardness_min, forged_item, replacements
  local recipe = recipe_list[selected_item_key]
  if recipe ~= nil then
    return recipe[2], recipe[3], recipe[4], recipe[5]
  end
  return {}, 0, "", nil

end -- used in the anvil on_punch

--[[ as i figured out that i could just use the key in the recipe list that i had already set up, this is useless.
im keeping this because i spent too mych time on it, i managed to figure out a solution. i just now found a better one.
function s.get_selected_recipe_results( srclist, srcsize, selected_item, sl_key )
  -- return items_needed, hammers_hardness_min, forged_item, replacements
  --if scrlist == nil or invref:is_empty(scrlist) or selected_recipe == "nothing_selected" then
  if selected_item == "nothing_selected" or selected_item == nil then
    return {}, 0, ""
  end

  local src_list, src_size = srclist, s.get_stack_count(srclist, srcsize)

  local selected_stack = ItemStack(selected_item)
  local selected_item_name = selected_stack:get_name()
  local recipe = recipe_list[selected_item_name]
  if recipe ~= nil then
    return recipe[2], recipe[3], recipe[4], recipe[5]
  else
    -- recipe is either dismantle or repair

    local r = selected_item_name:split(":")
    if r[1] == "smithery" and string.find(r[2], "repair") then
      -- i could be repairing an item like "modname:REPAIRable_rocket_boots", so ill just check if it is smithery's
      -- pattern: ["repair_tool_".. k] = "smithery:repair_tool"

      recipe = r[2]
      -- recipe string is incomplete, needs the ingot part, procede cheking what is going to be repaired

      local tmp_key, tmp_recipe, tmp_inp, ti_name, si_name, input_match
      for k,v in pairs(material_list) do
        tmp_key = recipe .."_".. k
        tmp_recipe = recipe_list[tmp_key]
        if tmp_recipe ~= nil then
          tmp_inp = tmp_recipe[2]
          input_match = {}

          -- check if the recipe inputs are present in src
          for i=1,#tmp_inp do
            ti_name = tmp_inp[i]:get_name()
            input_match[i] = false

            for j=1,src_size do
              si_name = src_list[j]:get_name()

              if (ti_name == si_name or minetest.get_item_group(si_name, ti_name) > 1 ) and src_list[j]:get_count() >= tmp_imp[i]:get_count() then
                input_match[i] = true
              end -- if item is in src

            end -- for src items

            -- item in recipe isnt present in src, reset input_match, check next material
            if input_match[i] == false then
              input_match = {}
              break
            end
          end -- for tmp recipe inputs

        end -- tmp is present in recipe_list

        if input_match ~= nil then
          return tmp_inp, tmp_recipe[3], tmp_recipe[4], tmp_recipe[5]
        end

      end -- for material list

    else
      -- pattern: ["dismantle_tool_".. k] = ingot .." n"
      -- as above, recipe string is incomplete, needs the ingot part

      recipe = recipe_list[sl_key]
      if recipe ~= nil then
        return recipe[2], recipe[3], recipe[4], recipe[5]
      end

      -- how do i know the tool???

      --[[
      -- doesnt work as i cant know the tool im about to dismantle. a user could potentially insert in src a steel pick,
      -- a steel shield and steel boots. how do i distinguish them if i cant carry over the tool selected??
      local tmp_key, tmp_recipe, tmp_inp, tmp_out, input_match
      for k,v in pairs(material_list) do
        tmp_key = recipe .. k
        tmp_recipe = recipe_list[tmp_key]

        if tmp_recipe ~= nil then
          tmp_inp = tmp_recipe[2]
          tmp_out = tmp_recipe[4]

          if selected_item_name == tmp_out:get_name() then
            -- material found, check tool

            for i=1,src_size do

              -- dismantle recipes have only one tool ar armour as input, else it is an ingot making recipe
              if src_list[i] == tmp_inp[1] then
                input_match = true
                break
              end -- if src has the correct input item
            end -- for src_list

            if input_match == true then
              break
            end -- if recipe found, break material_list for

          end -- if selected_item corresponds to recipe output

        end -- if recipe is present

      end -- for material_list

      if input_match == true then
        return tmp_inp, tmp_recipe[3], tmp_out, tmp_recipe[5]
      end

      ]-]--
    end -- if it is a repair or dismantle recipe
  end --

  return {}, 0, ""
end -- used in on_punch()
]]--

function s.contains_recipe(srclist, srcsize, choice_slots_size)
  -- return true, choices to update the choice_slots
  --if scrlist == nil or choice_slots_size < 1 then
    --minetest.chat_send_all("src is nil")
    --return false, {}
  --end
  local choices = {}
  local choices_left = choice_slots_size
  local src_list, src_size = srclist, s.get_stack_count(srclist, srcsize)
  local recipe_inputs, recipe_output, allowed, input_match, item_name, ri_size, ri_name

  for k,v in pairs(recipe_list) do
    recipe_inputs = v[2]
    recipe_output = v[4]
    ri_size = #recipe_inputs
    allowed = true
    input_match = {}
    -- check if the recipe inputs are present in src

    if src_size >= ri_size then
      for i=1,ri_size do
        local stack, r_count = ItemStack(recipe_inputs[i]), 1
        if stack == nil then
          stack = recipe_inputs[i]
        end
        ri_name = stack:get_name()
        local r_count = stack:get_count()
        if string.find(ri_name, "group:") then
          ri_name = ri_name:split(":")[2] -- from "group:name n" im taking first "group:name" then "name"
        end

        input_match[i] = false
        for j=1,src_size do
          stack = ItemStack(src_list[j])
          local s_count = 1
          if stack ~= nil then
            item_name = stack:get_name()
            s_count = stack:get_count()
          end

          --minetest.chat_send_all("src item ["..j.."] ".. item_name )
            if item_name == ri_name or minetest.get_item_group(item_name, ri_name) > 0 then

              if s_count >= r_count then
                --minetest.chat_send_all("recipe item ["..i.."] ".. ri_name .. " ".. r_count .. " TO ".. recipe_output )
                -- correct item is there, check next item
                input_match[i] = true

                -- /!\ should check if the repaired tool has not full wear to actualy repair it.
                -- TODO also... i shouldnt allow dismantle of tool almost broken (¼ ?)

              end -- if there are enough items in the stack to be taken

            end -- if recipe inputs is present in src

          end -- for src items


        end -- for recipe_inputs

    end -- check only if there are at least the same number of stacks in src

    -- i KNOW that there MUST BE a clever, better way to do this... but there are still some not matching items that slip in... ugh
    if input_match[1] ~= nil then
      for i=1,ri_size do
        if input_match[i] == false then
          allowed = false
        end
      end
    else
      allowed = false
    end

    if allowed == true  then
      local outstack = ItemStack(recipe_output)
      local tool = k:split("_")[2] -- pattern is "type_tool_ingot"
      local material = k:split("_")[3]
      local meta = outstack:get_meta()
      if v[1] == "dismantle" then
        meta:set_string("description", "Dismantle ".. material .." " .. tool)
      elseif v[1] == "repair" then
        meta:set_string("description", "Repair ".. material .." " .. tool)
      end
      meta:set_string("key", k)
      table.insert(choices, outstack)
      choices_left = choices_left -1
    end

    if choices_left < 1 then
      break
    end -- if there isnt enough space, returns only the first 16 found recipes, TODO scroll feature to bypass the problem

  end -- for recipe_list

  if choices[1] == nil then
    return false, {}
  end

  return true, choices

end -- used in refresh_choices()
