
UTL.BackInfo = {}


--[[
UTL.CleanUp()
Removes all hidden scenes and calls garbage collection
]]
function UTL.CleanUp()
	Composer.removeHidden();
	collectgarbage("collect");
end



--[[
UTL.SetBackScene(sceneName, confirmFunction)

Sets back scene for current scene, if confirmFunction is not nil then it will be called before going back.
If sceneName is nil then exits app.

Usage:

function create(group, params, scene);
	UTL.SetBackScene("mainmenu");
	...
	...
end

or 


function create(group, params, scene);
	UTL.SetBackScene("mainmenu", function(cb)
		-- Ask user if he wants to go back and if yes
		-- cb();
	end);

	...
	...
end
]]
function UTL.SetBackScene(sceneName, confirmFunction)
	UTL.BackInfo.name = sceneName;
	UTL.BackInfo.confirm = confirmFunction;
end


--[[
UTL.GoBack()

Goes back as specified using UTL.SetBackScene
]]
function UTL.GoBack()
	print("Go back", UTL.BackInfo.name, UTL.BackInfo.confirm);

	if (Composer.getSceneName("overlay") ~= nil) then
		local overlayName = Composer.getSceneName("overlay");

		local scene = Composer.getScene(overlayName);

		if (not scene.ignoreOnBack) then
			print("Hiding overlay ", overlayName);
			Composer.hideOverlay();
			return;
		end
	end

	local function GoBackImpl()
		collectgarbage("collect");
		
		print("Going back to: ", UTL.BackInfo.name, UTL.BackInfo.confirm);
		Composer.gotoScene(UTL.BackInfo.name, {
			params = {
				fromBack = true
			}
		});
	end
	
	if (UTL.BackInfo.name ~= nil) then

		if (UTL.BackInfo.confirm) then
			UTL.BackInfo.confirm(GoBackImpl);
		else
			GoBackImpl();
		end

	else

		if (UTL.BackInfo.confirm) then
			UTL.BackInfo.confirm();
		else
			native.requestExit();
		end

	end

end

--[[
UTL.RateApp() 

Opens rate dialog. For iOS it is required to have Config.IOS_APP_ID variable set to app ID

Usage:

Config = {
	IOS_APP_ID = "000000000"
};

local function create(group, params, scene)
	-- when user clicks Rate button call
	UTL.RateApp();
end
]]

function UTL.RateApp() 
	local packageName = system.getInfo("androidAppPackageName");
	local targetStore = system.getInfo("targetAppStore");
	
	native.showPopup("rateApp", {
		androidAppPackageName = system.getInfo("androidAppPackageName"),
		iOSAppId = Config.IOS_APP_ID,
		supportedAndroidStores = { system.getInfo("targetAppStore") }
	});

	if (Device.isSimulator) then
		native.showAlert(Config.GAME_NAME, "Showing Rate Popup", { "OK" });
	end

end



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



function UTL.LCS(string1, string2)
	local res = {};
	local len1, len2 = string1:len(), string2:len();

	print(len1, len2);

	for i = 0, len1 do
		res[i] = {};
		for j = 0, len2 do
			res[i][j] = {
				len = 0,
				str = ""
			};
		end
	end


	for i = 1, len1 do
		for j = 1, len2 do
			local c1, c2 = string1:sub(i, i), string2:sub(j, j);

			local equal = false;
			if (type(c1) == "string" and  type(c2) == "string") then
				equal = c1 == c2;
			end

			if (type(c1) == "table" and  type(c2) == "table") then
				equal = UTL.ArrayEqual(c1, c2);
			end


			if (equal) then
				print(c1, c2, "equal");
				res[i][j].len = res[i - 1][j - 1].len + 1;
				res[i][j].str = res[i - 1][j - 1].str .. c1;
			else

				print(c1, c2, "not equal");
				if (res[i - 1][j].len > res[i][j - 1].len) then
					res[i][j].len = res[i - 1][j].len;
					res[i][j].str = res[i - 1][j].str;
				else
					res[i][j].len = res[i][j - 1].len;
					res[i][j].str = res[i][j - 1].str;
				end


			end
		end
	end
	print("LCS(" .. string1 .. ", " .. string2 .. ") = " .. res[len1][len2].str);
	return res[len1][len2].str;
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

function table.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end




function string.lpad(str, len, char)
    if char == nil then char = ' ' end
    return str .. string.rep(char, len - #str)
end

function string.rpad(str, len, char)
    if char == nil then char = ' ' end
    return string.rep(char, len - #str) .. str
end

function string.char_replace(pos, str, r)
    return ("%s%s%s"):format(str:sub(1,pos-1), r, str:sub(pos+1));
end

function string.at(str, index)
	return string.sub(str, index, index);
end



display.newOutlinedText = function(parent, text, x, y, font, size, outlineSize) 
	local group = display.newGroup();
	parent:insert(group);


	local iterations = outlineSize * 2;

	local deltas = {};

	local angle = 0;
	local deltaAngle = 2 * math.pi / iterations;

	for i=1, iterations do
		deltas[#deltas + 1] = { math.sin(angle), math.cos(angle) };
		angle = angle + deltaAngle;
	end

	local outlines = {};

	for i = 1, #deltas do
		local delta = deltas[i];
		local x = delta[1] * outlineSize;
		local y =  delta[2] * outlineSize;
		outlines[i] = display.newText(group, text, 0, 0, font, size);
		outlines[i].anchorX = 0.5;
		outlines[i].anchorY = 0.5;
		outlines[i].x = x;
		outlines[i].y = y;
	end

	local txt = display.newText(group, text, 0, 0, font, size);
	txt.anchorX = 0.5;
	txt.anchorY = 0.5;

	group.setText = function(self, text)
		txt.text = text;
		for i = 1, #outlines do
			outlines[i].text = text;
		end
	end

	group.setOutlineColor = function(self, r, g, b)
		for i = 1, #outlines do
			outlines[i]:setFillColor(r, g, b);
		end
	end

	group.setFillColor = function(self, r, g, b)
		txt:setFillColor(r, g, b);
	end

	group.anchorChildren = true;
	group:translate(x, y);
	return group;
end


function UTL.GetTime(timestamp)
	return os.date("%H:%M:%S %d %b %Y", timestamp);
end


function UTL.Range(val, min, max)
	if (val < min) then return min; end
	if (val > max) then return max; end
	return val;
end






function UTL.MultiIndexMap()
	local miMap = {
		vals = {}	
	};

	miMap.Set = function(self, ...)
		local t = {...};

		local cval = self.vals;

		for i = 1, #t - 2 do
			if (cval[t[i]] == nil) then
				cval[t[i]] = {};
			end
			cval = cval[t[i]];
		end

		cval[t[#t - 1]] = t[#t];
	end

	miMap.Get = function(self, ...)
		local t = {...};

		local cval = self.vals;

		for i = 1, #t do
			if (cval[t[i]] == nil) then
				return nil;
			end
			cval = cval[t[i]];
		end

		return cval;
	end

	return miMap;
end





function UTL.Set()
	local set = {
		vals = UTL.MultiIndexMap()
	};

	set.Set = function(self, ...)
		self.vals:Set(..., 1);
	end

	set.IsSet = function(self, ...)
		local v = self.vals:Get(...);
		return (v == 1);
	end

	return set;
end

function UTL.GetDist(o1, o2) 
	return math.pow(math.pow(o1.x - o2.x, 2) + math.pow(o1.y - o2.y, 2), 0.5);
end

function UTL.GetAngle(o1, o2)
	local distance = UTL.GetDist(o1, o2);

	local dx = (o1.x - o2.x) / distance;
	local dy = (o1.y - o2.y) / distance;

	local angle = math.asin(dx) / math.pi * 180;
	if (dy > 0) then
		angle = 180 - angle;
	end

	return angle;
end



function UTL.URLify(str)
	local result = "";
	for i = 1, string.len(str) do
		local ch = string.sub(str, i, i);
		if (ch ~= " ") then
			result = result .. ch;
		else
			result = result .. "%20";
		end
	end
	return result;
end

