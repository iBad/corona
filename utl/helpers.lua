--[[
UTL.NewScene(OnCreate, [OnDestroy]) 

Usage: Use for composer.newScene() wrapping. Gets two functions OnCreate and OnDestroy. 
OnCreate funcitons will receive 3 arguments GroupObject of scene (i.e. self.view), params passed to gotoScene and scene itself
When scene is destroyed wrapper will automatically call Destructors (all functions added to scene.D) (see example)

Example file test.lua:

local function create(group, params, scene)
	local timerId = timer.performWithDelay(1000, function()
		print("Do something");
	end);

	scene.D.CancelTimer = function()
		timer.cancel(timerId);
	end
end

return UTL.NewScene(create);

Timer in this example will be called when scene gets destroyed.
]]

function UTL.NewScene(OnCreate, OnDestroy)

	local scene = Composer.newScene();
	scene.D = {};
	scene.X = {};


	function scene:create(event)
		Composer.removeHidden();

		if (OnCreate) then
			OnCreate(self.view, event.params or {}, scene);
		end
	end
	
	function scene:exit(event)
		for k, v in pairs(self.X) do
			print("Calling on exit destructor '" .. k .. "'");
			pcall(v);
		end
	end
	
	function scene:destroy(event)
		for k, v in pairs(self.D) do
			print("Calling on destroy destructor '" .. k .. "'");
			pcall(v);
		end

		if (OnDestroy) then
			OnDestroy();
		end
	end



	scene:addEventListener("create", scene);
	scene:addEventListener("exit", scene);
	scene:addEventListener("destroy", scene);
	return scene;
end

--[[
UTL.ClearGroup(group)
Clean everything in group using UTL.SafeRemove
]]
function UTL.ClearGroup(group)
	for i = group.numChildren, 1, -1 do
		UTL.SafeRemove(group[i]);
	end
end


--[[
UTL.SafeRemove(group)
Calls obj:removeSelf() in pcall
]]
function UTL.SafeRemove(obj)
	return pcall(function()
		obj:removeSelf();
	end);
end

--[[
UTL.NewGroup(parent)
Create new group and insert into parent
]]
function UTL.NewGroup(parent, anchor)
	local grp = display.newGroup();
	parent:insert(grp);
	grp.anchorChildren = (anchor == true);
	return grp;
end

--[[
UTL.DoLater(fn)
call fn in 1 milisecond
]]
function UTL.DoLater(fn)
	timer.performWithDelay(1, fn);
end



--[[
UTL.Stringify(this, [docol], [spacing_h], [spacing_v], [preindent])	
Converts complex object to string 
]]
function UTL.Stringify(this, docol, spacing_h, spacing_v, preindent)
	local function _stringify(stack, this, spacing_h, spacing_v, space_n, parsed)
	    local this_type = type(this)
	    if this_type == "string" then
	        stack[#stack+1] = (
	                spacing_v ~= "\n" and string.gsub(string.format("%q", this), "\\\n", "\\n")
	            or  string.format("%q", this)
	        )
	    elseif this_type == "boolean" then
	        stack[#stack+1] = this and "true" or "false"
	    elseif this_type == "number" then
	        stack[#stack+1] = tostring(this)
	    elseif this_type == "function" then
	        local info = debug.getinfo(this, "S")
	        stack[#stack+1] = "function"
	        stack[#stack+1] = ":("
	        if not info or info.what == "C" then
	            stack[#stack+1] = "[C]"
	        else
	            --[[local param_list = debug.getparams(this)
	            for param_i = 1, #param_list do
	                stack[#stack+1] = param_list[param_i]
	            end]]
	        end
	        stack[#stack+1] = ")"
	    elseif this_type == "table" then
	        if parsed[this] then
	            stack[#stack+1] = "<"..tostring(this)..">"
	        else
	            parsed[this] = true
	            stack[#stack+1] = "{"..spacing_v
	            for key,val in pairs(this) do
	                stack[#stack+1] = string.rep(spacing_h, space_n).."["
	                _stringify(stack, key, spacing_h, spacing_v, space_n+1, parsed)
	                stack[#stack+1] = "] = "
	                _stringify(stack, val, spacing_h, spacing_v, space_n+1, parsed)
	                stack[#stack+1] = ","..spacing_v
	            end
	            stack[#stack+1] = string.rep(spacing_h, space_n-1).."}"
	        end
	    elseif this_type == "nil" then
	        stack[#stack+1] = "nil"
	    else
	        stack[#stack+1] = this_type.."<"..tostring(this)..">"
	    end
	end



    local stack = {}
    _stringify(
        stack,
        this,
        spacing_h or "    ", spacing_v or "\n",
        (tonumber(preindent) or 0)+1,
        {}
    )
    return table.concat(stack)
end

--[[
UTL.PrintTable(tbl) and UTL.Dump(tbl)
Dump table to screen
]]
function UTL.PrintTable(tbl)
	print(UTL.Stringify(tbl));
end

function UTL.Dump(tbl)
	print(UTL.Stringify(tbl));
end







--[[
UTL.CallN(count, func)
Creates function-counter which will invoke func after called count times :)

Usage:
Very useful when dealing with animations and timers.

local objectsToZoom = {<list of objects>};

local callback = UTL.CallN(#objectsToZoom, function()
	print("All objects are zoomed in");
end);

for i = 1, #objectsToZoom do
	transition.to(objectsToZoom[i], {
		time = 100,
		onComplete = callback,
		xScale = 2,
		yScale = 2		
	});
end


Example above will print "All objects are zoomed in" once after all transitions are over.
]]
function UTL.CallN(count, func)
	local numCalls = 0;
	return function()
		numCalls = numCalls + 1;
		if (numCalls == count) then
			func();
		end
	end;
end


--[[
UTL.CallIf(func)
Schedules function call not nil
]]
function UTL.CallIf(func)
	if (func) then
		timer.performWithDelay(1, func);
	end
end



--[[
UTL.EmptyFn()
Just an empty function to pass as callback when you want to ignore something
]]
function UTL.EmptyFn()
end

--[[
UTL.FalseFn()
Just an empty function which returns false
]]
function UTL.FalseFn()
	return false;
end

--[[
UTL.TrueFn()
Just an empty function which returns true
]]
function UTL.TrueFn()
	return true;
end



--[[
UTL.Bind(func, ...)
Binds arguments to function and returns function which has no arguments. 
Usage:
Useful when trying to pass functions with arguments as callbacks

transition.to(obj, {
	alpha = 0.3,
	time = 1000,
	onComplete = UTL.Bind(composer.gotoScene, "sceneName")
});

]]
function UTL.Bind(func, ...)
	local args = {...};

	return function()
		return func(unpack(args));
	end;
end


function UTL.DoAsync(func)
	timer.performWithDelay(1, func);
end

--[[
UTL.Chain(...)

Calls all functions in ... sequentially passing i-th functions value(s) to i+1 function and finally returns ast functions return value
Usage:
	local function Func1(a)
		return a + 1;
	end

	local function Func2(a)
		return a + 2;
	end

	local function Func3(a)
		return a + 3;
	end

	local fn = UTL.Chain(Func1, Func2, Func3);
	fn(1);
]]

function UTL.Chain(...)
	local callbacks = {...};

	return function(...)
		local res = {...};
		for i = 1, #callbacks do
			res = { callbacks[i](unpack(res)) };
		end
		return unpack(res);
	end
end

--[[
UTL.OnPhase(phase, ...)
Calls all function in ... when event with phase is called
Usage: 

	obj:addEventListener("touch", UTL.OnPhase("ended", MyFunction1, MyFunction2, MyFunction3));

MyFunction1, MyFunction2, MyFunction3 will be called only when touch event with phase == "ended" fired.
Function passes return value of i-th function to i + 1 and after all functions are executed returns last functions value
]]
function UTL.OnPhase(phase, ...)
	local callbacks = {...};

	return function(event)
		if (event.phase == phase) then
			local res = nil;
			for i = 1, #callbacks do
				res = callbacks[i](event, res);
			end
			return res;
		end
	end;
end



--[[
UTL.Clone(obj)
return clone of obj. Using JSON.encode and JSON.decode to clone
]]
function UTL.Clone(obj)
	return JSON.decode(JSON.encode(obj));
end
