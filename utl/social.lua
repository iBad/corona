Social = {
	Message = "Try this game. It's amazing!",
	Picture = "upload.png",
	URL = {}
};


function Social.GetAppURL()

	local store = system.getInfo("targetAppStore");
	if (Social.URL[store]) then
		return Social.URL[store];
	end

	if (Social.URL.default) then
		return Social.URL.default;
	end

	return "http://angrymarmot.org";
end


function Social.Setup(options) 
	options = options or {};
	Social.Message = options.Message or Social.Message;
	Social.Picture = options.Picture or Social.Picture;
	Social.URL = options.URL or Social.URL;

	UTL.Dump(Social);
end


function Social.Share(method)
	UTL.Dump(Social);
	LogEvent(method .. "_share_attempt");

	if (Device.isSimulator) then
		native.showAlert("Social", "Sharing url '" .. Social.GetAppURL() .. "' with picture '" .. Social.Picture .. "' and message '" .. Social.Message .. "'", {"OK"});
		return;
	end


	if (Device.isApple) and (not Device.isSimulator) then

		if (method == "facebook" or method == "twitter") then
			local listener = {};

			function listener:popup( event )
				print( "Social: name(" .. event.name .. ") type(" .. event.type .. ") action(" .. tostring(event.action) .. ") limitReached(" .. tostring(event.limitReached) .. ")" )
			end

			native.showPopup("social", {
				service = method, -- The service key is ignored on Android.
				message = Social.Message,
				listener = listener,
				url = { 
					Social.GetAppURL(),
				},
				image = 
				{
					{ 
						filename = Social.Picture, 
						baseDir = system.ResourceDirectory 
					},
				},
			});
		end
	else

		if (method == "facebook") then
			system.openURL("https://www.facebook.com/sharer/sharer.php?m2w&u=" .. Social.GetAppURL());
		end
		

		if (method == "twitter") then
			native.showPopup("social", {
				service = method, -- The service key is ignored on Android.
				message = Social.Message,
				url = { 
					Social.GetAppURL(),
				},
				image = 
				{
					{ 
						filename = Social.Picture, 
						baseDir = system.ResourceDirectory 
					},
				},
			});
		end

	end
end