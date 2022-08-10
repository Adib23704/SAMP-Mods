script_name('CustomTags')
script_author('Adib')
script_version_number(100)
script_url("https://adib23704.tk")

require 'moonloader'
require 'sampfuncs'
local imgui = require 'imgui'
local encoding = require 'encoding'
local https = require 'ssl.https'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local inicfg = require 'inicfg'
dir = getWorkingDirectory() .. "\\config\\Adib's Config\\"
dir2 = getWorkingDirectory() .. "\\config\\"
config = dir .. "CustomTags.ini"

if not doesDirectoryExist(dir2) then createDirectory(dir2) end
if not doesDirectoryExist(dir) then createDirectory(dir) end
if not doesFileExist(config) then
    file = io.open(config, "w")
    file:write(" ")
    file:close()
    local directIni = config
    local mainIni = inicfg.load(inicfg.load({
        main = {
            posX = 0,
            posY = 0,
            posZ = 0.4,
            dist = 25,
            ignoreVer = tonumber(scr.version)
        },
    }, directIni))
    inicfg.save(mainIni, directIni)
end

local directIni = config
local mainIni = inicfg.load(nil, directIni)
inicfg.save(mainIni, directIni)

local window = imgui.ImBool(false)

local slider_dist = imgui.ImFloat(mainIni.main.dist)
local slider_posX = imgui.ImFloat(mainIni.main.posX)
local slider_posY = imgui.ImFloat(mainIni.main.posY)
local slider_posZ = imgui.ImFloat(mainIni.main.posZ)

local colorTEST = 0xFFFFFFFF

local pid = imgui.ImInt(0)
local tid = imgui.ImInt(19)
local text = imgui.ImBuffer(256)

local list = {}

local deleteMark_name = ''
local deleteMark_tag = ''

local listns = {}

local add_name = imgui.ImBuffer(21)
local add_text = imgui.ImBuffer(256)
local add_popup = imgui.ImBool(false)

local body = ""
local ignoringVers = false

function main()
    while not isSampAvailable() do wait(200) end
    checkUpdate()
    sampAddChatMessage("[ {00FF00}CustomTags{FFFFFF} ]: loaded! by {005522}Adib{FFFFFF}. Use {FF0000}/tags", -1)
    sampRegisterChatCommand('tags', function()
        window.v = not window.v
    end)
    loadTags()
    file = getWorkingDirectory()..'\\config\\Adib\'s Config\\CreatedCustom.tags'
    if doesFileExist(file) then
        for line in io.lines(file) do 
            listns[#listns + 1] = line
        end

        for i = 1, #listns do
            nick, tag = listns[i]:match('(.+);(.+)')
            table.insert(list, #list + 1, {nick, tag})
        end
    else
        create = io.open(file, 'w')
        create:close()
    end
    imgui.Process = false
    window.v = false
    while true do
        imgui.Process = window.v
        loadTags()
        local result, button, list, input = sampHasDialogRespond(23741)
        if result then
            local json = decodeJson(body)
            if button == 1 then
                sampAddChatMessage("[ {00FF00}CustomTags{FFFFFF} ]: Latest mod page should be open on your browser now!", -1)
                os.execute('explorer "' .. json.customtags.file .. '"')
            else
                sampAddChatMessage("[ {00FF00}CustomTags{FFFFFF} ]: {FF0000}Ignored this version! Remember, the latest version always contains more features and bug fixings.", -1)
                sampAddChatMessage("[ {00FF00}CustomTags{FFFFFF} ]: {A7A7A7}You will be notified when another version of this mod gets released...", -1)
                mainIni.main.ignoreVer = tonumber(json.customtags.version)
                inicfg.save(mainIni, directIni)
                ignoringVers = true
            end
        end
        wait(0)
    end
end

local deleteConfirm_popup = imgui.ImBool(false)

function imgui.OnDrawFrame()
    if window.v then
        windSizeX, windSizeY = 300, 300
        imgui.SetNextWindowPos(imgui.ImVec2(350.0, 250.0), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(windSizeX, windSizeY), imgui.Cond.FirstUseEver)
        imgui.Begin('CustomTags by Adib', window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)

        if imgui.CollapsingHeader(u8'List') then
            for i = 1, #list do
                if list[i] ~= nil then
                    if imgui.Button('-##'..i, imgui.ImVec2(20, 20)) then
                        deleteMark_name = list[i][1]
                        deleteMark_tag = list[i][2]
                        deleteMark_id = i
                        imgui.OpenPopup(u8'tag_delete')
                        deleteConfirm_popup.v = true
                    end
                    imgui.SameLine()
                    imgui.Text(u8('Player: "'..list[i][1]..'", Tag: ')..list[i][2]) 
                end
            end
        end

        if imgui.BeginPopupModal(u8'tag_delete', deleteConfirm_popup, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
            local popSizeX, popSizeY = 400, 200 
            imgui.SetWindowSize(imgui.ImVec2(popSizeX, popSizeY))

            imgui.CenterTextColoredRGB('Are you sure you want to remove the tag #'..deleteMark_id..'?')
            imgui.Text(u8'Player: '..deleteMark_name)
            imgui.Text(u8'Tag: '..deleteMark_tag)

            imgui.Spacing() imgui.Separator() imgui.Spacing()

            imgui.SetCursorPosX(5)
            if imgui.Button(u8'Confirm', imgui.ImVec2(popSizeX - 10, 20)) then
                if sampIs3dTextDefined(deleteMark_id) then
                    sampDestroy3dText(deleteMark_id)
                end
                table.remove(list, tonumber(deleteMark_id))
                saveList()
                loadTags()
                deleteConfirm_popup.v = false
                window.v = false
                sampAddChatMessage("[ {00FF00}CustomTags{FFFFFF} ]: {FF0000}If the tag didn't get removed then restart the game..", -1)
            end 
            imgui.SetCursorPosX(5)
            if imgui.Button(u8'Cancel', imgui.ImVec2(popSizeX - 10, 20)) then
                deleteConfirm_popup.v = false
            end 
            imgui.EndPopup()
        end

        imgui.Spacing() imgui.Separator() imgui.Spacing()
        btnSizeX, btnSizeY = windSizeX - 10, 20

        imgui.SetCursorPosX(5)
        if imgui.Button(u8'Add a tag', imgui.ImVec2(btnSizeX, btnSizeY)) then 
            add_popup.v = true
            imgui.OpenPopup('tag_add')
        end

        if imgui.BeginPopupModal('tag_add', add_popup, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
            local popSizeX, popSizeY = 400, 140 
            imgui.SetWindowSize(imgui.ImVec2(popSizeX, popSizeY))

            imgui.PushItemWidth(popSizeX - 10)
            imgui.CenterTextColoredRGB('Player name:')
            imgui.SetCursorPosX(5); imgui.InputText('##tag_popup_win_add_name', add_name)

            imgui.CenterTextColoredRGB('Tag Text:')
            imgui.SetCursorPosX(5); imgui.InputText('##tag_popup_win_add_text', add_text)

            imgui.SetCursorPosX(5)
            if imgui.Button(u8'Confirm', imgui.ImVec2(popSizeX - 10, 20)) then
                table.insert(list, #list + 1, {add_name.v, add_text.v})
                saveList()
                imgui.CloseCurrentPopup()
                add_popup.v = false
                loadTags()
                add_name.v, add_text.v = '', ''
            end
            imgui.SetCursorPosX(5)
            if imgui.Button(u8'Cancel', imgui.ImVec2(popSizeX - 10, 20)) then
                imgui.CloseCurrentPopup()
                add_popup.v = false
                add_name.v, add_text.v = '', ''
            end

            imgui.PopItemWidth()
            imgui.EndPopup()
        end

        imgui.SetCursorPosX(5)
        if imgui.Button(u8'General settings', imgui.ImVec2(btnSizeX, btnSizeY)) then 
            add_popup.v = true
            imgui.OpenPopup(u8'settings')
        end

        if imgui.BeginPopupModal(u8'settings', imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
            local popSizeX, popSizeY = 370, 170 
            imgui.SetWindowSize(imgui.ImVec2(popSizeX, popSizeY))
            
            imgui.Text(u8'Pos X: ');    imgui.SameLine() ; imgui.SetCursorPosX(75) if imgui.SliderFloat('##1pos X', slider_posX, -8, 8) then loadTags() end ; imgui.SameLine(); if imgui.Button('0##ps', imgui.ImVec2(20, 20)) then slider_posX.v = 0 end
            imgui.Text(u8'Pos Y: ');    imgui.SameLine() ; imgui.SetCursorPosX(75) if imgui.SliderFloat('##1pos Y', slider_posY, -8, 8) then loadTags() end ; imgui.SameLine(); if imgui.Button('0##py', imgui.ImVec2(20, 20)) then slider_posY.v = 0 end
            imgui.Text(u8'Pos Z: ');    imgui.SameLine() ; imgui.SetCursorPosX(75) if imgui.SliderFloat('##1pos Z', slider_posZ, -8, 8) then loadTags() end ; imgui.SameLine(); if imgui.Button('0##pz', imgui.ImVec2(20, 20)) then slider_posZ.v = 0 end
            imgui.Text(u8'Distance: '); imgui.SameLine() ; imgui.SetCursorPosX(75) if imgui.SliderFloat('##1dist', slider_dist, 2, 40) then loadTags() end ; imgui.SameLine(); if imgui.Button('0##dist', imgui.ImVec2(20, 20)) then slider_dist.v = 0 end

            imgui.SetCursorPosX(5)
            if imgui.Button(u8'Close', imgui.ImVec2(popSizeX - 10, 20)) then imgui.CloseCurrentPopup() end
           
            imgui.EndPopup()
        end

        imgui.SetCursorPosX(5)
        if imgui.Button(u8'Save Tags', imgui.ImVec2(btnSizeX, btnSizeY)) then saveList() end

        imgui.SetCursorPosX(5)
        if imgui.Button(u8'Reload Tags', imgui.ImVec2(btnSizeX, btnSizeY)) then loadTags() end

        imgui.End()
    end
end

function saveList()
    file = io.open(getWorkingDirectory()..'\\config\\Adib\'s Config\\CreatedCustom.tags', "w")
    totaltext = ''
    for i = 1, #list do
        totaltext = totaltext..list[i][1]..';'..list[i][2]..'\n'
    end
    file:write(totaltext)
    file:close()
end

function loadTags()
    for i = 1, #list do
        if sampIs3dTextDefined(i) then
            sampDestroy3dText(i)
        end
        
        pid = sampGetPlayerIdByNickname(tostring(list[i][1]))
        if pid ~= nil then
            if sampIsPlayerConnected(pid) then
                sampCreate3dTextEx(i, u8:decode(list[i][2]), 0xFFFFFFFF, slider_posX.v, slider_posY.v, slider_posZ.v, slider_dist.v, false, pid, -1)
            end
        end
    end
end

function save()
    mainIni.main.dist = slider_dist.v
    mainIni.main.posX = slider_posX.v
    mainIni.main.posY = slider_posY.v
    mainIni.main.posZ = slider_posZ.v
    inicfg.save(mainIni, directIni)
end

function onScriptTerminate(s, q)
    if s == thisScript() then
        for i = 1, #list do 
            if sampIs3dTextDefined(i) then sampDestroy3dText(i) end
        end
    end
end

function sampGetPlayerIdByNickname(nick) -- from blast.hk
    nick = tostring(nick)
    local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if nick == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1003 do
        if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
            return i
        end
    end
end

function imgui.CenterTextColoredRGB(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end

function style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    style.WindowPadding         = imgui.ImVec2(8, 8)
    style.WindowRounding        = 6
    style.ChildWindowRounding   = 5
    style.FramePadding          = imgui.ImVec2(5, 3)
    style.FrameRounding         = 3.0
    style.ItemSpacing           = imgui.ImVec2(5, 4)
    style.ItemInnerSpacing      = imgui.ImVec2(4, 4)
    style.IndentSpacing         = 21
    style.ScrollbarSize         = 10.0
    style.ScrollbarRounding     = 13
    style.GrabMinSize           = 8
    style.GrabRounding          = 1
    style.WindowTitleAlign      = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign       = imgui.ImVec2(0.5, 0.5)

    colors[clr.Text]                                = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]                        = ImVec4(0.30, 0.30, 0.30, 1.00)
    colors[clr.WindowBg]                            = ImVec4(0.09, 0.09, 0.09, 1.00)
    colors[clr.ChildWindowBg]                       = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                             = ImVec4(0.05, 0.05, 0.05, 1.00)
    colors[clr.ComboBg]                             = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.Border]                              = ImVec4(0.43, 0.43, 0.50, 0.10)
    colors[clr.BorderShadow]                        = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]                             = ImVec4(0.30, 0.30, 0.30, 0.10)
    colors[clr.FrameBgHovered]                      = ImVec4(0.00, 0.53, 0.76, 0.30)
    colors[clr.FrameBgActive]                       = ImVec4(0.00, 0.53, 0.76, 0.80)
    colors[clr.TitleBg]                             = ImVec4(0.09, 0.09, 0.09, 1.00)
    colors[clr.TitleBgActive]                       = ImVec4(0.09, 0.09, 0.09, 1.00)
    colors[clr.TitleBgCollapsed]                    = ImVec4(0.09, 0.09, 0.09, 1.00)
    colors[clr.MenuBarBg]                           = ImVec4(0.13, 0.13, 0.13, 0.99)
    colors[clr.ScrollbarBg]                         = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]                       = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]                = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]                 = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CheckMark]                           = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.SliderGrab]                          = ImVec4(0.28, 0.28, 0.28, 1.00)
    colors[clr.SliderGrabActive]                    = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.Button]                              = ImVec4(0.26, 0.26, 0.26, 0.30)
    colors[clr.ButtonHovered]                       = ImVec4(0.00, 0.55, 0.22, 1.00)
    colors[clr.ButtonActive]                        = ImVec4(0.00, 0.40, 0.22, 1.00)
    colors[clr.Header]                              = ImVec4(0.12, 0.12, 0.12, 0.94)
    colors[clr.HeaderHovered]                       = ImVec4(0.00, 0.55, 0.22, 1.00)
    colors[clr.HeaderActive]                        = ImVec4(0.00, 0.40, 0.22, 1.00)
    colors[clr.Separator]                           = ImVec4(0.30, 0.30, 0.30, 1.00)
    colors[clr.SeparatorHovered]                    = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]                     = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]                          = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]                   = ImVec4(0.00, 0.55, 0.22, 1.00)
    colors[clr.ResizeGripActive]                    = ImVec4(0.00, 0.40, 0.22, 1.00)
    colors[clr.CloseButton]                         = ImVec4(0.50, 0.00, 0.00, 1.00)
    colors[clr.CloseButtonHovered]                  = ImVec4(1.70, 0.70, 0.90, 0.60)
    colors[clr.CloseButtonActive]                   = ImVec4(1.70, 0.70, 0.70, 1.00)
    colors[clr.PlotLines]                           = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]                    = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]                       = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]                = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]                      = ImVec4(0.00, 0.43, 0.76, 1.00)
    colors[clr.ModalWindowDarkening]                = ImVec4(0.20, 0.20, 0.20,  0.0)
end
style()

local scr = thisScript()
function checkUpdate()
    local url = "https://raw.githubusercontent.com/Adib23704/SAMP-Mods/main/versions.json"
    body = https.request(url)
    local json = decodeJson(body)
    if tonumber(json.customtags.version) == tonumber(mainIni.main.ignoreVer) then
        sampAddChatMessage("[ {00FF00}CustomTags{FFFFFF} ]: {A7A7A7}Found a new version of the mod but ignoring as you wanted to ignore..", -1)
        ignoringVers = true
    elseif tonumber(json.customtags.version) ~= tonumber(scr.version) and ignoringVers == false then
        sampShowDialog(23741, "{00FF00}CustomTags", "{FFFFFF}New version available for the mod {00FF00}CustomTags {FFFFFF}by {005522}Adib\n{FFFFFF}Do you wanna {00FF00}download{FFFFFF} the latest version?", "Yes!", "Ignore", 0)
    end
end