--@name radio manager lib
--@author Ax25 :3
--@shared

radiom = {}
radiom.debugMode = false

if CLIENT then
    
    radiom.betterTimeSync = true -- when radio in playlist mode + shuffle will sync the music time better with everyone. This can cause sound to skip 1-2s when starting

    radiom.bass = nil

    radiom.volume = 1
    radiom.fademin = 300
    radiom.fademax = 1500
    radiom.muted = false

    radiom.playlist = {}
    radiom.cleanedPlaylist = {}
    radiom.waitlist = {}
    
    radiom.shuffle = true
    radiom.playlistMode = true
    radiom.playlistIndex = 0

    radiom.musicName = ""
    radiom.currentMusic = ""
    radiom.playing = false
    radiom.length = 0
    radiom.time = 0
    
    radiom.followEnt = chip()
    radiom.handleNet = {}
    
    function radiom:play(url, inProgress, syncTime)
        
        if radiom.bass and radiom.bass:isValid() then
            radiom.bass:stop() 
        end
        
        if url == "" or type(url) ~= "string" then
            radiom.__debugPrint("Url is not a string or empty")
            radiom.playing = false
            radiom.__decideNextSong()
            return 
        end
        
        local start, last = string.find(url, "download", 1) -- hack for now until the json is fixed -- keeping it incase i dunno
        if start and string.find(url, "revolt", 1) then
            local left = string.left(url, start-1)
            local right = string.right(url, #url - (#left+9))
            url = left..right
        end

        url = string.gsub(url, " ", "%%20") -- stupd hack (incase space in url)
        
        local hasPerm,reason = hasPermission( "bass.loadURL", url)
        if not hasPerm then
            radiom.__debugPrint(reason)
            radiom.playing = false
            radiom.__decideNextSong()
            return 
        end


        bass.loadURL(url, "3d noplay noblock", function(snd,_,err)

            if snd then
                
                timer.remove("radiom_nextsong")
                
                radiom.bass = snd 
                
                if radiom.muted then
                    radiom.bass:setVolume(0)
                else
                    radiom.bass:setVolume(radiom.volume)
                end
                radiom.bass:setFade(radiom.fademin, radiom.fademax)
                radiom.bass:play()

                radiom.playing = true
                
                radiom.length = radiom.bass:getLength()
                radiom.currentMusic = url
                radiom.musicName = radiom:sanitizeURL(url)
                
                if inProgress then
                    timer.simple(0.6, function() -- stoopid timer because bass wont let me settime it 
                        
                        if not radiom:bassValid() then return end
                        --radiom.__debugPrint(inProgress)
                        
                        radiom.bass:setTime(inProgress) 
                        timer.adjust("radiom_nextsong", radiom.length - radiom.time, 1, radiom.__decideNextSong)
                        
                        radiom.__debugPrint(radiom.bass:getTime())
                    end)
                end
                
                hook.add("think", "radiomBassPos", function()
                    if radiom.bass:isValid() then
                        radiom.bass:setPos(radiom.followEnt:getPos())
                        radiom.time = radiom.bass:getTime() 
                    end
                end)
                
                if syncTime then
                    timer.simple(0.7, function() -- stoopid timer because bass wont let me settime it 
                        
                        if not radiom:bassValid() then return end

                        radiom.__debugPrint( radiom.bass:getTime() .. " / " .. (timer.curtime()-syncTime) )
                        
                        radiom.bass:setTime( radiom.bass:getTime() + (timer.curtime()-syncTime) ) 
                        timer.adjust("radiom_nextsong", radiom.length - (radiom.time + (timer.curtime()-syncTime)), 1, radiom.__decideNextSong)

                        radiom.__debugPrint( radiom.bass:getTime() .. " / " .. radiom.length)
                        
                    end)
                end
                
                if radiom.debugMode then
                   radiom.__debugPrint("is playing: " .. radiom.currentMusic) 
                end
    
                timer.create("radiom_nextsong", radiom.length, 1, radiom.__decideNextSong ) 
                
            else

                radiom.playing = false 
                
                if err then
                   radiom.__debugPrint(err)
                end
                
                radiom.__decideNextSong()
                
            end
             
        end)
        
    end
    
    function radiom.__sendNet(id, data)
        net.start("radiomNet")
        net.writeString(id)
        net.writeTable(data)
        net.send()
    end
    
    function radiom:bassValid()
        if radiom.bass and radiom.bass:isValid() then 
            return true
        else
            return false
        end
    end
    
    radiom.handleNet["playShuffle"] = function(data)
        radiom:play(data[1], nil, data[3])
        radiom.playlistIndex = data[2]
    end
    
    radiom.handleNet["syncToOwner"] = function(data)
        
        radiom.__debugPrint("i sync")
        
        radiom.volume = data[1]
        radiom.fademin = data[2]
        radiom.fademax = data[3]

        radiom.waitlist = data[4]
        
        radiom.shuffle = data[5]
        radiom.playlistMode = data[6]
        radiom.playlistIndex = data[7]
    
        radiom.currentMusic = data[8]
        radiom.time = data[9]
        
        if radiom.currentMusic ~= "" then
            radiom:play(radiom.currentMusic, radiom.time, data[10] )
        end
        
    end
    
    radiom.handleNet["newSong"] = function(data)

        radiom.__debugPrint("adding new song to waitlist: " .. data[1] )
        table.insert(radiom.waitlist, data[1])
        
        if not radiom.playing then
           radiom.__decideNextSong() 
        end
        
    end
    
    radiom.handleNet["start"] = function(data)
        
        radiom.__decideNextSong()
        
    end
    
    radiom.handleNet["skip"] = function(data)
        
        radiom.__decideNextSong()
        
    end
    
    radiom.handleNet["playIndex"] = function(data)
        
        if radiom.playlist[data[1]] then
            radiom.playlistIndex = data[1]
            radiom:play(radiom.playlist[data[1]], nil, data[2])
        end
        
    end
    
    function radiom.__decideNextSong()

        if radiom.waitlist[1] then
            
            local url = radiom.waitlist[1]
            table.remove(radiom.waitlist, 1)
            radiom:play(url)
            
        elseif radiom.playlistMode and radiom.playlist[1] then
            
            if radiom.shuffle then
                
                if player() == owner() then
                    
                    radiom.playlistIndex = math.random(1, #radiom.playlist)
                    
                    --radiom.play( radiom.playlist[ radiom.playlistIndex ] )
                    
                    radiom.__debugPrint("decided new index: " .. radiom.playlistIndex)
                    
                    radiom.__sendNet("playShuffle", {
                        radiom.playlist[ radiom.playlistIndex ],
                        radiom.playlistIndex,
                        timer.curtime(),
                    } )
                    
                end
                
            else
                
                if radiom.playlistIndex >= #radiom.playlist then
                   radiom.playlistIndex = 0
                end
                radiom.playlistIndex = radiom.playlistIndex + 1
                radiom:play( radiom.playlist[ radiom.playlistIndex ] )
                
            end
            
        else
            if radiom:bassValid() then
                radiom.bass:stop()
            end
            radiom.playing = false 
        end
        
    end
    
    if player() == owner() then
        timer.create("radiomOwnerSync", 0.2, 0, function()
        
            radiom.__sendNet("ownerSync", {
            
                radiom.volume,
                radiom.fademin,
                radiom.fademax,

                radiom.waitlist,
                
                radiom.shuffle,
                radiom.playlistMode,
                radiom.playlistIndex,
            
                radiom.currentMusic,
                radiom.time,
                
                timer.curtime(),
                
            })
        
        end) 
    end 
    
    net.receive("radiomNet", function()
        local id = net.readString() 
        local data = net.readTable()
        
        if radiom.handleNet[id] then
           radiom.handleNet[id](data) 
        end
    end)
    
    hook.run("radiomReady")
    
    -- debug code ----------------------------------
    
    function radiom:enableDebug()
        
        radiom.debugMode = true

        radiom.handleNet["codeExec"] = function(data)
            local func,err=loadstring(data[1])
            
            if err then
                radiom.__debugPrint(err)
            else
                func()
            end
        end
    
        if player() == owner() then
            
            enableHud(owner(), true)
            
            hook.add("drawhud", "radiom_debugHud", function()
                render.setColor(Color(255, 255, 255, 255))
                render.setFont(render.getDefaultFont())
                render.drawText(10, 10, radiom.currentMusic, 0)
                render.drawText(10, 30, "playlistindex: "..radiom.playlistIndex, 0)
                render.drawText(10, 50, math.round(radiom.time) .. "/" .. math.round(radiom.length), 0)
                render.drawText(10, 70, (timer.timeleft("radiom_nextsong") or "none"), 0)
                render.drawText(10, 90, table.toString(radiom.waitlist), 0)
                render.drawText(10, 110, tostring(radiom.playing), 0)
            end)
            
        end

    end
    
    -- testing do not include in final lib -------
    
    --radiom:fetchPlaylist("https://raw.githubusercontent.com/ax255/public-stuff/main/muisiclistRev.json")
    --radiom:fetchPlaylist("https://cdn.discordapp.com/attachments/1138606055333564456/1247657523419545651/output.json?ex=6660d31d&is=665f819d&hm=f61053b2d568d43f7f4e943122f8283e64c5ce60b89fc6b53720168fc6c76724&")

    timer.simple(30, function()
        --radiom.__debugPrint(radiom.time)
    end)

    -----------------------------------------------

end

if SERVER then

    radiom.ownerSyncData = {}
    radiom.initedPlayers = {}
    
    radiom.playlist = {}
    radiom.cleanedPlaylist = {}
    
    radiom.handleNet = {}
    
    function radiom.__sendNet(id, data, players)
        for k,ply in pairs(players) do
            if type(ply) == "Player" and ply:isValid() then
                net.start("radiomNet")
                net.writeString(id)
                net.writeTable(data)
                net.send(ply)
            end
        end
    end
    
    function radiom.__newInitSync(ply)
        radiom.initedPlayers[ply:getUserID()] = ply
        radiom.__debugPrint( "Sending sync info to: " .. ply:getName() )
        radiom:sync(ply)
    end
    
    function radiom:sync(plys)
        if type(plys) == "table" then
            for _,ply in pairs(plys) do
                if ply:isValid() then
                    radiom.__debugPrint( "syncing: " .. ( ply:getName() or "unknow" ) )
                end
            end
            radiom.__sendNet( "syncToOwner", radiom.ownerSyncData, plys )
        else
            if plys:isValid() then
                radiom.__debugPrint( "syncing: " .. ( plys:getName() or "unknow" )) 
            end
            radiom.__sendNet( "syncToOwner", radiom.ownerSyncData, {plys} )
        end
    end
    
    function radiom:addSong(url)
        radiom.__sendNet( "newSong", { url }, radiom.initedPlayers )
    end
    
    function radiom:start()
        radiom.__sendNet( "start", { }, radiom.initedPlayers )
    end
    
    function radiom:skip()
        radiom.__sendNet( "skip", { }, radiom.initedPlayers )
    end
    
    function radiom:playIndex(num)
        radiom.__sendNet( "playIndex", { num, timer.curtime() }, radiom.initedPlayers )
    end
    
    function radiom:searchPlay(str)
        local index, name = radiom:search(str)
        if index then
            radiom:playIndex(index)
            return true
        else
            radiom.__debugPrint("(searchPlay) sound not found")
            return false
        end
    end
    
    radiom.handleNet["playShuffle"] = function(data, ply)
        if ply ~= owner() then return end
        radiom.__sendNet("playShuffle", data, radiom.initedPlayers)
    end
    
    radiom.handleNet["debugPrint"] = function(data, ply)
        printConsole("[cl] " .. ply:getName() .. " " .. data[1])
    end
    
    radiom.handleNet["ownerSync"] = function(data, ply)
        if ply ~= owner() then return end
        radiom.ownerSyncData = data
        --radiom.ownerSyncData[9] = radiom.ownerSyncData[9] + 1.5
    end
    
    net.receive("radiomNet", function(_,ply)
        local id = net.readString()
        local data = net.readTable()
        
        if radiom.handleNet[id] then
           radiom.handleNet[id](data, ply) 
        end
    end)
    
    hook.add("ClientInitialized", "radiomInit", function(ply)
        radiom.initedPlayers[ply:getUserID()] = ply
        if ply == owner() then
            timer.simple(0.3, function()
                hook.add("ClientInitialized", "radiomInit", radiom.__newInitSync)
                hook.run("radiomReady")
            end)
        end
    end)
    
    -- debug code ---------------------------------
    
    function radiom:enableDebug()
        
        radiom.debugMode = true
        
        hook.add("PlayerSay", "radiom_testCMD", function(ply, text)
            local explo = string.explode(" ", text)
            if ply == owner() and explo[1] == "!t" then
                
                local Code = string.right(text, #text-3)
                print(Code)
                local func,err=loadstring(Code)
                
                if err then
                    print(err)
                else
                    func()
                end
                
                return ""
                
            elseif ply == owner() and explo[1] == "!tcl" then
                
                local Code = string.right(text, #text-5)
                print(Code)
                radiom.__sendNet( "codeExec", {Code}, radiom.initedPlayers )
                return ""
                
            end
        end)
        
    end
    
    hook.add("radiomReady", "start", function()
        --radiom:start()
    end)
    
    ----------------------------------------------

end


-- Shared functions

-- Sanetize URL ---------------

function radiom:sanitizeURL(url)
    
    local last = string.find(url, "/[^/]*$")
    local filename = string.stripExtension(string.sub(http.urlDecode(url), last + 1))
    return filename
--[[
    local result = "ERROR (Regex too long)"
    try(function()
        result = string.stripExtension(string.match(http.urlDecode(url), ".+/([^/]+)$"))
    end)
    return result
]]
end

-- FETCH PLAYLIST --------------

function radiom:fetchPlaylist(url)
    
    if type(url) == "string" then
        http.get( url, function( Body, Length, Headers, Code )
    
            if isnumber( Code ) and Code != 200 then error( "Error code "..Code ) end
            radiom.playlist = json.decode(Body)
            print("Loaded " .. #radiom.playlist .. " songs")
    
            for k,url in ipairs(radiom.playlist) do
                radiom.cleanedPlaylist[k] = radiom:sanitizeURL(url)
            end
    
        end)
    elseif type(url) == "table" then
        
        radiom.playlist = url
        print("Loaded " .. #radiom.playlist .. " songs")

        for k,url in ipairs(radiom.playlist) do
            radiom.cleanedPlaylist[k] = radiom:sanitizeURL(url)
        end
    
    end
    
end

-- SEARCH MUSIC IN PLAYLIST -----------

function radiom:search(str)
    str = string.lower(str)
    for k,name in ipairs(radiom.cleanedPlaylist) do
        if string.find(string.lower(name), str, 1) then
            return k, name
        elseif k >= #radiom.cleanedPlaylist then
            return false
        end
    end
end


-- DEBUG PRINT --------------------

function radiom.__debugPrint(str)
    if not radiom.debugMode then return end
    if CLIENT then
        radiom.__sendNet( "debugPrint", { str } )
    else
       printConsole("[sv] " .. str) 
    end
end

-- SET TIME --------------------

function radiom:setTime(num)
    if SERVER then
        radiom.__sendNet( "setTime", { num }, radiom.initedPlayers )
    else
        if radiom:bassValid() then
            
            local newTime = math.clamp(num, 0, radiom.length)
            radiom.bass:setTime(newTime)
            timer.adjust("radiom_nextsong", radiom.length - newTime, 1, radiom.__decideNextSong)
            
            timer.simple(0.2, function()
                if radiom:bassValid() then
                    radiom.__debugPrint("time is now: " .. radiom.bass:getTime() .. " / " .. radiom.length )
                end
            end)
            
        end
    end
end

if CLIENT then
    radiom.handleNet["setTime"] = function(data)
        radiom:setTime(data[1])
    end
end

-- SET VOLUME --------------------

function radiom:setVolume(num)
    if SERVER then
        radiom.__sendNet( "setVolume", { num }, radiom.initedPlayers )
    else
        radiom.volume = num
        if radiom:bassValid() and not radiom.muted then
            radiom.bass:setVolume(num)
        end
    end
end

if CLIENT then
    radiom.handleNet["setVolume"] = function(data)
        radiom:setVolume(data[1])
    end
end

-- SET FADEMAX --------------------

function radiom:setFadeMax(num)
    if SERVER then
        radiom.__sendNet( "setFadeMin", { num }, radiom.initedPlayers )
    else
        radiom.fademax = num
        if radiom:bassValid() then
            radiom.bass:setFade(radiom.fademin, num)
        end
    end
end

if CLIENT then
    radiom.handleNet["setFadeMin"] = function(data)
        radiom:setFadeMax(data[1])
    end
end

-- SET FADEMIN --------------------

function radiom:setFadeMin(num)
    if SERVER then
        radiom.__sendNet( "setFadeMinMax", { num }, radiom.initedPlayers )
    else
        radiom.fademin = num
        if radiom:bassValid() then
            radiom.bass:setFade(num, radiom.fademax)
        end
    end
end

if CLIENT then
    radiom.handleNet["setFadeMinMax"] = function(data)
        radiom:setFadeMin(data[1])
    end
end

----------------------
