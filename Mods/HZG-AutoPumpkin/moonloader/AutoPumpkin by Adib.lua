script_name('AutoPumpkin')
script_author('Adib')
script_version('1.0')
script_url("https://adib23704.tk")
local prefix = "[ {FF0000}" .. thisScript().name .. "{FFFFFF} ]: "

require 'moonloader'
require 'sampfuncs'
local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'
dir = getWorkingDirectory() .. "\\config\\Adib's Config\\"
dir2 = getWorkingDirectory() .. "\\config\\"
config = dir .. "" .. thisScript().name .. ".ini"

if not doesDirectoryExist(dir2) then
    createDirectory(dir2)
end
if not doesDirectoryExist(dir) then
    createDirectory(dir)
end
if not doesFileExist(config) then
    file = io.open(config, "w")
    file:write(" ")
    file:close()
    local directIni = config
    local mainIni = inicfg.load(inicfg.load({
        main = {
            enabled = true,
            pumpkins = 0
        }
    }, directIni))
    inicfg.save(mainIni, directIni)
end

local directIni = config
local mainIni = inicfg.load(nil, directIni)
inicfg.save(mainIni, directIni)

local picked = false
local picking = false
local delivered = true
local detection = false

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then
        return
    end
    while not isSampAvailable() do
        wait(100)
    end
    repeat
        wait(50)
    until string.find(sampGetCurrentServerName(), "Horizon Roleplay")
    
    sampAddChatMessage(prefix .. "by {005522}Adib{FFFFFF} has been loaded! {00FFFF}/ap.help")
    sampRegisterChatCommand("ap.help", function()
        sampAddChatMessage(" ", -1)
        sampAddChatMessage("{FF0000}/ap.tog {FFFFFF}- Toggles Auto Pumpkin", -1)
        sampAddChatMessage("{FF0000}/ap.count {FFFFFF}- Check your delivered pumpkins (client-sided)", -1)
        sampAddChatMessage("{FF0000}/ap.set {FFFFFF}- Set your total delivered pumpkins (client-sided)", -1)
        sampAddChatMessage("Developed by {005522}Adib{FFFFFF} - Discord: {005522}adib23704", -1)
        sampAddChatMessage(" ", -1)
    end)
    sampRegisterChatCommand("ap.tog", function()
        mainIni.main.enabled = not mainIni.main.enabled
        if inicfg.save(mainIni, directIni) then
            sampAddChatMessage(prefix .. "" .. (mainIni.main.enabled and "{00FF00}Enabled" or "{FF0000}Disabled"), -1)
        else
            sampAddChatMessage(prefix .. "Something went wrong! Contact the developer.", -1)
        end
    end)
    sampRegisterChatCommand("ap.count", function()
        sampAddChatMessage(prefix .. "Total delivered pumpkins: {00FF00}" .. tostring(mainIni.main.pumpkins), -1)
    end)
    sampRegisterChatCommand("ap.set", function(params)
        if params then
            params = split(params)
            if params[1] and tonumber(params[1]) then
                mainIni.main.pumpkins = tonumber(params[1])
                if inicfg.save(mainIni, directIni) then
                    sampAddChatMessage(prefix .. "Total pumpkin count has been saved!", -1)
                else
                    sampAddChatMessage(prefix .. "Something went wrong! Contact the developer.", -1)
                end
            else
                sampAddChatMessage(prefix .. "/ap.set [count in number]", -1)
            end
        else
            sampAddChatMessage(prefix .. "/ap.set [count in number]", -1)
        end
    end)
    while true do
        if mainIni.main.enabled and not picked and not picking and delivered and not detection then
            local x, y, z = getCharCoordinates(PLAYER_PED)
            if isCharInArea2d(PLAYER_PED, 2885.6736, -1972.0729, 2890.4692, -1979.0304, false) or
            (getDistanceBetweenCoords3d(2887.9707, -1975.7114, 5.5909, x, y, z) < 4.0) then
                picked = false
                picking = true
                delivered = true
                detection = true
                sampSendChat("/takepumpkin")
            end
        end
        wait(0)
    end
end

function sampev.onServerMessage(c, t)
    if mainIni.main.enabled and c == -86 then
        if detection and (t == "You are not at the pumpkin area." or t == "You have moved away from the pumpkin area.") then
            picked = false
            picking = false
            delivered = true
            detection = false
        end
        if picking and t == "Drop the pumpkin off at the Flying Dutchman's ship (see checkpoint on radar)." then
            picked = true
            picking = false
            delivered = false
            detection = false
        end
        if picked and t == "You received $200 for delivering the pumpkin." then
            picked = false
            picking = false
            delivered = true
            detection = false
            mainIni.main.pumpkins = mainIni.main.pumpkins + 1
            if inicfg.save(mainIni, directIni) then
                sampAddChatMessage(
                    prefix .. "You recieved $200 for delivering the pumpkin. Total delivered pumpkins:" ..
                        mainIni.main.pumpkins, -1)
                return false
            else
                sampAddChatMessage(prefix .. "Something went wrong! Contact the developer.", -1)
            end
        end
        if t == "You are already picking up a pumpkin." then
            picking = true
        end
        if t ==
            "Please ensure that your current checkpoint is destroyed first (you either have material packages, or another existing checkpoint)." then
            delivered = false
        end
    end
end

function sampev.onSendCommand(cmd)
    if tostring(cmd) == "/kcp" or tostring(cmd) == "/killcheckpoint" then
        picked = false
        picking = false
        delivered = true
        detection = false
    end
end

function split(str, delim) -- Param splitter from Stackoverflow.
    local input = ("([^%s]+)"):format(delim)
    local output = {}
    for k in str:gmatch(input) do
        table.insert(output, k)
    end
    return output
end

--[[ Values. Ignore them

2887.9707, -1975.7114, 5.5909 // pickup

2885.6736, -1972.0729, 6.0331 // pos1
2890.4692, -1979.0304, 5.1072 // pos2

- -86 - You received $200 for delivering the pumpkin.

- -86 - Please ensure that your current checkpoint is destroyed first (you either have material packages, or another existing checkpoint).

- -86 - You are not at the pumpkin area.

- -86 - Drop the pumpkin off at the Flying Dutchman's ship (see checkpoint on radar).

- -86 - You are already picking up a pumpkin.

- -86 - You have moved away from the pumpkin area.

- pickup
BD_FIRE
wash_up

- delivered
BOMBER
BOM_Plant
]] --
