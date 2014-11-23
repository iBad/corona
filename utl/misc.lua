

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

function UTL.RateApp(config) 
	local packageName = system.getInfo("androidAppPackageName");
	local targetStore = system.getInfo("targetAppStore");
	
	config = config or {
		androidAppPackageName = system.getInfo("androidAppPackageName"),
		iOSAppId = Config.IOS_APP_ID,
		supportedAndroidStores = { system.getInfo("targetAppStore") }
	};

	native.showPopup("appStore", config);

	if (Device.isSimulator) then
		native.showAlert(Config.GAME_NAME, "Showing Rate Popup", { "OK" });
	end

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

		UTL.Dump(self);

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

function UTL.FileExist( fname, path )
    local results = false;
    local filePath = system.pathForFile( fname, path );

    if filePath then
        filePath = io.open( filePath, "r" );
    end

    if  filePath then
        filePath:close();
        results = true;
    end

    return results;
end


function UTL.CreateFolder(name)

	local lfs = require "lfs"
	local temp_path = system.pathForFile( "", system.TemporaryDirectory )
	local success = lfs.chdir( temp_path ) -- returns true on success
	local new_folder_path

	if success then
	   lfs.mkdir( name )
	   new_folder_path = lfs.currentdir() .. "/" .. name
	end

end


function UTL.Error(msg)
	if (Device.isSimulator) then
		native.showAlert("Error", msg, {"OK"});
	else
		print(msg);
	end
end







function UTL.ToPostData(tbl)
	local p = {};
	for k,v in pairs(tbl) do

		if (type(v) == "table") then

			for k1,v1 in pairs(v) do
				p[#p + 1] = k .. "%5B" .. k1 .. "%5D=" .. v1;
			end

		else
			p[#p + 1] = k .. "=" .. v;
		end

	end

	local str = "";

	for i = 1, #p do
		str = str .. p[i];
		if (i ~= #p) then
			str = str .. "&";
		end
	end

	return str;
end


function UTL.Post(url, data, onsuccess, onerror, oncomplete) 
	onsuccess = onsuccess or UTL.EmptyFn;
	onerror = onerror or UTL.EmptyFn;
	oncomplete = oncomplete or UTL.EmptyFn;

	local params = {};

	params.body = UTL.ToPostData(data);
	params.timeout = 10;

	local function networkListener(event)
		if ( event.isError ) then
			onerror({
				isError = true,
				message = "Network error"
			});
			return oncomplete();
		else
			
			local r = JSON.decode(event.response);
			if (r == nil) then
				onerror({
					isError = true,
					message = "Invalid response from server"
				});
				UTL.Dump(event);
				return oncomplete();
			end

			if (r.is_error) then
				
				onerror({
					isError = true,
					message = r.message
				});
				return oncomplete();
			end

			onsuccess(r);
			return oncomplete();
		end

	end

	network.request(url, "POST", networkListener, params);
end


