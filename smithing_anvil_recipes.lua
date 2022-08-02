print("smithing_anvil_recipes.lua LOADED")

hammers = {"iron","steel","bronze","damascus","adamantite"} -- dovrebbe essere lo stesso
-- hammers = {[1] = {"iron"}, [2] = {"steel"}, [3] = {"bronze"}, [4] = {"damascus"}, [5] = {"adamantite"}}

local hammer_recipes = {
	{"yl_smithing:iron_ingot",2,	"default:stick",1,"yl_smithing:iron_hammer",1},
	{"default:steel_ingot",2,	"basic_materials:iron_rod",1,"yl_smithing:steel_hammer",1},
	{"default:bronze_ingot",2,	"basic_materials:iron_rod",1,"yl_smithing:bronze_hammer",1},
	{"yl_smithing:damascus_ingot",2,"basic_materials:iron_rod",1,"yl_smithing:damascus_hammer",1},
	{"yl_smithing:adamantite_ingot",2,"basic_materials:iron_rod",1,"yl_smithing:adamantite_hammer",1}
}

local singular_recipes = {
	{"basic_materials:steel_wire",4, ""..hammers[2],"yl_rpg_armors:steel_chainmail",1},
	{"basic_materials:gold_wire",4,	 ""..hammers[3],"yl_rpg_armors:gold_chainmail",1},
	{"basic_materials:silver_wire",4,""..hammers[3],"yl_rpg_armors:silver_chainmail",1},
	{"default:steel_ingot",2, 	 ""..hammers[2],"yl_rpg_armors:steel_plate",1},
	{"default:gold_ingot",2, 	 ""..hammers[3],"yl_rpg_armors:gold_plate",1},
	--{"default:bronze_ingot",2, 	 ""..hammers[3],"yl_rpg_armors:bronze_plate",1},
}
local dual_recipes = {
	{"yl_smithing:iron_ingot",2, 	"default:coal_lump",4,       		   	""..hammers[1],"default:steel_ingot",2},
	{"mobs:leather",8, 		"default:steel_ingot",2,         		""..hammers[2],"yl_smithing:padded_leather",4},
	{"default:copper_ingot",7, 	"default:tin_ingot",1,         			""..hammers[2],"default:bronze_ingot",8},
	{"default:copper_ingot",2, 	"moreores:silver_ingot",1,      		""..hammers[3],"basic_materials:brass_ingot",1},
	{"moreores:silver_ingot",4, 	"ethereal:crystal_spike",1,    			""..hammers[3],"yl_smithing:astral_silver_ingot", 4}, -- ice
	{"default:gold_ingot",4,	"ethereal:fire_dust",1,    	  		""..hammers[3],"yl_smithing:flaring_gold_ingot",4}, -- fire
	{"yl_smithing:steel_ingot",2,	"yl_smithing:flaring_gold_ingot",3,   		""..hammers[3],"yl_smithing:damascus_ingot", 3},
	{"yl_smithing:steel_ingot",2,	"basic_materials:energy_crystal_simple",1, 	""..hammers[4],"yl_smithing:adamantite_ingot",3},
	{"yl_rpg_armors:gold_chainmail",1, "default:diamond",4, 			""..hammers[5],"yl_rpg_armors:diamond_chainmail",1}
}
local thrice_recipes = { -- infuse
	{"default:diamond",2,"default:gold_ingot",1,"default:mese_crystal_fragment",2,	""..hammers[4],"basic_materials:energy_crystal_simple",1},
	{"yl_smithing:astral_silver_ingot",1,"yl_smithing:flaring_gold_ingot",1,
		"basic_materials:energy_crystal_simple",1, 				""..hammers[4],"yl_smithing:mirage_ingot",2}, -- all arcane
}

local function hammers_hardness_min (ingot_required)
	--[[ -- indexes of table
	local indexes={}
	for k,v in ipairs(hammers) do
		indexes[v]=k
		if ""..indexes[v] == ingot_required then -- != > ~=
			break -- must always be the last statement before end
		end
	end
	--]]
	---[=[ -- from given ingot to max
	local given_ingot_k = 0
	for k,v in ipairs(hammers) do
		if ingot_required == v then -- two strings
			given_ingot_k = k
			break
		end
	end
	local ingots = {}
	local ii = 0
	for i= given_ingot_k, 5 do
		ii = ii + 1 -- ingots[ii+1] doesnt update ii
		ingots[ii]=""..hammers[i]
	end
	return ingots
	--]=]
	--[==[ -- from 1 to given ingot
	local ingots = {}
	for i=1,#hammers do
		ingots[i]=hammers[i]
		if ""..ingots[i] == ""..ingot_required then -- != > ~=
			break 
		end
	end
	return ingots
	--]==]
end

-- TODO make the hammers wear out every use, to do that the hammers need to be tools (consider implications)
-- https://stackoverflow.com/questions/23350281/bizzare-attempt-to-call-a-table-value-in-lua ????????

for k, v in pairs(hammer_recipes) do
	for index, ingot in ipairs(hammers) do
		smithing.dual_register_recipe('smithing_anvil', {
			input = {
				[""..v[1]..""] = v[2],
				[""..v[3]..""] = v[4],
			},
			output = v[5].." "..v[6],
		})
	end
end

for k, v in pairs(singular_recipes) do
	local hardness_required = hammers_hardness_min(v[3]) -- v[3] => {"ingot"}
	for index, ingot in ipairs(hardness_required) do
		smithing.dual_register_recipe('smithing_anvil', {
			input = {
				[""..v[1]..""] = v[2],
				["yl_smithing:".. ingot .."_hammer"] = 1,
			},
			output = v[4].." "..v[5],
			returns = {
				["yl_smithing:".. ingot .."_hammer"] = 1,
			},
		})
	end
end

for k, v in pairs(dual_recipes) do
	local hardness_required = hammers_hardness_min(v[5])
	for index, ingot in ipairs(hardness_required) do
		smithing.dual_register_recipe('smithing_anvil', {
			input = {
				[""..v[1]..""] = v[2],
				[""..v[3]..""] = v[4],
				["yl_smithing:".. ingot .."_hammer"] = 1,
			},
			output = v[6].." "..v[7],
			returns = {
				["yl_smithing:".. ingot .."_hammer"] = 1,
			},
		})
		
	end
end

for k, v in pairs(thrice_recipes) do
	local hardness_required = hammers_hardness_min(v[7])
	for index, ingot in ipairs(hardness_required) do
		smithing.dual_register_recipe('smithing_anvil', {
			input = {
				[""..v[1]..""] = v[2],
				[""..v[3]..""] = v[4],
				[""..v[5]..""] = v[6],
				["yl_smithing:".. ingot .."_hammer"] = 1,
			},
			output = v[8].." "..v[9],
			returns = {
				["yl_smithing:".. ingot .."_hammer"] = 1,
			},
		})
		
	end
end
