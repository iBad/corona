UTL = {};

JSON = require("json");
Composer = require("composer");
Device = require("utl.device");

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



require("utl.tableutl");
require("utl.settings");
require("utl.helpers");
require("utl.misc");
require("utl.timers");
require("utl.fireworks");
require("utl.composerutl");
require("utl.animations");
require("utl.social");

LogEvent = LogEvent or UTL.EmptyFn;

return UTL;