script_name('ChatSwtich')
script_author('Adib')

require 'moonloader'
local se = require 'lib.samp.events'
local memory = require 'memory'
cmd = '/b'

-- Creating Watermark
function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(80) end

	chatType = 'IC'
    font = renderCreateFont('Bahnscrift', 10, 13)
    while true do
    	if sampIsChatInputActive() then
            local input = sampGetChatInputText()
            local strEl = getStructElement(sampGetInputInfoPtr(), 0x8, 4)
            local X = getStructElement(strEl, 0x8, 4) + 12.5
            local Y = getStructElement(strEl, 0xC, 4) + 12.5

            if isKeyJustPressed(VK_TAB) then
            	chatType = chatType == 'IC' and 'OOC' or 'IC'
            	addOneOffSound(0, 0, 0, 1083)
            end

            if #input == 0 then
                renderFontDrawText(font, chatType..' | Enter anything.. (TAB) to switch type', X, Y, 0x20FFFFFF)
            else
            	chatEditBoxTextColor(chatType == 'OOC' and (input:match('^/') and 0xFFFFFFFF or 0xFF808080) or 0xFFFFFFFF)
            end
        end
    wait(0)
    end
end

-- Main Function
function se.onSendChat(msg)
	if chatType == 'OOC' then
		sampSendChat(string.format('%s %s', cmd, msg))
		return false
	end
end

-- OOC Color
function chatEditBoxTextColor(color)
    local pInput = memory.read(getModuleHandle("samp.dll") + 0x21A0E8, 4, true)
    local pEditInputBox = memory.read(pInput + 0x8, 4, true)
    memory.write(pEditInputBox + 0x127, color, 4, true)
end
