UTL = {};

JSON = require("json");
Composer = require("composer");
Device = require("utl.device");



require("utl.debugutl");
require("utl.displayutl");
require("utl.stringutl");
require("utl.tableutl");
require("utl.settings");
require("utl.helpers");
require("utl.misc");
require("utl.timers");
require("utl.fireworks");
require("utl.composerutl");
require("utl.animations");
require("utl.social");
require("utl.undderex");

LogEvent = LogEvent or UTL.EmptyFn;


Runtime:addEventListener("unhandledError", function( event )
	UTL.Dump(event);
	return true;
end);


return UTL;