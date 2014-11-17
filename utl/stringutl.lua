

function string.lpad(str, len, char)
	if char == nil then char = ' ' end
	return str .. string.rep(char, len - #str)
end

function string.rpad(str, len, char)
	if char == nil then char = ' ' end
	return string.rep(char, len - #str) .. str
end

function string.char_replace(pos, str, r)
	return ("%s%s%s"):format(str:sub(1,pos-1), r, str:sub(pos+1));
end

function string.at(str, index)
	return string.sub(str, index, index);
end




function UTL.GetTime(timestamp)
	return os.date("%H:%M:%S %d %b %Y", timestamp);
end