

Screen = {
   Top = display.screenOriginY,
   Left = display.screenOriginX,
   Right = display.contentWidth - display.screenOriginX,
   Bottom = display.contentHeight - display.screenOriginY,

   CenterX = display.contentCenterX,
   CenterY = display.contentCenterY,
   Center = { display.contentCenterX, display.contentCenterY },

   Width = display.contentWidth - 2 * display.screenOriginX,
   Height = display.contentHeight - 2 * display.screenOriginY,

   IsPortrait = display.contentHeight > display.contentWidth,
   IsLandscape = display.contentHeight < display.contentWidth,
};



--[[
UTL.HideObject(group)
Sets objects isVisible to false
]]
function UTL.HideObject(obj)
	obj.isVisible = false;
end

--[[
UTL.ShowObject(group)
Sets objects isVisible to true
]]
function UTL.ShowObject(obj)
	obj.isVisible = true;
end

--[[
UTL.NewGroup(parent)
Create new group and insert into parent
]]
function UTL.NewGroup(parent, anchor)
	local grp = display.newGroup();
	if (parent) then
		parent:insert(grp);
	end
	grp.anchorChildren = (anchor == true);
	return grp;
end


function UTL.Center(obj, dx, dy)
	obj.x, obj.y = unpack(Screen.Center);
	if (dx) then obj.x = obj.x + dx; end
	if (dy) then obj.y = obj.y + dy; end
end

function UTL.Pos(dest, source)
	dest.x, dest.y = source.x, source.y;
end

function UTL.RandomXY()
	return math.random(Screen.Left, Screen.Right), math.random(Screen.Top, Screen.Bottom);
end



display.newOutlinedTextLegacy = function(parent, text, font, size, outlineSize) 
	return display.newOutlinedText(parent, text, 0, 0, font, size, outlineSize);
end

display.newOutlinedText = function(parent, text, x, y, font, size, outlineSize) 
	local group = display.newGroup();
	parent:insert(group);

	if (Device.isSimulator) and (font ~= nil) then
		y = y - size * 0.15;
	end


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



display.newMaskPng = function(group, path, width, height, mpath)

	local mask = nil;
	mpath = mpath or string.gsub(path, "/", "-");
	if (UTL.FileExist(mpath, system.TemporaryDirectory)) then
		mask = graphics.newMask(mpath, system.TemporaryDirectory);
	else

		local grp = display.newGroup();
		grp.anchorChildren = true;
		
		width = math.ceil(width / 4) * 4;
		height = math.ceil(height / 4) * 4;

		local r = display.newRect(grp, 0, 0, width, height);
		r:setFillColor(0);

		local i = display.newImageRect(grp, path, width, height);
		i.fill.effect = "filter.brightness";
		i.fill.effect.intensity = 1;

		display.save(grp, {
			filename = mpath,
			baseDir = system.TemporaryDirectory,
			isFullResolution = true
		});

		grp:removeSelf();
		mask = graphics.newMask(mpath, system.TemporaryDirectory);
	end
	local i = display.newImageRect(group, path, width, height);
	i:setMask(mask);
	return i;
end






