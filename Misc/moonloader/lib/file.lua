--[[
	Project: folder
	File: lib/file.lua

	Website: blast.hk
	Author: LUCHARE

		Copyright (c) 2018
]]

local ffi = require('ffi');

ffi.cdef[[
	int __stdcall SetFileAttributesA(const char *lpFileName, unsigned long dwFileAttributes);
	unsigned long __stdcall GetFileAttributesA(const char *lpFileName);
	int __stdcall MoveFileA(const char *lpExistingFileName, const char *lpNewFileName);
	int __stdcall DeleteFileA(const char *lpFileName);
]];

local attribute = {
	archive                  = 0x20;
	compressed               = 0x800;
	device                   = 0x40;
	directory                = 0x10;
	encrypted                = 0x4000;
	hidden                   = 0x2;
	integrity_stream         = 0x8000;
	normal                   = 0x80;
	not_content_indexed      = 0x2000;
	no_scrub_data            = 0x20000;
	offline                  = 0x1000;
	readonly                 = 0x1;
	recall_on_data_access    = 0x400000;
	recall_on_open           = 0x40000;
	reparse_point            = 0x400;
	sparse_file              = 0x200;
	system                   = 0x4;
	temporary                = 0x100;
	virtual                  = 0x10000;
};

local function PSTR(string)
	return ffi.cast('char *', string);
end

local function new(path, name)
	local object = {
		path = path;
		name = name;
	};

	function object:type()
		return 'file';
	end

	function object:get_name()
		return self.name;
	end

	function object:get_path()
		return self.path;
	end

	function object:full_path_name()
		return self.path .. '\\' .. self.name;
	end

	function object:open(mode)
		return io.open(self:full_path_name(), mode);
	end

	function object:remove()
		ffi.C.DeleteFileA(PSTR(self:full_path_name()));
	end

	function object:rename(newname)
		if (ffi.C.MoveFileA(PSTR(self:full_path_name()), PSTR(self.path .. '\\' .. newname)) ~= 0x0) then;
			self.name = newname;
		end
	end

	function object:set_attributes(attributes)
		ffi.C.SetFileAttributesA(PSTR(self:full_path_name()), ffi.cast('unsigned long', attributes));
	end

	function object:get_attributes()
		return tonumber(ffi.C.GetFileAttributesA(PSTR(self:full_path_name())));
	end

	function object:move(newpath)
		 if (ffi.C.MoveFileA(PSTR(self:full_path_name()), PSTR(newpath .. '\\' .. self.name)) ~= 0x0) then
			 self.path = newpath;
		 end
	end

	return object;
end

return {
	new = new;
	attribute = attribute;
};
