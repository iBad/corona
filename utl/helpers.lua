

--[[
UTL.ClearGroup(group)
Clean everything in group using UTL.SafeRemove
]]
function UTL.ClearGroup(group)
	for i = group.numChildren, 1, -1 do

		if (group[i].numChildren ~= nil) then
			UTL.ClearGroup(group[i]);
		end

		UTL.SafeRemove(group[i]);
	end
end


--[[
UTL.SafeRemove(group)
Calls obj:removeSelf() in pcall
]]
function UTL.SafeRemove(obj)

	if (obj ~= nil and obj.D ~= nil and type(obj.D) == "table") then
		for k, v in pairs(obj.D) do
			print("Calling destructor of object called '" .. k .. "'");
			pcall(v);
		end
	end

	return pcall(function()
		obj:removeSelf();
	end);
end


--[[
UTL.DoLater(fn)
call fn in 1 milisecond
]]
function UTL.DoLater(fn)
	timer.performWithDelay(1, fn);
end



function UTL.DoAsync(func)
	timer.performWithDelay(1, func);
end


--[[
UTL.CallIf(func)
Schedules function call not nil
]]
function UTL.CallIf(func, ...)
	if (func) then
		func(...);
	end
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
	print("Use table.clone() insted");
	return JSON.decode(JSON.encode(obj));
end



function UTL.OneOf(...)
	local items = {...};
	local ind = math.random(1, #items);
	return items[ind];
end


function UTL.InRange(num, min, max)
	return (num <= max) and (num >= min);
end


function UTL.Range(val, min, max)
	if (val < min) then return min; end
	if (val > max) then return max; end
	return val;
end

UTL.Clip = UTL.Range;



