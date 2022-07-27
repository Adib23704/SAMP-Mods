--[[
	Project: folder
	File: lib/folder.lua

	Website: blast.hk
	Author: LUCHARE

		Copyright (c) 2018
]]

local function files(mask)
	local search, filen;

	local function iterator(mask)
		if (search == nil) then
			search, filen = findFirstFile(mask);
		else
			filen = findNextFile(search);
		end
		if (filen == nil) then
			findClose(search);
		end
		return filen
	end

	return iterator, mask;
end

local file = require('file');

local function new(path)
	local name = path:match('.+\\(.+)$')
	local object = file.new(path:gsub('\\' .. name, ''), name);

	object.entries = {};
	object.open = nil;

	function object:type()
		return 'folder';
	end

	function object:submit(mask)
		self.entries = {};
		local i = 0;
		for name in files(self:full_path_name() .. '\\' .. mask) do
			local tmp = file.new(self:full_path_name(), name);
			if (bit.band(tmp:get_attributes(), file.attribute.directory) == 16) then
				tmp = new(tmp:full_path_name());
			end
			self.entries[i] = tmp
			i = i + 1;
		end
	end

	function object:files()
		return self.entries;
	end

	return object;
end

return {
	max_path = 0x104;
	new = new;
};
