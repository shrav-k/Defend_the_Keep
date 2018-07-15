--<<
local wc2_utils = {}
-- variabel access with 
--local wc2_utils.vars = {}

function wc2_utils.split_to_array(s, res)
	res = res or {}
	for part in tostring(s or ""):gmatch("[^%s,][^,]*") do
		table.insert(res, part)
	end
	return res
end

function wc2_utils.split_to_set(s, res)
	res = res or {}
	for part in tostring(s or ""):gmatch("[^%s,][^,]*") do
		res[part] = true
	end
	return res
end

function wc2_utils.remove_dublicates(t)
	local found = {}
	for i = #t, 1, -1 do
		local v = t[i]
		if found[v] then
			table.remove(t, i)
		else
			found[v] = true
		end
	end
end

function wc2_utils.wml_sub(str)
	return wml.tovconfig({str = str}).str
end

--comma seperated list
function wc2_utils.pick_random(str, generator)
	local s2 = wml.variables[str]
	if s2 ~= nil or generator then
		local array = s2 and wc2_utils.split_to_array(s2) or {}
		if #array == 0 and generator then
			array = generator()
		end
		local index  = wesnoth.random(#array)
		local res = array[index]
		table.remove(array, index)
		wml.variables[str] = table.concat(array, ",")
		return res
	end
end

--wml array
function wc2_utils.pick_random_t(str)
	local size = wml.variables[str .. ".length"]
	if size ~= 0 then
		local index = wesnoth.random(size) - 1
		local res = wml.variables[str .. "[" ..  index .. "]"]
		wml.variables[str .. "[" ..  index .. "]"] = nil
		return res
	end
end

--like table concat but for tstrings.
function wc2_utils.concat(t, sep)
	local res = t[1]
	if not res then
		return ""
	end
	for i = 2, #t do
		-- uses .. so we dont hae to call tostring. so this function can still return a tstring.
		res = res .. sep .. t[i]
	end
	return res
end

function wc2_utils.range(a1,a2)
	if a2 == nil then
		a2 = a1
		a1 = 1
	end
	local res = {}
	for i = a1, a2 do
		res[i] = i
	end
	return res
end

function wc2_utils.facing_each_other(u1,u2)
	u1.facing = wesnoth.map.get_relative_dir(u1.x, u1.y, u2.x, u2.y)
	u2.facing = wesnoth.map.get_relative_dir(u2.x, u2.y, u1.x, u1.y)
	wesnoth.wml_actions.redraw {}
end

function wc2_utils.has_no_advances(u)
	return #u.advances_to == 0
end

return wc2_utils
-->>
