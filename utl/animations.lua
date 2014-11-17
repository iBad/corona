
Animations = {};


function Animations.apply(obj, options, properties)
	local onInit = options.onInit or UTL.EmptyFn;
	local onStep = options.onStep or UTL.EmptyFn;


	local tPrevious = system.getTimer();
	local timePassed = 0;

	local exitFunc = nil;

	local function doStep(event)
		local tDelta = event.time - tPrevious;
		tPrevious = event.time;
		timePassed = timePassed + tDelta;

		onStep(obj, timePassed / 1000, tDelta / 1000, properties, exitFunc);	
	end

	exitFunc = function()
		Runtime:removeEventListener("enterFrame", doStep);
	end


	onInit(obj, exitFunc);
	Runtime:addEventListener("enterFrame", doStep);
end	



---------------------------------------------------------------------------------------
-- A N I M A T I O N S
---------------------------------------------------------------------------------------




---------------------------------------------------------------------------------------
-- x = velocity * t;
-- y = y0 + amplitude * (omega * t)
---------------------------------------------------------------------------------------

Animations.Jumpy = {
	onInit = function(obj, exitFunc)
		obj.originalY = obj.y;
	end,
	onStep = function(obj, timePassed, timeDelta, props, exitFunc)
		obj.x = obj.x + props.velocity * timeDelta;
		obj.y = obj.originalY + math.abs(math.sin(timePassed * props.omega) * props.amplitude);
	end
};





---------------------------------------------------------------------------------------
-- (x, y) = (x0, y0) + (velocityx, velocityy) * t + (accelerationx, accelerationy) * t * t / 2;

---------------------------------------------------------------------------------------

Animations.SimplePhysics = {
	onInit = function(obj, exitFunc)
		obj.originalX = obj.x;
		obj.originalY = obj.y;

	end,

	onStep = function(obj, timePassed, timeDelta, props, exitFunc)
		obj.x = obj.originalX + props.velocity[1] * timePassed + props.acceleration[1] * timePassed * timePassed / 2;
		obj.y = obj.originalY + props.velocity[2] * timePassed + props.acceleration[2] * timePassed * timePassed / 2;
	end
};
