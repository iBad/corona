
function UTL.ArrayEqual(s1, s2)
	if (#s1 ~= #s2) then
		return false;
	end

	for i = 1, #s1 do
		if (s1[i] ~= s2[i]) then
			return false;
		end
	end

	return true;
end



function table.shuffle(t)
	--math.randomseed(os.time())
	assert(t, "table.shuffle() expected a table, got nil")
	local iterations = #t
	local j
	for i = iterations, 2, -1 do
		j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end

function table.merge(t1, t2)
	for i=1,#t2 do
		t1[#t1+1] = t2[i];
	end
	return t1;
end



function table.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
	t2[k] = v
  end
  return t2
end


function table.clone(t, seen)
	seen = seen or {}
	if t == nil then return nil end
	if seen[t] then return seen[t] end

	local nt = {}
	for k, v in pairs(t) do
		if type(v) == 'table' then
			nt[k] = table.copy(v, deep, seen)
		else
			nt[k] = v
		end
	end
	setmetatable(nt, table.clone(getmetatable(t), seen))
	seen[t] = nt
	return nt
end


function table.pick_random(tbl)
	if (#tbl ~= 0) then
		return tbl[math.random(#tbl)];
	end

	local keyset={}
	local n=0

	for k,v in pairs(tbl) do
		n=n+1
		keyset[n]=k
	end
	local rnd = math.random(n);
	return tbl[keyset[rnd]], keyset[rnd];
end




function table.objsort(t, cmpLess, start, endi)
	start, endi = start or 1, endi or #t;
	if (endi - start < 1) then 
		return t;
	end

	local pivot = start;

	for i = start + 1, endi do
		if cmpLess(t[i], t[pivot]) then
	  		local temp = t[pivot + 1];
	  		t[pivot + 1] = t[pivot];

			if(i == pivot + 1) then
				t[pivot] = temp;
			else
				t[pivot] = t[i];
				t[i] = temp;
			end
	  		
	  		pivot = pivot + 1;
		end
  	end
  	t = table.objsort(t, cmpLess, start, pivot - 1);
  	return table.objsort(t, cmpLess, pivot + 1, endi);
end

