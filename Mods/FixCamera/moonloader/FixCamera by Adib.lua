script_name("СameraLock")
script_author("Kingleonide")
script_version(0.1)

require "lib.moonloader"
local samp = require "sampfuncs"
local sampev = require "lib.samp.events"

local activate = false
local mode = 0

function main()
    while not isSampAvailable() do wait(100) end
	sampAddChatMessage("{00FFFF}FixCamera: {FFFFFF}Press {0000FF}C {FFFFFF}while on vehicle.", -1)
    restoreCamera()
    while true do
    if wasKeyPressed(VK_C) and not sampIsChatInputActive() and not isCharOnFoot(PLAYER_PED) then
		activate = true
		local car = isCharInAnyCar(PLAYER_PED)
		if (car == true) then
			restoreCamera()
		end
        mode = mode + 1
        if mode > 2 then 
            mode = 0 
        end
        if mode == 2 and activate then
            if activate then
                attachCameraToVehicleLookAtChar(veh, 0,-12, 3, PLAYER_PED, 0, 2)
            end
        end
    end
        wait(0) 
    end
end

function sampev.onSendExitVehicle(vehicleId)
	activate = false
	restoreCamera()
	mode = 0
end
