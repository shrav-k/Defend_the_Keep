-- The difficulty dialog. unlike other files this does not 'export' functions,
-- just run this file to show the diffculty dialog.
local _ = wesnoth.textdomain 'wesnoth-World_Conquest_II'
local vars = wml.variables
local strings = {
	chose_difficulty = "<span size='large'>" .. _"Choose difficulty level:" .. "</span>",
}

local function icon_human_difficult(unit_image, color)
	return "misc/blank-hex.png~SCALE(140,100)" ..
		"~BLIT(units/" .. unit_image .. ".png~RC(magenta>" .. color .. "),34,7)"
end

local function str_dif_lvl(name)
	return "<span size='large'>" .. name ..  "</span>"
end

local icon_nightmare_difficulty = "units/monsters/fire-dragon.png~CROP(0,0,160,160)~RC(magenta>red)"


local t_option = wml.tag.option

local function wct_difficulty(name, power, enemy_t, heroes, gold, train, exp)
	local nplayers = vars.players
	if nplayers == 1 then
		heroes = heroes + 1
	end
	-- adjust bonus gold for number of players
	gold = gold * math.pow(2, 3 - nplayers)
	vars["difficulty.name"] = name
	vars["difficulty.enemy_power"] = power
	vars["difficulty.enemy_trained"] = enemy_t
	vars["difficulty.heroes"] = heroes
	vars["difficulty.extra_gold"] = gold
	vars["difficulty.extra_trainig"] = train
	vars["difficulty.experience_penalty"] = exp
end


function wct_scenario_chose_difficulty()
	wesnoth.wml_actions.message {
		speaker = "narrator",
		caption = strings.chose_difficulty,
		t_option {
			image = icon_human_difficult("human-peasants/peasant", "purple"),
			label = str_dif_lvl("Peasant"),
			description="(" .. _"Easy" .. ")",
			wct_difficulty("Peasant",6, 2, 2, 10, true, 25),
		},
		t_option {
			image=icon_human_difficult("human-loyalists/sergeant", "black"),
			label=str_dif_lvl("Sergeant"),
			wct_difficulty("Sergeant",7, 3, 2, 7, true, 32),
		},
		t_option {
			image=icon_human_difficult("human-loyalists/lieutenant", "brown"),
			label=str_dif_lvl("Lieutenant"),
			wct_difficulty("Lieutenant",8, 4, 2, 5, true, 38),
		},
		t_option {
			image=icon_human_difficult("human-loyalists/general", "orange"),
			label=str_dif_lvl("General"),
			wct_difficulty("General",8, 5, 2, 2, false, 42),
		},
		t_option {
			image=icon_human_difficult("human-loyalists/marshal", "white"),
			label=str_dif_lvl("Grand_marshal"),
			wct_difficulty("Grand_marshal",9, 6, 2, 1, false, 46),
		},
		t_option {
			image=icon_nightmare_difficulty,
			label=str_dif_lvl("Nightmare"),
			description="(" .. _"Expert" .. ")",
			wct_difficulty("Nightmare",9, 7, 1, 0, false, 50),
		},
	}
end

function wct_scenario_start_bonus()
	for side_num = 1, wml.variables.players do
		wesnoth.wml_actions.wc2_start_units {
			side = side_num
		}
	end

	if vars.difficulty.extra_trainig then
		for side_num = 1, wml.variables.players do
			wesnoth.wml_actions.wc2_give_random_training {
				among="2,3,4,5,6",
				side = side_num,
			}
		end
	end
end

wct_scenario_chose_difficulty()
wct_scenario_start_bonus()