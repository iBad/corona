-----------------------------------------------------------
-----------------------------------------------------------
-- pTimer library version 1.0
-- 
-- v1.0 - Initial version
-----------------------------------------------------------
-----------------------------------------------------------

pTimer = {
	allTimers = {},
	debug = false,
};

function pTimer.print(...)
	if (pTimer.debug) then
		print(...);
	end
end

function pTimer.foreach(tagName, fn)
	
	for i = 1, #pTimer.allTimers do
		local t = pTimer.allTimers[i];
		
		if (not t.destroyed) then

			for j = 1, #t.tags do

				if (t.tags[j] == tagName) then
					fn(t);
				end
			end

		end
	end
end


function pTimer.pauseAll(tagName)
	pTimer.foreach(tagName, function(t)
		t:pause();
	end);
end


function pTimer.resumeAll(tagName)
	pTimer.foreach(tagName, function(t)
		t:resume();
	end);
end

function pTimer.cancelAll(tagName)
	pTimer.print("Calling cancel all with tag name '" .. tagName .. "'");

	pTimer.foreach(tagName, function(t)
		t:cancel();

		pTimer.allTimers[t.id] = {
			destroyed = true
		};
	end);
end



function pTimer.createNamed(name, timeOut, callback, arguments)
	pTimer.print("Creating timer '" .. name .. "'");
	local t = pTimer.create(timeOut, callback, arguments);
	return t:setName(name);
end


function pTimer.create(timeOut, callback, arguments)
	if (not callback) then
		return {};
	end

	local function callbackWrapper(event)

		local params = event.source.params;
		pTimer.print("Executing timer '" .. pTimer.allTimers[event.source.myId].name .. "'");
		if (params ~= nil) then
			callback(unpack(params));
		else
			callback();
		end

		pTimer.allTimers[event.source.myId] = {
			destroyed = true
		};
	end

	local timerId = timer.performWithDelay(timeOut, callbackWrapper);

	local myId = #pTimer.allTimers + 1;

	timerId.params = arguments;
	timerId.myId = myId;

	pTimer.allTimers[myId] = {
		timerId = timerId,
		id = myId,
		tags = {},
		name = "unnamed",

		cancel = function(self)
			pTimer.print("Cancelling timer '" .. self.name .. "'");
			timer.cancel(self.timerId);
			return self;
		end,
		pause = function(self)
			pTimer.print("Pausing timer '" .. self.name .. "'");
			timer.pause(self.timerId);
			return self;
		end,
		resume = function(self)
			pTimer.print("Resuming timer '" .. self.name .. "'");
			timer.resume(self.timerId);
			return self;
		end,
		setTag = function(self, tagName)
			table.insert(self.tags, tagName);
			return self;
		end,
		setName = function(self, name)
			self.name = name;
			return self;
		end
	};

	return pTimer.allTimers[myId];
end