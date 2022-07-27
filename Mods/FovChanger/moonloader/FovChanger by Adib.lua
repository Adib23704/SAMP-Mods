script_name('FovChanger')
script_author('Adib')
script_version('1.0')
script_url("https://adib23704.github.io")

require 'moonloader'
require 'sampfuncs'
local inicfg = require "inicfg"
local imgui = require 'imgui'
local encoding = require 'encoding'
local mem = require 'memory'
encoding.default = "CP1251"
u8 = encoding.UTF8

dir = getWorkingDirectory() .. "\\config\\Adib's Config\\"
dir2 = getWorkingDirectory() .. "\\config\\"
config = dir .. "FovChanger.ini"

if not doesDirectoryExist(dir2) then createDirectory(dir2) end
if not doesDirectoryExist(dir) then createDirectory(dir) end
if not doesFileExist(config) then
    file = io.open(config, "w")
    file:write(" ")
    file:close()
    local directIni = config
    local mainIni = inicfg.load(inicfg.load({
        main = {
            value = 80.0,
            smooth = true,
            startup = true
        }, 
    }, directIni))
    inicfg.save(mainIni, directIni)
end

local directIni = config
local mainIni = inicfg.load(nil, directIni)
inicfg.save(mainIni, directIni)

local window = imgui.ImBool(false)
local smooth = imgui.ImBool(mainIni.main.smooth)
local startup = imgui.ImBool(mainIni.main.startup)
local fov = imgui.ImFloat(mainIni.main.value)

local aiming = false

function main()
    while not isSampAvailable() do wait(50) end
    sampRegisterChatCommand("fov", function()
        window.v = not window.v
    end)
    sampAddChatMessage("{00FF00}[ {FF0000}Fov Changer {00FF00}] {FFFFFF}loaded by {FF0000}Adib. {FFFFFF}Use {FF0000}/fov" ,-1)
    while true do
        imgui.Process = window.v
        local weapon = getCurrentCharWeapon(PLAYER_PED)
        if isPlayerAiming(true, true) and (weapon == 34 or weapon == 35 or weapon == 36 or weapon == 43) then
            aiming = true
            cameraResetNewScriptables()
        else
            aiming = false
        end
        if startup.v and aiming == false then
            UpdateFov()
        end
        wait(1)
    end
end

function imgui.OnDrawFrame()
    local x, y = getScreenResolution()
	imgui.SetNextWindowSize(imgui.ImVec2(500, 110), imgui.Cond.FirstUseEver)
	imgui.SetNextWindowPos(imgui.ImVec2(x / 2, y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin("Fov Changer by Adib", window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
    imgui.SameLine(90)
    if imgui.SliderFloat("", fov, 10.0, 150.0) then
        mainIni.main.value = fov.v
        inicfg.save(mainIni, directIni)
        UpdateFov()
    end
    imgui.SameLine()
    imgui.Text("(?)")
    imgui.Hint("Default GTA:SA Fov is 70.0")
    imgui.NewLine() imgui.SameLine(40)
    if imgui.Checkbox("Smooth Transition?", smooth) then
        mainIni.main.smooth = smooth.v
        inicfg.save(mainIni, directIni)
    end
    imgui.Hint("It will only be applied if you select 'Set Fov on Startup'.")
    imgui.SameLine(320)
    if imgui.Checkbox("Set fov on startup?", startup) then
        mainIni.main.startup = startup.v
        inicfg.save(mainIni, directIni)
    end
    imgui.Hint("Auto set Fov once you start the game.")
    if fov.v > 130.0 or fov.v < 60.0 then
        imgui.CenterTextColoredRGB("{FF0000}Setting above 130 or lower than 60 is not recommended for shooting.")
    end
    imgui.End()
end

function UpdateFov()
    cameraSetLerpFov(fov.v, fov.v, 999988888, smooth.v)
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


function imgui.Hint(text)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 -- скорость появления
        if os.clock() >= go_hint then
            imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
                imgui.PushStyleColor(imgui.Col.PopupBg, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
                    imgui.BeginTooltip()
                    imgui.PushTextWrapPos(450)
                    imgui.TextUnformatted(text)
                    if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
                    imgui.PopTextWrapPos()
                    imgui.EndTooltip()
                imgui.PopStyleColor()
            imgui.PopStyleVar()
        end
    end
end

function isPlayerAiming(thirdperson, firstperson) -- Thanks to cross devil
	local id = mem.read(11989416, 2, false)
	if thirdperson and (id == 5 or id == 53 or id == 55 or id == 65) then return true end
	if firstperson and (id == 7 or id == 8 or id == 16 or id == 34 or id == 39 or id == 40 or id == 41 or id == 42 or id == 45 or id == 46 or id == 51 or id == 52) then return true end
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
    colors[clr.ButtonHovered]                       = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.ButtonActive]                        = ImVec4(0.00, 0.43, 0.76, 1.00)
    colors[clr.Header]                              = ImVec4(0.12, 0.12, 0.12, 0.94)
    colors[clr.HeaderHovered]                       = ImVec4(0.34, 0.34, 0.35, 0.89)
    colors[clr.HeaderActive]                        = ImVec4(0.12, 0.12, 0.12, 0.94)
    colors[clr.Separator]                           = ImVec4(0.30, 0.30, 0.30, 1.00)
    colors[clr.SeparatorHovered]                    = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]                     = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]                          = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]                   = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]                    = ImVec4(0.26, 0.59, 0.98, 0.95)
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
