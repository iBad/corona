-----------------------------------------------------------
-----------------------------------------------------------
-- pTimer library version 1.0
-- 
-- v1.0 - Initial version
-----------------------------------------------------------
-----------------------------------------------------------

Fireworks = {
	
};

function Fireworks.newBasic(options)
	local group = UTL.NewGroup(options.parent);

	options.color = options.color or {1, 1, 1};
	options.size = options.size or 10;
	options.dist = options.dist or 150;
	options.numParticles = options.numParticles or 100;


	local function ChangeBrightness(color, brightness)
		if (brightness < 0) then
			return { color[1] * (brightness + 1), color[2] * (brightness + 1), color[3] * (brightness + 1) };
		else
			return { (1 - color[1]) * brightness + color[1], (1 - color[2]) * brightness + color[2], (1 - color[3]) * brightness + color[3] }
		end
	end

	local function Dist(x1, y1, x2, y2)
		return math.pow(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2), 0.5);
	end

	local function BlowUp(bullet)
		transition.to(bullet, {
			alpha = 0,
			time = 200,
			tag = "Firework_Animation"
		});

		for i = 1, options.numParticles do
			local size = math.random(options.size * 0.5, options.size);
			local dir = math.random(360);
			local distance = math.random(options.dist * 0.1, options.dist);

			local c = ChangeBrightness(options.color, math.random(-100, 100) / 200);

			local particle = display.newRect(group, bullet.x, bullet.y, size, size);
			particle:setFillColor(unpack(c));

			transition.to(particle, {
				time = math.random(500, 3000),
				x = bullet.x + distance * math.sin(dir),
				y = bullet.y + distance * math.cos(dir),
				alpha = 0,
				tag = "Firework_Animation"
			});

		end
	end
	local function FireImpl()
		
		local bullet = display.newRect(group, 0, 0, options.size, options.size);
		bullet:setFillColor(unpack(options.color));

		bullet.x = options.fromX;
		bullet.y = options.fromY;

		local d = Dist(options.fromX, options.fromY, options.toX, options.toY);
		local time = d * 3;

		transition.to(bullet, {
			time = time,
			x = options.toX,
			y = options.toY,
			tag = "Firework_Animation",
			onComplete = UTL.Bind(BlowUp, bullet);
		});
	end

	local function Fire(delay)
		pTimer.create(delay, FireImpl):setTag("Firework_Animation");
	end
		
	local function Destroy()
		transition.cancel("Firework_Animation");
		pTimer.cancelAll("Firework_Animation");
	end

	return {
		Fire = Fire,
		Destroy = Destroy
	};
end



function Fireworks.newBunch(options)
	options.angle = options.angle or { 80, 100};
	options.distance = options.distance or {300, 400};

	options.numFireworks = options.numFireworks or 10;
	options.colors = options.colors or {{ 1, 1, 1}};

	local colors = UTL.Clone(options.colors);
	table.shuffle(colors);
	UTL.Dump(colors);

	local fireworks = {};

	for i = 1, options.numFireworks do
		local angle = math.random(options.angle[1], options.angle[2]);
		local distance = math.random(options.distance[1], options.distance[2]);

		local toX = options.fromX + math.sin(angle / 180 * math.pi) * distance;
		local toY = options.fromY + math.cos(angle / 180 * math.pi) * distance;

		local color = colors[(i - 1) % #colors + 1];

		table.insert(fireworks, Fireworks.newBasic({
			parent = options.parent,
			fromX = options.fromX,
			fromY = options.fromY,
			toX = toX,
			toY = toY,
			color = color
		}));
	end

	local function Fire(duration)
		local interval = math.ceil(duration / options.numFireworks);

		for i = 1, options.numFireworks do
			fireworks[i].Fire(interval * i);
		end
	end

	local function Destroy()
		for i = 1, options.numFireworks do
			fireworks[i].Destroy();
		end
	end


	return {
		Fire = Fire,
		Destroy = Destroy,
	};
end




