script_name('Check MoonLoader Updates')
script_author('FYP')
script_version_number(1)
script_properties('forced-reloading-only')

local dlstatus = require('moonloader').download_status
local gamekeys = require 'game.keys'

--- Main
function main()
	while not isPlayerPlaying(PLAYER_HANDLE) do wait(100) end
	wait(1000)
	local fpath = os.getenv('TEMP') .. '\\moonloader-version.json'
	downloadUrlToFile('https://blast.hk/moonloader/data/version-info.json', fpath, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			local f = io.open(fpath, 'r')
			if f then
				local info = decodeJson(f:read('*a'))
				if info and info.latest then
					local version = tonumber(info.latest)
					if version > getMoonloaderVersion() then
						lua_thread.create(dialog_thread, version)
					end
				end
			end
		end
	end)
	wait(-1)
end

function dialog_thread(new_version)
	setPlayerControl(PLAYER_HANDLE, false)
	setGxtEntry('CMLUTTL', 'MoonLoader')
	setGxtEntry('CMLUMSG', string.format('MoonLoader update is available!~n~New version: ~g~~h~.%03d~n~~w~Your version: ~y~~h~.%03d~n~~w~Do you want to open the download page?', new_version, getMoonloaderVersion()))
	setGxtEntry('CMLUYES', 'Yes')
	setGxtEntry('CMLUNO', 'No')
	local menu = createMenu('CMLUTTL', 120, 110, 400, 1, true, true, 1)
	local dummy = 'DUMMY'
	setMenuColumn(menu, 0, 'CMLUMSG', dummy, dummy, dummy, dummy, 'CMLUYES', 'CMLUNO', dummy, dummy, dummy, dummy, dummy, dummy)
	setActiveMenuItem(menu, 5)
	while true do
		wait(0)
		if isButtonPressed(PLAYER_HANDLE, gamekeys.player.ENTERVEHICLE) then
			break
		elseif isButtonPressed(PLAYER_HANDLE, gamekeys.player.SPRINT) then
			if getMenuItemSelected(menu) == 4 then
				local ffi = require 'ffi'
				ffi.cdef [[
					void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
					uint32_t __stdcall CoInitializeEx(void*, uint32_t);
				]]
				local shell32 = ffi.load 'Shell32'
				local ole32 = ffi.load 'Ole32'
				ole32.CoInitializeEx(nil, 2 + 4) -- COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE
				print(shell32.ShellExecuteA(nil, 'open', 'https://blast.hk/moonloader/', nil, nil, 1))
			end
			break
		end
	end
	wait(0)
	deleteMenu(menu)
	setPlayerControl(PLAYER_HANDLE, true)
	thisScript():unload()
end
