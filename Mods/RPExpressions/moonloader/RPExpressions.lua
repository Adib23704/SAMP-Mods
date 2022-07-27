-- Scroll down if you want to add/edit/replace your own words.

script_name("RPExpressions")
script_author("Adib, Adib23704#8947")

require "lib.moonloader"
require("sampfuncs")
local sampev = require("lib.samp.events")

function main()
	while not isSampAvailable() do wait(50) end
	sampRegisterChatCommand("rpehelp", cmd_rpehelp)
	sampAddChatMessage("{FF5722}RPExpressions: {FFFFFF}Credits: Adib. Use {FF5722}/rpehelp", 0x01A0E9)

	while true do
		wait(10)
	end
end

function cmd_rpehelp()
	sampShowDialog(69, "{FF5722}RPExpressions Help", "{FFFFFF}A Mod for for {FF5722}Roleplay Expressions {FFFFFF}with replaced some short-forms {F0FF00}(e.g: Lol, Lmao etc)\n{FFFFFF}You can add your own word. Just open the MOD and scroll down.\nThe short-form words are listed below.\n\n{fe3c94}lol, Lol, LOL, l0l, L0l, L0L {552dcc}mc, MC, Mc, m/c, M/c, M/C\n{FFFFFF}-\n{1238fa}wc, WC, Wc, w/c, W/c, W/C {b31e42}XD, xD, xd, Xd\n{FFFFFF}-\n{84dd38}LMAO, Lmao, lmao {42bea5}LMFAO, Lmfao. lmfao\n{FFFFFF}-\n{ab9641}wtf, WTF, Wtf {effc41}wth, WTH, Wth\n{FFFFFF}-\n{F498D2}ROFL, rofl, Rofl {CDB27B}:), : ), :D, : D, :3, : 3\n\n{FF0000}Type these words on your chat witout any {FFFFFF}'/'{FF0000} just like a normal chat for action.\n\n{2196F3}Mod by {00FF00}Adib {FFFFFF}| {00FF00}Adib23704#8947.\n{2196F3}Feel free to message him for any suggestions/bugs/errors.", "Close")
end

function sampev.onSendChat(message)
	if (message == "lol" or message == "Lol" or message == "LOL" or message == "l0l" or message == "L0l" or message == "L0L") then
		sampSendChat("/me laughs out loud")
		return false
	end
	if (message == "mc" or message == "MC" or message == "Mc" or message == "m/c" or message == "M/c" or message == "M/C") then
		sampSendChat("/b Miss click!")
		return false
	end
	if (message == "wc" or message == "WC" or message == "Wc" or message == "w/c" or message == "W/c" or message == "W/C") then
		sampSendChat("/b Wrong Chat!")
		return false
	end
	if (message == "lmao" or message == "LMAO" or message == "Lmao") then
		sampSendChat("/me laughs their ass off!")
		return false
	end
	if (message == "lmfao" or message == "LMFAO" or message == "Lmfao") then
		sampSendChat("/me laughs their fucking ass off!")
		return false
	end
	if (message == "wtf" or message == "WTF" or message == "Wtf") then
		sampSendChat("/me shouts, \"What the fuck?\"")
		return false
	end
	if (message == "wth" or message == "WTH" or message == "Wth") then
		sampSendChat("/me shouts, \"What the heck?\"")
		return false
	end
	if (message == "xd" or message == "XD" or message == "xD" or message == "Xd") then
		sampSendChat("/me laughs with their eyes closed")
		return false
	end
	if (message == "rofl" or message == "ROFL" or message == "Rofl") then
		sampSendChat("/me rolling on the ground and laughing hysterically")
		return false
	end
	if (message == ":)" or message == ": )") then
		sampSendChat("/me smiles")
		return false
	end
	if (message == ":D" or message == ": D") then
		sampSendChat("/me cracks a big smiles")
		return false
	end
	if (message == ":3" or message == ": 3") then
		sampSendChat("/me makes a sarcastic face")
		return false
	end
	-- New short-form adding format:
	-- ---------------------------------
	-- if (message == "word1" or message == "word2" or message == "word3") then
	-- 	sampSendChat("command send. You can use '/' too for commands.")
	-- 	return false
	-- end
	-- ---------------------------------
	-- Contact with the developer if you don't understand
end
