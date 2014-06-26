


--[[
UTL.SetSetting(name, value)
Saves value in settings file

Usage:
UTL.SetSetting("last_level", 6);

]]
function UTL.SetSetting(name, value)
	local setting = UTL.LoadTable("settings.json");

	if (setting == nil) then
		setting = {};
	end

	setting[name] = value;
	UTL.SaveTable(setting, "settings.json");
end

--[[
UTL.GetSetting(name, [default])
Retrieves value from settings file. If not found return defaul value

Usage:
local lastLevel = UTL.GetSetting("last_level", 1);

]]
function UTL.GetSetting(name, default)
	local setting = UTL.LoadTable("settings.json");

	if (setting == nil) then
		return default;
	end

	if (setting[name] == nil) then
		return default;
	end

	return setting[name];
end



--[[
UTL.SaveTable(t, filename)
Saves table info file in JSON format

Usage:

UTL.SaveTable({
	a = "somevalue",
	b = 2193
}, "file.json");
]]
function UTL.SaveTable(t, filename)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
    local file = io.open(path, "w")
    if file then
        local contents = JSON.encode(t)
        file:write( contents )
        io.close( file )
        return true
    else
        return false
    end
end



--[[
UTL.LoadTable(filename, [dir])
Load table from JSON file

Usage:
local myTable = UTL.LoadTable("file.json");
]]
function UTL.LoadTable(filename, dir)
	if (dir == nil) then
		dir = system.DocumentsDirectory;
	end

    local path = system.pathForFile( filename, dir)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
         -- read all contents of file into a string
         local contents = file:read( "*a" )
         myTable = JSON.decode(contents);
         io.close( file )
         return myTable 
    end
    return nil
end




function UTL.NewVariable(filename)
	local tbl = UTL.LoadTable(filename);
	if not (tbl) then
		tbl = {};
	end

	return setmetatable({
			Get = function()
				return tbl;
			end
		}, {
		__index = function(t, key)
			return tbl[key];
		end,

		__newindex = function(t, key, value)
			tbl[key] = value;
			UTL.SaveTable(tbl, filename);
		end
	});
end



