-- helper functions for lua map generation.
function get_locations(t)
	-- TODO: this looks wrong
	local filter = wesnoth.create_filter(t.filter, t.filter_extra)
	return map:get_locations(t, t.locs)
end

function set_terrain_impl(data)
	local locs = {}
	local nlocs_total = 0
	for i = 1, #data do
		if data[i].filter then
			local f = wesnoth.create_filter(data[i].filter, data[i].known or {})
			locs[i] = map:get_locations(f, data[i].locs)
		else
			locs[i] = data[i].locs
		end
		nlocs_total = nlocs_total + #locs[1]
	end
	local nlocs_changed = 0
	for i = 1, #data do
		local d = data[i]
		local chance = d.per_thousand
		local terrains = d.terrain
		local layer = d.layer
		local num_tiles = d.nlocs and math.min(#locs[i], d.nlocs) or #locs[i]
		if d.exact then
			num_tiles = math.ceil(num_tiles * chance / 1000)
			chance = 1000
			helper.shuffle(locs[i])
		end
		for j = 1, num_tiles do
			local loc = locs[i][j]
			if chance >= 1000 or chance >= wesnoth.random(1000) then
				map:set_terrain(loc, helper.rand(terrains), layer)
				nlocs_changed = nlocs_changed + 1
			end
		end
	end
end

function set_terrain_simul(cfg)
	cfg = helper.parsed(cfg)
	local data = {}
	for i, r in ipairs(cfg) do
		r_new = {
			filter = r[2] or r.filter,
			terrain = r[1] or r.terrain,
			locs = r.locs,
			layer = r.layer,
			exact = r.exact ~= false,
			per_thousand = 1000,
			nlocs = r.nlocs,
			known = r.known or f.filter_extra
		}
		if r.percentage then
			r_new.per_thousand = r.percentage * 10
		elseif r.per_thousand then
			r_new.per_thousand = r.per_thousand;
		elseif r.fraction then
			r_new.per_thousand = math.ceil(1000 / r.fraction);
		elseif r.fraction_rand then
			r_new.per_thousand = math.ceil(1000 / helper.rand(r.fraction_rand));
		end
		table.insert(data, r_new)
	end
	set_terrain_impl(data)
end

function set_terrain(a)
	set_terrain_simul({a})
end

function set_map_name(str)
	scenario_data.map_name = str
end
