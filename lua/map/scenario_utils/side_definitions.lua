
---------------------------------------------------------
---- Code to add the [side]s to the [scenario]       ----
---- And the wml events to initilize the enemy sides ----
---------------------------------------------------------

_ = wesnoth.textdomain "wesnoth"
helper = wesnoth.require("helper")

local function table_join(t1, t2)
	local r = {}
    for i=1,#t1 do
        r[#r+1] = t1[i]
    end
    for i=1,#t2 do
        r[#r+1] = t2[i]
    end
	return r
end

local function adjust_enemy_bonus_gold(bonus_gold, nplayers, difficulty_enemy_power)
	--difficulty_enemy_power is in [6,9]
	local factor = (nplayers + 1) * (difficulty_enemy_power/6) - 2
	return factor * bonus_gold
end

local function add_enemy_side(scenario, gold, starting_pos)
	std_print("starting pos:", starting_pos)
	local side_num = #scenario.side + 1
	-- recruits and leader gets overwritten later by [wc2_enemy] implementation
	local side = {
		wml.tag.ai {
			villages_per_scout=20,
			caution=0.1,
		},
		side = side_num,
		type = "Peasant",
		location_id = starting_pos,
		persistent = false,
		canrecruit = true,
		gold = gold,
		controller = "ai",
		team_name = "wct_enemy",
		user_team_name = _ "Enemies",
		fog = true,
		village_gold = 2,
		terrain_liked = "",
		allow_player = false,
		disallow_observers = true,
		recruit = "",
	}
	table.insert(scenario.side, side)
end

local function add_player_side(scenario, scenario_num, gold)
	local side_num = #scenario.side + 1
	local side = {
		side = side_num,
		type = "Peasant",
		id = "wct_leader" .. side_num,
		save_id = "wct_leader" .. side_num,
		persistent = true,
		canrecruit = true,
		gold = gold,
		controller = "human",
		team_name = "wct_player",
		user_team_name = _ "Allies",
		fog = true,
		village_gold = 2,
		share_view = true,
		terrain_liked = "",
	}
	if scenario_num == 1 then
		side.type=""
		side.color_lock = false
		side.faction_lock = false
		side.leader_lock = false
	end
	table.insert(scenario.side, side)
end

local function add_empty_side(scenario)
	local side_num = #scenario.side + 1
	local side = {
		side = side_num,
		controller = "null",
		no_leader = true,
		allow_player = false,
		hidden = true,
		terrain_liked = "",
	}
	table.insert(scenario.side, side)
end

function wc_ii_generate_sides(scenario, prestart_event, nplayers, scenario_num, enemy_stength, enemy_data, scenario_data)

	local n_enemty_sides = scenario_num == 5 and 6 or scenario_num
	local enemy_bonus_gold = adjust_enemy_bonus_gold(enemy_data.bonus_gold, nplayers, enemy_stength)

	for i = 1, nplayers do
		add_player_side(scenario, scenario_num, scenario_data.player_gold)
	end
	for i = nplayers + 1, 3 do
		add_empty_side(scenario)
	end
	for i = 1, n_enemty_sides do
		local side_data = enemy_data.sides[i]
		--note: this must go before the 'wc2_enemy_themed' generated by the mapgen.
		table.insert(prestart_event, wml.tag.wc2_enemy {
			side = #scenario.side + 1,
			commander = side_data.commander,
			have_item = side_data.have_item,
			trained = side_data.trained,
			supply = side_data.supply,
			wml.tag.recall {
				level2 = side_data.recall_level2,
				level3 = side_data.recall_level3,
			},
		})
		add_enemy_side(scenario, enemy_data.gold + enemy_bonus_gold, i + nplayers)
	end
end
