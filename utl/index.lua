UTL = {};

JSON = require("json");
Composer = require("composer");
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
};


require("utl.settings");
require("utl.helpers");
require("utl.misc");
require("utl.timers");
require("utl.fireworks");



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

return UTL;