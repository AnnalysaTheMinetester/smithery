local lib = smithery

local function get_anvil_formspec ()
  return "formspec_version[5]" ..
  "size[10.5,11]" ..
  "image[0.65,0.4;9,9;smithing_anvil_icon.png]" ..
  "list[context;src;0.6,1.1;1,3]" ..
  "list[context;choice_slots;2.2,0.5;4,4]" ..
  "list[context;chosen;8.1,0.5;1,1]" ..
  "list[context;dst;7.5,1.75;2,3]" ..
  "list[current_player;main;0.4,5.75;8,1]" ..
  "list[current_player;main;0.4,7;8,3;8]" ..
  "listring[current_player;main]" ..
  "listring[context;src]" ..
  "listring[current_player;main]" ..
  "listring[context;dst]" ..
  "listring[current_player;main]" ..
  default.get_hotbar_bg(0, 4.25)
end


local function can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("src") and inv:is_empty("dst")
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if listname == "src" then
		return stack:get_count()
	end
  return 0
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
  if from_list == "choice_slots" and to_list == "chosen" then
    inv:set_stack(to_list, 1, stack)
    return 0
  elseif from_list == "chosen" then
    inv:set_stack("chosen", 1, "")
    return 0
  end
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
  if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
  if listname == "choice_slots" then
    return 0
  elseif listname == "chosen" then
    local meta = minetest.get_meta(pos)
  	local inv = meta:get_inventory()
    inv:set_stack(listname, 1, "")
    return 0
  end
	return stack:get_count()
end

local function refresh_choices (pos, listname, index, stack, player)
  if listname == "src" then
    local meta = minetest.get_meta(pos)
  	local inv = meta:get_inventory()
    local src_list, src_size = inv:get_list(listname), inv:get_size(listname)
    local items_in_src = lib.get_stack_count(src_list, src_size)
    local cr, choices = lib.contains_recipe(src_list, items_in_src, 16)
    --if cr then
    -- choices needs to reset and be empty if src doesnt contain a recipe
      inv:set_list("choice_slots", choices)
      inv:set_stack("chosen", 1, "")
    --end
  end
end -- used in on_metadata_inventory_put and take, and move in a specific circumstance

local function on_metadata_inventory_move (pos, from_list, from_index, to_list, to_index, count, player)
  if from_list == "dst" and to_list == "src" then
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local stack = inv:get_stack(from_list, from_index)
    refresh_choices(pos, to_list, to_index, stack, player )
  end
end

local smithing_anvil_table_def = {
   description = 'Blacksmith Anvil',
   drawtype = 'nodebox',
   --mesh = 'onegoxel000.obj',
   --tiles = {'anvil3wt.png'},
   tiles = {
     "iron_anvil_top.png",
     "iron_anvil_top.png",
     "iron_anvil_side.png",
     "iron_anvil_side.png^[transformFX",
     "iron_anvil_front.png",
     "iron_anvil_front.png",
   },
   use_texture_alpha = "clip",
   sounds = default.node_sound_metal_defaults(),
   paramtype2 = 'facedir',
   paramtype = 'light',
   node_box = {
		type = "fixed",
		fixed = {
      {-0.25, -0.5, -0.25, 0.25, -0.3125, 0.25}, -- Base
			{-0.15625, -0.3125, -0.15625, 0.15625, 0.0625, 0.15625}, -- upperBase
			{-0.25, 0.0625, -0.25, 0.25, 0.375, 0.25}, -- middlecore
			{0.0625, 0.375, -0.25, 0.125, 0.4375, 0.25}, -- hammerHandle
      {-0.0625, 0.375, 0.0625, 0.1875, 0.5, 0.125}, -- hammerhandle2
			{0, 0.375, 0.0625, 0.1875, 0.5, 0.1875}, -- hammerHead
			{-0.375, -0.5, -0.3125, -0.0625, -0.375, 0.3125}, -- base1
			{0.0625, -0.5, -0.3125, 0.375, -0.375, 0.3125}, -- base2
			{-0.375, 0.1875, -0.1875, -0.25, 0.3125, 0.1875}, -- middleleft11
      {-0.5, 0.1875, -0.125, -0.375, 0.3125, 0.125}, -- middleleft12
      {-0.625, 0.1875, -0.0625, -0.5, 0.3125, 0.0625}, -- middleleft13
			{-0.375, 0.125, -0.15625, -0.25, 0.1875, 0.15625}, -- middleleft21
      {-0.5, 0.125, -0.0625, -0.375, 0.1875, 0.0625}, -- middleleft22
			{-0.375, 0.0625, -0.125, -0.25, 0.125, 0.125}, -- middleleft3
			{0.25, 0.0625, -0.1875, 0.3125, 0.3125, 0.1875}, -- middleright1
			{0.3125, 0.125, -0.0625, 0.4375, 0.25, 0.0625}, -- middleright2
			{0.4375, 0.0625, -0.125, 0.5, 0.3125, 0.125}, -- middleright3
		}
	},
  selection_box = {
    type = "fixed",
  	fixed = {
  		{-0.375, -0.5, -0.25, 0.375, -0.3125, 0.25}, -- Base
  		{-0.1875, -0.3125, -0.1875, 0.1875, 0, 0.1875}, -- upperBase
  		{-0.625, 0, -0.25, 0.625, 0.375, 0.25}, -- middle
  		{0.0625, 0.375, -0.25, 0.125, 0.4375, 0.25}, -- hammerHandle
  		{-0.0625, 0.375, 0.0625, 0.1875, 0.5, 0.1875}, -- hammerHead
  	}
  },
  collision_box = {
  type = "fixed",
  fixed = {
  	{-0.375, -0.5, -0.25, 0.375, -0.3125, 0.25}, -- Base
  	{-0.1875, -0.3125, -0.1875, 0.1875, 0, 0.1875}, -- upperBase
  	{-0.625, 0, -0.25, 0.625, 0.375, 0.25}, -- middle
  	{0.0625, 0.375, -0.25, 0.125, 0.4375, 0.25}, -- hammerHandle
  	{-0.0625, 0.375, 0.0625, 0.1875, 0.5, 0.1875}, -- hammerHead
  }
  },
  groups = {crumbly=3, smithing_anvil = 1},

  on_construct = function(pos)
  	local meta = minetest.get_meta(pos)
  	local inv = meta:get_inventory()
  	inv:set_size("src", 3)
    inv:set_size("choice_slots", 16)
  	inv:set_size("chosen", 1)
  	inv:set_size("dst", 6)
  end,

  after_place_node = function(pos, placer, itemstack)
    local meta = minetest.get_meta(pos)
    meta:set_string('infotext', 'Blacksmith Anvil\nSelect an item to craft, then hit the anvil with the hammer.')
    meta:set_string('formspec', get_anvil_formspec() )
  end,

  can_dig = can_dig,

 	allow_metadata_inventory_put = allow_metadata_inventory_put,
 	allow_metadata_inventory_move = allow_metadata_inventory_move,
 	allow_metadata_inventory_take = allow_metadata_inventory_take,
  on_metadata_inventory_put = refresh_choices,
  on_metadata_inventory_take = refresh_choices,
  on_metadata_inventory_move = on_metadata_inventory_move,

  --on_receive_fields = function(pos, formname, fields, sender),

  on_punch = function(pos, node, player, pointed_thing)
    -- 3 things should be done: take enough_items from src, add_wear to the correct hammer, put forged_item in dst
    if player:is_player() then
      local meta = minetest.get_meta(pos)
      local wielded_item = player:get_wielded_item()
      local wielded_item_name = wielded_item:get_name()

      if minetest.get_item_group(wielded_item_name , "hammer") > 0 then
        local inv = meta:get_inventory()
        local src_list = inv:get_list("src")
        local src_size = lib.get_stack_count(src_list, inv:get_size("src"))
        local selected = inv:get_stack("chosen", 1)
        local sl_meta =  selected:get_meta()
        local sl_key =   sl_meta:get_string("key")

        if not selected:is_empty() and inv:room_for_item("dst", selected) then
          local selected_name = selected:get_name()
          local items_needed, hammer_hardness_min, forged_item, repl = lib.get_selected_recipe_results(sl_key)

          if items_needed ~= nil then -- and get group
            local str = "get_selected_recipe_results: inputs: {"
            for i=1,#items_needed do
              str = str .. items_needed[i] .. ", "
            end
            str = str .. "}, hammer_hardness_min: " .. hammer_hardness_min .. ", output: " ..
             forged_item .. ", weilded_hammer_hardness: ".. minetest.get_item_group(wielded_item_name, "hammer_hardness")
          --  minetest.chat_send_all(str)

            if minetest.get_item_group(wielded_item_name , "hammer_hardness") >= hammer_hardness_min then

              -- if enough_items

              for i=1,#items_needed do
                minetest.chat_send_all("revoming items ".. items_needed[i])
                inv:remove_item("src", items_needed[i])
              end -- remove items in src

              -- add_wear to hammer
              local max_uses = lib.get_hammer_max_uses(wielded_item_name)
              wielded_item:add_wear(65535 / (max_uses))
              minetest.chat_send_all("max uses ".. max_uses .. ", total wear ".. wielded_item:get_wear())
              player:set_wielded_item(wielded_item) -- update the wielded hammer

              -- add forged_item to dst
              local leftover = inv:add_item("dst", forged_item)
              local above = vector.new(pos.x, pos.y + 1, pos.z)
              local drop_pos = minetest.find_node_near(above, 1, {"air"}) or above
              if not leftover:is_empty() then
                minetest.item_drop(forged_item, nil, drop_pos)
              end -- if leftover of item is not empty

              -- add replacements to dst
              leftover = inv:add_item("dst", repl)
              if not leftover:is_empty() then
                minetest.item_drop(repl, nil, drop_pos)
              end -- if leftover of item is not empty

              -- needs to be reset as it has just been modified
              src_size = lib.get_stack_count(inv:get_list("src"), inv:get_size("src"))

              -- reset choice_slots if needed
              local cr, choices = lib.contains_recipe(src_list, src_size , inv:get_size("choice_slots") )

              -- check if selected item is still in choices
              local selected_found = false
              local new_csl = inv:get_list("choice_slots")
              local new_csl_size = lib.get_stack_count(new_csl, inv:get_size("choice_slots"))
              for i=1,new_csl_size do
                if new_csl[i] ~= nil and new_csl[i]:get_name() == selected_name then
                  selected_found = true
                  break
                end -- if items arent the same
              end --for choises, to check if the selected item is still there or not

              if cr == false or selected_found == false then
                --enough_items = false
                minetest.chat_send_all("not enough items: cr ".. tostring(cr) .. ", selected_found ".. tostring(selected_found) )
                inv:set_list("choice_slots", choices)
                inv:set_stack("chosen", 1, "")
              end -- if it doesnt contain a recipe anymore or it differs from the selected one, refresh choices

              -- sound handling
              minetest.sound_play("blig1", {pos = pos, max_hear_distance = 8, gain = 0.1})

            else
              minetest.chat_send_player(player:get_name(), "A stronger hammer is required!")
            end -- if hammer_hardness is enough

          end -- if items_needed is not nil, recipe present

        end -- if selected something and there is space for it in dst

      end -- if wielded item has group hammer

    end -- if player:is_player

  end -- on_punch

}

-- TODO anvil craks after a time and is useless, can be repaired with refault craft, steel anvil dosnt have this mechanic
-- also the iron anvil has 4x4 choice_slots, the enchanced one has more with scroll

minetest.register_node('smithery:anvil', smithing_anvil_table_def)

minetest.register_craft({
  output = "smithery:smithing_anvil",
  recipe = {
    {"smithery:iron_ingot", "smithery:iron_block", "smithery:iron_ingot"},
    {"", "smithery:iron_block", ""},
    {"smithery:iron_ingot", "smithery:iron_block", "smithery:iron_ingot"},
  }
}) -- 31 iron ingots

--[[

unified_inventory.register_craft_type("smithing_anvil", {
   description = "Blacksmith Anvil",
   icon = 'smithing_anvil_icon.png',
   width = 3,
   height = 1,
   uses_crafting_grid = false
})

]]--
