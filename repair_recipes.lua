local parts = {"helmet","chestplate","leggings","boots"}
local chainmail_ingot = {"steel","gold","silver","diamond"}
local plate_ingot = {"steel","bronze","damascus","adamantite"}

-- local shield_repair_recipes = {}
-- local default_tools_repair_recipes = {}
-- local rpg_weapons_repair_recipes = {}

local armour_repair_recipes = {
	-- type,		 necessary repair item, 	hammer needed, 	result is the same as the given item all from yl_rpg_armors
	{"steel_chainmail",	"basic_materials:steel_wire",3,	""..hammers[2]},
	{"gold_chainmail",	"basic_materials:gold_wire",3,	""..hammers[3]},
	{"silver_chainmail",	"basic_materials:silver_wire",3,""..hammers[3]},
	--{"steel_plate" ,	"default:steel_ingot",1,	""..hammers[2]},
	--{"bronze_plate",	"default:bronze_ingot",1,	""..hammers[3]},
}
for k, v in pairs(armour_repair_recipes) do
	for i=1,#parts do
		smithing.dual_register_recipe('smithing_anvil', {
			input = {
				--yl_rpg_armors:helmet_steel_chainmail
				["yl_rpg_armors:"..parts[i].."_"..v[1] ] = 1,
				[""..v[2] ] = v[3],
				["yl_smithing:".. v[4] .."_hammer"] = 1,
			},
			output = "yl_rpg_armors:"..parts[i].."_"..v[1] ,
			returns = {
				["yl_smithing:".. v[4] .."_hammer"] = 1,
			}
		})
	end
end
--[[
local armour_repair_recipes = {
	-- type, repair item qty, min hammer needed,
	{"chainmail",	3,	""..hammers[ chainmail_ingot[k] ] },
	{"plate",	1,	""..hammers[ plate_ingot[k] ]},
}
]]--

local shield_repair_recipes = {
	{"steel_chainmail",	"basic_materials:steel_wire",3,	""..hammers[2]},
	{"gold_chainmail",	"basic_materials:gold_wire",3,	""..hammers[3]},
	{"silver_chainmail",	"basic_materials:silver_wire",3,""..hammers[3]},
	--{"steel_plate" ,	"default:steel_ingot",1,	""..hammers[2]},
	--{"bronze_plate",	"default:bronze_ingot",1,	""..hammers[3]},
}

