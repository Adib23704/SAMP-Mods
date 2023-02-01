script_name('EasyCall')
script_author('Adib')
script_version_number(100)
script_url("https://adib23704.tk")
local scr = thisScript()
local prefix = "{FFFFFF}[ {FF0000}" .. scr.name .. " {FFFFFF}]: "

require 'moonloader'
require 'sampfuncs'
local sampev = require 'lib.samp.events'
local calling = false
local callingID = nil

function main()
    while not isSampAvailable() do wait(50) end
    sampAddChatMessage(prefix .. "loaded! made by {FF0000}Adib{FFFFFF}. Use {00FF00}/ca", -1)
    sampRegisterChatCommand("ca", function(args)
        if #args == 0 then
            sampAddChatMessage(prefix .. "{A7A7A7}Usage: /ca (player ID)", -1)
            return true
        end
        local arg = splitArgs(args)
        if not string.find(arg[1], "%d") then
            sampAddChatMessage(prefix .. "{A7A7A7}Usage: /ca (player ID)", -1)
            return true
        end
        if not sampIsPlayerConnected(arg[1]) then
            sampAddChatMessage(prefix .. "{A7A7A7}Invalid player specified.", -1)
            return true
        end
        sampSendChat("/number " .. arg[1])
        calling = true
        callingID = arg[1]
    end)
    while true do
        wait(0)
    end
end

-- /number command's msg text -1263159297

function sampev.onServerMessage(c, t)
    if calling then
        if string.find(string.sub(t, 1, 1), "*") and c == -1263159297 then
            calling = false
            local number = t:match("%((.+)%)")
            sampAddChatMessage(prefix .. "Calling {00FF00}" .. sampGetPlayerNickname(callingID) .. " {CCCCCC}| {FFFFFF}Number: {00FF00}" .. number, -1)
            sampSendChat("/call " .. number)
            return false
        end 
    end
end

function splitArgs(arg)
    local t = {}
    for str in string.gmatch(arg, "([^%s]+)") do
        table.insert(t, str)
    end
    return t
end