local ffi = require("ffi")
local memory = require("memory")

local offsets = require("samp-api.offsets")

function isSampLoaded()
    return getModuleHandle("samp.dll") > 0
end

function isSampAvailable()
    local samp_dll = getModuleHandle("samp.dll")
    if samp_dll > 0 then
        local version = memory.getuint32(samp_dll + memory.getint32(samp_dll + 0x3C) + 0x28)
        assert(offsets[version], ("Unknown version of SA-MP (Entry point: 0x%X)"):format(version))

        local offset = offsets[version]
        for _, data in pairs(offset) do
            if memory.getuint32(samp_dll + data) == 0x0 then
                return false
            end
        end

        local stChatInfo = ffi.cast("intptr_t*", samp_dll + offset.stChatInfo)[0]
        local stInputInfo = ffi.cast("intptr_t*", samp_dll + offset.stInputInfo)[0]
        local stLocalPlayer = ffi.cast("intptr_t*", samp_dll + offset.stLocalPlayer)[0]

        local fnSendMessage = ffi.cast("void(__thiscall*)(intptr_t, const char*)", samp_dll + offset.fnSendMessage)
        local fnSendCommand = ffi.cast("void(__thiscall*)(intptr_t, const char*)", samp_dll + offset.fnSendCommand)
        local fnAddChatMessage = ffi.cast("void(__thiscall*)(intptr_t, uint32_t, const char*)", samp_dll + offset.fnAddChatMessage)

        function sampGetBase()
            return samp_dll
        end

        function sampSendChat(text)
            if text:sub(1, 1) == "/" then
                fnSendCommand(stInputInfo, text)
            else
                fnSendMessage(stLocalPlayer, text)
            end
        end

        function sampAddChatMessage(text, color)
            fnAddChatMessage(stChatInfo, color, text)
        end

        return true
    end
end