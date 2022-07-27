script_name("ChatCounter")
script_author("Adib")
script_version("1.5")
script_url("https://adib23704.github.io")
scr = thisScript()

require "moonloader"
require "sampfuncs"
local vk = require "vkeys"
local sampev = require "lib.samp.events"
local inicfg = require "inicfg"
local https = require "ssl.https"
local json = require "json"

notif = true
old = false
body = nil

dir = getWorkingDirectory( ) .. "\\config\\Adib's Config\\"
dir2 = getWorkingDirectory() .. "\\config\\"
config = dir .. "ChatCounter.ini"
 
if not doesDirectoryExist(dir2) then createDirectory(dir2) end
if not doesDirectoryExist(dir) then createDirectory(dir) end
if not doesFileExist(config) then
    file = io.open(config, "w")
    file:write(" ")
    file:close()
    local directIni = config
    local mainIni = inicfg.load(inicfg.load({
        main = {
            enabled = true,
            x = 772,
            y = 345
        }, 
    }, directIni)) 
    inicfg.save(mainIni, directIni)
end

local directIni = config
local mainIni = inicfg.load(nil, directIni)
inicfg.save(mainIni, directIni)

fontName = nil
fontSize = nil
font = nil
toggle = mainIni.main.enabled
scrColor = "{009900}"
isMoving = false

function main()
   checkUpdate()
   while not isSampAvailable() do wait(50) end
   sampRegisterChatCommand("chatcounter", help)
   sampRegisterChatCommand(".togcount", function()
      toggle = not toggle
      sampAddChatMessage(string.format("[ %s%s{FFFFFF} ]: %s.", scrColor, scr.name, toggle and "{00FF00}Enabled" or "{FF0000}Disabled"), -1)
      mainIni.main.enabled = toggle
      inicfg.save(mainIni, directIni)
   end)
   sampRegisterChatCommand(".countmove", function()
      sampSetChatInputEnabled(true)
      isMoving = true
      sampAddChatMessage(" ", -1)
      sampAddChatMessage(string.format("[ %s%s{FFFFFF} ]: Counter Moving Started!", scrColor, scr.name), -1)
      sampAddChatMessage(string.format("[ %s%s{FFFFFF} ]: Press {FF0000}%s{FFFFFF} for {00FF00}Left{FFFFFF} & {FF0000}%s{FFFFFF} for {00FF00}Right.", scrColor, scr.name, vk.id_to_name(vk.VK_LEFT), vk.id_to_name(vk.VK_RIGHT)), -1)
      sampAddChatMessage(string.format("[ %s%s{FFFFFF} ]: Press {FF0000}%s{FFFFFF} for {00FF00}Up{FFFFFF} & {FF0000}%s{FFFFFF} for {00FF00}Down.", scrColor, scr.name, vk.id_to_name(vk.VK_UP), vk.id_to_name(vk.VK_DOWN)), -1)
      sampAddChatMessage(string.format("[ %s%s{FFFFFF} ]: Press {FF0000}%s{FFFFFF} to {00FF00}Fast Movement.", scrColor, scr.name, vk.id_to_name(vk.VK_LSHIFT)), -1)
      sampAddChatMessage(string.format("[ %s%s{FFFFFF} ]: Press {FF0000}%s{FFFFFF} to {00FF00}Slow Movement.", scrColor, scr.name,  vk.id_to_name(vk.VK_LMENU)), -1)
      sampAddChatMessage(string.format("[ %s%s{FFFFFF} ]: Press {FF0000}%s{FFFFFF} to {00FF00}Finish.", scrColor, scr.name, vk.id_to_name(vk.VK_SPACE)), -1)
      sampAddChatMessage(" ", -1)
   end)
   createFont()
   sampAddChatMessage(string.format("[ %s%s{FFFFFF} ]: {00FF00}Loaded{FFFFFF}! Script by %s%s{FFFFFF}. Use {FF0000}/chatcounter", scrColor, scr.name, scrColor, scr.authors[1]), -1)
   while true do
      moveCheck()
      if sampIsChatInputActive() and toggle then
         text = tostring(sampGetChatInputText())
         textInt = string.len(text)
         count = colorCheck(textInt)
         if (textInt < 10) then
            renderFontDrawText(font, count .. "{FFFFFF}/{E6F387}128", mainIni.main.x, mainIni.main.y, -1)
         elseif (textInt > 9 and textInt < 100) then
            renderFontDrawText(font, count .. "{FFFFFF}/{E6F387}128", mainIni.main.x-10, mainIni.main.y, -1)
         elseif (textInt > 100 or textInt == 100) then
            renderFontDrawText(font, count .. "{FFFFFF}/{E6F387}128", mainIni.main.x-20, mainIni.main.y, -1)
         end
      end
      wait(0)
   end
end

function help()
   sampAddChatMessage(" ", -1)
   sampAddChatMessage("______ " .. scrColor .. scr.name .. " {a7a7a7}v" .. scr.version .. " {FFFFFF}______" , -1)
   sampAddChatMessage(" ", -1)
   sampAddChatMessage("{FF0000}/.countmove {a7a7a7}- {FFFFFF}Change the counter's position.", -1)
   sampAddChatMessage("{FF0000}/.togcount {a7a7a7}- {00FF00}Enable{FFFFFF} / {FF0000}Disable {FFFFFF}the counter.", -1)
   sampAddChatMessage(" ", -1)
   sampAddChatMessage("By " .. scrColor .. scr.authors[1] .. " {FFFFFF}- {cccccc}Adib23704#8947", -1)
end

function createFont()
   fontName = "Segoe UI"
   fontSize = 7
   font = renderCreateFont(fontName, fontSize, 13)
end

function onScriptTerminate(script, quitGame) 
   if script == scr.this then 
      mainIni.main.enabled = toggle
      inicfg.save(mainIni, directIni)
   end
end

function colorCheck(count)
   if(count == 0) then
      count = "{FFFFFF}" .. count
   elseif (count > 0 and count < 50) then
      count = "{00FF00}" .. count
   elseif (count > 50 and count < 100) then
      count = "{FFFF00}" .. count
   elseif (count > 100 and count < 128) then
      count = "{FFA500}" .. count
   elseif (count == 128) then
      count = "{FF0000}" .. count
   end
   return count
end

function moveCheck()
   if isMoving then
      local x = mainIni.main.x
      local y = mainIni.main.y
      if isKeyDown(vk.VK_LMENU) then
         mod = 0.5
      elseif isKeyDown(vk.VK_LSHIFT) then
         mod = 2
      else
         mod = 1
      end

      sampSetChatInputEnabled(true)
      if isKeyJustPressed(vk.VK_SPACE) then 
         sampSetChatInputEnabled(false)
         isMoving = false
         inicfg.save(mainIni, directIni)
      elseif isKeyDown(vk.VK_LEFT) then
         x = x - mod
      elseif isKeyDown(vk.VK_RIGHT) then
         x = x + mod
      elseif isKeyDown(vk.VK_UP) then
         y = y - mod
      elseif isKeyDown(vk.VK_DOWN) then
         y = y + mod
      end
      mainIni.main.x = x
      mainIni.main.y = y
   end
end

function checkUpdate()
   local url = scr.url .. "/luaVers.html"
   local result = https.request(url)
   body = json.decode(result)
   if not (body.ChatCounter == scr.version) then
      old = true
   end 
end

function sampev.onSendSpawn()
   if (old and notif) then
      sampAddChatMessage(string.format("[ %s%s{FFFFFF} ]: {00FF00}New version update available! v%s -> v%s. To download visit {FFFFFF}https://is.gd/chatcounter", scrColor, scr.name, tostring(scr.version), tostring(body.ChatCounter)), -1)
      notif = false
   end
end
