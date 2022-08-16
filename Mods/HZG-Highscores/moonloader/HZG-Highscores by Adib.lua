script_name('[HZG] Highscores')
script_author('Adib')
script_version_number(100)
script_url("https://adib23704.tk")

require 'moonloader'
require 'sampfuncs'
local https = require 'ssl.https'
local baseUrl = "https://hzgaming.net/high.php?scores="

local idList = {}
local nameList = {}
local valueList = {}
local extraList = {}
local listScores = nil

local body = ""

local scores = {
    "Money",
    "Materials",
    "Kills (Paintball)",
    "Playing Hours",
    "Crime & Arrests",
    "Skins",
    "Popular Car Models",
    "Types of Crime",
    "Most Members",
    "Most Money",
    "Detective",
    "Lawyer",
    "Whore",
    "Drug Dealer",
    "Drug Smuggler",
    "Arms Dealer",
    "Mechanic",
    "Boxing",
    "Fishing",
    "Trucker",
    "Carjacker",
    "Hunger Games"
}

local type = {
    "Total Wealth",
    "Materials",
    "Kills",
    "Hours",
    "Amount",
    "Skin ID",
    "Amount",
    "Crime",
    "Members",
    "Money",
    "People Found",
    "Freed",
    "Times Whored",
    "Number of Deals",
    "Crates Smuggled",
    "Guns Made",
    "Cars Repaired",
    "Fights Won",
    "Fish Caught",
    "Deliveries Completed",
    "Cars Stolen and Sold",
    "Rounds Won"
}

local param = {
    "money",
    "materials",
    "kills",
    "hours",
    "crime",
    "skins",
    "cars",
    "typesofcrime",
    "mostmembers",
    "mostmoney",
    "detective",
    "lawyer",
    "whore",
    "drugdealer",
    "drugsmuggler",
    "armsdealer",
    "mechanic",
    "boxing",
    "fishing",
    "trucker",
    "carjacker",
    "hungergames"
}

local vehicleNames = {
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perennial", "Sentinel", "Dumper", "Fire Truck", "Trashmaster", "Stretch", "Manana", 
    "Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", 
    "Mr. Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", 
    "Trailer 1", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", 
    "Seasparrow", "Pizzaboy", "Tram", "Trailer 2", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", 
    "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic", "Sanchez", "Sparrow", "Patriot", 
    "Quadbike", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", 
    "Baggage", "Dozer", "Maverick", "News Chopper", "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring Racer", "Sandking", 
    "Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer 2", "Hotring Racer 3", "Bloodring Banger", 
    "Rancher Lure", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stuntplane", "Tanker", "Roadtrain", "Nebula", 
    "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Towtruck", "Fortune", "Cadrona", "FBI Truck", 
    "Willard", "Forklift", "Tractor", "Combine Harvester", "Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Brown Streak", "Vortex", "Vincent", 
    "Bullet", "Clover", "Sadler", "Fire Truck Ladder", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility Van", 
    "Nevada", "Yosemite", "Windsor", "Monster 2", "Monster 3", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", 
    "Tahoma", "Savanna", "Bandito", "Freight Train Flatbed", "Streak Train Trailer", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", 
    "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "Newsvan", "Tug", "Trailer (Tanker Commando)", "Emperor", "Wayfarer", "Euros", "Hotdog", 
    "Club", "Box Freight", "Trailer 3", "Andromada", "Dodo", "RC Cam", "Launch", "Police LS", "Police SF", "Police LV", "Police Ranger", 
    "Picador", "S.W.A.T.", "Alpha", "Phoenix", "Glendale Damaged", "Sadler Damaged", "Baggage Trailer (covered)", 
    "Baggage Trailer (Uncovered)", "Trailer (Stairs)", "Boxville Mission", "Farm Trailer", "Street Clean Trailer"
}

function main()
    while not isSampAvailable() do wait(50) end
    sampAddChatMessage("{FFFFFF}[ {FF0000}Highscores {FFFFFF}by {005522}Adib {FFFFFF}] has loaded! Use {FF0000}/highscore", -1)
    for i=1, #scores do
        if listScores == nil then
            listScores = scores[i]
        else
            listScores = listScores..'\n'..scores[i]
        end
    end
    sampRegisterChatCommand("highscore", function()
        sampShowDialog(23747, "{FF0000}[HZG] Highscores {FFFFFF}by {005522}Adib", listScores, "View", "Close", 2)
    end)
    while true do
        local result, button, list, _ = sampHasDialogRespond(23747)
        if result then
            if button == 1 then
                list = list + 1
                if list == 6 or list == 8 then
                    sampAddChatMessage("{FFFFFF}[ {FF0000}Highscores {FFFFFF}by {005522}Adib {FFFFFF}]: Skins & Types of Crimes highscore is still under development!", -1)
                    sampShowDialog(23747, "{FF0000}[HZG] Highscores {FFFFFF}by {005522}Adib", listScores, "View", "Close", 2)
                else
                    fetchHighscoreData(list)
                end
            end
        end
        local result, button, list, _ = sampHasDialogRespond(23746)
        if result then
            if button == 1 then
                sampShowDialog(23747, "{FF0000}[HZG] Highscores {FFFFFF}by {005522}Adib", listScores, "View", "Close", 2)
            end
        end
        local result, button, list, _ = sampHasDialogRespond(23748)
        if result then
            local json = decodeJson(body)
            if button == 1 then
                sampAddChatMessage("{FFFFFF}[ {FF0000}Highscores {FFFFFF}by {005522}Adib {FFFFFF}]: Latest mod page should be open on your browser now!", -1)
                os.execute('explorer "' .. json.highscore.file .. '"')
            else
                sampAddChatMessage("{FFFFFF}[ {FF0000}Highscores {FFFFFF}by {005522}Adib {FFFFFF}]: {FF0000}Ignored this version! Remember, the latest version always contains more features and bug fixings.", -1)
            end
        end
        wait(0)
    end
end

function fetchHighscoreData(id)
    lua_thread.create(function()
        idList = {}
        nameList = {}
        valueList = {}
        extraList = {}
        sampAddChatMessage("{FFFFFF}[ {FF0000}Highscores {FFFFFF}by {005522}Adib {FFFFFF}]: Hang on while I collect highscores! You might a little lag spike", -1)
        wait(2000)
        local body, statusCode, headers, statusText =  https.request(baseUrl..""..param[id])
    
        if statusCode == 200 or statusCode == "200" then
            local tdTagRemoved = scorePrettier(body)
            
            if id == 1 or id == 10 then
                for dollars in string.gmatch(tdTagRemoved, "$%d+,%d+,%d+") do
                    tdTagRemoved = string.gsub(tdTagRemoved, dollars, "")
                    table.insert(valueList, dollars)
                end 
            elseif id == 2 then
                for mats in string.gmatch(tdTagRemoved, "%d+,%d+,%d+") do
                    tdTagRemoved = string.gsub(tdTagRemoved, mats, "")
                    table.insert(valueList, mats)
                end 
            elseif id == 3 or id == 7 then
                for kills in string.gmatch(tdTagRemoved, "%d+,%d+") do
                    tdTagRemoved = string.gsub(tdTagRemoved, kills, "")
                    table.insert(valueList, kills)
                end
            elseif id == 4 or id == 5 then
                for fValue in string.gmatch(tdTagRemoved, "%d+,%d+") do
                    tdTagRemoved = string.gsub(tdTagRemoved, fValue, "")
                    table.insert(extraList, fValue)
                end
    
                for sValue in string.gmatch(tdTagRemoved, "%d+") do
                    if tonumber(sValue) > 20 then
                        tdTagRemoved = string.gsub(tdTagRemoved, sValue, "")
                        table.insert(valueList, addCommas(tonumber(sValue)))
                    end
                end
            else     
                for sValue in string.gmatch(tdTagRemoved, "%d+") do
                    if tonumber(sValue) > 20 then
                        tdTagRemoved = string.gsub(tdTagRemoved, sValue, "")
                        table.insert(valueList, addCommas(tonumber(sValue)))
                    end
                end
            end
    
            if id == 7 then
                for amount in string.gmatch(tdTagRemoved, "%d+") do
                    if tonumber(amount) > 20 then
                        table.insert(nameList, vehicleNames[amount-399])
                    end
                end
            end
    
            for idEx in string.gmatch(tdTagRemoved, "%d+") do
                if tonumber(idEx) < 21 then
                    tdTagRemoved = string.gsub(tdTagRemoved, idEx, "")
                    table.insert(idList, idEx)
                end 
            end 
    
            if id == 9 or id == 10 then
                tdTagRemoved = string.gsub(tdTagRemoved, "%d", "")
                tdTagRemoved = string.gsub(tdTagRemoved, "%s", "_")
                tdTagRemoved = string.gsub(tdTagRemoved, "__", "\n")
                tdTagRemoved = string.gsub(tdTagRemoved, "_", " ")
                for name in countLines(tdTagRemoved) do
                    name = string.sub(name, 2, string.len(tdTagRemoved))
                    table.insert(nameList, name)
                end
            end
    
            if id ~= 7 and id ~= 9 and id ~= 10 then
                tdTagRemoved = string.gsub(tdTagRemoved, "%d", "")
                for name in string.gmatch(tdTagRemoved, "%S+") do
                    table.insert(nameList, name)
                end
            end
    
            if id == 4 or id == 5 then
                local string = id == 4 and "#\tName\tLevel\tHours" or "#\tName\tArrests\tCrimes" 
                for i=1, #idList do
                    string = string .. "\n{A7A7A7}" .. idList[i] .. "\t{2196F3}" .. nameList[i] .. "\t{FFFFFF}" .. valueList[i] .. "\t{FFFFFF}" .. extraList[i] 
                end
                sampShowDialog(23746, scores[id].." Highscores | {C62828}Updates every 10 minutes.", string, "Highscores", "Exit", 5)
                sampAddChatMessage("{FFFFFF}[ {FF0000}Highscores {FFFFFF}by {005522}Adib {FFFFFF}]: {C62828}These highscore updates every 10 minutes.", -1)
            else
                local string = "#\tName\t"..type[id]
                for i=1, #idList do
                    string = string .. "\n{A7A7A7}" .. idList[i] .. "\t{2196F3}" .. nameList[i] .. "\t{FFFFFF}" .. valueList[i] 
                end
                sampShowDialog(23746, scores[id].." Highscores | {C62828}Updates every 10 minutes.", string, "Highscores", "Exit", 5)
                sampAddChatMessage("{FFFFFF}[ {FF0000}Highscores {FFFFFF}by {005522}Adib {FFFFFF}]: {C62828}These highscore updates every 10 minutes.", -1)
            end
        end 
    end)
end

function scorePrettier(body)
    local tableData = string.match(body, "<td>(.*)</td>")
    local tdTagRemoved = string.gsub(tableData, "</td><td>", " ")
    tdTagRemoved = string.gsub(tdTagRemoved, "</td></tr><tr><td>", " ")
    tdTagRemoved = string.gsub(tdTagRemoved, "%s+", " ")
    return tdTagRemoved
end

function countLines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

local scr = thisScript()
function checkUpdate()
    local url = "https://raw.githubusercontent.com/Adib23704/SAMP-Mods/main/versions.json"
    body = https.request(url)
    local json = decodeJson(body)
    if tonumber(json.highscore.version) ~= tonumber(scr.version) then
        sampShowDialog(23741, "{FFFFFF}[ {FF0000}Highscores {FFFFFF}by {005522}Adib {FFFFFF}]:", "{FFFFFF}New version available for the mod {00FF00}Highscore {FFFFFF}by {005522}Adib\n{FFFFFF}Do you wanna {00FF00}download{FFFFFF} the latest version?", "Yes!", "Close", 0)
    end
end

function addCommas(number)
    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus .. int:reverse():gsub("^,", "") .. fraction
end