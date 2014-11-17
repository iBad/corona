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
	scene.H = {};
	scene.S = {};


	function scene:create(event)
		scene.sceneName = event.sceneName or Composer.getSceneName("current");
		scene.removeOnHide = true;

		print("Creating scene ", scene.sceneName);

		if (OnCreate) then
			OnCreate(self.view, event.params or {}, scene);
		end

	end
	
	function scene:hide(event)
		if (event.phase == "did") and (self.removeOnHide) then
			Composer.removeScene(self.sceneName);


			for k, v in pairs(self.H) do
				print("Calling on hide function '" .. k .. "'");
				pcall(v);
			end
		end
	end
	
	function scene:show(event)
		

		if (event.phase == "did") then
			for k, v in pairs(self.S) do
				print("Calling on show function '" .. k .. "'");
				pcall(v, event.params);
			end

		end
	end
	
	function scene:destroy(event)
		print("Destroying scene ", self.sceneName);

		for k, v in pairs(self.D) do
			print("Calling on destroy destructor '" .. k .. "'");
			print("NOTE: Outdated, use object destructors instead");
			pcall(v);
		end

		UTL.ClearGroup(self.view);

		if (OnDestroy) then
			OnDestroy();
		end
	end



	scene:addEventListener("create", scene);
	scene:addEventListener("hide", scene);
	scene:addEventListener("show", scene);
	scene:addEventListener("destroy", scene);
	return scene;
end





Composer.Overlay = function(scene, params)
	Composer.showOverlay(scene, {
		params = params,
		isModal = true
	});
end



Composer.Goto = function(scene, params, options)
   options = options or {};
   options.params = params;

   if (Composer.getSceneName("current") == scene) then
      Composer.gotoScene("scenereloader", {
         params = {
            callback = UTL.Bind(Composer.gotoScene, scene, options)
         }
      });
   else
	  Composer.gotoScene(scene, options);
   end
end
















UTL.BackInfo = {}

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